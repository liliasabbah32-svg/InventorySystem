-- Inserting sample data for testing
-- Insert sample users
INSERT INTO users (username, full_name, email, password_hash, role, department, permissions) VALUES
('admin', 'المدير العام', 'admin@company.com', '$2b$10$hash', 'مدير النظام', 'الإدارة', '{"جميع الصلاحيات"}'),
('sales', 'مدير المبيعات', 'sales@company.com', '$2b$10$hash', 'مدير المبيعات', 'المبيعات', '{"المبيعات", "التقارير", "الزبائن", "الأصناف"}'),
('accountant', 'المحاسب الرئيسي', 'accountant@company.com', '$2b$10$hash', 'محاسب', 'المحاسبة', '{"المحاسبة", "التقارير المالية", "أسعار الصرف"}')
ON CONFLICT (username) DO NOTHING;

-- Insert sample cities
INSERT INTO cities (name) VALUES
('نابلس'), ('رام الله'), ('القدس'), ('الخليل'), ('جنين'), ('طولكرم'), ('قلقيلية'), ('سلفيت')
ON CONFLICT DO NOTHING;

-- Insert sample product categories
INSERT INTO product_categories (name, description) VALUES
('إلكترونيات', 'أجهزة إلكترونية ومعدات تقنية'),
('مكتبية', 'لوازم مكتبية وقرطاسية'),
('أثاث', 'أثاث مكتبي ومنزلي')
ON CONFLICT DO NOTHING;

-- Insert sample warehouses
INSERT INTO warehouses (name, location, manager) VALUES
('المستودع الرئيسي', 'نابلس - المنطقة الصناعية', 'أحمد المخازن'),
('مستودع الفرع الثاني', 'رام الله - البيرة', 'محمد المخازن')
ON CONFLICT DO NOTHING;

-- Insert sample customers
INSERT INTO customers (customer_code, name, mobile1, mobile2, whatsapp1, whatsapp2, city, address, email, business_nature, salesman, classification, transaction_notes, general_notes, web_username, api_key) VALUES
('C001', 'أحمد محمد علي', '0599123456', '0597111222', '0599123456', '0597111222', 'نابلس', 'وسط البلد - شارع فيصل', 'ahmed@example.com', 'تجارة عامة', 'محمد أحمد', 'فئة أ', 'زبون مميز - دفع نقدي', 'زبون قديم وموثوق', 'ahmed_ali', 'API_C001_2023'),
('C002', 'فاطمة حسن محمود', '0597654321', '0599888999', '0597654321', '', 'رام الله', 'البيرة - حي الريحان', 'fatima@example.com', 'مطعم شعبي', 'علي حسن', 'فئة ب', 'طلبات أسبوعية منتظمة', 'تفضل التوصيل صباحاً', '', 'API_C002_2023')
ON CONFLICT (customer_code) DO NOTHING;

-- Insert sample suppliers
INSERT INTO suppliers (supplier_code, name, phone1, phone2, whatsapp1, whatsapp2, city, address, email, activity, representative, classification, transaction_notes, general_notes, username, api_key) VALUES
('S001', 'شركة الإمداد للتجارة', '0599888777', '0567123456', '0599888777', '', 'رام الله', 'شارع الإرسال، مجمع النور التجاري', 'supply@company.com', 'تجارة جملة', 'محمد أحمد', 'مورد رئيسي', 'يفضل التعامل نقداً', 'مورد موثوق ومواعيد تسليم ممتازة', 'supply_user', 'API_SUP_001_XYZ789'),
('S002', 'مؤسسة التوريد المتقدم', '0567123456', '0599987654', '0567123456', '0599987654', 'نابلس', 'المنطقة الصناعية، مبنى رقم 15', 'advanced@supply.com', 'استيراد وتصدير', 'علي حسن', 'مورد ثانوي', 'يتطلب دفعة مقدمة 30%', 'متخصص في المواد الإلكترونية', 'advanced_supply', 'API_SUP_002_ABC123')
ON CONFLICT (supplier_code) DO NOTHING;

-- Insert sample exchange rates
INSERT INTO exchange_rates (currency_code, currency_name, buy_rate, sell_rate, exchange_rate) VALUES
('ILS', 'الشيكل الإسرائيلي', 1.0000, 1.0000, 1.0000),
('USD', 'الدولار الأمريكي', 3.6500, 3.7000, 3.6750),
('EUR', 'اليورو', 4.0000, 4.0500, 4.0250),
('JOD', 'الدينار الأردني', 5.1500, 5.2000, 5.1750)
ON CONFLICT DO NOTHING;
