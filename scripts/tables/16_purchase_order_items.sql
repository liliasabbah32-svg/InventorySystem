-- جدول أصناف طلبيات المشتريات
CREATE TABLE IF NOT EXISTS purchase_order_items (
    id SERIAL PRIMARY KEY,
    purchase_order_id INTEGER REFERENCES purchase_orders(id) ON DELETE CASCADE,
    product_id INTEGER REFERENCES products(id),
    product_code VARCHAR(100),
    product_name VARCHAR(255),
    barcode VARCHAR(100),
    lot_id INTEGER REFERENCES product_lots(id),
    batch_number VARCHAR(100),
    expiry_date DATE,
    quantity NUMERIC(15,2) NOT NULL,
    received_quantity NUMERIC(15,2) DEFAULT 0,
    bonus_quantity NUMERIC(15,2) DEFAULT 0,
    unit VARCHAR(50),
    unit_price NUMERIC(15,2) NOT NULL,
    total_price NUMERIC(15,2) NOT NULL,
    warehouse VARCHAR(100),
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_purchase_order_items_order ON purchase_order_items(purchase_order_id);
CREATE INDEX IF NOT EXISTS idx_purchase_order_items_product ON purchase_order_items(product_id);
CREATE INDEX IF NOT EXISTS idx_purchase_order_items_lot ON purchase_order_items(lot_id);
