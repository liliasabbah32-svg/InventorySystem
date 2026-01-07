-- إدخال 100 صنف تجريبي يغطي جميع الاحتمالات لفحص شاشة الصنف
-- Insert 100 test products covering all field possibilities

-- حذف البيانات التجريبية السابقة إذا كانت موجودة
DELETE FROM product_warehouse_stock WHERE product_id IN (
    SELECT id FROM products WHERE product_code LIKE 'TEST%'
);
DELETE FROM products WHERE product_code LIKE 'TEST%';

-- إدخال 100 صنف تجريبي
INSERT INTO products (
    product_code, product_name, product_name_en, barcode, description, 
    category, subcategory, brand, model, main_unit, secondary_unit, conversion_factor,
    last_purchase_price, average_cost, selling_price, wholesale_price, retail_price,
    currency, tax_rate, discount_rate, min_stock_level, max_quantity, reorder_point,
    location, shelf_life, expiry_tracking, batch_tracking, serial_tracking,
    status, supplier_name, supplier_code, supplier_id, manufacturer, country_of_origin,
    weight, dimensions, color, size, material, warranty_period, image_url, notes,
    has_colors, has_expiry, has_batch, product_type, classifications, order_quantity,
    original_number, manufacturer_number, attachments, general_notes, entry_date
) VALUES 
-- إلكترونيات (20 صنف)
('TEST001', 'جهاز كمبيوتر محمول ديل', 'Dell Laptop Computer', '1234567890123', 'جهاز كمبيوتر محمول عالي الأداء للأعمال والألعاب', 'إلكترونيات', 'أجهزة كمبيوتر', 'ديل', 'Inspiron 15 3000', 'قطعة', 'صندوق', 1, 2500.00, 2600.00, 3200.00, 3000.00, 3100.00, 'ريال سعودي', 15.00, 5.00, 5, 100, 10, 'A1-R1-S1', 1095, false, true, true, 'نشط', 'شركة التقنية المتقدمة', 'SUP001', 1, 'Dell Inc.', 'الولايات المتحدة', 2.5, '35×25×2 سم', 'أسود', '15 بوصة', 'بلاستيك وألومنيوم', 24, '/images/dell-laptop.jpg', 'جهاز عالي الجودة مع ضمان شامل', true, false, true, 'منتج نهائي', 'إلكترونيات متقدمة', 1, 'DELL-INS-15', 'MFG-DELL-001', 'warranty.pdf', 'منتج أصلي بضمان الوكيل', '2024-01-15'),

('TEST002', 'هاتف ذكي سامسونج جالاكسي', 'Samsung Galaxy Smartphone', '2345678901234', 'هاتف ذكي متطور بكاميرا عالية الدقة', 'إلكترونيات', 'هواتف ذكية', 'سامسونج', 'Galaxy S23', 'قطعة', 'علبة', 1, 1800.00, 1900.00, 2400.00, 2200.00, 2300.00, 'ريال سعودي', 15.00, 3.00, 10, 200, 20, 'A2-R1-S2', 730, false, true, true, 'نشط', 'موزع الهواتف الذكية', 'SUP002', 2, 'Samsung Electronics', 'كوريا الجنوبية', 0.195, '15×7×0.8 سم', 'أزرق', '6.1 بوصة', 'زجاج وألومنيوم', 12, '/images/samsung-phone.jpg', 'هاتف بمواصفات عالية وبطارية طويلة المدى', true, false, true, 'منتج نهائي', 'إلكترونيات استهلاكية', 1, 'SAM-GAL-S23', 'MFG-SAM-002', 'manual.pdf', 'منتج أصلي بضمان دولي', '2024-01-16'),

('TEST003', 'تلفزيون ذكي إل جي', 'LG Smart TV', '3456789012345', 'تلفزيون ذكي بدقة 4K وتقنية OLED', 'إلكترونيات', 'أجهزة تلفزيون', 'إل جي', 'OLED55C3', 'قطعة', 'كرتون', 1, 3500.00, 3600.00, 4500.00, 4200.00, 4300.00, 'ريال سعودي', 15.00, 7.00, 3, 50, 5, 'B1-R2-S1', 1825, false, true, true, 'نشط', 'وكيل الأجهزة المنزلية', 'SUP003', 3, 'LG Electronics', 'كوريا الجنوبية', 18.5, '123×71×25 سم', 'أسود', '55 بوصة', 'بلاستيك ومعدن', 24, '/images/lg-tv.jpg', 'تلفزيون بجودة صورة استثنائية', false, false, true, 'منتج نهائي', 'إلكترونيات منزلية', 1, 'LG-OLED-55', 'MFG-LG-003', 'setup.pdf', 'تلفزيون ذكي بتقنيات متقدمة', '2024-01-17'),

('TEST004', 'سماعات لاسلكية آبل', 'Apple AirPods Wireless', '4567890123456', 'سماعات لاسلكية عالية الجودة مع إلغاء الضوضاء', 'إلكترونيات', 'سماعات', 'آبل', 'AirPods Pro 2', 'قطعة', 'علبة', 1, 800.00, 850.00, 1100.00, 1000.00, 1050.00, 'ريال سعودي', 15.00, 2.00, 15, 300, 30, 'A3-R1-S3', 1095, false, true, true, 'نشط', 'موزع منتجات آبل', 'SUP004', 4, 'Apple Inc.', 'الولايات المتحدة', 0.056, '6×4.5×2.5 سم', 'أبيض', 'صغير', 'بلاستيك ومعدن', 12, '/images/airpods.jpg', 'سماعات بتقنية إلغاء الضوضاء النشطة', true, false, true, 'منتج نهائي', 'إكسسوارات إلكترونية', 1, 'APL-AIRP-PRO2', 'MFG-APL-004', 'guide.pdf', 'سماعات أصلية بضمان آبل', '2024-01-18'),

('TEST005', 'كاميرا رقمية كانون', 'Canon Digital Camera', '5678901234567', 'كاميرا رقمية احترافية للتصوير الفوتوغرافي', 'إلكترونيات', 'كاميرات', 'كانون', 'EOS R6 Mark II', 'قطعة', 'حقيبة', 1, 4200.00, 4300.00, 5500.00, 5200.00, 5300.00, 'ريال سعودي', 15.00, 8.00, 2, 30, 3, 'C1-R1-S1', 1825, false, true, true, 'نشط', 'معرض الكاميرات المحترف', 'SUP005', 5, 'Canon Inc.', 'اليابان', 0.598, '13.8×9.8×8.8 سم', 'أسود', 'متوسط', 'معدن وبلاستيك', 24, '/images/canon-camera.jpg', 'كاميرا احترافية بدقة عالية ومثبت صورة', false, false, true, 'منتج نهائي', 'معدات تصوير', 1, 'CAN-EOS-R6M2', 'MFG-CAN-005', 'manual.pdf', 'كاميرا احترافية بضمان دولي', '2024-01-19'),

-- ملابس (15 صنف)
('TEST006', 'قميص رجالي قطني', 'Men Cotton Shirt', '6789012345678', 'قميص رجالي أنيق من القطن الخالص', 'ملابس', 'ملابس رجالية', 'لاكوست', 'Classic Fit', 'قطعة', 'كيس', 12, 120.00, 130.00, 180.00, 160.00, 170.00, 'ريال سعودي', 15.00, 10.00, 50, 500, 100, 'D1-R1-S1', 1095, false, false, false, 'نشط', 'مصنع الملابس الراقية', 'SUP006', 6, 'Lacoste SA', 'فرنسا', 0.3, '70×50×2 سم', 'أزرق', 'كبير', 'قطن 100%', 0, '/images/shirt.jpg', 'قميص عالي الجودة مناسب للمناسبات الرسمية', true, false, false, 'منتج نهائي', 'ملابس كاجوال', 12, 'LAC-SHIRT-001', 'MFG-LAC-006', 'care.pdf', 'قميص أصلي بجودة عالية', '2024-01-20'),

('TEST007', 'فستان نسائي أنيق', 'Elegant Women Dress', '7890123456789', 'فستان نسائي أنيق للمناسبات الخاصة', 'ملابس', 'ملابس نسائية', 'زارا', 'Evening Collection', 'قطعة', 'علبة', 1, 200.00, 220.00, 320.00, 280.00, 300.00, 'ريال سعودي', 15.00, 15.00, 30, 200, 50, 'D2-R1-S2', 730, false, false, false, 'نشط', 'بوتيك الأزياء النسائية', 'SUP007', 7, 'Zara International', 'إسبانيا', 0.4, '120×80×3 سم', 'أحمر', 'متوسط', 'بوليستر وحرير', 0, '/images/dress.jpg', 'فستان أنيق بتصميم عصري وخامات فاخرة', true, false, false, 'منتج نهائي', 'أزياء راقية', 1, 'ZAR-DRESS-001', 'MFG-ZAR-007', 'size-guide.pdf', 'فستان بتصميم أوروبي راقي', '2024-01-21'),

('TEST008', 'حذاء رياضي نايكي', 'Nike Sports Shoes', '8901234567890', 'حذاء رياضي مريح للجري والتمارين', 'ملابس', 'أحذية رياضية', 'نايكي', 'Air Max 270', 'زوج', 'صندوق', 1, 300.00, 320.00, 450.00, 400.00, 425.00, 'ريال سعودي', 15.00, 5.00, 25, 150, 40, 'E1-R1-S1', 1095, false, false, false, 'نشط', 'متجر الأحذية الرياضية', 'SUP008', 8, 'Nike Inc.', 'الولايات المتحدة', 0.8, '32×20×12 سم', 'أسود وأبيض', '42', 'جلد صناعي ومطاط', 6, '/images/nike-shoes.jpg', 'حذاء رياضي بتقنية امتصاص الصدمات', true, false, false, 'منتج نهائي', 'أحذية رياضية', 1, 'NIK-AIRMAX-270', 'MFG-NIK-008', 'care.pdf', 'حذاء أصلي بضمان نايكي', '2024-01-22'),

-- أغذية (20 صنف)
('TEST009', 'أرز بسمتي هندي', 'Indian Basmati Rice', '9012345678901', 'أرز بسمتي عالي الجودة من الهند', 'أغذية', 'حبوب', 'تيلدا', 'Premium Basmati', 'كيلو', 'كيس', 25, 15.00, 16.00, 22.00, 20.00, 21.00, 'ريال سعودي', 0.00, 0.00, 100, 1000, 200, 'F1-R1-S1', 365, true, true, false, 'نشط', 'مستورد المواد الغذائية', 'SUP009', 9, 'Tilda Ltd', 'الهند', 25.0, '50×30×10 سم', 'أبيض', '25 كيلو', 'أرز طبيعي', 0, '/images/rice.jpg', 'أرز بسمتي طويل الحبة وعطري', false, true, true, 'مادة خام', 'مواد غذائية أساسية', 25, 'TIL-RICE-BAS', 'MFG-TIL-009', 'nutrition.pdf', 'أرز طبيعي بدون إضافات', '2024-01-23'),

('TEST010', 'زيت زيتون بكر ممتاز', 'Extra Virgin Olive Oil', '0123456789012', 'زيت زيتون بكر ممتاز من إسبانيا', 'أغذية', 'زيوت', 'بورجيس', 'Extra Virgin', 'لتر', 'زجاجة', 1, 45.00, 48.00, 65.00, 58.00, 62.00, 'ريال سعودي', 0.00, 0.00, 50, 300, 80, 'F2-R1-S2', 730, true, true, false, 'نشط', 'شركة الزيوت الطبيعية', 'SUP010', 10, 'Borges International', 'إسبانيا', 1.0, '25×8×8 سم', 'ذهبي', '1 لتر', 'زيت زيتون طبيعي', 0, '/images/olive-oil.jpg', 'زيت زيتون بكر ممتاز بطعم مميز', false, true, true, 'منتج نهائي', 'زيوت طبيعية', 1, 'BOR-OLIVE-EV', 'MFG-BOR-010', 'origin.pdf', 'زيت زيتون أصلي من بساتين إسبانيا', '2024-01-24'),

-- مشروبات (10 صنف)
('TEST011', 'عصير برتقال طبيعي', 'Natural Orange Juice', '1234567890124', 'عصير برتقال طبيعي 100% بدون إضافات', 'مشروبات', 'عصائر طبيعية', 'المراعي', 'Fresh Orange', 'لتر', 'كرتون', 12, 8.00, 9.00, 14.00, 12.00, 13.00, 'ريال سعودي', 0.00, 0.00, 200, 1000, 300, 'F3-R1-S1', 14, true, true, false, 'نشط', 'شركة المراعي للألبان', 'SUP011', 11, 'Almarai Company', 'السعودية', 1.0, '20×10×10 سم', 'برتقالي', '1 لتر', 'عصير طبيعي', 0, '/images/orange-juice.jpg', 'عصير برتقال طازج ومنعش', false, true, true, 'منتج نهائي', 'مشروبات طبيعية', 12, 'ALM-JUICE-OR', 'MFG-ALM-011', 'nutrition.pdf', 'عصير طبيعي بدون مواد حافظة', '2024-01-25'),

-- أدوية (10 صنف)
('TEST012', 'باراسيتامول أقراص', 'Paracetamol Tablets', '2345678901235', 'أقراص باراسيتامول لتسكين الألم وخفض الحرارة', 'أدوية', 'مسكنات', 'سبيماكو', 'Panadol', 'علبة', 'كرتون', 20, 12.00, 13.00, 18.00, 16.00, 17.00, 'ريال سعودي', 0.00, 0.00, 500, 2000, 800, 'M1-R1-S1', 1095, true, true, true, 'نشط', 'شركة الأدوية الوطنية', 'SUP012', 12, 'Spimaco Pharmaceutical', 'السعودية', 0.1, '12×8×3 سم', 'أبيض', '20 قرص', 'دواء', 0, '/images/paracetamol.jpg', 'دواء آمن وفعال لتسكين الألم', false, true, true, 'منتج نهائي', 'أدوية بدون وصفة', 20, 'SPI-PARA-500', 'MFG-SPI-012', 'leaflet.pdf', 'دواء مرخص من وزارة الصحة', '2024-01-26'),

-- مستحضرات تجميل (10 صنف)
('TEST013', 'كريم مرطب للوجه', 'Face Moisturizing Cream', '3456789012346', 'كريم مرطب للوجه بخلاصة الألوة فيرا', 'مستحضرات تجميل', 'كريمات', 'نيفيا', 'Daily Moisture', 'قطعة', 'علبة', 1, 25.00, 28.00, 40.00, 35.00, 38.00, 'ريال سعودي', 15.00, 5.00, 100, 500, 150, 'C2-R1-S1', 1095, true, true, false, 'نشط', 'موزع مستحضرات التجميل', 'SUP013', 13, 'Nivea (Beiersdorf)', 'ألمانيا', 0.15, '10×10×5 سم', 'أبيض', '50 مل', 'كريم طبيعي', 0, '/images/face-cream.jpg', 'كريم مرطب بتركيبة لطيفة على البشرة', false, true, true, 'منتج نهائي', 'مستحضرات العناية', 1, 'NIV-CREAM-FACE', 'MFG-NIV-013', 'ingredients.pdf', 'كريم بمكونات طبيعية آمنة', '2024-01-27'),

-- أدوات منزلية (5 صنف)
('TEST014', 'مقلاة تيفال غير لاصقة', 'Tefal Non-Stick Pan', '4567890123457', 'مقلاة طبخ غير لاصقة عالية الجودة', 'أدوات منزلية', 'أدوات طبخ', 'تيفال', 'Excellence', 'قطعة', 'صندوق', 1, 85.00, 90.00, 130.00, 115.00, 125.00, 'ريال سعودي', 15.00, 8.00, 30, 200, 50, 'H1-R1-S1', 3650, false, false, true, 'نشط', 'متجر الأدوات المنزلية', 'SUP014', 14, 'Tefal (SEB Group)', 'فرنسا', 1.2, '28×28×5 سم', 'أسود', '28 سم', 'ألومنيوم وتيفلون', 24, '/images/tefal-pan.jpg', 'مقلاة بطلاء غير لاصق ومقاوم للخدش', false, false, true, 'منتج نهائي', 'أدوات طبخ', 1, 'TEF-PAN-28', 'MFG-TEF-014', 'care.pdf', 'مقلاة بضمان الجودة الفرنسية', '2024-01-28'),

-- كتب (3 صنف)
('TEST015', 'كتاب إدارة الأعمال', 'Business Management Book', '5678901234568', 'كتاب شامل في إدارة الأعمال والقيادة', 'كتب', 'كتب إدارة', 'دار النهضة', 'الإدارة الحديثة', 'قطعة', 'كيس', 10, 45.00, 48.00, 70.00, 60.00, 65.00, 'ريال سعودي', 0.00, 10.00, 50, 300, 80, 'B2-R1-S1', 3650, false, false, false, 'نشط', 'دار النشر العربية', 'SUP015', 15, 'دار النهضة العربية', 'لبنان', 0.8, '24×17×3 سم', 'متعدد', 'كبير', 'ورق', 0, '/images/business-book.jpg', 'كتاب مرجعي في الإدارة الحديثة', false, false, false, 'منتج نهائي', 'كتب تعليمية', 1, 'DAR-BUS-MGT', 'MFG-DAR-015', 'contents.pdf', 'كتاب بمحتوى علمي متميز', '2024-01-29'),

-- ألعاب (2 صنف)
('TEST016', 'لعبة ليجو للأطفال', 'LEGO Building Blocks', '6789012345679', 'مجموعة ألعاب ليجو لتنمية الإبداع', 'ألعاب', 'ألعاب تعليمية', 'ليجو', 'Creator Expert', 'قطعة', 'صندوق', 1, 180.00, 190.00, 280.00, 240.00, 260.00, 'ريال سعودي', 15.00, 5.00, 20, 100, 30, 'T1-R1-S1', 3650, false, false, true, 'نشط', 'متجر ألعاب الأطفال', 'SUP016', 16, 'LEGO Group', 'الدنمارك', 2.5, '35×25×15 سم', 'متعدد', 'كبير', 'بلاستيك ABS', 0, '/images/lego-set.jpg', 'لعبة تعليمية لتطوير المهارات الحركية', true, false, true, 'منتج نهائي', 'ألعاب تعليمية', 1, 'LEG-CREAT-EXP', 'MFG-LEG-016', 'instructions.pdf', 'لعبة آمنة ومعتمدة دولياً', '2024-01-30'),

-- رياضة (5 صنف)
('TEST017', 'كرة قدم جلدية', 'Leather Football', '7890123456780', 'كرة قدم جلدية احترافية للملاعب', 'رياضة', 'كرات رياضية', 'أديداس', 'Tango España', 'قطعة', 'كيس', 1, 120.00, 130.00, 180.00, 160.00, 170.00, 'ريال سعودي', 15.00, 3.00, 50, 200, 80, 'S1-R1-S1', 1825, false, false, false, 'نشط', 'متجر المعدات الرياضية', 'SUP017', 17, 'Adidas AG', 'ألمانيا', 0.45, '22×22×22 سم', 'أبيض وأسود', 'حجم 5', 'جلد طبيعي', 12, '/images/football.jpg', 'كرة قدم بمواصفات FIFA المعتمدة', false, false, false, 'منتج نهائي', 'معدات رياضية', 1, 'ADI-FOOT-TANGO', 'MFG-ADI-017', 'fifa-cert.pdf', 'كرة معتمدة للمباريات الرسمية', '2024-01-31'),

-- سيارات (5 صنف)
('TEST018', 'إطار سيارة ميشلان', 'Michelin Car Tire', '8901234567891', 'إطار سيارة عالي الجودة للطرق المختلطة', 'سيارات', 'إطارات', 'ميشلان', 'Primacy 4', 'قطعة', 'إطار', 1, 450.00, 480.00, 650.00, 580.00, 620.00, 'ريال سعودي', 15.00, 5.00, 20, 100, 30, 'A4-R1-S1', 1825, false, false, true, 'نشط', 'معرض الإطارات المتخصص', 'SUP018', 18, 'Michelin Group', 'فرنسا', 12.5, '65×65×25 سم', 'أسود', '205/55R16', 'مطاط مقوى', 60, '/images/michelin-tire.jpg', 'إطار بتقنية متقدمة للأمان والراحة', false, false, true, 'منتج نهائي', 'قطع غيار سيارات', 1, 'MIC-PRIM4-205', 'MFG-MIC-018', 'warranty.pdf', 'إطار بضمان الجودة الفرنسية', '2024-02-01'),

-- أصناف أخرى متنوعة (15 صنف)
('TEST019', 'بطارية ليثيوم قابلة للشحن', 'Rechargeable Lithium Battery', '9012345678902', 'بطارية ليثيوم عالية الأداء قابلة للشحن', 'إلكترونيات', 'بطاريات', 'دوراسيل', 'Ultra Lithium', 'قطعة', 'علبة', 4, 35.00, 38.00, 55.00, 48.00, 52.00, 'ريال سعودي', 15.00, 2.00, 100, 500, 150, 'A5-R1-S1', 1095, false, true, true, 'نشط', 'موزع البطاريات', 'SUP019', 19, 'Duracell Inc.', 'الولايات المتحدة', 0.025, '5×1.4×1.4 سم', 'ذهبي', 'AA', 'ليثيوم', 120, '/images/battery.jpg', 'بطارية طويلة المدى وقابلة للشحن', false, false, true, 'منتج نهائي', 'مصادر طاقة', 4, 'DUR-LITH-AA', 'MFG-DUR-019', 'safety.pdf', 'بطارية آمنة وصديقة للبيئة', '2024-02-02'),

('TEST020', 'قلم حبر جاف فاخر', 'Luxury Ballpoint Pen', '0123456789013', 'قلم حبر جاف فاخر للكتابة الراقية', 'أخرى', 'أدوات مكتبية', 'باركر', 'Jotter Premium', 'قطعة', 'علبة', 1, 85.00, 90.00, 140.00, 120.00, 130.00, 'ريال سعودي', 15.00, 8.00, 50, 200, 75, 'O1-R1-S1', 3650, false, false, true, 'نشط', 'متجر الأدوات المكتبية الفاخرة', 'SUP020', 20, 'Parker Pen Company', 'المملكة المتحدة', 0.03, '14×1×1 سم', 'فضي', 'متوسط', 'معدن وبلاستيك', 24, '/images/parker-pen.jpg', 'قلم أنيق بتصميم كلاسيكي وجودة عالية', true, false, true, 'منتج نهائي', 'أدوات كتابة فاخرة', 1, 'PAR-JOTT-PREM', 'MFG-PAR-020', 'warranty.pdf', 'قلم بضمان الجودة البريطانية', '2024-02-03');

-- إضافة المزيد من الأصناف لتصل إلى 100 صنف
INSERT INTO products (
    product_code, product_name, product_name_en, barcode, description, 
    category, subcategory, brand, model, main_unit, secondary_unit, conversion_factor,
    last_purchase_price, average_cost, selling_price, wholesale_price, retail_price,
    currency, tax_rate, discount_rate, min_stock_level, max_quantity, reorder_point,
    location, shelf_life, expiry_tracking, batch_tracking, serial_tracking,
    status, supplier_name, supplier_code, supplier_id, manufacturer, country_of_origin,
    weight, dimensions, color, size, material, warranty_period, image_url, notes,
    has_colors, has_expiry, has_batch, product_type, classifications, order_quantity,
    original_number, manufacturer_number, attachments, general_notes, entry_date
) 
SELECT 
    'TEST' || LPAD((ROW_NUMBER() OVER() + 20)::text, 3, '0'),
    CASE (ROW_NUMBER() OVER() % 10)
        WHEN 1 THEN 'منتج تجريبي ' || (ROW_NUMBER() OVER() + 20)
        WHEN 2 THEN 'صنف اختبار ' || (ROW_NUMBER() OVER() + 20)
        WHEN 3 THEN 'عنصر تجريبي ' || (ROW_NUMBER() OVER() + 20)
        WHEN 4 THEN 'مادة اختبار ' || (ROW_NUMBER() OVER() + 20)
        WHEN 5 THEN 'قطعة تجريبية ' || (ROW_NUMBER() OVER() + 20)
        WHEN 6 THEN 'وحدة اختبار ' || (ROW_NUMBER() OVER() + 20)
        WHEN 7 THEN 'جهاز تجريبي ' || (ROW_NUMBER() OVER() + 20)
        WHEN 8 THEN 'أداة اختبار ' || (ROW_NUMBER() OVER() + 20)
        WHEN 9 THEN 'مكون تجريبي ' || (ROW_NUMBER() OVER() + 20)
        ELSE 'عنصر تجريبي ' || (ROW_NUMBER() OVER() + 20)
    END,
    'Test Product ' || (ROW_NUMBER() OVER() + 20),
    LPAD((ROW_NUMBER() OVER() + 20)::text, 13, '0'),
    'وصف تفصيلي للمنتج التجريبي رقم ' || (ROW_NUMBER() OVER() + 20),
    CASE (ROW_NUMBER() OVER() % 12)
        WHEN 1 THEN 'إلكترونيات'
        WHEN 2 THEN 'ملابس'
        WHEN 3 THEN 'أغذية'
        WHEN 4 THEN 'مشروبات'
        WHEN 5 THEN 'أدوية'
        WHEN 6 THEN 'مستحضرات تجميل'
        WHEN 7 THEN 'أدوات منزلية'
        WHEN 8 THEN 'كتب'
        WHEN 9 THEN 'ألعاب'
        WHEN 10 THEN 'رياضة'
        WHEN 11 THEN 'سيارات'
        ELSE 'أخرى'
    END,
    'فئة فرعية ' || (ROW_NUMBER() OVER() % 5 + 1),
    'علامة تجارية ' || (ROW_NUMBER() OVER() % 8 + 1),
    'موديل ' || (ROW_NUMBER() OVER() % 6 + 1),
    CASE (ROW_NUMBER() OVER() % 10)
        WHEN 1 THEN 'قطعة'
        WHEN 2 THEN 'كيلو'
        WHEN 3 THEN 'لتر'
        WHEN 4 THEN 'متر'
        WHEN 5 THEN 'صندوق'
        WHEN 6 THEN 'كرتون'
        WHEN 7 THEN 'علبة'
        WHEN 8 THEN 'زجاجة'
        WHEN 9 THEN 'كيس'
        ELSE 'جرام'
    END,
    CASE (ROW_NUMBER() OVER() % 8)
        WHEN 1 THEN 'علبة'
        WHEN 2 THEN 'صندوق'
        WHEN 3 THEN 'كرتون'
        WHEN 4 THEN 'كيس'
        WHEN 5 THEN 'زجاجة'
        WHEN 6 THEN 'حقيبة'
        WHEN 7 THEN 'حاوية'
        ELSE 'وحدة'
    END,
    CASE (ROW_NUMBER() OVER() % 5) WHEN 0 THEN 1 ELSE (ROW_NUMBER() OVER() % 5) END,
    (RANDOM() * 1000 + 10)::DECIMAL(10,2),
    (RANDOM() * 1000 + 15)::DECIMAL(10,2),
    (RANDOM() * 1500 + 20)::DECIMAL(10,2),
    (RANDOM() * 1300 + 18)::DECIMAL(10,2),
    (RANDOM() * 1400 + 19)::DECIMAL(10,2),
    CASE (ROW_NUMBER() OVER() % 4)
        WHEN 1 THEN 'ريال سعودي'
        WHEN 2 THEN 'دولار أمريكي'
        WHEN 3 THEN 'يورو'
        ELSE 'شيكل إسرائيلي'
    END,
    CASE (ROW_NUMBER() OVER() % 3) WHEN 0 THEN 0 WHEN 1 THEN 5 ELSE 15 END,
    (RANDOM() * 20)::DECIMAL(5,2),
    (RANDOM() * 200 + 10)::INTEGER,
    (RANDOM() * 1000 + 100)::INTEGER,
    (RANDOM() * 100 + 20)::INTEGER,
    'موقع ' || CHR(65 + (ROW_NUMBER() OVER() % 5)) || (ROW_NUMBER() OVER() % 3 + 1) || '-R' || (ROW_NUMBER() OVER() % 2 + 1) || '-S' || (ROW_NUMBER() OVER() % 3 + 1),
    CASE (ROW_NUMBER() OVER() % 4) WHEN 0 THEN 0 WHEN 1 THEN 365 WHEN 2 THEN 730 ELSE 1095 END,
    (ROW_NUMBER() OVER() % 3) = 1,
    (ROW_NUMBER() OVER() % 3) = 2,
    (ROW_NUMBER() OVER() % 4) = 1,
    CASE (ROW_NUMBER() OVER() % 3) WHEN 0 THEN 'نشط' WHEN 1 THEN 'غير نشط' ELSE 'متوقف' END,
    'مورد تجريبي ' || (ROW_NUMBER() OVER() % 10 + 1),
    'SUP' || LPAD((ROW_NUMBER() OVER() % 10 + 21)::text, 3, '0'),
    (ROW_NUMBER() OVER() % 10 + 21),
    'شركة مصنعة ' || (ROW_NUMBER() OVER() % 8 + 1),
    CASE (ROW_NUMBER() OVER() % 15)
        WHEN 1 THEN 'السعودية' WHEN 2 THEN 'الإمارات' WHEN 3 THEN 'الكويت'
        WHEN 4 THEN 'قطر' WHEN 5 THEN 'البحرين' WHEN 6 THEN 'عمان'
        WHEN 7 THEN 'الأردن' WHEN 8 THEN 'لبنان' WHEN 9 THEN 'سوريا'
        WHEN 10 THEN 'العراق' WHEN 11 THEN 'مصر' WHEN 12 THEN 'المغرب'
        WHEN 13 THEN 'تونس' WHEN 14 THEN 'الجزائر' ELSE 'أخرى'
    END,
    (RANDOM() * 50 + 0.1)::DECIMAL(10,3),
    (10 + ROW_NUMBER() OVER() % 50) || '×' || (5 + ROW_NUMBER() OVER() % 30) || '×' || (2 + ROW_NUMBER() OVER() % 20) || ' سم',
    CASE (ROW_NUMBER() OVER() % 8)
        WHEN 1 THEN 'أحمر' WHEN 2 THEN 'أزرق' WHEN 3 THEN 'أخضر'
        WHEN 4 THEN 'أصفر' WHEN 5 THEN 'أسود' WHEN 6 THEN 'أبيض'
        WHEN 7 THEN 'بني' ELSE 'متعدد'
    END,
    CASE (ROW_NUMBER() OVER() % 5)
        WHEN 1 THEN 'صغير' WHEN 2 THEN 'متوسط' WHEN 3 THEN 'كبير'
        WHEN 4 THEN 'كبير جداً' ELSE 'قياس خاص'
    END,
    CASE (ROW_NUMBER() OVER() % 6)
        WHEN 1 THEN 'بلاستيك' WHEN 2 THEN 'معدن' WHEN 3 THEN 'خشب'
        WHEN 4 THEN 'زجاج' WHEN 5 THEN 'قماش' ELSE 'مواد مختلطة'
    END,
    CASE (ROW_NUMBER() OVER() % 5) WHEN 0 THEN 0 WHEN 1 THEN 6 WHEN 2 THEN 12 WHEN 3 THEN 24 ELSE 36 END,
    '/images/test-product-' || (ROW_NUMBER() OVER() + 20) || '.jpg',
    'ملاحظات تفصيلية للمنتج التجريبي رقم ' || (ROW_NUMBER() OVER() + 20) || ' مع معلومات إضافية مهمة',
    (ROW_NUMBER() OVER() % 3) = 1,
    (ROW_NUMBER() OVER() % 4) = 1,
    (ROW_NUMBER() OVER() % 3) = 1,
    CASE (ROW_NUMBER() OVER() % 3) WHEN 0 THEN 'منتج نهائي' WHEN 1 THEN 'مادة خام' ELSE 'منتج وسطي' END,
    'تصنيف ' || (ROW_NUMBER() OVER() % 5 + 1),
    CASE (ROW_NUMBER() OVER() % 4) WHEN 0 THEN 1 WHEN 1 THEN 5 WHEN 2 THEN 10 ELSE 20 END,
    'ORG-' || LPAD((ROW_NUMBER() OVER() + 20)::text, 3, '0'),
    'MFG-' || LPAD((ROW_NUMBER() OVER() + 20)::text, 3, '0'),
    'document' || (ROW_NUMBER() OVER() + 20) || '.pdf',
    'ملاحظات عامة للمنتج التجريبي مع تفاصيل إضافية',
    CURRENT_DATE - (ROW_NUMBER() OVER() % 365)
FROM generate_series(1, 80);

-- إدخال بيانات المستودعات للمنتجات التجريبية
INSERT INTO product_warehouse_stock (
    product_id, warehouse_name, available_quantity, reserved_quantity, 
    actual_balance, inventory_value, stock_status, batch_number, 
    expiry_date, manufacturing_date, serial_number, location
)
SELECT 
    p.id,
    CASE (ROW_NUMBER() OVER() % 5)
        WHEN 1 THEN 'المستودع الرئيسي'
        WHEN 2 THEN 'مستودع المبيعات'
        WHEN 3 THEN 'مستودع الإنتاج'
        WHEN 4 THEN 'مستودع التالف'
        ELSE 'مستودع الإرجاع'
    END,
    (RANDOM() * 500 + 10)::INTEGER,
    (RANDOM() * 50)::INTEGER,
    (RANDOM() * 450 + 10)::INTEGER,
    (RANDOM() * 10000 + 100)::DECIMAL(15,2),
    CASE (ROW_NUMBER() OVER() % 5)
        WHEN 1 THEN 'متوفر'
        WHEN 2 THEN 'تحت الحد الأدنى'
        WHEN 3 THEN 'نفد المخزون'
        WHEN 4 THEN 'محجوز'
        ELSE 'تالف'
    END,
    CASE WHEN p.batch_tracking THEN 'BATCH-' || LPAD((ROW_NUMBER() OVER())::text, 6, '0') ELSE NULL END,
    CASE WHEN p.expiry_tracking THEN CURRENT_DATE + (ROW_NUMBER() OVER() % 365 + 30) ELSE NULL END,
    CASE WHEN p.expiry_tracking THEN CURRENT_DATE - (ROW_NUMBER() OVER() % 180 + 10) ELSE NULL END,
    CASE WHEN p.serial_tracking THEN 'SN-' || LPAD((ROW_NUMBER() OVER())::text, 8, '0') ELSE NULL END,
    p.location
FROM products p 
WHERE p.product_code LIKE 'TEST%'
ORDER BY p.id;

-- إضافة المزيد من بيانات المستودعات (مستودع ثاني لكل منتج)
INSERT INTO product_warehouse_stock (
    product_id, warehouse_name, available_quantity, reserved_quantity, 
    actual_balance, inventory_value, stock_status, batch_number, 
    expiry_date, manufacturing_date, serial_number, location
)
SELECT 
    p.id,
    CASE (ROW_NUMBER() OVER() % 3)
        WHEN 1 THEN 'مستودع المبيعات'
        WHEN 2 THEN 'مستودع الإنتاج'
        ELSE 'مستودع الإرجاع'
    END,
    (RANDOM() * 200 + 5)::INTEGER,
    (RANDOM() * 20)::INTEGER,
    (RANDOM() * 180 + 5)::INTEGER,
    (RANDOM() * 5000 + 50)::DECIMAL(15,2),
    CASE (ROW_NUMBER() OVER() % 4)
        WHEN 1 THEN 'متوفر'
        WHEN 2 THEN 'تحت الحد الأدنى'
        WHEN 3 THEN 'محجوز'
        ELSE 'متوفر'
    END,
    CASE WHEN p.batch_tracking THEN 'BATCH-' || LPAD((ROW_NUMBER() OVER() + 1000)::text, 6, '0') ELSE NULL END,
    CASE WHEN p.expiry_tracking THEN CURRENT_DATE + (ROW_NUMBER() OVER() % 200 + 60) ELSE NULL END,
    CASE WHEN p.expiry_tracking THEN CURRENT_DATE - (ROW_NUMBER() OVER() % 120 + 5) ELSE NULL END,
    CASE WHEN p.serial_tracking THEN 'SN-' || LPAD((ROW_NUMBER() OVER() + 10000)::text, 8, '0') ELSE NULL END,
    p.location || '-B'
FROM products p 
WHERE p.product_code LIKE 'TEST%' AND (ROW_NUMBER() OVER()) % 2 = 0
ORDER BY p.id;

-- تحديث إحصائيات الجداول
ANALYZE products;
ANALYZE product_warehouse_stock;

-- عرض ملخص البيانات المدخلة
SELECT 
    'تم إدخال ' || COUNT(*) || ' صنف تجريبي بنجاح' as summary
FROM products 
WHERE product_code LIKE 'TEST%';

SELECT 
    'تم إدخال ' || COUNT(*) || ' سجل مخزون في المستودعات' as warehouse_summary
FROM product_warehouse_stock pws
JOIN products p ON pws.product_id = p.id
WHERE p.product_code LIKE 'TEST%';
