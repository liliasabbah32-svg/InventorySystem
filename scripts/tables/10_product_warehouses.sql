-- جدول مخزون المنتجات في المستودعات
CREATE TABLE IF NOT EXISTS product_warehouses (
    id SERIAL PRIMARY KEY,
    product_id INTEGER REFERENCES products(id) ON DELETE CASCADE,
    warehouse_id INTEGER REFERENCES warehouses(id) ON DELETE CASCADE,
    quantity NUMERIC(15,2) DEFAULT 0,
    reserved_quantity NUMERIC(15,2) DEFAULT 0,
    min_stock_level NUMERIC(15,2),
    max_stock_level NUMERIC(15,2),
    floor VARCHAR(50),
    area VARCHAR(50),
    shelf VARCHAR(50),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(product_id, warehouse_id)
);

CREATE INDEX IF NOT EXISTS idx_product_warehouses_product ON product_warehouses(product_id);
CREATE INDEX IF NOT EXISTS idx_product_warehouses_warehouse ON product_warehouses(warehouse_id);
