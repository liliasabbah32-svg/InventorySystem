-- جدول أصناف طلبيات المبيعات
CREATE TABLE IF NOT EXISTS sales_order_items (
    id SERIAL PRIMARY KEY,
    sales_order_id INTEGER REFERENCES sales_orders(id) ON DELETE CASCADE,
    product_id INTEGER REFERENCES products(id),
    product_code VARCHAR(100),
    product_name VARCHAR(255),
    barcode VARCHAR(100),
    lot_id INTEGER REFERENCES product_lots(id),
    batch_number VARCHAR(100),
    expiry_date DATE,
    quantity NUMERIC(15,2) NOT NULL,
    delivered_quantity NUMERIC(15,2) DEFAULT 0,
    bonus_quantity NUMERIC(15,2) DEFAULT 0,
    unit VARCHAR(50),
    unit_price NUMERIC(15,2) NOT NULL,
    discount_percentage NUMERIC(5,2) DEFAULT 0,
    total_price NUMERIC(15,2) NOT NULL,
    warehouse VARCHAR(100),
    item_status VARCHAR(50) DEFAULT 'pending',
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_sales_order_items_order ON sales_order_items(sales_order_id);
CREATE INDEX IF NOT EXISTS idx_sales_order_items_product ON sales_order_items(product_id);
CREATE INDEX IF NOT EXISTS idx_sales_order_items_lot ON sales_order_items(lot_id);
