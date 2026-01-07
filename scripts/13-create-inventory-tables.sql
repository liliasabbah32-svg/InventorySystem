-- إنشاء جدول مخزون المنتجات
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

-- إنشاء جدول حركات المخزون
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

-- إنشاء فهارس للأداء
CREATE INDEX IF NOT EXISTS idx_product_stock_product_id ON product_stock(product_id);
CREATE INDEX IF NOT EXISTS idx_product_stock_organization ON product_stock(organization_id);
CREATE INDEX IF NOT EXISTS idx_inventory_transactions_product_id ON inventory_transactions(product_id);
CREATE INDEX IF NOT EXISTS idx_inventory_transactions_created_at ON inventory_transactions(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_inventory_transactions_organization ON inventory_transactions(organization_id);

-- إنشاء مشغل لتحديث last_updated في product_stock
CREATE OR REPLACE FUNCTION update_product_stock_timestamp()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    NEW.last_updated = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_update_product_stock_timestamp
    BEFORE UPDATE ON product_stock
    FOR EACH ROW
    EXECUTE FUNCTION update_product_stock_timestamp();

-- إنشاء مشغل لتحديث المخزون عند إضافة حركة مخزون
CREATE OR REPLACE FUNCTION update_stock_on_transaction()
RETURNS TRIGGER AS $$
BEGIN
    -- تحديث المخزون الحالي بناءً على نوع الحركة
    IF NEW.transaction_type = 'in' THEN
        INSERT INTO product_stock (product_id, current_stock, organization_id)
        VALUES (NEW.product_id, NEW.quantity, NEW.organization_id)
        ON CONFLICT (product_id, organization_id)
        DO UPDATE SET 
            current_stock = product_stock.current_stock + NEW.quantity,
            last_updated = CURRENT_TIMESTAMP;
    ELSIF NEW.transaction_type = 'out' THEN
        INSERT INTO product_stock (product_id, current_stock, organization_id)
        VALUES (NEW.product_id, -NEW.quantity, NEW.organization_id)
        ON CONFLICT (product_id, organization_id)
        DO UPDATE SET 
            current_stock = product_stock.current_stock - NEW.quantity,
            last_updated = CURRENT_TIMESTAMP;
    ELSIF NEW.transaction_type = 'adjustment' THEN
        -- للتعديل، نحتاج لمعرفة الكمية الجديدة من الملاحظات
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

CREATE TRIGGER trigger_update_stock_on_transaction
    AFTER INSERT ON inventory_transactions
    FOR EACH ROW
    EXECUTE FUNCTION update_stock_on_transaction();

-- إضافة بيانات أولية للمنتجات الموجودة
INSERT INTO product_stock (product_id, current_stock, reorder_level, organization_id)
SELECT 
    id,
    COALESCE(order_quantity, 0) as current_stock,
    COALESCE(order_quantity, 0) as reorder_level,
    1 as organization_id
FROM products
WHERE id NOT IN (SELECT product_id FROM product_stock WHERE organization_id = 1)
ON CONFLICT (product_id, organization_id) DO NOTHING;

-- إنشاء دالة للحصول على المنتجات مع المخزون
CREATE OR REPLACE FUNCTION get_products_with_stock(org_id INTEGER DEFAULT 1)
RETURNS TABLE (
    id INTEGER,
    product_code VARCHAR,
    product_name VARCHAR,
    description TEXT,
    category VARCHAR,
    main_unit VARCHAR,
    secondary_unit VARCHAR,
    conversion_factor NUMERIC,
    last_purchase_price NUMERIC,
    currency VARCHAR,
    status VARCHAR,
    product_type VARCHAR,
    barcode VARCHAR,
    max_quantity NUMERIC,
    order_quantity NUMERIC,
    has_batch BOOLEAN,
    has_expiry BOOLEAN,
    has_colors BOOLEAN,
    general_notes TEXT,
    created_at TIMESTAMP,
    current_stock NUMERIC,
    reserved_stock NUMERIC,
    available_stock NUMERIC,
    reorder_level NUMERIC,
    max_stock_level NUMERIC,
    stock_last_updated TIMESTAMP,
    stock_status TEXT
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        p.id,
        p.product_code,
        p.product_name,
        p.description,
        p.category,
        p.main_unit,
        p.secondary_unit,
        p.conversion_factor,
        p.last_purchase_price,
        p.currency,
        p.status,
        p.product_type,
        p.barcode,
        p.max_quantity,
        p.order_quantity,
        p.has_batch,
        p.has_expiry,
        p.has_colors,
        p.general_notes,
        p.created_at,
        COALESCE(ps.current_stock, 0) as current_stock,
        COALESCE(ps.reserved_stock, 0) as reserved_stock,
        COALESCE(ps.available_stock, 0) as available_stock,
        COALESCE(ps.reorder_level, 0) as reorder_level,
        ps.max_stock_level,
        ps.last_updated as stock_last_updated,
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

COMMENT ON TABLE product_stock IS 'جدول مخزون المنتجات';
COMMENT ON TABLE inventory_transactions IS 'جدول حركات المخزون';
COMMENT ON FUNCTION get_products_with_stock IS 'دالة للحصول على المنتجات مع بيانات المخزون';
