-- إدخال بيانات تجريبية شاملة لجميع مكونات النظام
-- Comprehensive test data for all system components

-- إضافة بيانات تجريبية شاملة لجميع الجداول

-- 1. إعدادات النظام العامة
INSERT INTO system_settings (
    organization_id, company_name, company_name_en, company_address, company_phone, 
    company_email, company_website, tax_number, commercial_register,
    default_currency, language, timezone, date_format, time_format,
    auto_numbering, numbering_system, order_prefix, invoice_prefix, purchase_prefix,
    session_timeout, two_factor_auth, audit_log, print_logo, print_footer,
    fiscal_year_start, working_hours, working_days, paper_size, default_printer,
    password_policy, created_at, updated_at
) VALUES 
(1, 'شركة الأنظمة المتقدمة للتجارة', 'Advanced Trading Systems Co.', 
 'الرياض، المملكة العربية السعودية، ص.ب 12345', '+966-11-1234567',
 'info@advancedtrading.sa', 'www.advancedtrading.sa', '123456789012345', 'CR-1234567890',
 'SAR', 'ar', 'Asia/Riyadh', 'DD/MM/YYYY', '24H',
 true, 'AUTO', 'SO-', 'INV-', 'PO-',
 30, true, true, true, true,
 '2024-01-01', '08:00-17:00', '{"sunday": true, "monday": true, "tuesday": true, "wednesday": true, "thursday": true, "friday": false, "saturday": false}',
 'A4', 'HP LaserJet Pro', 'STRONG', NOW(), NOW());

-- 2. إعدادات الطباعة
INSERT INTO print_settings (
    company_id, paper_size, orientation, font_family, font_size,
    margin_top, margin_bottom, margin_left, margin_right,
    show_logo, logo_position, logo_size, show_header, header_text,
    show_footer, footer_text, show_company_info, show_bank_details,
    show_payment_terms, show_page_numbers, show_print_date,
    use_colors, primary_color, secondary_color, print_copies,
    auto_print, default_printer, invoice_template,
    created_at, updated_at
) VALUES 
(1, 'A4', 'portrait', 'Arial', 12,
 20, 20, 15, 15,
 true, 'top-left', 'medium', true, 'شركة الأنظمة المتقدمة للتجارة',
 true, 'شكراً لتعاملكم معنا - هاتف: +966-11-1234567', true, true,
 true, true, true,
 true, '#2563eb', '#64748b', 2,
 false, 'HP LaserJet Pro', 'modern',
 NOW(), NOW());

-- 3. إعدادات المظهر
INSERT INTO theme_settings (
    organization_id, theme_name, primary_color, secondary_color, accent_color,
    background_color, text_color, font_family, font_size, font_weight,
    line_height, letter_spacing, border_radius, header_height, sidebar_width,
    dark_mode, rtl_support, created_at, updated_at
) VALUES 
(1, 'النمط الافتراضي', '#2563eb', '#64748b', '#10b981',
 '#ffffff', '#1f2937', 'Cairo', 14, 400,
 1.5, 0.025, 8, 64, 256,
 false, true, NOW(), NOW());

-- 4. مجموعات الأصناف
INSERT INTO item_groups (
    organization_id, group_number, group_name, description, parent_group_id, is_active, created_at, updated_at
) VALUES 
(1, 'GRP001', 'الإلكترونيات', 'جميع المنتجات الإلكترونية والتقنية', NULL, true, NOW(), NOW()),
(1, 'GRP002', 'الهواتف الذكية', 'هواتف ذكية من جميع الماركات', 1, true, NOW(), NOW()),
(1, 'GRP003', 'أجهزة الكمبيوتر', 'أجهزة كمبيوتر محمولة ومكتبية', 1, true, NOW(), NOW()),
(1, 'GRP004', 'الإكسسوارات', 'إكسسوارات الهواتف والأجهزة', 1, true, NOW(), NOW()),
(1, 'GRP005', 'الأجهزة المنزلية', 'أجهزة كهربائية منزلية', NULL, true, NOW(), NOW()),
(1, 'GRP006', 'أجهزة المطبخ', 'أجهزة المطبخ الكهربائية', 5, true, NOW(), NOW()),
(1, 'GRP007', 'أجهزة التكييف', 'مكيفات هواء ومراوح', 5, true, NOW(), NOW()),
(1, 'GRP008', 'الملابس والأزياء', 'ملابس رجالية ونسائية وأطفال', NULL, true, NOW(), NOW()),
(1, 'GRP009', 'ملابس رجالية', 'ملابس وأزياء رجالية', 8, true, NOW(), NOW()),
(1, 'GRP010', 'ملابس نسائية', 'ملابس وأزياء نسائية', 8, true, NOW(), NOW());

-- 5. المنتجات (100 منتج متنوع)
INSERT INTO products (
    product_code, product_name, description, category, product_type, status,
    barcode, manufacturer_number, original_number, main_unit, secondary_unit,
    conversion_factor, currency, last_purchase_price, max_quantity, order_quantity,
    has_expiry, has_batch, has_colors, classifications, general_notes,
    product_image, attachments, entry_date, created_at
) VALUES 
-- هواتف ذكية
('PHONE001', 'iPhone 15 Pro Max 256GB', 'هاتف ذكي من آبل بسعة 256 جيجابايت', 'الهواتف الذكية', 'منتج', 'نشط',
 '1234567890123', 'A3108', 'IP15PM256', 'قطعة', 'علبة', 1, 'SAR', 4500.00, 100, 10,
 false, true, true, 'فئة أ', 'هاتف ذكي متطور مع كاميرا احترافية',
 '/images/iphone15pro.jpg', 'warranty_card.pdf', '2024-01-15', NOW()),

('PHONE002', 'Samsung Galaxy S24 Ultra 512GB', 'هاتف ذكي من سامسونج بسعة 512 جيجابايت', 'الهواتف الذكية', 'منتج', 'نشط',
 '1234567890124', 'SM-S928B', 'SGS24U512', 'قطعة', 'علبة', 1, 'SAR', 4200.00, 80, 8,
 false, true, true, 'فئة أ', 'هاتف ذكي بقلم S Pen وكاميرا 200 ميجابكسل',
 '/images/galaxys24ultra.jpg', 'warranty_card.pdf', '2024-01-20', NOW()),

('PHONE003', 'Xiaomi 14 Pro 256GB', 'هاتف ذكي من شاومي بسعة 256 جيجابايت', 'الهواتف الذكية', 'منتج', 'نشط',
 '1234567890125', 'MI14PRO256', 'XM14P256', 'قطعة', 'علبة', 1, 'SAR', 2800.00, 120, 12,
 false, true, true, 'فئة أ', 'هاتف ذكي بمعالج Snapdragon 8 Gen 3',
 '/images/xiaomi14pro.jpg', 'warranty_card.pdf', '2024-01-25', NOW()),

-- أجهزة كمبيوتر
('LAPTOP001', 'MacBook Pro 16" M3 Pro 512GB', 'لابتوب من آبل بمعالج M3 Pro', 'أجهزة الكمبيوتر', 'منتج', 'نشط',
 '1234567890126', 'MBP16M3P512', 'MBP16-512', 'قطعة', 'علبة', 1, 'SAR', 8500.00, 50, 5,
 false, true, false, 'فئة أ', 'لابتوب احترافي للمصممين والمطورين',
 '/images/macbookpro16.jpg', 'warranty_card.pdf', '2024-02-01', NOW()),

('LAPTOP002', 'Dell XPS 15 Intel i7 1TB', 'لابتوب من ديل بمعالج Intel i7', 'أجهزة الكمبيوتر', 'منتج', 'نشط',
 '1234567890127', 'XPS15I71TB', 'DELL-XPS15', 'قطعة', 'علبة', 1, 'SAR', 6500.00, 40, 4,
 false, true, false, 'فئة أ', 'لابتوب عالي الأداء للأعمال والألعاب',
 '/images/dellxps15.jpg', 'warranty_card.pdf', '2024-02-05', NOW()),

-- إكسسوارات
('ACC001', 'AirPods Pro 2nd Gen', 'سماعات لاسلكية من آبل', 'الإكسسوارات', 'منتج', 'نشط',
 '1234567890128', 'APP2GEN', 'AIRPODS-PRO2', 'قطعة', 'علبة', 1, 'SAR', 950.00, 200, 20,
 false, true, false, 'فئة أ', 'سماعات لاسلكية بخاصية إلغاء الضوضاء',
 '/images/airpodspro2.jpg', 'warranty_card.pdf', '2024-02-10', NOW()),

('ACC002', 'Samsung Galaxy Watch 6 44mm', 'ساعة ذكية من سامسونج', 'الإكسسوارات', 'منتج', 'نشط',
 '1234567890129', 'SMW644MM', 'GW6-44MM', 'قطعة', 'علبة', 1, 'SAR', 1200.00, 100, 10,
 false, true, true, 'فئة أ', 'ساعة ذكية بمراقبة الصحة واللياقة',
 '/images/galaxywatch6.jpg', 'warranty_card.pdf', '2024-02-15', NOW()),

-- أجهزة منزلية
('HOME001', 'LG OLED 65" 4K Smart TV', 'تلفزيون ذكي من إل جي', 'الأجهزة المنزلية', 'منتج', 'نشط',
 '1234567890130', 'LGOLED65', 'LG-OLED65', 'قطعة', 'علبة', 1, 'SAR', 3500.00, 30, 3,
 false, true, false, 'فئة أ', 'تلفزيون OLED بدقة 4K وتقنيات ذكية',
 '/images/lgoled65.jpg', 'warranty_card.pdf', '2024-02-20', NOW()),

('HOME002', 'Samsung French Door Refrigerator 600L', 'ثلاجة من سامسونج', 'الأجهزة المنزلية', 'منتج', 'نشط',
 '1234567890131', 'SMFD600L', 'SAM-REF600', 'قطعة', 'علبة', 1, 'SAR', 4200.00, 20, 2,
 false, true, true, 'فئة أ', 'ثلاجة بتقنية التبريد المزدوج وموزع المياه',
 '/images/samsungfridge.jpg', 'warranty_card.pdf', '2024-02-25', NOW()),

-- أجهزة مطبخ
('KITCHEN001', 'Breville Barista Express Coffee Machine', 'ماكينة قهوة من بريفيل', 'أجهزة المطبخ', 'منتج', 'نشط',
 '1234567890132', 'BVBE870XL', 'BRV-BE870', 'قطعة', 'علبة', 1, 'SAR', 2200.00, 25, 3,
 false, true, false, 'فئة أ', 'ماكينة قهوة احترافية بمطحنة مدمجة',
 '/images/brevillecoffee.jpg', 'warranty_card.pdf', '2024-03-01', NOW());

-- إضافة المزيد من المنتجات (90 منتج إضافي)
DO $$
DECLARE
    i INTEGER;
    categories TEXT[] := ARRAY['الهواتف الذكية', 'أجهزة الكمبيوتر', 'الإكسسوارات', 'الأجهزة المنزلية', 'أجهزة المطبخ', 'الملابس والأزياء'];
    product_types TEXT[] := ARRAY['منتج', 'خدمة', 'مجموعة'];
    statuses TEXT[] := ARRAY['نشط', 'غير نشط', 'متوقف'];
    units TEXT[] := ARRAY['قطعة', 'كيلو', 'متر', 'لتر', 'علبة', 'حبة'];
BEGIN
    FOR i IN 11..100 LOOP
        INSERT INTO products (
            product_code, product_name, description, category, product_type, status,
            barcode, manufacturer_number, original_number, main_unit, secondary_unit,
            conversion_factor, currency, last_purchase_price, max_quantity, order_quantity,
            has_expiry, has_batch, has_colors, classifications, general_notes,
            entry_date, created_at
        ) VALUES (
            'PROD' || LPAD(i::TEXT, 3, '0'),
            'منتج تجريبي رقم ' || i,
            'وصف تفصيلي للمنتج التجريبي رقم ' || i || ' مع مواصفات متقدمة',
            categories[1 + (i % array_length(categories, 1))],
            product_types[1 + (i % array_length(product_types, 1))],
            statuses[1 + (i % array_length(statuses, 1))],
            '123456789' || LPAD(i::TEXT, 4, '0'),
            'MFG' || LPAD(i::TEXT, 6, '0'),
            'ORG' || LPAD(i::TEXT, 6, '0'),
            units[1 + (i % array_length(units, 1))],
            'علبة',
            CASE WHEN units[1 + (i % array_length(units, 1))] = 'قطعة' THEN 12 ELSE 1 END,
            'SAR',
            (RANDOM() * 5000 + 100)::NUMERIC(10,2),
            (RANDOM() * 1000 + 10)::INTEGER,
            (RANDOM() * 50 + 5)::INTEGER,
            RANDOM() > 0.7,
            RANDOM() > 0.6,
            RANDOM() > 0.5,
            CASE WHEN RANDOM() > 0.5 THEN 'فئة أ' ELSE 'فئة ب' END,
            'ملاحظات عامة للمنتج رقم ' || i,
            CURRENT_DATE - (RANDOM() * 365)::INTEGER,
            NOW()
        );
    END LOOP;
END $$;

-- 6. العملاء (50 عميل)
INSERT INTO customers (
    customer_code, customer_name, email, mobile1, mobile2, whatsapp1, whatsapp2,
    address, city, business_nature, classifications, status, salesman,
    account_opening_date, api_number, general_notes, movement_notes, attachments, created_at
) VALUES 
('CUST001', 'شركة التقنيات المتطورة المحدودة', 'info@advtech.sa', '+966501234567', '+966112345678', '+966501234567', '+966112345678',
 'الرياض، حي العليا، شارع الملك فهد', 'الرياض', 'تجارة إلكترونيات', 'عميل ذهبي', 'نشط', 'أحمد محمد',
 '2023-01-15', 'API001', 'عميل مميز يتعامل بكميات كبيرة', 'دفع نقدي فوري', 'contract.pdf', NOW()),

('CUST002', 'مؤسسة الأنظمة الذكية', 'contact@smartsys.com.sa', '+966502345678', '+966113456789', '+966502345678', '+966113456789',
 'جدة، حي الزهراء، طريق الملك عبدالعزيز', 'جدة', 'حلول تقنية', 'عميل فضي', 'نشط', 'فاطمة أحمد',
 '2023-02-20', 'API002', 'متخصص في الحلول التقنية للشركات', 'دفع آجل 30 يوم', 'agreement.pdf', NOW()),

('CUST003', 'شركة الإبداع التجاري', 'sales@creative-trade.sa', '+966503456789', '+966114567890', '+966503456789', '+966114567890',
 'الدمام، حي الفيصلية، شارع الأمير محمد بن فهد', 'الدمام', 'تجارة عامة', 'عميل عادي', 'نشط', 'محمد علي',
 '2023-03-10', 'API003', 'يركز على المنتجات الاستهلاكية', 'دفع نقدي عند التسليم', 'profile.pdf', NOW());

-- إضافة المزيد من العملاء
DO $$
DECLARE
    i INTEGER;
    cities TEXT[] := ARRAY['الرياض', 'جدة', 'الدمام', 'مكة', 'المدينة', 'الطائف', 'تبوك', 'أبها', 'جازان', 'حائل'];
    business_types TEXT[] := ARRAY['تجارة إلكترونيات', 'حلول تقنية', 'تجارة عامة', 'مقاولات', 'خدمات', 'تصنيع'];
    classifications TEXT[] := ARRAY['عميل ذهبي', 'عميل فضي', 'عميل عادي', 'عميل جديد'];
    salesmen TEXT[] := ARRAY['أحمد محمد', 'فاطمة أحمد', 'محمد علي', 'سارة خالد', 'عبدالله سعد', 'نورا عبدالرحمن'];
BEGIN
    FOR i IN 4..50 LOOP
        INSERT INTO customers (
            customer_code, customer_name, email, mobile1, whatsapp1,
            address, city, business_nature, classifications, status, salesman,
            account_opening_date, api_number, general_notes, created_at
        ) VALUES (
            'CUST' || LPAD(i::TEXT, 3, '0'),
            'عميل تجريبي رقم ' || i,
            'customer' || i || '@example.sa',
            '+96650' || LPAD((1000000 + i)::TEXT, 7, '0'),
            '+96650' || LPAD((1000000 + i)::TEXT, 7, '0'),
            cities[1 + (i % array_length(cities, 1))] || '، حي تجريبي، شارع رقم ' || i,
            cities[1 + (i % array_length(cities, 1))],
            business_types[1 + (i % array_length(business_types, 1))],
            classifications[1 + (i % array_length(classifications, 1))],
            CASE WHEN RANDOM() > 0.1 THEN 'نشط' ELSE 'غير نشط' END,
            salesmen[1 + (i % array_length(salesmen, 1))],
            CURRENT_DATE - (RANDOM() * 730)::INTEGER,
            'API' || LPAD(i::TEXT, 3, '0'),
            'ملاحظات عامة للعميل رقم ' || i,
            NOW()
        );
    END LOOP;
END $$;

-- 7. الموردين (30 مورد)
INSERT INTO suppliers (
    supplier_code, supplier_name, email, mobile1, mobile2, whatsapp1, whatsapp2,
    address, city, business_nature, classifications, status, salesman,
    account_opening_date, api_number, web_username, web_password, general_notes, movement_notes, attachments, created_at
) VALUES 
('SUPP001', 'شركة التوريدات التقنية المتقدمة', 'supply@techadvanced.sa', '+966501111111', '+966112111111', '+966501111111', '+966112111111',
 'الرياض، المنطقة الصناعية الثانية', 'الرياض', 'توريد إلكترونيات', 'مورد معتمد', 'نشط', 'خالد أحمد',
 '2022-06-15', 'SAPI001', 'tech_supplier', 'pass123', 'مورد رئيسي للإلكترونيات', 'دفع آجل 45 يوم', 'contract.pdf', NOW()),

('SUPP002', 'مؤسسة الجودة للاستيراد والتصدير', 'import@quality-trade.com', '+966502222222', '+966113222222', '+966502222222', '+966113222222',
 'جدة، منطقة الميناء التجاري', 'جدة', 'استيراد وتصدير', 'مورد دولي', 'نشط', 'سعد محمد',
 '2022-08-20', 'SAPI002', 'quality_import', 'secure456', 'متخصص في الاستيراد من آسيا', 'دفع نقدي مقدم', 'license.pdf', NOW()),

('SUPP003', 'شركة الأجهزة المنزلية الحديثة', 'home@modern-appliances.sa', '+966503333333', '+966114333333', '+966503333333', '+966114333333',
 'الدمام، المدينة الصناعية الأولى', 'الدمام', 'أجهزة منزلية', 'مورد محلي', 'نشط', 'نوال عبدالله',
 '2022-09-10', 'SAPI003', 'home_appliances', 'home789', 'مورد الأجهزة المنزلية الرئيسي', 'دفع آجل 30 يوم', 'catalog.pdf', NOW());

-- إضافة المزيد من الموردين
DO $$
DECLARE
    i INTEGER;
    cities TEXT[] := ARRAY['الرياض', 'جدة', 'الدمام', 'مكة', 'المدينة', 'الطائف'];
    business_types TEXT[] := ARRAY['توريد إلكترونيات', 'استيراد وتصدير', 'أجهزة منزلية', 'مواد خام', 'قطع غيار'];
    classifications TEXT[] := ARRAY['مورد معتمد', 'مورد دولي', 'مورد محلي', 'مورد جديد'];
    salesmen TEXT[] := ARRAY['خالد أحمد', 'سعد محمد', 'نوال عبدالله', 'عمر حسن', 'ليلى فهد'];
BEGIN
    FOR i IN 4..30 LOOP
        INSERT INTO suppliers (
            supplier_code, supplier_name, email, mobile1, whatsapp1,
            address, city, business_nature, classifications, status, salesman,
            account_opening_date, api_number, web_username, web_password, general_notes, created_at
        ) VALUES (
            'SUPP' || LPAD(i::TEXT, 3, '0'),
            'مورد تجريبي رقم ' || i,
            'supplier' || i || '@example.sa',
            '+96650' || LPAD((2000000 + i)::TEXT, 7, '0'),
            '+96650' || LPAD((2000000 + i)::TEXT, 7, '0'),
            cities[1 + (i % array_length(cities, 1))] || '، منطقة صناعية، مجمع رقم ' || i,
            cities[1 + (i % array_length(cities, 1))],
            business_types[1 + (i % array_length(business_types, 1))],
            classifications[1 + (i % array_length(classifications, 1))],
            CASE WHEN RANDOM() > 0.05 THEN 'نشط' ELSE 'غير نشط' END,
            salesmen[1 + (i % array_length(salesmen, 1))],
            CURRENT_DATE - (RANDOM() * 1095)::INTEGER,
            'SAPI' || LPAD(i::TEXT, 3, '0'),
            'supplier_' || i,
            'pass' || i || '123',
            'ملاحظات عامة للمورد رقم ' || i,
            NOW()
        );
    END LOOP;
END $$;

-- 8. المستخدمين (20 مستخدم)
INSERT INTO user_settings (
    username, email, password_hash, full_name, role, department, phone,
    is_active, permissions, language, timezone, theme_preference,
    email_notifications, sms_notifications, notifications_enabled,
    date_format, time_format, sidebar_collapsed, dashboard_layout,
    avatar_url, last_login, organization_id, created_at, updated_at
) VALUES 
('admin', 'admin@company.sa', '$2b$10$rQZ9uP7QK8GHWKz5vJ2nLOXxYzJ8qP3mN4kL6sR7tU9vW1xY2zA3B', 'مدير النظام', 'مدير عام', 'الإدارة العامة', '+966501000001',
 true, '{"sales": {"read": true, "write": true, "delete": true}, "purchases": {"read": true, "write": true, "delete": true}, "inventory": {"read": true, "write": true, "delete": true}, "customers": {"read": true, "write": true, "delete": true}, "suppliers": {"read": true, "write": true, "delete": true}, "reports": {"read": true, "write": true, "delete": true}, "settings": {"read": true, "write": true, "delete": true}}',
 'ar', 'Asia/Riyadh', 'light', true, true, true, 'DD/MM/YYYY', '24H', false,
 '{"widgets": ["sales_summary", "inventory_alerts", "recent_orders", "top_products"]}',
 '/avatars/admin.jpg', NOW() - INTERVAL '2 hours', 1, NOW(), NOW()),

('sales_manager', 'sales@company.sa', '$2b$10$rQZ9uP7QK8GHWKz5vJ2nLOXxYzJ8qP3mN4kL6sR7tU9vW1xY2zA3B', 'مدير المبيعات', 'مدير مبيعات', 'المبيعات', '+966501000002',
 true, '{"sales": {"read": true, "write": true, "delete": false}, "customers": {"read": true, "write": true, "delete": false}, "inventory": {"read": true, "write": false, "delete": false}, "reports": {"read": true, "write": false, "delete": false}}',
 'ar', 'Asia/Riyadh', 'light', true, true, true, 'DD/MM/YYYY', '24H', false,
 '{"widgets": ["sales_summary", "customer_activity", "sales_targets"]}',
 '/avatars/sales_manager.jpg', NOW() - INTERVAL '1 hour', 1, NOW(), NOW()),

('purchase_manager', 'purchase@company.sa', '$2b$10$rQZ9uP7QK8GHWKz5vJ2nLOXxYzJ8qP3mN4kL6sR7tU9vW1xY2zA3B', 'مدير المشتريات', 'مدير مشتريات', 'المشتريات', '+966501000003',
 true, '{"purchases": {"read": true, "write": true, "delete": false}, "suppliers": {"read": true, "write": true, "delete": false}, "inventory": {"read": true, "write": false, "delete": false}, "reports": {"read": true, "write": false, "delete": false}}',
 'ar', 'Asia/Riyadh', 'light', true, true, true, 'DD/MM/YYYY', '24H', false,
 '{"widgets": ["purchase_summary", "supplier_performance", "inventory_levels"]}',
 '/avatars/purchase_manager.jpg', NOW() - INTERVAL '30 minutes', 1, NOW(), NOW()),

('warehouse_manager', 'warehouse@company.sa', '$2b$10$rQZ9uP7QK8GHWKz5vJ2nLOXxYzJ8qP3mN4kL6sR7tU9vW1xY2zA3B', 'مدير المخازن', 'مدير مخازن', 'المخازن', '+966501000004',
 true, '{"inventory": {"read": true, "write": true, "delete": false}, "products": {"read": true, "write": true, "delete": false}, "reports": {"read": true, "write": false, "delete": false}}',
 'ar', 'Asia/Riyadh', 'light', true, true, true, 'DD/MM/YYYY', '24H', false,
 '{"widgets": ["inventory_summary", "stock_alerts", "movement_history"]}',
 '/avatars/warehouse_manager.jpg', NOW() - INTERVAL '15 minutes', 1, NOW(), NOW()),

('accountant', 'accounting@company.sa', '$2b$10$rQZ9uP7QK8GHWKz5vJ2nLOXxYzJ8qP3mN4kL6sR7tU9vW1xY2zA3B', 'المحاسب الرئيسي', 'محاسب', 'المحاسبة', '+966501000005',
 true, '{"reports": {"read": true, "write": true, "delete": false}, "sales": {"read": true, "write": false, "delete": false}, "purchases": {"read": true, "write": false, "delete": false}}',
 'ar', 'Asia/Riyadh', 'light', true, true, true, 'DD/MM/YYYY', '24H', false,
 '{"widgets": ["financial_summary", "payment_status", "profit_analysis"]}',
 '/avatars/accountant.jpg', NOW() - INTERVAL '45 minutes', 1, NOW(), NOW());

-- إضافة المزيد من المستخدمين
DO $$
DECLARE
    i INTEGER;
    roles TEXT[] := ARRAY['موظف مبيعات', 'موظف مشتريات', 'موظف مخازن', 'محاسب مساعد', 'مدخل بيانات'];
    departments TEXT[] := ARRAY['المبيعات', 'المشتريات', 'المخازن', 'المحاسبة', 'إدخال البيانات'];
BEGIN
    FOR i IN 6..20 LOOP
        INSERT INTO user_settings (
            username, email, password_hash, full_name, role, department, phone,
            is_active, permissions, language, timezone, theme_preference,
            email_notifications, sms_notifications, notifications_enabled,
            date_format, time_format, sidebar_collapsed, dashboard_layout,
            last_login, organization_id, created_at, updated_at
        ) VALUES (
            'user' || i,
            'user' || i || '@company.sa',
            '$2b$10$rQZ9uP7QK8GHWKz5vJ2nLOXxYzJ8qP3mN4kL6sR7tU9vW1xY2zA3B',
            'موظف تجريبي رقم ' || i,
            roles[1 + (i % array_length(roles, 1))],
            departments[1 + (i % array_length(departments, 1))],
            '+96650100000' || i,
            RANDOM() > 0.1,
            '{"sales": {"read": true, "write": false, "delete": false}, "inventory": {"read": true, "write": false, "delete": false}}',
            'ar', 'Asia/Riyadh', 'light', true, false, true,
            'DD/MM/YYYY', '24H', false,
            '{"widgets": ["daily_tasks", "notifications"]}',
            CASE WHEN RANDOM() > 0.3 THEN NOW() - (RANDOM() * INTERVAL '7 days') ELSE NULL END,
            1, NOW(), NOW()
        );
    END LOOP;
END $$;

-- 9. طلبيات المبيعات (100 طلبية)
DO $$
DECLARE
    i INTEGER;
    customer_ids INTEGER[];
    product_ids INTEGER[];
    order_statuses TEXT[] := ARRAY['مسودة', 'معتمد', 'قيد التنفيذ', 'مكتمل', 'ملغي'];
    financial_statuses TEXT[] := ARRAY['غير مدفوع', 'مدفوع جزئياً', 'مدفوع بالكامل'];
    salesmen TEXT[] := ARRAY['أحمد محمد', 'فاطمة أحمد', 'محمد علي', 'سارة خالد'];
    order_id INTEGER;
    num_items INTEGER;
    j INTEGER;
BEGIN
    -- الحصول على معرفات العملاء والمنتجات
    SELECT ARRAY_AGG(id) INTO customer_ids FROM customers WHERE id <= 50;
    SELECT ARRAY_AGG(id) INTO product_ids FROM products WHERE id <= 100;
    
    FOR i IN 1..100 LOOP
        INSERT INTO sales_orders (
            order_number, customer_id, customer_name, order_date, delivery_datetime,
            order_status, financial_status, total_amount, currency_code, currency_name,
            exchange_rate, salesman, notes, manual_document, barcode,
            workflow_sequence_id, attachments, created_at, updated_at
        ) VALUES (
            'SO-' || LPAD(i::TEXT, 6, '0'),
            customer_ids[1 + (i % array_length(customer_ids, 1))],
            'عميل تجريبي رقم ' || (1 + (i % array_length(customer_ids, 1))),
            CURRENT_DATE - (RANDOM() * 90)::INTEGER,
            CURRENT_TIMESTAMP + (RANDOM() * INTERVAL '30 days'),
            order_statuses[1 + (i % array_length(order_statuses, 1))],
            financial_statuses[1 + (i % array_length(financial_statuses, 1))],
            (RANDOM() * 50000 + 1000)::NUMERIC(10,2),
            'SAR', 'ريال سعودي', 1.00,
            salesmen[1 + (i % array_length(salesmen, 1))],
            'ملاحظات طلبية المبيعات رقم ' || i,
            'DOC-' || i, 'SO' || LPAD(i::TEXT, 10, '0'),
            1, 'invoice_' || i || '.pdf',
            NOW(), NOW()
        ) RETURNING id INTO order_id;
        
        -- إضافة عناصر الطلبية (2-5 عناصر لكل طلبية)
        num_items := 2 + (RANDOM() * 4)::INTEGER;
        FOR j IN 1..num_items LOOP
            INSERT INTO sales_order_items (
                sales_order_id, product_id, product_code, product_name, barcode,
                quantity, unit_price, discount_percentage, total_price, unit,
                delivered_quantity, bonus_quantity, warehouse, batch_number,
                expiry_date, item_status, notes, created_at
            ) VALUES (
                order_id,
                product_ids[1 + ((i + j) % array_length(product_ids, 1))],
                'PROD' || LPAD(((i + j) % 100 + 1)::TEXT, 3, '0'),
                'منتج تجريبي رقم ' || ((i + j) % 100 + 1),
                '123456789' || LPAD(((i + j) % 100 + 1)::TEXT, 4, '0'),
                (RANDOM() * 10 + 1)::NUMERIC(10,2),
                (RANDOM() * 1000 + 50)::NUMERIC(10,2),
                (RANDOM() * 10)::NUMERIC(5,2),
                (RANDOM() * 10000 + 500)::NUMERIC(10,2),
                'قطعة',
                CASE WHEN RANDOM() > 0.5 THEN (RANDOM() * 5)::NUMERIC(10,2) ELSE 0 END,
                CASE WHEN RANDOM() > 0.7 THEN (RANDOM() * 2)::NUMERIC(10,2) ELSE 0 END,
                'المخزن الرئيسي',
                CASE WHEN RANDOM() > 0.6 THEN 'BATCH' || LPAD(i::TEXT, 6, '0') ELSE NULL END,
                CASE WHEN RANDOM() > 0.8 THEN CURRENT_DATE + (RANDOM() * 365)::INTEGER ELSE NULL END,
                CASE WHEN RANDOM() > 0.2 THEN 'مؤكد' ELSE 'معلق' END,
                'ملاحظات العنصر رقم ' || j,
                NOW()
            );
        END LOOP;
    END LOOP;
END $$;

-- 10. طلبيات الشراء (80 طلبية)
DO $$
DECLARE
    i INTEGER;
    supplier_ids INTEGER[];
    product_ids INTEGER[];
    workflow_statuses TEXT[] := ARRAY['مسودة', 'معتمد', 'مرسل للمورد', 'قيد التنفيذ', 'مستلم جزئياً', 'مستلم بالكامل', 'ملغي'];
    salesmen TEXT[] := ARRAY['خالد أحمد', 'سعد محمد', 'نوال عبدالله', 'عمر حسن'];
    order_id INTEGER;
    num_items INTEGER;
    j INTEGER;
BEGIN
    -- الحصول على معرفات الموردين والمنتجات
    SELECT ARRAY_AGG(id) INTO supplier_ids FROM suppliers WHERE id <= 30;
    SELECT ARRAY_AGG(id) INTO product_ids FROM products WHERE id <= 100;
    
    FOR i IN 1..80 LOOP
        INSERT INTO purchase_orders (
            order_number, supplier_id, supplier_name, order_date, expected_delivery_date,
            workflow_status, total_amount, currency_code, currency_name,
            exchange_rate, salesman, notes, manual_document,
            workflow_sequence_id, attachments, created_at, updated_at
        ) VALUES (
            'PO-' || LPAD(i::TEXT, 6, '0'),
            supplier_ids[1 + (i % array_length(supplier_ids, 1))],
            'مورد تجريبي رقم ' || (1 + (i % array_length(supplier_ids, 1))),
            CURRENT_DATE - (RANDOM() * 120)::INTEGER,
            CURRENT_DATE + (RANDOM() * 60)::INTEGER,
            workflow_statuses[1 + (i % array_length(workflow_statuses, 1))],
            (RANDOM() * 100000 + 5000)::NUMERIC(10,2),
            'SAR', 'ريال سعودي', 1.00,
            salesmen[1 + (i % array_length(salesmen, 1))],
            'ملاحظات طلبية الشراء رقم ' || i,
            'PO-DOC-' || i, 1, 'purchase_order_' || i || '.pdf',
            NOW(), NOW()
        ) RETURNING id INTO order_id;
        
        -- إضافة عناصر الطلبية (3-7 عناصر لكل طلبية)
        num_items := 3 + (RANDOM() * 5)::INTEGER;
        FOR j IN 1..num_items LOOP
            INSERT INTO purchase_order_items (
                purchase_order_id, product_id, product_code, product_name, barcode,
                quantity, unit_price, total_price, unit, received_quantity,
                bonus_quantity, warehouse, batch_number, expiry_date, notes, created_at
            ) VALUES (
                order_id,
                product_ids[1 + ((i + j) % array_length(product_ids, 1))],
                'PROD' || LPAD(((i + j) % 100 + 1)::TEXT, 3, '0'),
                'منتج تجريبي رقم ' || ((i + j) % 100 + 1),
                '123456789' || LPAD(((i + j) % 100 + 1)::TEXT, 4, '0'),
                (RANDOM() * 50 + 5)::NUMERIC(10,2),
                (RANDOM() * 800 + 30)::NUMERIC(10,2),
                (RANDOM() * 40000 + 1000)::NUMERIC(10,2),
                'قطعة',
                CASE WHEN RANDOM() > 0.3 THEN (RANDOM() * 30)::NUMERIC(10,2) ELSE 0 END,
                CASE WHEN RANDOM() > 0.6 THEN (RANDOM() * 5)::NUMERIC(10,2) ELSE 0 END,
                'المخزن الرئيسي',
                CASE WHEN RANDOM() > 0.5 THEN 'BATCH' || LPAD((i*100+j)::TEXT, 8, '0') ELSE NULL END,
                CASE WHEN RANDOM() > 0.7 THEN CURRENT_DATE + (RANDOM() * 730)::INTEGER ELSE NULL END,
                'ملاحظات عنصر الشراء رقم ' || j,
                NOW()
            );
        END LOOP;
    END LOOP;
END $$;

-- 11. مخزون المنتجات
INSERT INTO product_stock (
    product_id, organization_id, current_stock, available_stock, reserved_stock,
    reorder_level, max_stock_level, last_updated, created_at, updated_at
)
SELECT 
    id,
    1,
    (RANDOM() * 1000 + 10)::NUMERIC(10,2),
    (RANDOM() * 800 + 5)::NUMERIC(10,2),
    (RANDOM() * 50)::NUMERIC(10,2),
    (RANDOM() * 100 + 10)::NUMERIC(10,2),
    (RANDOM() * 2000 + 500)::NUMERIC(10,2),
    NOW(),
    NOW(),
    NOW()
FROM products;

-- 12. حركات المخزون (500 حركة)
DO $$
DECLARE
    i INTEGER;
    product_ids INTEGER[];
    transaction_types TEXT[] := ARRAY['استلام', 'صرف', 'تحويل', 'تسوية', 'إرجاع'];
    reference_types TEXT[] := ARRAY['طلبية مبيعات', 'طلبية شراء', 'تحويل مخزني', 'تسوية جرد', 'إرجاع عميل'];
    users TEXT[] := ARRAY['admin', 'warehouse_manager', 'user6', 'user7', 'user8'];
BEGIN
    SELECT ARRAY_AGG(id) INTO product_ids FROM products WHERE id <= 100;
    
    FOR i IN 1..500 LOOP
        INSERT INTO inventory_transactions (
            product_id, transaction_type, quantity, unit_cost, reference_type,
            reference_id, notes, created_by, organization_id, created_at
        ) VALUES (
            product_ids[1 + (i % array_length(product_ids, 1))],
            transaction_types[1 + (i % array_length(transaction_types, 1))],
            CASE 
                WHEN transaction_types[1 + (i % array_length(transaction_types, 1))] = 'صرف' 
                THEN -(RANDOM() * 50 + 1)::NUMERIC(10,2)
                ELSE (RANDOM() * 100 + 1)::NUMERIC(10,2)
            END,
            (RANDOM() * 500 + 10)::NUMERIC(10,2),
            reference_types[1 + (i % array_length(reference_types, 1))],
            (RANDOM() * 1000 + 1)::INTEGER,
            'ملاحظات حركة المخزون رقم ' || i,
            users[1 + (i % array_length(users, 1))],
            1,
            NOW() - (RANDOM() * INTERVAL '180 days')
        );
    END LOOP;
END $$;

-- 13. مراحل سير العمل
INSERT INTO workflow_stages (
    stage_code, stage_name, stage_name_en, description, stage_type,
    requires_approval, auto_advance, max_duration_hours, stage_color,
    icon_name, is_active, created_at, updated_at
) VALUES 
('DRAFT', 'مسودة', 'Draft', 'مرحلة إنشاء الطلبية', 'initial', false, false, 24, '#6b7280', 'edit', true, NOW(), NOW()),
('REVIEW', 'مراجعة', 'Review', 'مرحلة مراجعة الطلبية', 'process', true, false, 48, '#f59e0b', 'eye', true, NOW(), NOW()),
('APPROVE', 'اعتماد', 'Approval', 'مرحلة اعتماد الطلبية', 'approval', true, false, 72, '#10b981', 'check', true, NOW(), NOW()),
('EXECUTE', 'تنفيذ', 'Execution', 'مرحلة تنفيذ الطلبية', 'process', false, false, 168, '#3b82f6', 'play', true, NOW(), NOW()),
('DELIVER', 'تسليم', 'Delivery', 'مرحلة تسليم الطلبية', 'process', false, false, 48, '#8b5cf6', 'truck', true, NOW(), NOW()),
('COMPLETE', 'مكتمل', 'Complete', 'مرحلة اكتمال الطلبية', 'final', false, true, 0, '#059669', 'check-circle', true, NOW(), NOW()),
('CANCEL', 'ملغي', 'Cancelled', 'مرحلة إلغاء الطلبية', 'final', true, true, 0, '#dc2626', 'x-circle', true, NOW(), NOW());

-- 14. تسلسل سير العمل
INSERT INTO workflow_sequences (
    sequence_name, sequence_type, description, is_default, is_active, created_by, created_at, updated_at
) VALUES 
('تسلسل المبيعات الافتراضي', 'sales', 'تسلسل سير العمل الافتراضي لطلبيات المبيعات', true, true, 1, NOW(), NOW()),
('تسلسل المشتريات الافتراضي', 'purchase', 'تسلسل سير العمل الافتراضي لطلبيات المشتريات', true, true, 1, NOW(), NOW());

-- 15. خطوات تسلسل سير العمل
INSERT INTO workflow_sequence_steps (
    sequence_id, stage_id, step_order, next_stage_id, alternative_stage_id, is_optional, conditions, created_at
) VALUES 
-- تسلسل المبيعات
(1, 1, 1, 2, 7, false, 'amount > 0', NOW()),
(1, 2, 2, 3, 7, false, 'reviewed = true', NOW()),
(1, 3, 3, 4, 7, false, 'approved = true', NOW()),
(1, 4, 4, 5, NULL, false, 'executed = true', NOW()),
(1, 5, 5, 6, NULL, false, 'delivered = true', NOW()),
-- تسلسل المشتريات
(2, 1, 1, 2, 7, false, 'amount > 0', NOW()),
(2, 2, 2, 3, 7, false, 'reviewed = true', NOW()),
(2, 3, 3, 4, 7, false, 'approved = true', NOW()),
(2, 4, 4, 6, NULL, false, 'received = true', NOW());

-- 16. حالات سير العمل للطلبيات
DO $$
DECLARE
    i INTEGER;
    order_ids INTEGER[];
    stage_ids INTEGER[] := ARRAY[1, 2, 3, 4, 5, 6];
    departments TEXT[] := ARRAY['المبيعات', 'المراجعة', 'الإدارة', 'المخازن', 'التسليم'];
    users INTEGER[] := ARRAY[1, 2, 3, 4, 5];
    priorities TEXT[] := ARRAY['عادي', 'مهم', 'عاجل'];
BEGIN
    -- الحصول على معرفات طلبيات المبيعات
    SELECT ARRAY_AGG(id) INTO order_ids FROM sales_orders WHERE id <= 50;
    
    FOR i IN 1..50 LOOP
        INSERT INTO order_workflow_status (
            order_id, order_number, order_type, current_stage_id, current_step_order,
            assigned_to_user, assigned_to_department, priority_level, sequence_id,
            stage_start_time, expected_completion_time, is_overdue, notes, created_at, updated_at
        ) VALUES (
            order_ids[i],
            'SO-' || LPAD(i::TEXT, 6, '0'),
            'sales',
            stage_ids[1 + (i % array_length(stage_ids, 1))],
            1 + (i % 5),
            users[1 + (i % array_length(users, 1))],
            departments[1 + (i % array_length(departments, 1))],
            priorities[1 + (i % array_length(priorities, 1))],
            1,
            NOW() - (RANDOM() * INTERVAL '10 days'),
            NOW() + (RANDOM() * INTERVAL '5 days'),
            RANDOM() > 0.8,
            'ملاحظات سير العمل للطلبية رقم ' || i,
            NOW(), NOW()
        );
    END LOOP;
END $$;

-- 17. تاريخ سير العمل
DO $$
DECLARE
    i INTEGER;
    order_ids INTEGER[];
    stage_ids INTEGER[] := ARRAY[1, 2, 3, 4];
    users INTEGER[] := ARRAY[1, 2, 3, 4, 5];
    departments TEXT[] := ARRAY['المبيعات', 'المراجعة', 'الإدارة', 'المخازن'];
    actions TEXT[] := ARRAY['إنشاء', 'مراجعة', 'اعتماد', 'تنفيذ', 'تسليم'];
BEGIN
    SELECT ARRAY_AGG(id) INTO order_ids FROM sales_orders WHERE id <= 30;
    
    FOR i IN 1..100 LOOP
        INSERT INTO workflow_history (
            order_id, order_number, order_type, sequence_id, from_stage_id, to_stage_id,
            from_stage_name, to_stage_name, action_type, performed_by_user, performed_by_username,
            performed_by_department, duration_in_previous_stage, reason, notes, created_at
        ) VALUES (
            order_ids[1 + (i % array_length(order_ids, 1))],
            'SO-' || LPAD((1 + (i % array_length(order_ids, 1)))::TEXT, 6, '0'),
            'sales', 1,
            CASE WHEN i % 4 = 0 THEN NULL ELSE stage_ids[1 + ((i-1) % array_length(stage_ids, 1))] END,
            stage_ids[1 + (i % array_length(stage_ids, 1))],
            CASE WHEN i % 4 = 0 THEN NULL ELSE 'المرحلة السابقة' END,
            'المرحلة الحالية',
            actions[1 + (i % array_length(actions, 1))],
            users[1 + (i % array_length(users, 1))],
            'user' || (1 + (i % array_length(users, 1))),
            departments[1 + (i % array_length(departments, 1))],
            (RANDOM() * INTERVAL '5 days'),
            'سبب الانتقال للمرحلة التالية',
            'ملاحظات تاريخ سير العمل رقم ' || i,
            NOW() - (RANDOM() * INTERVAL '30 days')
        );
    END LOOP;
END $$;

-- 18. الإعدادات العامة
INSERT INTO general_settings (
    organization_id, category, setting_key, setting_value, setting_type,
    description, is_public, created_at, updated_at
) VALUES 
(1, 'system', 'company_logo', '/images/company-logo.png', 'file', 'شعار الشركة', true, NOW(), NOW()),
(1, 'system', 'max_login_attempts', '5', 'integer', 'عدد محاولات تسجيل الدخول المسموحة', false, NOW(), NOW()),
(1, 'system', 'session_timeout', '30', 'integer', 'مهلة انتهاء الجلسة بالدقائق', false, NOW(), NOW()),
(1, 'inventory', 'low_stock_threshold', '10', 'integer', 'حد التنبيه للمخزون المنخفض', false, NOW(), NOW()),
(1, 'inventory', 'auto_reorder', 'true', 'boolean', 'إعادة الطلب التلقائي', false, NOW(), NOW()),
(1, 'sales', 'default_tax_rate', '15', 'decimal', 'معدل الضريبة الافتراضي', false, NOW(), NOW()),
(1, 'sales', 'allow_negative_stock', 'false', 'boolean', 'السماح بالمخزون السالب', false, NOW(), NOW()),
(1, 'notifications', 'email_enabled', 'true', 'boolean', 'تفعيل الإشعارات بالبريد الإلكتروني', false, NOW(), NOW()),
(1, 'notifications', 'sms_enabled', 'true', 'boolean', 'تفعيل الإشعارات بالرسائل النصية', false, NOW(), NOW()),
(1, 'backup', 'auto_backup', 'true', 'boolean', 'النسخ الاحتياطي التلقائي', false, NOW(), NOW());

-- 19. أسعار الصرف
INSERT INTO exchange_rates (
    organization_id, currency_code, currency_name, exchange_rate, buy_rate, sell_rate, last_updated
) VALUES 
(1, 'USD', 'دولار أمريكي', 3.75, 3.74, 3.76, NOW()),
(1, 'EUR', 'يورو', 4.10, 4.08, 4.12, NOW()),
(1, 'GBP', 'جنيه إسترليني', 4.75, 4.73, 4.77, NOW()),
(1, 'AED', 'درهم إماراتي', 1.02, 1.01, 1.03, NOW()),
(1, 'KWD', 'دينار كويتي', 12.25, 12.20, 12.30, NOW()),
(1, 'BHD', 'دينار بحريني', 9.95, 9.90, 10.00, NOW()),
(1, 'QAR', 'ريال قطري', 1.03, 1.02, 1.04, NOW()),
(1, 'OMR', 'ريال عماني', 9.75, 9.70, 9.80, NOW());

-- 20. إعدادات سير العمل
INSERT INTO workflow_settings (
    workflow_system_mandatory, send_notifications, track_time_in_stages,
    allow_skip_stages, allow_parallel_processing, require_approval_notes,
    require_rejection_reason, auto_assign_to_department, created_at, updated_at
) VALUES 
(true, true, true, false, false, true, true, true, NOW(), NOW());

-- 21. الأدوار المخصصة
INSERT INTO custom_roles (
    id, name, name_ar, description, permissions, hierarchy, is_active, created_by, created_at, updated_at
) VALUES 
('role_001', 'Sales Executive', 'مدير مبيعات تنفيذي', 'دور مدير المبيعات التنفيذي مع صلاحيات محدودة',
 '{"sales": {"read": true, "write": true, "delete": false}, "customers": {"read": true, "write": true, "delete": false}, "reports": {"read": true, "write": false, "delete": false}}',
 3, true, 'admin', NOW(), NOW()),
('role_002', 'Inventory Specialist', 'أخصائي مخزون', 'دور أخصائي المخزون مع صلاحيات إدارة المخزون',
 '{"inventory": {"read": true, "write": true, "delete": false}, "products": {"read": true, "write": true, "delete": false}, "suppliers": {"read": true, "write": false, "delete": false}}',
 4, true, 'admin', NOW(), NOW()),
('role_003', 'Financial Analyst', 'محلل مالي', 'دور المحلل المالي مع صلاحيات التقارير المالية',
 '{"reports": {"read": true, "write": true, "delete": false}, "sales": {"read": true, "write": false, "delete": false}, "purchases": {"read": true, "write": false, "delete": false}}',
 5, true, 'admin', NOW(), NOW());

-- 22. تعيين الأدوار للمستخدمين
INSERT INTO user_role_assignments (
    user_id, role_id, assigned_by, assigned_at, expires_at, is_active
) VALUES 
('sales_manager', 'role_001', 'admin', NOW(), NOW() + INTERVAL '1 year', true),
('warehouse_manager', 'role_002', 'admin', NOW(), NOW() + INTERVAL '1 year', true),
('accountant', 'role_003', 'admin', NOW(), NOW() + INTERVAL '1 year', true);

-- 23. سجل الأنشطة
DO $$
DECLARE
    i INTEGER;
    users INTEGER[] := ARRAY[1, 2, 3, 4, 5];
    actions TEXT[] := ARRAY['إنشاء', 'تعديل', 'حذف', 'عرض', 'طباعة'];
    resources TEXT[] := ARRAY['طلبية مبيعات', 'طلبية شراء', 'منتج', 'عميل', 'مورد'];
BEGIN
    FOR i IN 1..200 LOOP
        INSERT INTO organization_activity_log (
            organization_id, user_id, action, resource_type, resource_id,
            details, ip_address, user_agent, created_at
        ) VALUES (
            1,
            users[1 + (i % array_length(users, 1))],
            actions[1 + (i % array_length(actions, 1))],
            resources[1 + (i % array_length(resources, 1))],
            (RANDOM() * 100 + 1)::INTEGER,
            '{"description": "تفاصيل النشاط رقم ' || i || '", "changes": {"field1": "old_value", "field2": "new_value"}}',
            ('192.168.1.' || (1 + (RANDOM() * 254)::INTEGER))::INET,
            'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36',
            NOW() - (RANDOM() * INTERVAL '30 days')
        );
    END LOOP;
END $$;

-- 24. محاولات تسجيل الدخول الفاشلة
DO $$
DECLARE
    i INTEGER;
    usernames TEXT[] := ARRAY['admin', 'test_user', 'hacker', 'guest', 'demo'];
    reasons TEXT[] := ARRAY['كلمة مرور خاطئة', 'اسم مستخدم غير موجود', 'حساب مقفل', 'انتهت صلاحية الحساب'];
BEGIN
    FOR i IN 1..50 LOOP
        INSERT INTO failed_login_attempts (
            username, ip_address, user_agent, failure_reason, attempt_time, created_at
        ) VALUES (
            usernames[1 + (i % array_length(usernames, 1))],
            ('192.168.1.' || (1 + (RANDOM() * 254)::INTEGER)),
            'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36',
            reasons[1 + (i % array_length(reasons, 1))],
            NOW() - (RANDOM() * INTERVAL '7 days'),
            NOW() - (RANDOM() * INTERVAL '7 days')
        );
    END LOOP;
END $$;

-- 25. سجل التدقيق
DO $$
DECLARE
    i INTEGER;
    modules TEXT[] := ARRAY['المبيعات', 'المشتريات', 'المخزون', 'العملاء', 'الموردين'];
    actions TEXT[] := ARRAY['إنشاء', 'تعديل', 'حذف', 'عرض'];
    statuses TEXT[] := ARRAY['نجح', 'فشل', 'تحذير'];
    users TEXT[] := ARRAY['admin', 'sales_manager', 'purchase_manager', 'warehouse_manager', 'accountant'];
BEGIN
    FOR i IN 1..300 LOOP
        INSERT INTO audit_logs (
            user_id, user_name, session_id, module, action, status,
            old_values, new_values, affected_records, details,
            ip_address, user_agent, timestamp, created_at
        ) VALUES (
            'user' || (1 + (i % 5)),
            users[1 + (i % array_length(users, 1))],
            'session_' || LPAD(i::TEXT, 10, '0'),
            modules[1 + (i % array_length(modules, 1))],
            actions[1 + (i % array_length(actions, 1))],
            statuses[1 + (i % array_length(statuses, 1))],
            CASE WHEN actions[1 + (i % array_length(actions, 1))] = 'تعديل' 
                 THEN '{"name": "القيمة القديمة", "price": 100}'::JSONB 
                 ELSE NULL END,
            CASE WHEN actions[1 + (i % array_length(actions, 1))] IN ('إنشاء', 'تعديل') 
                 THEN '{"name": "القيمة الجديدة", "price": 150}'::JSONB 
                 ELSE NULL END,
            '[{"id": ' || i || ', "type": "record"}]'::JSONB,
            'تفاصيل عملية التدقيق رقم ' || i,
            ('192.168.1.' || (1 + (RANDOM() * 254)::INTEGER)),
            'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36',
            NOW() - (RANDOM() * INTERVAL '60 days'),
            NOW() - (RANDOM() * INTERVAL '60 days')
        );
    END LOOP;
END $$;

-- تحديث الإحصائيات
ANALYZE;

-- رسالة النجاح
SELECT 'تم إدخال البيانات التجريبية الشاملة بنجاح!' as message,
       (SELECT COUNT(*) FROM products) as products_count,
       (SELECT COUNT(*) FROM customers) as customers_count,
       (SELECT COUNT(*) FROM suppliers) as suppliers_count,
       (SELECT COUNT(*) FROM sales_orders) as sales_orders_count,
       (SELECT COUNT(*) FROM purchase_orders) as purchase_orders_count,
       (SELECT COUNT(*) FROM user_settings) as users_count,
       (SELECT COUNT(*) FROM inventory_transactions) as inventory_transactions_count;
