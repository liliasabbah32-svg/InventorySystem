-- Create the missing product_warehouses table
CREATE TABLE IF NOT EXISTS product_warehouses (
  id SERIAL PRIMARY KEY,
  product_id INTEGER REFERENCES products(id) ON DELETE CASCADE,
  warehouse_id INTEGER REFERENCES warehouses(id) ON DELETE CASCADE,
  floor VARCHAR(50),
  area VARCHAR(50),
  shelf VARCHAR(50),
  quantity NUMERIC(15,3) DEFAULT 0,
  reserved_quantity NUMERIC(15,3) DEFAULT 0,
  min_stock_level NUMERIC(15,3) DEFAULT 0,
  max_stock_level NUMERIC(15,3) DEFAULT 0,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
  UNIQUE(product_id, warehouse_id)
);

-- Create indexes for better performance
CREATE INDEX IF NOT EXISTS idx_product_warehouses_product_id ON product_warehouses(product_id);
CREATE INDEX IF NOT EXISTS idx_product_warehouses_warehouse_id ON product_warehouses(warehouse_id);

-- Add trigger for updated_at
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER update_product_warehouses_updated_at 
    BEFORE UPDATE ON product_warehouses 
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Insert default warehouse locations for existing products
-- First, ensure we have at least one warehouse
INSERT INTO warehouses (warehouse_name, warehouse_code, location, is_active) 
VALUES ('المستودع الرئيسي', 'MAIN', 'الموقع الرئيسي', true)
ON CONFLICT (warehouse_code) DO NOTHING;

-- Get the main warehouse ID
DO $$
DECLARE
    main_warehouse_id INTEGER;
BEGIN
    SELECT id INTO main_warehouse_id FROM warehouses WHERE warehouse_code = 'MAIN' LIMIT 1;
    
    -- If no main warehouse exists, create one
    IF main_warehouse_id IS NULL THEN
        INSERT INTO warehouses (warehouse_name, warehouse_code, location, is_active) 
        VALUES ('المستودع الرئيسي', 'MAIN', 'الموقع الرئيسي', true)
        RETURNING id INTO main_warehouse_id;
    END IF;
    
    -- Insert product warehouse records for all existing products
    INSERT INTO product_warehouses (product_id, warehouse_id, quantity, reserved_quantity, min_stock_level, max_stock_level)
    SELECT 
        p.id,
        main_warehouse_id,
        COALESCE(ps.current_stock, 0),
        COALESCE(ps.reserved_stock, 0),
        COALESCE(ps.reorder_level, 0),
        COALESCE(ps.max_stock_level, 0)
    FROM products p
    LEFT JOIN product_stock ps ON p.id = ps.product_id
    WHERE NOT EXISTS (
        SELECT 1 FROM product_warehouses pw 
        WHERE pw.product_id = p.id AND pw.warehouse_id = main_warehouse_id
    );
END $$;

-- Create a view for easy warehouse inventory reporting
CREATE OR REPLACE VIEW warehouse_inventory_summary AS
SELECT 
    w.id as warehouse_id,
    w.warehouse_name,
    w.warehouse_code,
    w.location,
    COUNT(pw.product_id) as total_products,
    SUM(pw.quantity) as total_quantity,
    SUM(pw.reserved_quantity) as total_reserved,
    SUM(pw.quantity - pw.reserved_quantity) as total_available,
    COUNT(CASE WHEN pw.quantity <= pw.min_stock_level THEN 1 END) as low_stock_products,
    COUNT(CASE WHEN pw.quantity = 0 THEN 1 END) as out_of_stock_products
FROM warehouses w
LEFT JOIN product_warehouses pw ON w.id = pw.warehouse_id
WHERE w.is_active = true
GROUP BY w.id, w.warehouse_name, w.warehouse_code, w.location;
