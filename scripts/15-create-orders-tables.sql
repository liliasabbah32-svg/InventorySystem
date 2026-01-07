-- Create sales orders table
CREATE TABLE IF NOT EXISTS sales_orders (
    id SERIAL PRIMARY KEY,
    order_number VARCHAR(50) UNIQUE NOT NULL,
    order_date DATE NOT NULL,
    customer_id INTEGER,
    customer_name VARCHAR(255) NOT NULL,
    salesman VARCHAR(255),
    total_amount DECIMAL(15,2) DEFAULT 0,
    currency_code VARCHAR(3) DEFAULT 'USD',
    currency_name VARCHAR(50) DEFAULT 'US Dollar',
    exchange_rate DECIMAL(10,4) DEFAULT 1.0000,
    order_status VARCHAR(50) DEFAULT 'pending',
    financial_status VARCHAR(50) DEFAULT 'unpaid',
    delivery_datetime TIMESTAMP,
    manual_document TEXT,
    notes TEXT,
    attachments TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create purchase orders table
CREATE TABLE IF NOT EXISTS purchase_orders (
    id SERIAL PRIMARY KEY,
    order_number VARCHAR(50) UNIQUE NOT NULL,
    order_date DATE NOT NULL,
    supplier_id INTEGER,
    supplier_name VARCHAR(255) NOT NULL,
    salesman VARCHAR(255),
    total_amount DECIMAL(15,2) DEFAULT 0,
    currency_code VARCHAR(3) DEFAULT 'USD',
    currency_name VARCHAR(50) DEFAULT 'US Dollar',
    exchange_rate DECIMAL(10,4) DEFAULT 1.0000,
    workflow_status VARCHAR(50) DEFAULT 'pending',
    expected_delivery_date DATE,
    manual_document TEXT,
    notes TEXT,
    attachments TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create sales order items table
CREATE TABLE IF NOT EXISTS sales_order_items (
    id SERIAL PRIMARY KEY,
    sales_order_id INTEGER NOT NULL REFERENCES sales_orders(id) ON DELETE CASCADE,
    product_id INTEGER,
    product_name VARCHAR(255) NOT NULL,
    product_code VARCHAR(100),
    quantity DECIMAL(10,3) NOT NULL,
    unit_price DECIMAL(15,2) NOT NULL,
    discount_percentage DECIMAL(5,2) DEFAULT 0,
    total_price DECIMAL(15,2) NOT NULL,
    delivered_quantity DECIMAL(10,3) DEFAULT 0,
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create purchase order items table
CREATE TABLE IF NOT EXISTS purchase_order_items (
    id SERIAL PRIMARY KEY,
    purchase_order_id INTEGER NOT NULL REFERENCES purchase_orders(id) ON DELETE CASCADE,
    product_id INTEGER,
    product_name VARCHAR(255) NOT NULL,
    product_code VARCHAR(100),
    quantity DECIMAL(10,3) NOT NULL,
    unit_price DECIMAL(15,2) NOT NULL,
    total_price DECIMAL(15,2) NOT NULL,
    received_quantity DECIMAL(10,3) DEFAULT 0,
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create customers table if not exists
CREATE TABLE IF NOT EXISTS customers (
    id SERIAL PRIMARY KEY,
    customer_code VARCHAR(50) UNIQUE NOT NULL,
    customer_name VARCHAR(255) NOT NULL,
    email VARCHAR(255),
    mobile1 VARCHAR(20),
    mobile2 VARCHAR(20),
    address TEXT,
    city VARCHAR(100),
    country VARCHAR(100),
    status VARCHAR(20) DEFAULT 'active',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create suppliers table if not exists
CREATE TABLE IF NOT EXISTS suppliers (
    id SERIAL PRIMARY KEY,
    supplier_code VARCHAR(50) UNIQUE NOT NULL,
    supplier_name VARCHAR(255) NOT NULL,
    email VARCHAR(255),
    mobile1 VARCHAR(20),
    mobile2 VARCHAR(20),
    address TEXT,
    city VARCHAR(100),
    country VARCHAR(100),
    status VARCHAR(20) DEFAULT 'active',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create workflow history table if not exists
CREATE TABLE IF NOT EXISTS workflow_history (
    id SERIAL PRIMARY KEY,
    order_id INTEGER NOT NULL,
    order_type VARCHAR(20) NOT NULL,
    order_number VARCHAR(50) NOT NULL,
    previous_status VARCHAR(50),
    new_status VARCHAR(50) NOT NULL,
    changed_by VARCHAR(255) NOT NULL,
    change_reason TEXT,
    organization_id INTEGER DEFAULT 1,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Insert sample customers
INSERT INTO customers (customer_code, customer_name, email, mobile1, status) VALUES
('CUST001', 'شركة الأمل للتجارة', 'info@alamal.com', '+966501234567', 'active'),
('CUST002', 'مؤسسة النور التجارية', 'contact@alnoor.com', '+966502345678', 'active'),
('CUST003', 'شركة الفجر للمقاولات', 'sales@alfajr.com', '+966503456789', 'active')
ON CONFLICT (customer_code) DO NOTHING;

-- Insert sample suppliers
INSERT INTO suppliers (supplier_code, supplier_name, email, mobile1, status) VALUES
('SUPP001', 'مصنع الجودة للمواد', 'orders@quality.com', '+966511234567', 'active'),
('SUPP002', 'شركة التميز للتوريد', 'info@tamayoz.com', '+966512345678', 'active'),
('SUPP003', 'مؤسسة الإبداع التجارية', 'sales@ibdaa.com', '+966513456789', 'active')
ON CONFLICT (supplier_code) DO NOTHING;

-- Create indexes for better performance
CREATE INDEX IF NOT EXISTS idx_sales_orders_customer_id ON sales_orders(customer_id);
CREATE INDEX IF NOT EXISTS idx_sales_orders_order_date ON sales_orders(order_date);
CREATE INDEX IF NOT EXISTS idx_sales_orders_status ON sales_orders(order_status);
CREATE INDEX IF NOT EXISTS idx_purchase_orders_supplier_id ON purchase_orders(supplier_id);
CREATE INDEX IF NOT EXISTS idx_purchase_orders_order_date ON purchase_orders(order_date);
CREATE INDEX IF NOT EXISTS idx_purchase_orders_status ON purchase_orders(workflow_status);
CREATE INDEX IF NOT EXISTS idx_sales_order_items_order_id ON sales_order_items(sales_order_id);
CREATE INDEX IF NOT EXISTS idx_purchase_order_items_order_id ON purchase_order_items(purchase_order_id);
