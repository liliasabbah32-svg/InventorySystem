-- إنشاء جدول لتتبع الدفعات (Lots) لكل منتج
CREATE TABLE IF NOT EXISTS product_lots (
    id SERIAL PRIMARY KEY,
    product_id INTEGER NOT NULL REFERENCES products(id) ON DELETE CASCADE,
    lot_number VARCHAR(50) NOT NULL,
    manufacturing_date DATE,
    expiry_date DATE,
    supplier_id INTEGER REFERENCES suppliers(id),
    purchase_order_id INTEGER REFERENCES purchase_orders(id),
    initial_quantity NUMERIC(10,2) NOT NULL DEFAULT 0,
    current_quantity NUMERIC(10,2) NOT NULL DEFAULT 0,
    reserved_quantity NUMERIC(10,2) NOT NULL DEFAULT 0,
    available_quantity NUMERIC(10,2) GENERATED ALWAYS AS (current_quantity - reserved_quantity) STORED,
    unit_cost NUMERIC(10,2) DEFAULT 0,
    notes TEXT,
    status VARCHAR(20) DEFAULT 'active', -- active, expired, recalled, sold_out
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    
    -- فهرس مركب لضمان عدم تكرار رقم الدفعة لنفس المنتج
    UNIQUE(product_id, lot_number)
);

-- إنشاء فهارس لتحسين الأداء
CREATE INDEX IF NOT EXISTS idx_product_lots_product_id ON product_lots(product_id);
CREATE INDEX IF NOT EXISTS idx_product_lots_lot_number ON product_lots(lot_number);
CREATE INDEX IF NOT EXISTS idx_product_lots_expiry_date ON product_lots(expiry_date);
CREATE INDEX IF NOT EXISTS idx_product_lots_status ON product_lots(status);

-- إنشاء جدول لتتبع حركات الدفعات
CREATE TABLE IF NOT EXISTS lot_transactions (
    id SERIAL PRIMARY KEY,
    lot_id INTEGER NOT NULL REFERENCES product_lots(id) ON DELETE CASCADE,
    transaction_type VARCHAR(20) NOT NULL, -- purchase, sale, adjustment, transfer, return
    quantity NUMERIC(10,2) NOT NULL,
    reference_type VARCHAR(20), -- purchase_order, sales_order, adjustment, transfer
    reference_id INTEGER,
    unit_cost NUMERIC(10,2),
    notes TEXT,
    created_by VARCHAR(255),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- إنشاء فهارس لجدول حركات الدفعات
CREATE INDEX IF NOT EXISTS idx_lot_transactions_lot_id ON lot_transactions(lot_id);
CREATE INDEX IF NOT EXISTS idx_lot_transactions_type ON lot_transactions(transaction_type);
CREATE INDEX IF NOT EXISTS idx_lot_transactions_reference ON lot_transactions(reference_type, reference_id);

-- تحديث جدول purchase_order_items لإضافة معرف الدفعة
ALTER TABLE purchase_order_items 
ADD COLUMN IF NOT EXISTS lot_id INTEGER REFERENCES product_lots(id);

-- تحديث جدول sales_order_items لإضافة معرف الدفعة
ALTER TABLE sales_order_items 
ADD COLUMN IF NOT EXISTS lot_id INTEGER REFERENCES product_lots(id);

-- إنشاء دالة لتحديث كميات الدفعات تلقائياً
CREATE OR REPLACE FUNCTION update_lot_quantities()
RETURNS TRIGGER AS $$
BEGIN
    -- تحديث الكميات في جدول product_lots عند إضافة حركة جديدة
    IF TG_OP = 'INSERT' THEN
        UPDATE product_lots 
        SET 
            current_quantity = CASE 
                WHEN NEW.transaction_type IN ('purchase', 'return', 'adjustment_in') 
                THEN current_quantity + NEW.quantity
                WHEN NEW.transaction_type IN ('sale', 'adjustment_out', 'transfer_out')
                THEN current_quantity - NEW.quantity
                ELSE current_quantity
            END,
            updated_at = CURRENT_TIMESTAMP
        WHERE id = NEW.lot_id;
    END IF;
    
    RETURN COALESCE(NEW, OLD);
END;
$$ LANGUAGE plpgsql;

-- إنشاء المشغل (Trigger)
DROP TRIGGER IF EXISTS trigger_update_lot_quantities ON lot_transactions;
CREATE TRIGGER trigger_update_lot_quantities
    AFTER INSERT ON lot_transactions
    FOR EACH ROW
    EXECUTE FUNCTION update_lot_quantities();

-- إنشاء view لعرض تقرير الدفعات
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
    pl.status,
    pl.created_at,
    pl.updated_at
FROM product_lots pl
JOIN products p ON pl.product_id = p.id
LEFT JOIN suppliers s ON pl.supplier_id = s.id
WHERE pl.status = 'active'
ORDER BY p.product_name, pl.expiry_date;

COMMENT ON TABLE product_lots IS 'جدول تتبع دفعات المنتجات (Lot Numbers)';
COMMENT ON TABLE lot_transactions IS 'جدول حركات الدفعات';
COMMENT ON VIEW lot_inventory_report IS 'تقرير المخزون حسب الدفعات';
