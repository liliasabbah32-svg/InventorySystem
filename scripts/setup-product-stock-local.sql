-- =====================================================
-- Script: إنشاء جدول product_stock مع بيانات تجريبية
-- الوصف: script شامل لإعداد نظام المخزون محلياً
-- =====================================================

-- 1. إنشاء جدول product_stock
-- =====================================================
CREATE TABLE IF NOT EXISTS product_stock (
    id SERIAL PRIMARY KEY,
    product_id INTEGER NOT NULL REFERENCES products(id) ON DELETE CASCADE,
    current_stock NUMERIC(15,3) DEFAULT 0,
    reserved_stock NUMERIC(15,3) DEFAULT 0,
    available_stock NUMERIC(15,3) GENERATED ALWAYS AS (current_stock - reserved_stock) STORED,
    reorder_level NUMERIC(15,3) DEFAULT 0,
    max_stock_level NUMERIC(15,3),
    last_updated TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    organization_id INTEGER DEFAULT 1,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(product_id, organization_id)
);

-- 2. إنشاء جدول inventory_transactions (حركات المخزون)
-- =====================================================
CREATE TABLE IF NOT EXISTS inventory_transactions (
    id SERIAL PRIMARY KEY,
    product_id INTEGER NOT NULL REFERENCES products(id) ON DELETE CASCADE,
    transaction_type VARCHAR(20) NOT NULL CHECK (transaction_type IN ('in', 'out', 'adjustment', 'transfer')),
    quantity NUMERIC(15,3) NOT NULL,
    unit_cost NUMERIC(15,3),
    reference_type VARCHAR(50),
    reference_id INTEGER,
    notes TEXT,
    created_by VARCHAR(255) NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    organization_id INTEGER DEFAULT 1
);

-- 3. إنشاء الفهارس للأداء
-- =====================================================
CREATE INDEX IF NOT EXISTS idx_product_stock_product_id ON product_stock(product_id);
CREATE INDEX IF NOT EXISTS idx_product_stock_organization ON product_stock(organization_id);
CREATE INDEX IF NOT EXISTS idx_product_stock_available ON product_stock(available_stock);
CREATE INDEX IF NOT EXISTS idx_product_stock_reorder ON product_stock(reorder_level);

CREATE INDEX IF NOT EXISTS idx_inventory_transactions_product_id ON inventory_transactions(product_id);
CREATE INDEX IF NOT EXISTS idx_inventory_transactions_created_at ON inventory_transactions(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_inventory_transactions_organization ON inventory_transactions(organization_id);
CREATE INDEX IF NOT EXISTS idx_inventory_transactions_type ON inventory_transactions(transaction_type);

-- 4. إنشاء Trigger لتحديث updated_at تلقائياً
-- =====================================================
CREATE OR REPLACE FUNCTION update_product_stock_timestamp()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    NEW.last_updated = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trigger_update_product_stock_timestamp ON product_stock;
CREATE TRIGGER trigger_update_product_stock_timestamp
    BEFORE UPDATE ON product_stock
    FOR EACH ROW
    EXECUTE FUNCTION update_product_stock_timestamp();

-- 5. إنشاء Trigger لتحديث المخزون عند إضافة حركة
-- =====================================================
CREATE OR REPLACE FUNCTION update_stock_on_transaction()
RETURNS TRIGGER AS $$
BEGIN
    -- تحديث المخزون الحالي بناءً على نوع الحركة
    IF NEW.transaction_type = 'in' THEN
        -- إضافة للمخزون
        INSERT INTO product_stock (product_id, current_stock, organization_id)
        VALUES (NEW.product_id, NEW.quantity, NEW.organization_id)
        ON CONFLICT (product_id, organization_id)
        DO UPDATE SET 
            current_stock = product_stock.current_stock + NEW.quantity,
            last_updated = CURRENT_TIMESTAMP;
            
    ELSIF NEW.transaction_type = 'out' THEN
        -- خصم من المخزون
        INSERT INTO product_stock (product_id, current_stock, organization_id)
        VALUES (NEW.product_id, -NEW.quantity, NEW.organization_id)
        ON CONFLICT (product_id, organization_id)
        DO UPDATE SET 
            current_stock = product_stock.current_stock - NEW.quantity,
            last_updated = CURRENT_TIMESTAMP;
            
    ELSIF NEW.transaction_type = 'adjustment' THEN
        -- تعديل المخزون
        INSERT INTO product_stock (product_id, current_stock, organization_id)
        VALUES (NEW.product_id, NEW.quantity, NEW.organization_id)
        ON CONFLICT (product_id, organization_id)
        DO UPDATE SET 
            current_stock = NEW.quantity,
            last_updated = CURRENT_TIMESTAMP;
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trigger_update_stock_on_transaction ON inventory_transactions;
CREATE TRIGGER trigger_update_stock_on_transaction
    AFTER INSERT ON inventory_transactions
    FOR EACH ROW
    EXECUTE FUNCTION update_stock_on_transaction();

-- 6. إنشاء دالة للحصول على المنتجات مع المخزون
-- =====================================================
CREATE OR REPLACE FUNCTION get_products_with_stock(org_id INTEGER DEFAULT 1)
RETURNS TABLE (
    id INTEGER,
    product_code VARCHAR,
    product_name VARCHAR,
    current_stock NUMERIC,
    reserved_stock NUMERIC,
    available_stock NUMERIC,
    reorder_level NUMERIC,
    max_stock_level NUMERIC,
    stock_status TEXT
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        p.id,
        p.product_code,
        p.product_name,
        COALESCE(ps.current_stock, 0) as current_stock,
        COALESCE(ps.reserved_stock, 0) as reserved_stock,
        COALESCE(ps.available_stock, 0) as available_stock,
        COALESCE(ps.reorder_level, 0) as reorder_level,
        ps.max_stock_level,
        CASE 
            WHEN COALESCE(ps.current_stock, 0) <= COALESCE(ps.reorder_level, 0) AND COALESCE(ps.current_stock, 0) > 0 THEN 'low'
            WHEN COALESCE(ps.current_stock, 0) = 0 THEN 'out'
            ELSE 'available'
        END as stock_status
    FROM products p
    LEFT JOIN product_stock ps ON p.id = ps.product_id AND ps.organization_id = org_id
    ORDER BY p.product_name;
END;
$$ LANGUAGE plpgsql;

-- 7. إدخال بيانات تجريبية للمخزون
-- =====================================================
-- ملاحظة: تأكد من وجود منتجات في جدول products أولاً

-- إضافة مخزون للمنتجات الموجودة (أول 20 منتج)
INSERT INTO product_stock (product_id, current_stock, reserved_stock, reorder_level, max_stock_level, organization_id)
SELECT 
    id,
    FLOOR(RANDOM() * 500 + 50)::NUMERIC(15,3) as current_stock,
    FLOOR(RANDOM() * 20)::NUMERIC(15,3) as reserved_stock,
    50 as reorder_level,
    1000 as max_stock_level,
    1 as organization_id
FROM products
WHERE id <= 20
ON CONFLICT (product_id, organization_id) DO NOTHING;

-- إضافة بعض حركات المخزون التجريبية
INSERT INTO inventory_transactions (product_id, transaction_type, quantity, unit_cost, reference_type, notes, created_by, organization_id)
SELECT 
    id,
    'in' as transaction_type,
    FLOOR(RANDOM() * 100 + 10)::NUMERIC(15,3) as quantity,
    FLOOR(RANDOM() * 50 + 10)::NUMERIC(15,3) as unit_cost,
    'purchase_order' as reference_type,
    'مخزون افتتاحي' as notes,
    'admin' as created_by,
    1 as organization_id
FROM products
WHERE id <= 10;

-- 8. إضافة تعليقات توضيحية
-- =====================================================
COMMENT ON TABLE product_stock IS 'جدول مخزون المنتجات - يحتوي على الكميات الحالية والمتاحة والمحجوزة';
COMMENT ON TABLE inventory_transactions IS 'جدول حركات المخزون - يسجل جميع عمليات الإضافة والخصم والتعديل';
COMMENT ON COLUMN product_stock.current_stock IS 'المخزون الحالي الإجمالي';
COMMENT ON COLUMN product_stock.reserved_stock IS 'المخزون المحجوز (في طلبيات معلقة)';
COMMENT ON COLUMN product_stock.available_stock IS 'المخزون المتاح = المخزون الحالي - المخزون المحجوز (محسوب تلقائياً)';
COMMENT ON COLUMN product_stock.reorder_level IS 'مستوى إعادة الطلب - عند الوصول لهذا المستوى يجب إعادة الطلب';
COMMENT ON COLUMN product_stock.max_stock_level IS 'الحد الأقصى للمخزون';

-- 9. عرض ملخص المخزون
-- =====================================================
SELECT 
    'إجمالي المنتجات في المخزون' as description,
    COUNT(*) as count
FROM product_stock
UNION ALL
SELECT 
    'منتجات بمخزون منخفض' as description,
    COUNT(*) as count
FROM product_stock
WHERE current_stock <= reorder_level AND current_stock > 0
UNION ALL
SELECT 
    'منتجات نفذت من المخزون' as description,
    COUNT(*) as count
FROM product_stock
WHERE current_stock = 0
UNION ALL
SELECT 
    'إجمالي حركات المخزون' as description,
    COUNT(*) as count
FROM inventory_transactions;

-- =====================================================
-- انتهى Script إعداد product_stock
-- =====================================================
