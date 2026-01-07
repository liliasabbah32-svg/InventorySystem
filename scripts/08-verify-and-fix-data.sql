-- Verify current data in tables
SELECT 'user_settings' as table_name, COUNT(*) as record_count FROM user_settings
UNION ALL
SELECT 'customers' as table_name, COUNT(*) as record_count FROM customers
UNION ALL
SELECT 'suppliers' as table_name, COUNT(*) as record_count FROM suppliers
UNION ALL
SELECT 'products' as table_name, COUNT(*) as record_count FROM products
UNION ALL
SELECT 'sales_orders' as table_name, COUNT(*) as record_count FROM sales_orders
UNION ALL
SELECT 'purchase_orders' as table_name, COUNT(*) as record_count FROM purchase_orders;

-- Insert test users if they don't exist
INSERT INTO user_settings (
  user_id, organization_id, username, email, full_name, role, 
  department, phone, password_hash, language, timezone, 
  date_format, time_format, notifications_enabled, 
  email_notifications, sms_notifications, theme_preference, 
  sidebar_collapsed, dashboard_layout, permissions, is_active
) VALUES 
  ('U001', 1, 'admin', 'admin@company.com', 'المدير العام', 'مدير النظام', 
   'الإدارة', '+966501234567', 'YWRtaW4xMjM=', 'ar', 'Asia/Riyadh', 
   'DD/MM/YYYY', '24h', true, true, false, 'light', false, '{}', 
   '{"all_permissions": true}', true),
  ('U002', 1, 'sales', 'sales@company.com', 'مدير المبيعات', 'مدير المبيعات', 
   'المبيعات', '+966501234568', 'c2FsZXMxMjM=', 'ar', 'Asia/Riyadh', 
   'DD/MM/YYYY', '24h', true, true, false, 'light', false, '{}', 
   '{"sales": true, "customers": true, "products": true}', true),
  ('U003', 1, 'accountant', 'accountant@company.com', 'المحاسب الرئيسي', 'محاسب', 
   'المحاسبة', '+966501234569', 'YWNjMTIz', 'ar', 'Asia/Riyadh', 
   'DD/MM/YYYY', '24h', true, true, false, 'light', false, '{}', 
   '{"accounting": true, "reports": true}', true),
  ('U004', 1, 'Zaid Salous', 'zaid.salous@gmail.com', 'زيد سلعوس', 'مدير النظام', 
   'الإدارة', '+966501234570', 'WlhjMDU5NTU3MDIy', 'ar', 'Asia/Riyadh', 
   'DD/MM/YYYY', '24h', true, true, false, 'light', false, '{}', 
   '{"all_permissions": true}', true),
  ('U005', 1, 'employee1', 'employee1@company.com', 'أحمد محمد', 'موظف', 
   'المبيعات', '+966501234571', 'ZW1wMTIz', 'ar', 'Asia/Riyadh', 
   'DD/MM/YYYY', '24h', true, true, false, 'light', false, '{}', 
   '{"customers": {"view": true}, "products": {"view": true}}', true)
ON CONFLICT (user_id) DO UPDATE SET
  username = EXCLUDED.username,
  email = EXCLUDED.email,
  full_name = EXCLUDED.full_name,
  updated_at = CURRENT_TIMESTAMP;

-- Update last_login for existing users to show recent activity
UPDATE user_settings 
SET last_login = CURRENT_TIMESTAMP - INTERVAL '5 minutes'
WHERE user_id = 'U001';

UPDATE user_settings 
SET last_login = CURRENT_TIMESTAMP - INTERVAL '2 hours'
WHERE user_id = 'U002';

UPDATE user_settings 
SET last_login = CURRENT_TIMESTAMP - INTERVAL '1 day'
WHERE user_id = 'U003';

UPDATE user_settings 
SET last_login = CURRENT_TIMESTAMP - INTERVAL '30 minutes'
WHERE user_id = 'U004';

UPDATE user_settings 
SET last_login = CURRENT_TIMESTAMP - INTERVAL '3 days'
WHERE user_id = 'U005';
