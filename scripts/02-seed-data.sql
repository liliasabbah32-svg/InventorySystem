-- بيانات تجريبية لنظام ERP
-- Sample Data for Arabic ERP System

-- إدراج بيانات المستخدمين
INSERT INTO users (username, email, password_hash, full_name, role) VALUES
('admin', 'admin@company.com', '$2b$10$hash', 'مدير النظام', 'admin'),
('manager', 'manager@company.com', '$2b$10$hash', 'مدير المبيعات', 'manager'),
('user1', 'user1@company.com', '$2b$10$hash', 'موظف المبيعات', 'user')
ON CONFLICT (username) DO NOTHING;

-- إدراج فئات المنتجات
INSERT INTO product_categories (name, description) VALUES
('إلكترونيات', 'الأجهزة الإلكترونية والكهربائية'),
('أثاث', 'الأثاث المنزلي والمكتبي'),
('ملابس', 'الملابس والأزياء'),
('كتب', 'الكتب والمطبوعات'),
('رياضة', 'المعدات الرياضية')
ON CONFLICT DO NOTHING;

-- إدراج المستودعات
INSERT INTO warehouses (warehouse_code, name, location, manager_name, phone) VALUES
('WH001', 'المستودع الرئيسي', 'الرياض - حي الصناعية', 'أحمد محمد', '0501234567'),
('WH002', 'مستودع جدة', 'جدة - حي الفيصلية', 'محمد علي', '0509876543'),
('WH003', 'مستودع الدمام', 'الدمام - الحي التجاري', 'علي أحمد', '0505555555')
ON CONFLICT (warehouse_code) DO NOTHING;

-- إدراج العملاء
INSERT INTO customers (customer_code, name, contact_person, phone, email, address, city, country, credit_limit) VALUES
('CUST001', 'شركة التقنية المتقدمة', 'سالم الأحمد', '0501111111', 'salem@tech.com', 'شارع الملك فهد', 'الرياض', 'السعودية', 50000.00),
('CUST002', 'مؤسسة التجارة الحديثة', 'فهد المحمد', '0502222222', 'fahad@trade.com', 'شارع التحلية', 'جدة', 'السعودية', 75000.00),
('CUST003', 'شركة الخليج للمقاولات', 'عبدالله السالم', '0503333333', 'abdullah@gulf.com', 'شارع الظهران', 'الدمام', 'السعودية', 100000.00)
ON CONFLICT (customer_code) DO NOTHING;

-- إدراج الموردين
INSERT INTO suppliers (supplier_code, name, contact_person, phone, email, address, city, country) VALUES
('SUPP001', 'شركة الإمدادات الصناعية', 'خالد العتيبي', '0504444444', 'khalid@supply.com', 'المنطقة الصناعية الثانية', 'الرياض', 'السعودية'),
('SUPP002', 'مؤسسة الجودة للتوريد', 'ناصر القحطاني', '0505555555', 'nasser@quality.com', 'حي الفيصلية', 'جدة', 'السعودية'),
('SUPP003', 'شركة الشرق للتجارة', 'عمر البلوي', '0506666666', 'omar@east.com', 'الحي التجاري', 'الدمام', 'السعودية')
ON CONFLICT (supplier_code) DO NOTHING;

-- إدراج المنتجات
INSERT INTO products (product_code, name, description, category_id, unit_of_measure, cost_price, selling_price, min_stock_level, reorder_point) VALUES
('PROD001', 'لابتوب ديل XPS 13', 'لابتوب عالي الأداء للأعمال', 1, 'قطعة', 3500.00, 4200.00, 5, 10),
('PROD002', 'مكتب خشبي فاخر', 'مكتب خشبي بتصميم عصري', 2, 'قطعة', 800.00, 1200.00, 2, 5),
('PROD003', 'قميص قطني رجالي', 'قميص قطني عالي الجودة', 3, 'قطعة', 45.00, 85.00, 20, 50),
('PROD004', 'كتاب إدارة الأعمال', 'كتاب متخصص في إدارة الأعمال', 4, 'قطعة', 25.00, 45.00, 10, 25),
('PROD005', 'كرة قدم جلدية', 'كرة قدم احترافية', 5, 'قطعة', 35.00, 65.00, 15, 30)
ON CONFLICT (product_code) DO NOTHING;

-- إدراج مخزون المنتجات
INSERT INTO product_stock (product_id, warehouse_id, quantity_on_hand) VALUES
(1, 1, 25), (1, 2, 15), (1, 3, 10),
(2, 1, 8), (2, 2, 5), (2, 3, 3),
(3, 1, 100), (3, 2, 75), (3, 3, 50),
(4, 1, 40), (4, 2, 30), (4, 3, 20),
(5, 1, 60), (5, 2, 45), (5, 3, 35)
ON CONFLICT (product_id, warehouse_id) DO NOTHING;
