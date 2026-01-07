-- ========================================
-- توحيد مصطلحات الباتش نمبر في النظام
-- Unify Batch Number Terminology
-- ========================================
-- هذا السكريبت يوحد المصطلحات ويحسن الربط بين الجداول

-- 1. إضافة foreign key constraints لتحسين الربط بين الجداول
-- Add foreign key constraints to improve table relationships

-- ربط sales_order_items.lot_id مع product_lots.id
ALTER TABLE sales_order_items
DROP CONSTRAINT IF EXISTS fk_sales_order_items_lot;

ALTER TABLE sales_order_items
ADD CONSTRAINT fk_sales_order_items_lot
FOREIGN KEY (lot_id) REFERENCES product_lots(id)
ON DELETE SET NULL;

-- ربط purchase_order_items.lot_id مع product_lots.id
ALTER TABLE purchase_order_items
DROP CONSTRAINT IF EXISTS fk_purchase_order_items_lot;

ALTER TABLE purchase_order_items
ADD CONSTRAINT fk_purchase_order_items_lot
FOREIGN KEY (lot_id) REFERENCES product_lots(id)
ON DELETE SET NULL;

-- 2. إضافة indexes لتحسين الأداء
-- Add indexes for better performance

CREATE INDEX IF NOT EXISTS idx_product_lots_product_id 
ON product_lots(product_id);

CREATE INDEX IF NOT EXISTS idx_product_lots_lot_number 
ON product_lots(lot_number);

CREATE INDEX IF NOT EXISTS idx_product_lots_status_available 
ON product_lots(status, available_quantity) 
WHERE status = 'active' AND available_quantity > 0;

CREATE INDEX IF NOT EXISTS idx_sales_order_items_lot_id 
ON sales_order_items(lot_id) 
WHERE lot_id IS NOT NULL;

CREATE INDEX IF NOT EXISTS idx_purchase_order_items_lot_id 
ON purchase_order_items(lot_id) 
WHERE lot_id IS NOT NULL;

CREATE INDEX IF NOT EXISTS idx_lot_transactions_lot_id 
ON lot_transactions(lot_id);

-- 3. إضافة تعليقات توضيحية للجداول والحقول
-- Add descriptive comments to tables and columns

COMMENT ON TABLE product_lots IS 'جدول الدفعات (Batches/Lots) - يحتوي على معلومات الباتش نمبر لكل منتج';
COMMENT ON COLUMN product_lots.lot_number IS 'رقم الباتش/الدفعة - Batch Number';
COMMENT ON COLUMN product_lots.available_quantity IS 'الكمية المتاحة = الكمية الحالية - الكمية المحجوزة';

COMMENT ON TABLE lot_transactions IS 'جدول حركات الدفعات - يسجل جميع العمليات على الباتش';
COMMENT ON COLUMN lot_transactions.transaction_type IS 'نوع الحركة: reserve, release, consume, adjust';

COMMENT ON TABLE batch_settings IS 'إعدادات الباتش لكل نوع سند';
COMMENT ON COLUMN batch_settings.mandatory_batch_selection IS 'هل اختيار الباتش إجباري؟';
COMMENT ON COLUMN batch_settings.auto_select_fifo IS 'اختيار تلقائي بنظام FIFO (الأقدم أولاً)';

COMMENT ON COLUMN sales_order_items.batch_number IS 'رقم الباتش (للعرض فقط) - الربط الفعلي عبر lot_id';
COMMENT ON COLUMN sales_order_items.lot_id IS 'معرف الدفعة - Foreign Key إلى product_lots';

COMMENT ON COLUMN purchase_order_items.batch_number IS 'رقم الباتش (للعرض فقط) - الربط الفعلي عبر lot_id';
COMMENT ON COLUMN purchase_order_items.lot_id IS 'معرف الدفعة - Foreign Key إلى product_lots';

-- 4. إنشاء view موحد لعرض معلومات الباتش
-- Create unified view for batch information

CREATE OR REPLACE VIEW batch_inventory_view AS
SELECT 
  pl.id as lot_id,
  pl.lot_number as batch_number,
  pl.product_id,
  p.product_code,
  p.product_name,
  p.barcode,
  pl.manufacturing_date,
  pl.expiry_date,
  pl.initial_quantity,
  pl.current_quantity,
  pl.reserved_quantity,
  pl.available_quantity,
  pl.unit_cost,
  pl.status,
  pl.supplier_id,
  s.supplier_name,
  -- حساب حالة الصلاحية
  CASE 
    WHEN pl.expiry_date IS NULL THEN 'no_expiry'
    WHEN pl.expiry_date < CURRENT_DATE THEN 'expired'
    WHEN pl.expiry_date <= CURRENT_DATE + INTERVAL '30 days' THEN 'near_expiry'
    ELSE 'good'
  END as expiry_status,
  -- حساب الأيام المتبقية للصلاحية
  CASE 
    WHEN pl.expiry_date IS NOT NULL 
    THEN EXTRACT(DAY FROM (pl.expiry_date - CURRENT_DATE))
    ELSE NULL 
  END as days_until_expiry,
  -- حساب القيمة الإجمالية
  (pl.current_quantity * pl.unit_cost) as total_value,
  pl.created_at,
  pl.updated_at
FROM product_lots pl
LEFT JOIN products p ON pl.product_id = p.id
LEFT JOIN suppliers s ON pl.supplier_id = s.id;

COMMENT ON VIEW batch_inventory_view IS 'عرض موحد لمعلومات الباتش مع حسابات الصلاحية والقيمة';

-- 5. إنشاء function للحصول على الباتش حسب FIFO
-- Create function to get batches using FIFO method

CREATE OR REPLACE FUNCTION get_fifo_batches(
  p_product_id INTEGER,
  p_requested_quantity NUMERIC
)
RETURNS TABLE (
  lot_id INTEGER,
  batch_number VARCHAR,
  available_quantity NUMERIC,
  allocated_quantity NUMERIC,
  unit_cost NUMERIC,
  expiry_date DATE,
  expiry_status TEXT
) AS $$
DECLARE
  remaining_qty NUMERIC := p_requested_quantity;
  current_lot RECORD;
BEGIN
  FOR current_lot IN
    SELECT 
      pl.id,
      pl.lot_number,
      pl.available_quantity,
      pl.unit_cost,
      pl.expiry_date,
      CASE 
        WHEN pl.expiry_date IS NULL THEN 'no_expiry'
        WHEN pl.expiry_date < CURRENT_DATE THEN 'expired'
        WHEN pl.expiry_date <= CURRENT_DATE + INTERVAL '30 days' THEN 'near_expiry'
        ELSE 'good'
      END as exp_status
    FROM product_lots pl
    WHERE pl.product_id = p_product_id
      AND pl.available_quantity > 0
      AND pl.status = 'active'
    ORDER BY 
      CASE WHEN pl.expiry_date IS NULL THEN 1 ELSE 0 END,
      pl.expiry_date ASC NULLS LAST,
      pl.manufacturing_date ASC NULLS LAST,
      pl.created_at ASC
  LOOP
    IF remaining_qty <= 0 THEN
      EXIT;
    END IF;
    
    lot_id := current_lot.id;
    batch_number := current_lot.lot_number;
    available_quantity := current_lot.available_quantity;
    allocated_quantity := LEAST(remaining_qty, current_lot.available_quantity);
    unit_cost := current_lot.unit_cost;
    expiry_date := current_lot.expiry_date;
    expiry_status := current_lot.exp_status;
    
    remaining_qty := remaining_qty - allocated_quantity;
    
    RETURN NEXT;
  END LOOP;
END;
$$ LANGUAGE plpgsql;

COMMENT ON FUNCTION get_fifo_batches IS 'دالة للحصول على الباتشات حسب نظام FIFO (الأقدم أولاً)';

-- 6. إنشاء trigger لتحديث available_quantity تلقائياً
-- Create trigger to automatically update available_quantity

CREATE OR REPLACE FUNCTION update_available_quantity()
RETURNS TRIGGER AS $$
BEGIN
  NEW.available_quantity := NEW.current_quantity - NEW.reserved_quantity;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_update_available_quantity ON product_lots;

CREATE TRIGGER trg_update_available_quantity
BEFORE INSERT OR UPDATE OF current_quantity, reserved_quantity ON product_lots
FOR EACH ROW
EXECUTE FUNCTION update_available_quantity();

COMMENT ON FUNCTION update_available_quantity IS 'دالة لتحديث الكمية المتاحة تلقائياً عند تغيير الكمية الحالية أو المحجوزة';

-- 7. إضافة constraint للتأكد من صحة البيانات
-- Add constraints to ensure data integrity

ALTER TABLE product_lots
DROP CONSTRAINT IF EXISTS chk_quantities_valid;

ALTER TABLE product_lots
ADD CONSTRAINT chk_quantities_valid
CHECK (
  current_quantity >= 0 AND
  reserved_quantity >= 0 AND
  reserved_quantity <= current_quantity AND
  available_quantity >= 0
);

-- 8. تحديث البيانات الموجودة لضمان التناسق
-- Update existing data to ensure consistency

UPDATE product_lots
SET available_quantity = current_quantity - reserved_quantity
WHERE available_quantity != (current_quantity - reserved_quantity);

-- 9. إنشاء view لملخص الباتش لكل منتج
-- Create view for batch summary per product

CREATE OR REPLACE VIEW product_batch_summary AS
SELECT 
  p.id as product_id,
  p.product_code,
  p.product_name,
  p.has_batch,
  COUNT(pl.id) as total_batches,
  COUNT(CASE WHEN pl.status = 'active' THEN 1 END) as active_batches,
  SUM(pl.current_quantity) as total_quantity,
  SUM(pl.reserved_quantity) as total_reserved,
  SUM(pl.available_quantity) as total_available,
  SUM(pl.current_quantity * pl.unit_cost) as total_value,
  MIN(pl.expiry_date) as earliest_expiry,
  COUNT(CASE 
    WHEN pl.expiry_date IS NOT NULL AND pl.expiry_date < CURRENT_DATE 
    THEN 1 
  END) as expired_batches,
  COUNT(CASE 
    WHEN pl.expiry_date IS NOT NULL 
    AND pl.expiry_date <= CURRENT_DATE + INTERVAL '30 days'
    AND pl.expiry_date >= CURRENT_DATE
    THEN 1 
  END) as near_expiry_batches
FROM products p
LEFT JOIN product_lots pl ON p.id = pl.product_id
WHERE p.has_batch = true
GROUP BY p.id, p.product_code, p.product_name, p.has_batch;

COMMENT ON VIEW product_batch_summary IS 'ملخص الباتشات لكل منتج مع إحصائيات الصلاحية';

-- 10. إنشاء indexes إضافية للـ views
-- Create additional indexes for views

CREATE INDEX IF NOT EXISTS idx_product_lots_expiry_status 
ON product_lots(expiry_date) 
WHERE expiry_date IS NOT NULL;

CREATE INDEX IF NOT EXISTS idx_product_lots_created_at 
ON product_lots(created_at);

-- نهاية السكريبت
-- End of script
