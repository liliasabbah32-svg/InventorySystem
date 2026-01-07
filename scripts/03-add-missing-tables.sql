-- Add missing tables that APIs expect but don't exist in current schema

-- Units table for product units
CREATE TABLE IF NOT EXISTS units (
  id SERIAL PRIMARY KEY,
  name VARCHAR(50) NOT NULL,
  name_en VARCHAR(50),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Insert default units
INSERT INTO units (name, name_en) VALUES 
('قطعة', 'piece'),
('كيلو', 'kg'),
('متر', 'meter'),
('لتر', 'liter'),
('علبة', 'box'),
('كرتون', 'carton'),
('متر مربع', 'sqm'),
('متر مكعب', 'cbm')
ON CONFLICT DO NOTHING;

-- Currencies table for proper currency management
CREATE TABLE IF NOT EXISTS currencies (
  id SERIAL PRIMARY KEY,
  code VARCHAR(10) NOT NULL UNIQUE,
  name VARCHAR(50) NOT NULL,
  symbol VARCHAR(10),
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Insert default currencies
INSERT INTO currencies (code, name, symbol) VALUES 
('ILS', 'شيكل إسرائيلي', '₪'),
('USD', 'دولار أمريكي', '$'),
('JOD', 'دينار أردني', 'د.أ'),
('EUR', 'يورو', '€')
ON CONFLICT (code) DO NOTHING;

-- Update products table to use proper foreign keys
ALTER TABLE products 
ADD COLUMN IF NOT EXISTS primary_unit_id INTEGER REFERENCES units(id),
ADD COLUMN IF NOT EXISTS secondary_unit_id INTEGER REFERENCES units(id),
ADD COLUMN IF NOT EXISTS currency_id INTEGER REFERENCES currencies(id);

-- Update sales_orders table to use proper foreign keys
ALTER TABLE sales_orders 
ADD COLUMN IF NOT EXISTS customer_id INTEGER REFERENCES customers(id),
ADD COLUMN IF NOT EXISTS currency_id INTEGER REFERENCES currencies(id),
ADD COLUMN IF NOT EXISTS salesman_id INTEGER;

-- Update purchase_orders table to use proper foreign keys
ALTER TABLE purchase_orders 
ADD COLUMN IF NOT EXISTS supplier_id INTEGER REFERENCES suppliers(id),
ADD COLUMN IF NOT EXISTS currency_id INTEGER REFERENCES currencies(id),
ADD COLUMN IF NOT EXISTS salesman_id INTEGER;

-- Create indexes for performance
CREATE INDEX IF NOT EXISTS idx_products_primary_unit ON products(primary_unit_id);
CREATE INDEX IF NOT EXISTS idx_products_secondary_unit ON products(secondary_unit_id);
CREATE INDEX IF NOT EXISTS idx_products_currency ON products(currency_id);
CREATE INDEX IF NOT EXISTS idx_sales_orders_customer ON sales_orders(customer_id);
CREATE INDEX IF NOT EXISTS idx_sales_orders_currency ON sales_orders(currency_id);
CREATE INDEX IF NOT EXISTS idx_purchase_orders_supplier ON purchase_orders(supplier_id);
CREATE INDEX IF NOT EXISTS idx_purchase_orders_currency ON purchase_orders(currency_id);
