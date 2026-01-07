-- تحديث نظام حالات الدفعات (Lot Status System)

-- إنشاء enum للحالات الجديدة
DO $$ 
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'lot_status_enum') THEN
        CREATE TYPE lot_status_enum AS ENUM (
            'new',          -- جديد - لم يتم البيع منه
            'in_use',       -- قيد الاستخدام - تم البيع منه جزئياً
            'finished',     -- منتهي - تم بيع الكمية كاملة
            'damaged'       -- تالف/مغلق - بناء على حركة يدوية
        );
    END IF;
END $$;

-- تحديث جدول product_lots لاستخدام الحالات الجديدة
ALTER TABLE product_lots 
DROP COLUMN IF EXISTS status CASCADE;

ALTER TABLE product_lots 
ADD COLUMN status lot_status_enum DEFAULT 'new';

-- إضافة حقول إضافية لتتبع الحالة
ALTER TABLE product_lots 
ADD COLUMN IF NOT EXISTS status_changed_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
ADD COLUMN IF NOT EXISTS status_changed_by VARCHAR(255),
ADD COLUMN IF NOT EXISTS status_notes TEXT;

-- إنشاء فهرس للحالة
CREATE INDEX IF NOT EXISTS idx_product_lots_status_new ON product_lots(status);

-- إنشاء دالة لتحديث حالة الدفعة تلقائياً
CREATE OR REPLACE FUNCTION update_lot_status()
RETURNS TRIGGER AS $$
BEGIN
    -- تحديث الحالة بناء على الكميات
    IF NEW.current_quantity = NEW.initial_quantity AND NEW.current_quantity > 0 THEN
        -- جديد - لم يتم البيع منه
        NEW.status = 'new';
    ELSIF NEW.current_quantity > 0 AND NEW.current_quantity < NEW.initial_quantity THEN
        -- قيد الاستخدام - تم البيع منه جزئياً
        NEW.status = 'in_use';
    ELSIF NEW.current_quantity = 0 AND NEW.initial_quantity > 0 THEN
        -- منتهي - تم بيع الكمية كاملة
        NEW.status = 'finished';
    END IF;
    
    -- تحديث وقت تغيير الحالة إذا تغيرت
    IF OLD.status IS DISTINCT FROM NEW.status THEN
        NEW.status_changed_at = CURRENT_TIMESTAMP;
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- إنشاء المشغل لتحديث الحالة تلقائياً
DROP TRIGGER IF EXISTS trigger_update_lot_status ON product_lots;
CREATE TRIGGER trigger_update_lot_status
    BEFORE UPDATE ON product_lots
    FOR EACH ROW
    EXECUTE FUNCTION update_lot_status();

-- تحديث lot_transactions لإضافة نوع حركة تغيير الحالة
ALTER TABLE lot_transactions 
DROP CONSTRAINT IF EXISTS lot_transactions_transaction_type_check;

ALTER TABLE lot_transactions 
ADD CONSTRAINT lot_transactions_transaction_type_check 
CHECK (transaction_type IN (
    'purchase', 'sale', 'adjustment', 'transfer', 'return', 
    'status_change', 'damage', 'close'
));

-- إنشاء دالة لتغيير حالة الدفعة يدوياً
CREATE OR REPLACE FUNCTION change_lot_status(
    p_lot_id INTEGER,
    p_new_status lot_status_enum,
    p_notes TEXT DEFAULT NULL,
    p_changed_by VARCHAR(255) DEFAULT NULL
)
RETURNS BOOLEAN AS $$
DECLARE
    v_old_status lot_status_enum;
    v_lot_number VARCHAR(50);
    v_product_name VARCHAR(255);
BEGIN
    -- الحصول على الحالة الحالية
    SELECT status, lot_number INTO v_old_status, v_lot_number
    FROM product_lots pl
    JOIN products p ON pl.product_id = p.id
    WHERE pl.id = p_lot_id;
    
    IF NOT FOUND THEN
        RAISE EXCEPTION 'Lot not found with ID: %', p_lot_id;
    END IF;
    
    -- تحديث الحالة
    UPDATE product_lots 
    SET 
        status = p_new_status,
        status_changed_at = CURRENT_TIMESTAMP,
        status_changed_by = p_changed_by,
        status_notes = p_notes
    WHERE id = p_lot_id;
    
    -- إدراج سجل في حركات الدفعات
    INSERT INTO lot_transactions (
        lot_id, 
        transaction_type, 
        quantity, 
        notes, 
        created_by
    ) VALUES (
        p_lot_id,
        'status_change',
        0,
        FORMAT('تغيير الحالة من %s إلى %s. %s', 
               v_old_status, p_new_status, COALESCE(p_notes, '')),
        p_changed_by
    );
    
    RETURN TRUE;
END;
$$ LANGUAGE plpgsql;

-- تحديث view تقرير الدفعات لإظهار الحالات الجديدة
CREATE OR REPLACE VIEW lot_inventory_report AS
SELECT 
    pl.id as lot_id,
    pl.lot_number,
    p.product_code,
    p.product_name,
    pl.manufacturing_date,
    pl.expiry_date,
    CASE 
        WHEN pl.expiry_date < CURRENT_DATE THEN 'منتهي الصلاحية'
        WHEN pl.expiry_date <= CURRENT_DATE + INTERVAL '30 days' THEN 'قريب الانتهاء'
        ELSE 'صالح'
    END as expiry_status,
    pl.initial_quantity,
    pl.current_quantity,
    pl.reserved_quantity,
    pl.available_quantity,
    pl.unit_cost,
    pl.current_quantity * pl.unit_cost as total_value,
    s.supplier_name,
    CASE pl.status
        WHEN 'new' THEN 'جديد'
        WHEN 'in_use' THEN 'قيد الاستخدام'
        WHEN 'finished' THEN 'منتهي'
        WHEN 'damaged' THEN 'تالف/مغلق'
        ELSE pl.status::text
    END as status_display,
    pl.status,
    pl.status_changed_at,
    pl.status_changed_by,
    pl.status_notes,
    pl.created_at,
    pl.updated_at
FROM product_lots pl
JOIN products p ON pl.product_id = p.id
LEFT JOIN suppliers s ON pl.supplier_id = s.id
ORDER BY p.product_name, pl.expiry_date;

-- إنشاء view لإحصائيات الحالات
CREATE OR REPLACE VIEW lot_status_summary AS
SELECT 
    p.product_name,
    pl.status,
    CASE pl.status
        WHEN 'new' THEN 'جديد'
        WHEN 'in_use' THEN 'قيد الاستخدام'
        WHEN 'finished' THEN 'منتهي'
        WHEN 'damaged' THEN 'تالف/مغلق'
        ELSE pl.status::text
    END as status_display,
    COUNT(*) as lot_count,
    SUM(pl.current_quantity) as total_quantity,
    SUM(pl.current_quantity * pl.unit_cost) as total_value
FROM product_lots pl
JOIN products p ON pl.product_id = p.id
GROUP BY p.product_name, pl.status
ORDER BY p.product_name, pl.status;

-- تحديث الدفعات الموجودة لتطبيق الحالات الجديدة
UPDATE product_lots 
SET status = CASE 
    WHEN current_quantity = initial_quantity AND current_quantity > 0 THEN 'new'::lot_status_enum
    WHEN current_quantity > 0 AND current_quantity < initial_quantity THEN 'in_use'::lot_status_enum
    WHEN current_quantity = 0 AND initial_quantity > 0 THEN 'finished'::lot_status_enum
    ELSE 'new'::lot_status_enum
END,
status_changed_at = CURRENT_TIMESTAMP;

COMMENT ON TYPE lot_status_enum IS 'حالات الدفعات: جديد، قيد الاستخدام، منتهي، تالف/مغلق';
COMMENT ON FUNCTION change_lot_status IS 'دالة لتغيير حالة الدفعة يدوياً';
COMMENT ON VIEW lot_status_summary IS 'ملخص إحصائيات حالات الدفعات';
