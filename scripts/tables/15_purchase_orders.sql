-- جدول طلبيات المشتريات
CREATE TABLE IF NOT EXISTS purchase_orders (
    id SERIAL PRIMARY KEY,
    order_number VARCHAR(100) UNIQUE NOT NULL,
    supplier_id INTEGER REFERENCES suppliers(id),
    supplier_name VARCHAR(255),
    order_date DATE NOT NULL,
    expected_delivery_date DATE,
    salesman VARCHAR(100),
    currency_code VARCHAR(10) DEFAULT 'SAR',
    currency_name VARCHAR(50),
    exchange_rate NUMERIC(10,4) DEFAULT 1,
    total_amount NUMERIC(15,2) DEFAULT 0,
    workflow_status VARCHAR(50) DEFAULT 'pending',
    workflow_sequence_id INTEGER,
    order_source VARCHAR(50) DEFAULT 'manual',
    manual_document VARCHAR(255),
    notes TEXT,
    attachments TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_purchase_orders_number ON purchase_orders(order_number);
CREATE INDEX IF NOT EXISTS idx_purchase_orders_supplier ON purchase_orders(supplier_id);
CREATE INDEX IF NOT EXISTS idx_purchase_orders_date ON purchase_orders(order_date);
CREATE INDEX IF NOT EXISTS idx_purchase_orders_status ON purchase_orders(workflow_status);
CREATE INDEX IF NOT EXISTS idx_purchase_orders_source ON purchase_orders(order_source);
