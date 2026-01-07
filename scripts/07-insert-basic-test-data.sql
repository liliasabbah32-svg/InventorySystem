-- إدخال بيانات تجريبية أساسية للنظام

-- إدخال العملاء
INSERT INTO customers (customer_name, customer_code, email, mobile1, city, address, status, account_opening_date, created_at) VALUES
('شركة الأمل للتجارة', 'CUST001', 'amal@example.com', '966501234567', 'الرياض', 'شارع الملك فهد، الرياض', 'نشط', '2024-01-15', NOW()),
('مؤسسة النور التجارية', 'CUST002', 'noor@example.com', '966502345678', 'جدة', 'شارع التحلية، جدة', 'نشط', '2024-01-20', NOW()),
('شركة الفجر للمقاولات', 'CUST003', 'fajar@example.com', '966503456789', 'الدمام', 'شارع الملك عبدالعزيز، الدمام', 'نشط', '2024-02-01', NOW()),
('مجموعة الشروق التجارية', 'CUST004', 'shorouk@example.com', '966504567890', 'مكة', 'شارع العزيزية، مكة', 'نشط', '2024-02-10', NOW()),
('شركة البدر للاستيراد', 'CUST005', 'badr@example.com', '966505678901', 'المدينة', 'شارع قباء، المدينة المنورة', 'نشط', '2024-02-15', NOW());

-- إدخال الموردين
INSERT INTO suppliers (supplier_name, supplier_code, email, mobile1, city, address, status, account_opening_date, created_at) VALUES
('شركة الإمداد الذهبي', 'SUPP001', 'golden@example.com', '966511234567', 'الرياض', 'المنطقة الصناعية، الرياض', 'نشط', '2024-01-10', NOW()),
('مؤسسة التوريد المتقدم', 'SUPP002', 'advanced@example.com', '966512345678', 'جدة', 'المنطقة الصناعية، جدة', 'نشط', '2024-01-18', NOW()),
('شركة المصادر الشاملة', 'SUPP003', 'masader@example.com', '966513456789', 'الدمام', 'المنطقة الصناعية، الدمام', 'نشط', '2024-01-25', NOW()),
('مجموعة الخدمات اللوجستية', 'SUPP004', 'logistics@example.com', '966514567890', 'الخبر', 'المنطقة الصناعية، الخبر', 'نشط', '2024-02-05', NOW()),
('شركة التجهيزات الحديثة', 'SUPP005', 'modern@example.com', '966515678901', 'القطيف', 'المنطقة الصناعية، القطيف', 'نشط', '2024-02-12', NOW());

-- إدخال مجموعات الأصناف
INSERT INTO item_groups (group_name, group_number, description, is_active, organization_id, created_at, updated_at) VALUES
('الإلكترونيات', 'GRP001', 'أجهزة إلكترونية ومعدات تقنية', true, 1, NOW(), NOW()),
('المكتبية', 'GRP002', 'لوازم ومعدات مكتبية', true, 1, NOW(), NOW()),
('المنزلية', 'GRP003', 'أدوات ومعدات منزلية', true, 1, NOW(), NOW()),
('الطبية', 'GRP004', 'معدات وأدوات طبية', true, 1, NOW(), NOW()),
('الصناعية', 'GRP005', 'معدات وأدوات صناعية', true, 1, NOW(), NOW());

-- إدخال المنتجات
INSERT INTO products (product_name, product_code, barcode, description, category, main_unit, product_type, status, entry_date, created_at) VALUES
('لابتوب ديل XPS 13', 'PROD001', '1234567890123', 'لابتوب عالي الأداء للأعمال', 'الإلكترونيات', 'قطعة', 'منتج', 'نشط', '2024-01-01', NOW()),
('طابعة HP LaserJet', 'PROD002', '1234567890124', 'طابعة ليزر عالية الجودة', 'المكتبية', 'قطعة', 'منتج', 'نشط', '2024-01-02', NOW()),
('كرسي مكتبي مريح', 'PROD003', '1234567890125', 'كرسي مكتبي بتصميم مريح', 'المكتبية', 'قطعة', 'منتج', 'نشط', '2024-01-03', NOW()),
('جهاز قياس الضغط', 'PROD004', '1234567890126', 'جهاز قياس ضغط الدم الرقمي', 'الطبية', 'قطعة', 'منتج', 'نشط', '2024-01-04', NOW()),
('مكيف هواء سبليت', 'PROD005', '1234567890127', 'مكيف هواء بقوة 18000 وحدة', 'المنزلية', 'قطعة', 'منتج', 'نشط', '2024-01-05', NOW()),
('ماوس لاسلكي', 'PROD006', '1234567890128', 'ماوس لاسلكي بتقنية البلوتوث', 'الإلكترونيات', 'قطعة', 'منتج', 'نشط', '2024-01-06', NOW()),
('لوحة مفاتيح ميكانيكية', 'PROD007', '1234567890129', 'لوحة مفاتيح ميكانيكية للألعاب', 'الإلكترونيات', 'قطعة', 'منتج', 'نشط', '2024-01-07', NOW()),
('شاشة LED 27 بوصة', 'PROD008', '1234567890130', 'شاشة LED عالية الدقة 4K', 'الإلكترونيات', 'قطعة', 'منتج', 'نشط', '2024-01-08', NOW()),
('طاولة مكتبية خشبية', 'PROD009', '1234567890131', 'طاولة مكتبية من الخشب الطبيعي', 'المكتبية', 'قطعة', 'منتج', 'نشط', '2024-01-09', NOW()),
('سماعات بلوتوث', 'PROD010', '1234567890132', 'سماعات لاسلكية عالية الجودة', 'الإلكترونيات', 'قطعة', 'منتج', 'نشط', '2024-01-10', NOW());

-- إدخال مخزون المنتجات
INSERT INTO product_stock (product_id, current_stock, available_stock, reserved_stock, reorder_level, max_stock_level, organization_id, created_at, updated_at, last_updated) VALUES
(1, 50, 45, 5, 10, 100, 1, NOW(), NOW(), NOW()),
(2, 30, 28, 2, 5, 50, 1, NOW(), NOW(), NOW()),
(3, 25, 23, 2, 5, 40, 1, NOW(), NOW(), NOW()),
(4, 15, 14, 1, 3, 30, 1, NOW(), NOW(), NOW()),
(5, 20, 18, 2, 5, 35, 1, NOW(), NOW(), NOW()),
(6, 100, 95, 5, 20, 200, 1, NOW(), NOW(), NOW()),
(7, 75, 70, 5, 15, 150, 1, NOW(), NOW(), NOW()),
(8, 40, 38, 2, 8, 80, 1, NOW(), NOW(), NOW()),
(9, 35, 33, 2, 7, 70, 1, NOW(), NOW(), NOW()),
(10, 60, 55, 5, 12, 120, 1, NOW(), NOW(), NOW());

-- إدخال طلبيات المبيعات
INSERT INTO sales_orders (order_number, customer_id, customer_name, order_date, total_amount, order_status, financial_status, currency_code, currency_name, exchange_rate, salesman, notes, created_at, updated_at) VALUES
('SO-2024-001', 1, 'شركة الأمل للتجارة', '2024-03-01', 15000.00, 'مؤكد', 'مدفوع جزئياً', 'SAR', 'ريال سعودي', 1.00, 'أحمد محمد', 'طلبية عاجلة', NOW(), NOW()),
('SO-2024-002', 2, 'مؤسسة النور التجارية', '2024-03-02', 8500.00, 'قيد المعالجة', 'غير مدفوع', 'SAR', 'ريال سعودي', 1.00, 'فاطمة علي', 'تسليم خلال أسبوع', NOW(), NOW()),
('SO-2024-003', 3, 'شركة الفجر للمقاولات', '2024-03-03', 22000.00, 'مؤكد', 'مدفوع', 'SAR', 'ريال سعودي', 1.00, 'محمد سالم', 'طلبية كبيرة', NOW(), NOW()),
('SO-2024-004', 4, 'مجموعة الشروق التجارية', '2024-03-04', 12500.00, 'قيد المراجعة', 'غير مدفوع', 'SAR', 'ريال سعودي', 1.00, 'سارة أحمد', 'يحتاج موافقة الإدارة', NOW(), NOW()),
('SO-2024-005', 5, 'شركة البدر للاستيراد', '2024-03-05', 18750.00, 'مؤكد', 'مدفوع جزئياً', 'SAR', 'ريال سعودي', 1.00, 'عبدالله خالد', 'دفعة أولى مستلمة', NOW(), NOW());

-- إدخال عناصر طلبيات المبيعات
INSERT INTO sales_order_items (sales_order_id, product_id, product_code, product_name, quantity, unit_price, total_price, unit, notes, created_at) VALUES
(1, 1, 'PROD001', 'لابتوب ديل XPS 13', 3, 4500.00, 13500.00, 'قطعة', 'مواصفات خاصة', NOW()),
(1, 6, 'PROD006', 'ماوس لاسلكي', 3, 150.00, 450.00, 'قطعة', 'لون أسود', NOW()),
(1, 7, 'PROD007', 'لوحة مفاتيح ميكانيكية', 2, 300.00, 600.00, 'قطعة', 'تخطيط عربي', NOW()),
(2, 2, 'PROD002', 'طابعة HP LaserJet', 2, 2500.00, 5000.00, 'قطعة', 'مع كرتونة حبر إضافية', NOW()),
(2, 3, 'PROD003', 'كرسي مكتبي مريح', 5, 700.00, 3500.00, 'قطعة', 'لون بني', NOW()),
(3, 5, 'PROD005', 'مكيف هواء سبليت', 4, 3200.00, 12800.00, 'قطعة', 'مع التركيب', NOW()),
(3, 8, 'PROD008', 'شاشة LED 27 بوصة', 3, 1800.00, 5400.00, 'قطعة', 'دقة 4K', NOW()),
(3, 9, 'PROD009', 'طاولة مكتبية خشبية', 2, 1900.00, 3800.00, 'قطعة', 'خشب بلوط', NOW()),
(4, 4, 'PROD004', 'جهاز قياس الضغط', 10, 450.00, 4500.00, 'قطعة', 'للاستخدام المنزلي', NOW()),
(4, 10, 'PROD010', 'سماعات بلوتوث', 20, 400.00, 8000.00, 'قطعة', 'ألوان متنوعة', NOW()),
(5, 1, 'PROD001', 'لابتوب ديل XPS 13', 2, 4500.00, 9000.00, 'قطعة', 'مع ضمان ممتد', NOW()),
(5, 8, 'PROD008', 'شاشة LED 27 بوصة', 3, 1800.00, 5400.00, 'قطعة', 'للاستخدام التجاري', NOW()),
(5, 2, 'PROD002', 'طابعة HP LaserJet', 1, 2500.00, 2500.00, 'قطعة', 'طراز حديث', NOW()),
(5, 6, 'PROD006', 'ماوس لاسلكي', 5, 150.00, 750.00, 'قطعة', 'مع بطاريات إضافية', NOW()),
(5, 7, 'PROD007', 'لوحة مفاتيح ميكانيكية', 4, 300.00, 1200.00, 'قطعة', 'إضاءة RGB', NOW());

-- إدخال طلبيات الشراء
INSERT INTO purchase_orders (order_number, supplier_id, supplier_name, order_date, total_amount, currency_code, currency_name, exchange_rate, salesman, notes, expected_delivery_date, workflow_status, created_at, updated_at) VALUES
('PO-2024-001', 1, 'شركة الإمداد الذهبي', '2024-02-20', 45000.00, 'SAR', 'ريال سعودي', 1.00, 'خالد أحمد', 'طلبية شهرية', '2024-03-05', 'مؤكد', NOW(), NOW()),
('PO-2024-002', 2, 'مؤسسة التوريد المتقدم', '2024-02-22', 28000.00, 'SAR', 'ريال سعودي', 1.00, 'نورا سالم', 'طلبية عاجلة', '2024-03-01', 'مستلم جزئياً', NOW(), NOW()),
('PO-2024-003', 3, 'شركة المصادر الشاملة', '2024-02-25', 35000.00, 'SAR', 'ريال سعودي', 1.00, 'عمر محمد', 'طلبية ربع سنوية', '2024-03-10', 'قيد المعالجة', NOW(), NOW()),
('PO-2024-004', 4, 'مجموعة الخدمات اللوجستية', '2024-02-28', 52000.00, 'SAR', 'ريال سعودي', 1.00, 'ليلى عبدالله', 'طلبية خاصة', '2024-03-15', 'مؤكد', NOW(), NOW()),
('PO-2024-005', 5, 'شركة التجهيزات الحديثة', '2024-03-01', 41000.00, 'SAR', 'ريال سعودي', 1.00, 'يوسف علي', 'طلبية تجديد المخزون', '2024-03-12', 'قيد المراجعة', NOW(), NOW());

-- إدخال عناصر طلبيات الشراء
INSERT INTO purchase_order_items (purchase_order_id, product_id, product_code, product_name, quantity, unit_price, total_price, unit, notes, created_at) VALUES
(1, 1, 'PROD001', 'لابتوب ديل XPS 13', 10, 4000.00, 40000.00, 'قطعة', 'إصدار جديد', NOW()),
(1, 6, 'PROD006', 'ماوس لاسلكي', 50, 100.00, 5000.00, 'قطعة', 'كمية بالجملة', NOW()),
(2, 2, 'PROD002', 'طابعة HP LaserJet', 8, 2200.00, 17600.00, 'قطعة', 'مع ضمان سنتين', NOW()),
(2, 3, 'PROD003', 'كرسي مكتبي مريح', 20, 520.00, 10400.00, 'قطعة', 'ألوان متنوعة', NOW()),
(3, 5, 'PROD005', 'مكيف هواء سبليت', 12, 2800.00, 33600.00, 'قطعة', 'كفاءة عالية', NOW()),
(3, 4, 'PROD004', 'جهاز قياس الضغط', 5, 280.00, 1400.00, 'قطعة', 'معايرة دقيقة', NOW()),
(4, 8, 'PROD008', 'شاشة LED 27 بوصة', 15, 1600.00, 24000.00, 'قطعة', 'دقة عالية', NOW()),
(4, 9, 'PROD009', 'طاولة مكتبية خشبية', 18, 1400.00, 25200.00, 'قطعة', 'تصميم حديث', NOW()),
(4, 7, 'PROD007', 'لوحة مفاتيح ميكانيكية', 10, 280.00, 2800.00, 'قطعة', 'مقاومة للماء', NOW()),
(5, 10, 'PROD010', 'سماعات بلوتوث', 30, 350.00, 10500.00, 'قطعة', 'جودة صوت عالية', NOW()),
(5, 1, 'PROD001', 'لابتوب ديل XPS 13', 8, 3800.00, 30400.00, 'قطعة', 'طراز محدث', NOW()),
(5, 6, 'PROD006', 'ماوس لاسلكي', 15, 70.00, 1050.00, 'قطعة', 'بطارية طويلة المدى', NOW());

-- إدخال المستخدمين
INSERT INTO user_settings (username, full_name, email, password_hash, role, department, phone, is_active, permissions, language, timezone, theme_preference, email_notifications, sms_notifications, notifications_enabled, organization_id, created_at, updated_at, last_login) VALUES
('admin', 'مدير النظام', 'admin@company.com', '$2b$10$hashedpassword1', 'مدير عام', 'الإدارة', '966501111111', true, '{"all": true}', 'ar', 'Asia/Riyadh', 'light', true, true, true, 1, NOW(), NOW(), NOW()),
('ahmed.mohamed', 'أحمد محمد السالم', 'ahmed@company.com', '$2b$10$hashedpassword2', 'مدير مبيعات', 'المبيعات', '966502222222', true, '{"sales": true, "customers": true}', 'ar', 'Asia/Riyadh', 'light', true, false, true, 1, NOW(), NOW(), NOW() - INTERVAL '2 hours'),
('fatima.ali', 'فاطمة علي أحمد', 'fatima@company.com', '$2b$10$hashedpassword3', 'محاسب', 'المحاسبة', '966503333333', true, '{"accounting": true, "reports": true}', 'ar', 'Asia/Riyadh', 'dark', true, true, true, 1, NOW(), NOW(), NOW() - INTERVAL '1 day'),
('omar.salem', 'عمر سالم الغامدي', 'omar@company.com', '$2b$10$hashedpassword4', 'مدير مخازن', 'المخازن', '966504444444', true, '{"inventory": true, "products": true}', 'ar', 'Asia/Riyadh', 'light', false, true, true, 1, NOW(), NOW(), NOW() - INTERVAL '3 hours'),
('sara.ahmed', 'سارة أحمد الزهراني', 'sara@company.com', '$2b$10$hashedpassword5', 'مشتري', 'المشتريات', '966505555555', true, '{"purchasing": true, "suppliers": true}', 'ar', 'Asia/Riyadh', 'light', true, false, true, 1, NOW(), NOW(), NOW() - INTERVAL '5 hours');

-- إدخال حركات المخزون
INSERT INTO inventory_transactions (product_id, transaction_type, quantity, unit_cost, reference_type, reference_id, notes, created_by, organization_id, created_at) VALUES
(1, 'استلام', 10, 4000.00, 'purchase_order', 1, 'استلام من طلبية شراء PO-2024-001', 'omar.salem', 1, NOW() - INTERVAL '5 days'),
(2, 'استلام', 8, 2200.00, 'purchase_order', 2, 'استلام من طلبية شراء PO-2024-002', 'omar.salem', 1, NOW() - INTERVAL '4 days'),
(1, 'صرف', 3, 4500.00, 'sales_order', 1, 'صرف لطلبية مبيعات SO-2024-001', 'ahmed.mohamed', 1, NOW() - INTERVAL '3 days'),
(6, 'استلام', 50, 100.00, 'purchase_order', 1, 'استلام من طلبية شراء PO-2024-001', 'omar.salem', 1, NOW() - INTERVAL '3 days'),
(2, 'صرف', 2, 2500.00, 'sales_order', 2, 'صرف لطلبية مبيعات SO-2024-002', 'ahmed.mohamed', 1, NOW() - INTERVAL '2 days'),
(3, 'استلام', 20, 520.00, 'purchase_order', 2, 'استلام من طلبية شراء PO-2024-002', 'omar.salem', 1, NOW() - INTERVAL '2 days'),
(5, 'استلام', 12, 2800.00, 'purchase_order', 3, 'استلام من طلبية شراء PO-2024-003', 'omar.salem', 1, NOW() - INTERVAL '1 day'),
(8, 'صرف', 3, 1800.00, 'sales_order', 3, 'صرف لطلبية مبيعات SO-2024-003', 'ahmed.mohamed', 1, NOW() - INTERVAL '1 day'),
(4, 'تسوية', 2, 450.00, 'adjustment', NULL, 'تسوية جرد دوري', 'omar.salem', 1, NOW()),
(10, 'استلام', 30, 350.00, 'purchase_order', 5, 'استلام من طلبية شراء PO-2024-005', 'omar.salem', 1, NOW());

-- إدخال إعدادات النظام
INSERT INTO system_settings (company_name, company_name_en, company_address, company_phone, company_email, company_website, language, timezone, default_currency, date_format, time_format, fiscal_year_start, auto_numbering, order_prefix, invoice_prefix, purchase_prefix, numbering_system, session_timeout, password_policy, two_factor_auth, audit_log, organization_id, created_at, updated_at) VALUES
('شركة التقنية المتقدمة', 'Advanced Technology Company', 'الرياض، المملكة العربية السعودية', '966112345678', 'info@advtech.com', 'www.advtech.com', 'ar', 'Asia/Riyadh', 'SAR', 'dd/mm/yyyy', '24h', '2024-01-01', true, 'SO-', 'INV-', 'PO-', 'yearly', 30, 'medium', false, true, 1, NOW(), NOW());

-- إدخال إعدادات المظهر
INSERT INTO theme_settings (theme_name, primary_color, secondary_color, accent_color, background_color, text_color, font_family, font_size, font_weight, line_height, letter_spacing, border_radius, dark_mode, rtl_support, header_height, sidebar_width, organization_id, created_at, updated_at) VALUES
('المظهر الافتراضي', '#2563eb', '#64748b', '#10b981', '#ffffff', '#1e293b', 'Cairo', 14, 400, 1.5, 0.025, 8, false, true, 64, 256, 1, NOW(), NOW());

-- إدخال سجل الأنشطة
INSERT INTO audit_logs (user_id, user_name, action, module, details, ip_address, user_agent, status, timestamp, created_at) VALUES
('admin', 'مدير النظام', 'تسجيل دخول', 'المصادقة', 'تسجيل دخول ناجح', '192.168.1.100', 'Mozilla/5.0', 'نجح', NOW() - INTERVAL '1 hour', NOW() - INTERVAL '1 hour'),
('ahmed.mohamed', 'أحمد محمد السالم', 'إنشاء طلبية', 'المبيعات', 'إنشاء طلبية مبيعات SO-2024-001', '192.168.1.101', 'Mozilla/5.0', 'نجح', NOW() - INTERVAL '3 days', NOW() - INTERVAL '3 days'),
('omar.salem', 'عمر سالم الغامدي', 'استلام بضاعة', 'المخازن', 'استلام 10 قطع من المنتج PROD001', '192.168.1.102', 'Mozilla/5.0', 'نجح', NOW() - INTERVAL '5 days', NOW() - INTERVAL '5 days'),
('sara.ahmed', 'سارة أحمد الزهراني', 'إنشاء طلبية شراء', 'المشتريات', 'إنشاء طلبية شراء PO-2024-001', '192.168.1.103', 'Mozilla/5.0', 'نجح', NOW() - INTERVAL '10 days', NOW() - INTERVAL '10 days'),
('fatima.ali', 'فاطمة علي أحمد', 'تصدير تقرير', 'التقارير', 'تصدير تقرير المبيعات الشهري', '192.168.1.104', 'Mozilla/5.0', 'نجح', NOW() - INTERVAL '2 days', NOW() - INTERVAL '2 days');

-- إدخال أسعار الصرف
INSERT INTO exchange_rates (currency_code, currency_name, exchange_rate, buy_rate, sell_rate, last_updated, organization_id) VALUES
('USD', 'دولار أمريكي', 3.75, 3.74, 3.76, NOW(), 1),
('EUR', 'يورو', 4.10, 4.08, 4.12, NOW(), 1),
('GBP', 'جنيه إسترليني', 4.75, 4.73, 4.77, NOW(), 1),
('AED', 'درهم إماراتي', 1.02, 1.01, 1.03, NOW(), 1),
('KWD', 'دينار كويتي', 12.25, 12.20, 12.30, NOW(), 1);

COMMIT;
