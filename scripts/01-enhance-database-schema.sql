-- Enhanced database schema for inventory ordering system
-- Adding missing tables and improving existing ones

-- Create inventory_transactions table for tracking stock movements
CREATE TABLE IF NOT EXISTS inventory_transactions (
    id SERIAL PRIMARY KEY,
    product_id INTEGER REFERENCES products(id) ON DELETE CASCADE,
    transaction_type VARCHAR(50) NOT NULL, -- 'in', 'out', 'adjustment', 'transfer'
    quantity NUMERIC(10,2) NOT NULL,
    unit_cost NUMERIC(10,2),
    reference_type VARCHAR(50), -- 'purchase_order', 'sales_order', 'adjustment', 'transfer'
    reference_id INTEGER,
    notes TEXT,
    created_by VARCHAR(255),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    organization_id INTEGER
);

-- Create product_stock table for current stock levels
CREATE TABLE IF NOT EXISTS product_stock (
    id SERIAL PRIMARY KEY,
    product_id INTEGER REFERENCES products(id) ON DELETE CASCADE,
    current_stock NUMERIC(10,2) DEFAULT 0,
    reserved_stock NUMERIC(10,2) DEFAULT 0,
    available_stock NUMERIC(10,2) GENERATED ALWAYS AS (current_stock - reserved_stock) STORED,
    reorder_level NUMERIC(10,2) DEFAULT 0,
    max_stock_level NUMERIC(10,2),
    last_updated TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    organization_id INTEGER,
    UNIQUE(product_id, organization_id)
);

-- Create purchase_order_items table
CREATE TABLE IF NOT EXISTS purchase_order_items (
    id SERIAL PRIMARY KEY,
    purchase_order_id INTEGER REFERENCES purchase_orders(id) ON DELETE CASCADE,
    product_id INTEGER REFERENCES products(id) ON DELETE CASCADE,
    product_name VARCHAR(255),
    product_code VARCHAR(100),
    quantity NUMERIC(10,2) NOT NULL,
    unit_price NUMERIC(10,2) NOT NULL,
    total_price NUMERIC(10,2) GENERATED ALWAYS AS (quantity * unit_price) STORED,
    received_quantity NUMERIC(10,2) DEFAULT 0,
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create sales_order_items table
CREATE TABLE IF NOT EXISTS sales_order_items (
    id SERIAL PRIMARY KEY,
    sales_order_id INTEGER REFERENCES sales_orders(id) ON DELETE CASCADE,
    product_id INTEGER REFERENCES products(id) ON DELETE CASCADE,
    product_name VARCHAR(255),
    product_code VARCHAR(100),
    quantity NUMERIC(10,2) NOT NULL,
    unit_price NUMERIC(10,2) NOT NULL,
    discount_percentage NUMERIC(5,2) DEFAULT 0,
    total_price NUMERIC(10,2) GENERATED ALWAYS AS (quantity * unit_price * (1 - discount_percentage/100)) STORED,
    delivered_quantity NUMERIC(10,2) DEFAULT 0,
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create notifications table for system alerts
CREATE TABLE IF NOT EXISTS notifications (
    id SERIAL PRIMARY KEY,
    user_id VARCHAR(255),
    title VARCHAR(255) NOT NULL,
    message TEXT NOT NULL,
    type VARCHAR(50) DEFAULT 'info', -- 'info', 'warning', 'error', 'success'
    is_read BOOLEAN DEFAULT FALSE,
    action_url VARCHAR(500),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    organization_id INTEGER
);

-- Create indexes for better performance
CREATE INDEX IF NOT EXISTS idx_inventory_transactions_product_id ON inventory_transactions(product_id);
CREATE INDEX IF NOT EXISTS idx_inventory_transactions_created_at ON inventory_transactions(created_at);
CREATE INDEX IF NOT EXISTS idx_product_stock_product_id ON product_stock(product_id);
CREATE INDEX IF NOT EXISTS idx_purchase_order_items_order_id ON purchase_order_items(purchase_order_id);
CREATE INDEX IF NOT EXISTS idx_sales_order_items_order_id ON sales_order_items(sales_order_id);
CREATE INDEX IF NOT EXISTS idx_notifications_user_id ON notifications(user_id);
CREATE INDEX IF NOT EXISTS idx_notifications_is_read ON notifications(is_read);

-- Add triggers to update stock levels automatically
CREATE OR REPLACE FUNCTION update_product_stock()
RETURNS TRIGGER AS $$
BEGIN
    -- Update stock levels when inventory transactions are added
    INSERT INTO product_stock (product_id, current_stock, organization_id)
    VALUES (NEW.product_id, 
            CASE 
                WHEN NEW.transaction_type IN ('in', 'adjustment') THEN NEW.quantity
                WHEN NEW.transaction_type = 'out' THEN -NEW.quantity
                ELSE 0
            END,
            NEW.organization_id)
    ON CONFLICT (product_id, organization_id) 
    DO UPDATE SET 
        current_stock = product_stock.current_stock + 
            CASE 
                WHEN NEW.transaction_type IN ('in', 'adjustment') THEN NEW.quantity
                WHEN NEW.transaction_type = 'out' THEN -NEW.quantity
                ELSE 0
            END,
        last_updated = CURRENT_TIMESTAMP;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create trigger
DROP TRIGGER IF EXISTS trigger_update_product_stock ON inventory_transactions;
CREATE TRIGGER trigger_update_product_stock
    AFTER INSERT ON inventory_transactions
    FOR EACH ROW
    EXECUTE FUNCTION update_product_stock();
