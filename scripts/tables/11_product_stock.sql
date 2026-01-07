-- جدول المخزون الإجمالي للمنتجات
CREATE TABLE IF NOT EXISTS product_stock (
    id SERIAL PRIMARY KEY,
    product_id INTEGER UNIQUE REFERENCES products(id) ON DELETE CASCADE,
    organization_id INTEGER,
    current_stock NUMERIC(15,2) DEFAULT 0,
    available_stock NUMERIC(15,2) DEFAULT 0,
    reserved_stock NUMERIC(15,2) DEFAULT 0,
    reorder_level NUMERIC(15,2),
    max_stock_level NUMERIC(15,2),
    last_updated TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_product_stock_product ON product_stock(product_id);
CREATE INDEX IF NOT EXISTS idx_product_stock_available ON product_stock(available_stock);
