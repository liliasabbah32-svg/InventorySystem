-- إدراج بيانات تجريبية للنظام
-- إدراج الزبائن
INSERT INTO customers (customer_name, customer_code, email, mobile1, city, address, status, account_opening_date, created_at) VALUES
('شركة الأمل للتجارة', 'CUST001', 'info@alamal.com', '966501234567', 'الرياض', 'شارع الملك فهد، الرياض', 'نشط', '2024-01-15', NOW()),
('مؤسسة النور التجارية', 'CUST002', 'contact@alnoor.com', '966502345678', 'جدة', 'طريق الملك عبدالعزيز، جدة', 'نشط', '2024-01-20', NOW()),
('شركة الفجر للمقاولات', 'CUST003', 'info@alfajr.com', '966503456789', 'الدمام', 'شارع الأمير محمد بن فهد، الدمام', 'نشط', '2024-02-01', NOW()),
('مجموعة الخليج التجارية', 'CUST004', 'sales@gulf-group.com', '966504567890', 'الرياض', 'حي العليا، الرياض', 'نشط', '2024-02-10', NOW()),
('شركة الصحراء للتوريدات', 'CUST005', 'orders@sahara.com', '966505678901', 'مكة', 'شارع إبراهيم الخليل، مكة', 'نشط', '2024-02-15', NOW());

-- إدراج الموردين
INSERT INTO suppliers (supplier_name, supplier_code, email, mobile1, city, address, status, account_opening_date, created_at) VALUES
('شركة التقنية المتقدمة', 'SUPP001', 'info@advanced-tech.com', '966511234567', 'الرياض', 'مدينة الملك عبدالعزيز للعلوم والتقنية', 'نشط', '2024-01-10', NOW()),
('مؤسسة الجودة للاستيراد', 'SUPP002', 'import@quality.com', '966512345678', 'جدة', 'ميناء جدة الإسلامي', 'نشط', '2024-01-12', NOW()),
('شركة الإبداع للتصنيع', 'SUPP003', 'factory@ibdaa.com', '966513456789', 'الدمام', 'المدينة الصناعية الثانية', 'نشط', '2024-01-18', NOW()),
('مجموعة الشرق الأوسط', 'SUPP004', 'me@middle-east.com', '966514567890', 'الرياض', 'طريق الملك خالد', 'نشط', '2024-01-25', NOW()),
('شركة الخبرة التجارية', 'SUPP005', 'trade@khibra.com', '966515678901', 'جدة', 'شارع فلسطين', 'نشط', '2024-02-05', NOW());

-- إدراج مجموعات الأصناف
INSERT INTO item_groups (group_name, group_number, description, is_active, organization_id, created_at, updated_at) VALUES
('الإلكترونيات', 'GRP001', 'أجهزة إلكترونية ومعدات تقنية', true, 1, NOW(), NOW()),
('المواد الغذائية', 'GRP002', 'منتجات غذائية ومشروبات', true, 1, NOW(), NOW()),
('الملابس والأزياء', 'GRP003', 'ملابس رجالية ونسائية وأطفال', true, 1, NOW(), NOW()),
('مواد البناء', 'GRP004', 'أسمنت وحديد ومواد إنشائية', true, 1, NOW(), NOW()),
('الأثاث والديكور', 'GRP005', 'أثاث منزلي ومكتبي وديكورات', true, 1, NOW(), NOW());

-- إدراج المنتجات
INSERT INTO products (product_name, product_code, barcode, description, category, status, main_unit, last_purchase_price, currency, created_at, entry_date) VALUES
('لابتوب ديل XPS 13', 'PROD001', '1234567890123', 'لابتوب عالي الأداء للأعمال', 'الإلكترونيات', 'نشط', 'قطعة', 4500.00, 'SAR', NOW(), '2024-01-15'),
('هاتف آيفون 15', 'PROD002', '1234567890124', 'هاتف ذكي من آبل', 'الإلكترونيات', 'نشط', 'قطعة', 3800.00, 'SAR', NOW(), '2024-01-16'),
('أرز بسمتي فاخر', 'PROD003', '1234567890125', 'أرز بسمتي درجة أولى', 'المواد الغذائية', 'نشط', 'كيس', 25.00, 'SAR', NOW(), '2024-01-17'),
('قميص قطني رجالي', 'PROD004', '1234567890126', 'قميص قطني عالي الجودة', 'الملابس والأزياء', 'نشط', 'قطعة', 120.00, 'SAR', NOW(), '2024-01-18'),
('أسمنت بورتلاندي', 'PROD005', '1234567890127', 'أسمنت للبناء والإنشاءات', 'مواد البناء', 'نشط', 'كيس', 18.50, 'SAR', NOW(), '2024-01-19'),
('كرسي مكتبي دوار', 'PROD006', '1234567890128', 'كرسي مكتبي مريح وقابل للتعديل', 'الأثاث والديكور', 'نشط', 'قطعة', 450.00, 'SAR', NOW(), '2024-01-20'),
('تلفزيون سامسونج 55 بوصة', 'PROD007', '1234567890129', 'تلفزيون ذكي 4K', 'الإلكترونيات', 'نشط', 'قطعة', 2200.00, 'SAR', NOW(), '2024-01-21'),
('زيت زيتون إيطالي', 'PROD008', '1234567890130', 'زيت زيتون بكر ممتاز', 'المواد الغذائية', 'نشط', 'زجاجة', 45.00, 'SAR', NOW(), '2024-01-22');

-- إدراج المخزون
INSERT INTO product_stock (product_id, current_stock, available_stock, reserved_stock, reorder_level, max_stock_level, organization_id, created_at, updated_at, last_updated) VALUES
(1, 50, 45, 5, 10, 100, 1, NOW(), NOW(), NOW()),
(2, 30, 28, 2, 5, 50, 1, NOW(), NOW(), NOW()),
(3, 200, 180, 20, 50, 500, 1, NOW(), NOW(), NOW()),
(4, 75, 70, 5, 20, 150, 1, NOW(), NOW(), NOW()),
(5, 500, 480, 20, 100, 1000, 1, NOW(), NOW(), NOW()),
(6, 25, 23, 2, 5, 50, 1, NOW(), NOW(), NOW()),
(7, 15, 12, 3, 3, 30, 1, NOW(), NOW(), NOW()),
(8, 100, 95, 5, 25, 200, 1, NOW(), NOW(), NOW());

-- إدراج طلبيات المبيعات
INSERT INTO sales_orders (order_number, customer_id, customer_name, order_date, total_amount, currency_code, currency_name, exchange_rate, order_status, financial_status, salesman, notes, created_at, updated_at) VALUES
('SO-2024-001', 1, 'شركة الأمل للتجارة', '2024-03-01', 9500.00, 'SAR', 'ريال سعودي', 1.00, 'مؤكد', 'مدفوع جزئياً', 'أحمد محمد', 'طلبية عاجلة للتسليم', NOW(), NOW()),
('SO-2024-002', 2, 'مؤسسة النور التجارية', '2024-03-02', 7600.00, 'SAR', 'ريال سعودي', 1.00, 'قيد المعالجة', 'غير مدفوع', 'سارة أحمد', 'طلبية شهرية اعتيادية', NOW(), NOW()),
('SO-2024-003', 3, 'شركة الفجر للمقاولات', '2024-03-03', 15000.00, 'SAR', 'ريال سعودي', 1.00, 'مؤكد', 'مدفوع', 'محمد علي', 'طلبية مواد بناء', NOW(), NOW()),
('SO-2024-004', 4, 'مجموعة الخليج التجارية', '2024-03-04', 3200.00, 'SAR', 'ريال سعودي', 1.00, 'ملغي', 'غير مدفوع', 'فاطمة خالد', 'تم إلغاء الطلبية بناء على طلب العميل', NOW(), NOW()),
('SO-2024-005', 5, 'شركة الصحراء للتوريدات', '2024-03-05', 5400.00, 'SAR', 'ريال سعودي', 1.00, 'مؤكد', 'مدفوع', 'عبدالله سعد', 'طلبية أسبوعية', NOW(), NOW());

-- إدراج عناصر طلبيات المبيعات
INSERT INTO sales_order_items (sales_order_id, product_id, product_name, product_code, quantity, unit_price, total_price, unit, notes, created_at) VALUES
(1, 1, 'لابتوب ديل XPS 13', 'PROD001', 2, 4500.00, 9000.00, 'قطعة', 'مع ضمان سنتين', NOW()),
(1, 4, 'قميص قطني رجالي', 'PROD004', 4, 125.00, 500.00, 'قطعة', 'مقاسات متنوعة', NOW()),
(2, 2, 'هاتف آيفون 15', 'PROD002', 2, 3800.00, 7600.00, 'قطعة', 'ألوان متنوعة', NOW()),
(3, 5, 'أسمنت بورتلاندي', 'PROD005', 500, 18.50, 9250.00, 'كيس', 'تسليم على دفعات', NOW()),
(3, 6, 'كرسي مكتبي دوار', 'PROD006', 12, 450.00, 5400.00, 'قطعة', 'للمكاتب الإدارية', NOW()),
(5, 7, 'تلفزيون سامسونج 55 بوصة', 'PROD007', 2, 2200.00, 4400.00, 'قطعة', 'مع التركيب', NOW()),
(5, 8, 'زيت زيتون إيطالي', 'PROD008', 20, 45.00, 900.00, 'زجاجة', 'تاريخ انتهاء طويل', NOW());

-- إدراج طلبيات الشراء
INSERT INTO purchase_orders (order_number, supplier_id, supplier_name, order_date, total_amount, currency_code, currency_name, exchange_rate, workflow_status, salesman, notes, expected_delivery_date, created_at, updated_at) VALUES
('PO-2024-001', 1, 'شركة التقنية المتقدمة', '2024-02-28', 22500.00, 'SAR', 'ريال سعودي', 1.00, 'مؤكد', 'خالد أحمد', 'طلبية شهرية للأجهزة', '2024-03-15', NOW(), NOW()),
('PO-2024-002', 2, 'مؤسسة الجودة للاستيراد', '2024-03-01', 1800.00, 'SAR', 'ريال سعودي', 1.00, 'قيد المراجعة', 'نورا سعد', 'طلبية مواد غذائية', '2024-03-20', NOW(), NOW()),
('PO-2024-003', 3, 'شركة الإبداع للتصنيع', '2024-03-02', 6000.00, 'SAR', 'ريال سعودي', 1.00, 'مؤكد', 'عمر محمد', 'طلبية ملابس', '2024-03-25', NOW(), NOW());

-- إدراج عناصر طلبيات الشراء
INSERT INTO purchase_order_items (purchase_order_id, product_id, product_name, product_code, quantity, unit_price, total_price, unit, notes, created_at) VALUES
(1, 1, 'لابتوب ديل XPS 13', 'PROD001', 5, 4500.00, 22500.00, 'قطعة', 'للمخزون', NOW()),
(2, 3, 'أرز بسمتي فاخر', 'PROD003', 72, 25.00, 1800.00, 'كيس', 'جودة عالية', NOW()),
(3, 4, 'قميص قطني رجالي', 'PROD004', 50, 120.00, 6000.00, 'قطعة', 'مقاسات متنوعة', NOW());

-- إدراج أسعار الصرف
INSERT INTO exchange_rates (currency_code, currency_name, exchange_rate, buy_rate, sell_rate, organization_id, last_updated) VALUES
('USD', 'دولار أمريكي', 3.75, 3.73, 3.77, 1, NOW()),
('EUR', 'يورو', 4.10, 4.08, 4.12, 1, NOW()),
('GBP', 'جنيه إسترليني', 4.75, 4.73, 4.77, 1, NOW()),
('AED', 'درهم إماراتي', 1.02, 1.01, 1.03, 1, NOW());

-- إدراج الإعدادات العامة
INSERT INTO general_settings (setting_key, setting_value, setting_type, category, description, organization_id, is_public, created_at, updated_at) VALUES
('company_name', 'شركة الإدارة المتكاملة', 'text', 'company', 'اسم الشركة', 1, true, NOW(), NOW()),
('company_phone', '+966112345678', 'text', 'company', 'هاتف الشركة', 1, true, NOW(), NOW()),
('company_email', 'info@company.com', 'email', 'company', 'بريد الشركة الإلكتروني', 1, true, NOW(), NOW()),
('default_currency', 'SAR', 'text', 'system', 'العملة الافتراضية', 1, false, NOW(), NOW()),
('tax_rate', '15', 'number', 'financial', 'معدل الضريبة المضافة', 1, false, NOW(), NOW());
