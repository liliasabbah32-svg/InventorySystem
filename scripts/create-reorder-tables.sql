-- Create reorder_rules table for automated reorder system
CREATE TABLE IF NOT EXISTS reorder_rules (
    id SERIAL PRIMARY KEY,
    product_id INTEGER NOT NULL REFERENCES products(id) ON DELETE CASCADE,
    reorder_point INTEGER NOT NULL DEFAULT 0,
    reorder_quantity INTEGER NOT NULL DEFAULT 0,
    supplier_id INTEGER REFERENCES suppliers(id) ON DELETE SET NULL,
    is_active BOOLEAN DEFAULT true,
    auto_create_po BOOLEAN DEFAULT false,
    notification_enabled BOOLEAN DEFAULT true,
    last_triggered TIMESTAMP WITH TIME ZONE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(product_id)
);

-- Create index for better performance
CREATE INDEX IF NOT EXISTS idx_reorder_rules_product_id ON reorder_rules(product_id);
CREATE INDEX IF NOT EXISTS idx_reorder_rules_active ON reorder_rules(is_active);

-- Add reorder system settings to general_settings if not exists
INSERT INTO general_settings (setting_key, setting_value, category, description, created_at, updated_at)
VALUES 
    ('enabled', 'false', 'reorder_system', 'Enable/disable automated reorder system', NOW(), NOW()),
    ('check_frequency_hours', '24', 'reorder_system', 'How often to check for reorders (in hours)', NOW(), NOW()),
    ('auto_create_purchase_orders', 'false', 'reorder_system', 'Automatically create purchase orders', NOW(), NOW()),
    ('notification_email', '', 'reorder_system', 'Email address for reorder notifications', NOW(), NOW()),
    ('notification_sms', 'false', 'reorder_system', 'Enable SMS notifications', NOW(), NOW()),
    ('minimum_order_value', '1000', 'reorder_system', 'Minimum order value for automatic orders', NOW(), NOW()),
    ('default_reorder_multiplier', '2', 'reorder_system', 'Default multiplier for reorder quantities', NOW(), NOW())
ON CONFLICT (setting_key, category) DO NOTHING;

-- Update products table to ensure reorder fields exist
ALTER TABLE products 
ADD COLUMN IF NOT EXISTS min_stock_level INTEGER DEFAULT 0,
ADD COLUMN IF NOT EXISTS max_stock_level INTEGER DEFAULT 0,
ADD COLUMN IF NOT EXISTS reorder_point INTEGER DEFAULT 0;

-- Update product_stock table to ensure reorder fields exist  
ALTER TABLE product_stock
ADD COLUMN IF NOT EXISTS reorder_level INTEGER DEFAULT 0,
ADD COLUMN IF NOT EXISTS max_stock_level INTEGER DEFAULT 0;

-- Create a view for easy reorder monitoring
CREATE OR REPLACE VIEW reorder_monitoring AS
SELECT 
    p.id as product_id,
    p.product_code,
    p.product_name,
    p.status,
    COALESCE(ps.current_stock, 0) as current_stock,
    COALESCE(ps.reorder_level, p.reorder_point, p.min_stock_level, 0) as reorder_point,
    COALESCE(ps.max_stock_level, p.max_stock_level, 0) as max_stock_level,
    p.last_purchase_price,
    s.id as supplier_id,
    s.supplier_name,
    rr.id as rule_id,
    rr.is_active as rule_active,
    rr.auto_create_po,
    rr.notification_enabled,
    rr.last_triggered,
    CASE 
        WHEN COALESCE(ps.current_stock, 0) = 0 THEN 'out_of_stock'
        WHEN COALESCE(ps.current_stock, 0) <= COALESCE(ps.reorder_level, p.reorder_point, p.min_stock_level, 0) THEN 'low_stock'
        ELSE 'normal'
    END as stock_status
FROM products p
LEFT JOIN product_stock ps ON p.id = ps.product_id
LEFT JOIN suppliers s ON p.supplier_id = s.id
LEFT JOIN reorder_rules rr ON p.id = rr.product_id
WHERE p.status = 'نشط';
