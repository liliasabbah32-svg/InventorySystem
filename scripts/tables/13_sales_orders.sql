-- جدول طلبيات المبيعات
CREATE TABLE IF NOT EXISTS sales_orders (
    id SERIAL PRIMARY KEY,
    order_number VARCHAR(100) UNIQUE NOT NULL,
    invoice_number VARCHAR(100),
    barcode VARCHAR(100),
    customer_id INTEGER REFERENCES customers(id),
    customer_name VARCHAR(255),
    order_date DATE NOT NULL,
    delivery_datetime TIMESTAMP,
    salesman VARCHAR(100),
    currency_code VARCHAR(10) DEFAULT 'SAR',
    currency_name VARCHAR(50),
    exchange_rate NUMERIC(10,4) DEFAULT 1,
    total_amount NUMERIC(15,2) DEFAULT 0,
    order_status VARCHAR(50) DEFAULT 'pending',
    financial_status VARCHAR(50) DEFAULT 'unpaid',
    workflow_sequence_id INTEGER,
    order_source VARCHAR(50) DEFAULT 'manual',
    manual_document VARCHAR(255),
    notes TEXT,
    attachments TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_sales_orders_number ON sales_orders(order_number);
CREATE INDEX IF NOT EXISTS idx_sales_orders_customer ON sales_orders(customer_id);
CREATE INDEX IF NOT EXISTS idx_sales_orders_date ON sales_orders(order_date);
CREATE INDEX IF NOT EXISTS idx_sales_orders_status ON sales_orders(order_status);
CREATE INDEX IF NOT EXISTS idx_sales_orders_source ON sales_orders(order_source);
