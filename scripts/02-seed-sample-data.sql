-- Seed sample data for testing the inventory ordering system

-- Insert sample item groups
INSERT INTO item_groups (group_code, group_name, description, is_active, organization_id) VALUES
('ELEC', 'Electronics', 'Electronic devices and components', true, 1),
('FURN', 'Furniture', 'Office and home furniture', true, 1),
('STAT', 'Stationery', 'Office supplies and stationery', true, 1),
('COMP', 'Computers', 'Computer hardware and accessories', true, 1)
ON CONFLICT DO NOTHING;

-- Insert sample products with enhanced data
INSERT INTO products (product_code, product_name, description, category, main_unit, secondary_unit, 
                     conversion_factor, last_purchase_price, currency, status, product_type, 
                     barcode, max_quantity, order_quantity, has_batch, has_expiry, has_colors, entry_date) VALUES
('LAPTOP001', 'Dell Latitude 5520', 'Business laptop with Intel i7 processor', 'COMP', 'piece', 'box', 1, 1200.00, 'USD', 'active', 'finished', '1234567890123', 100, 10, false, false, false, CURRENT_DATE),
('CHAIR001', 'Ergonomic Office Chair', 'Adjustable office chair with lumbar support', 'FURN', 'piece', 'set', 1, 250.00, 'USD', 'active', 'finished', '1234567890124', 50, 5, false, false, true, CURRENT_DATE),
('PEN001', 'Blue Ballpoint Pen', 'Standard blue ink ballpoint pen', 'STAT', 'piece', 'box', 12, 0.50, 'USD', 'active', 'finished', '1234567890125', 1000, 100, true, false, false, CURRENT_DATE),
('MOUSE001', 'Wireless Mouse', 'Bluetooth wireless mouse', 'COMP', 'piece', 'box', 1, 25.00, 'USD', 'active', 'finished', '1234567890126', 200, 20, false, false, true, CURRENT_DATE),
('DESK001', 'Standing Desk', 'Height adjustable standing desk', 'FURN', 'piece', 'set', 1, 450.00, 'USD', 'active', 'finished', '1234567890127', 30, 3, false, false, false, CURRENT_DATE)
ON CONFLICT (product_code) DO NOTHING;

-- Insert initial stock levels
INSERT INTO product_stock (product_id, current_stock, reorder_level, max_stock_level, organization_id)
SELECT p.id, 
       CASE 
           WHEN p.product_code = 'LAPTOP001' THEN 25
           WHEN p.product_code = 'CHAIR001' THEN 15
           WHEN p.product_code = 'PEN001' THEN 500
           WHEN p.product_code = 'MOUSE001' THEN 75
           WHEN p.product_code = 'DESK001' THEN 8
       END as current_stock,
       CASE 
           WHEN p.product_code = 'LAPTOP001' THEN 10
           WHEN p.product_code = 'CHAIR001' THEN 5
           WHEN p.product_code = 'PEN001' THEN 100
           WHEN p.product_code = 'MOUSE001' THEN 20
           WHEN p.product_code = 'DESK001' THEN 3
       END as reorder_level,
       p.max_quantity,
       1 as organization_id
FROM products p
WHERE p.product_code IN ('LAPTOP001', 'CHAIR001', 'PEN001', 'MOUSE001', 'DESK001')
ON CONFLICT (product_id, organization_id) DO NOTHING;

-- Insert sample customers
INSERT INTO customers (customer_code, customer_name, email, mobile1, address, city, status, 
                      business_nature, account_opening_date, salesman) VALUES
('CUST001', 'Tech Solutions LLC', 'contact@techsolutions.com', '+1234567890', '123 Business St', 'New York', 'active', 'Technology', CURRENT_DATE, 'John Smith'),
('CUST002', 'Office Supplies Co', 'orders@officesupplies.com', '+1234567891', '456 Commerce Ave', 'Los Angeles', 'active', 'Retail', CURRENT_DATE, 'Jane Doe'),
('CUST003', 'Modern Workspace Inc', 'info@modernworkspace.com', '+1234567892', '789 Corporate Blvd', 'Chicago', 'active', 'Furniture', CURRENT_DATE, 'Mike Johnson')
ON CONFLICT (customer_code) DO NOTHING;

-- Insert sample suppliers
INSERT INTO suppliers (supplier_code, supplier_name, email, mobile1, address, city, status, 
                      business_nature, account_opening_date, salesman) VALUES
('SUPP001', 'Dell Technologies', 'orders@dell.com', '+1800DELL123', '1 Dell Way', 'Round Rock', 'active', 'Technology', CURRENT_DATE, 'Dell Sales Team'),
('SUPP002', 'Herman Miller', 'sales@hermanmiller.com', '+1800HERMAN1', '855 E Main Ave', 'Zeeland', 'active', 'Furniture', CURRENT_DATE, 'HM Sales'),
('SUPP003', 'Staples Business', 'business@staples.com', '+1800STAPLES', '500 Staples Dr', 'Framingham', 'active', 'Office Supplies', CURRENT_DATE, 'Staples Team')
ON CONFLICT (supplier_code) DO NOTHING;

-- Insert sample exchange rates
INSERT INTO exchange_rates (currency_code, currency_name, exchange_rate, buy_rate, sell_rate, organization_id) VALUES
('USD', 'US Dollar', 1.00, 1.00, 1.00, 1),
('EUR', 'Euro', 0.85, 0.84, 0.86, 1),
('GBP', 'British Pound', 0.73, 0.72, 0.74, 1),
('SAR', 'Saudi Riyal', 3.75, 3.74, 3.76, 1)
ON CONFLICT (currency_code, organization_id) DO NOTHING;

-- Insert system settings
INSERT INTO system_settings (
    organization_id, company_name, company_name_en, company_email, company_phone,
    company_address, company_website, default_currency, language, timezone,
    date_format, time_format, auto_numbering, order_prefix, invoice_prefix,
    purchase_prefix, fiscal_year_start, audit_log, two_factor_auth,
    session_timeout, password_policy, working_days, working_hours
) VALUES (
    1, 'شركة إدارة المخزون', 'Inventory Management Co.', 'info@inventory.com', '+966123456789',
    'الرياض، المملكة العربية السعودية', 'www.inventory.com', 'SAR', 'ar', 'Asia/Riyadh',
    'DD/MM/YYYY', '24H', true, 'SO-', 'INV-', 'PO-', '2024-01-01', true, false,
    30, 'medium', '["Sunday","Monday","Tuesday","Wednesday","Thursday"]', '08:00-17:00'
) ON CONFLICT (organization_id) DO NOTHING;
