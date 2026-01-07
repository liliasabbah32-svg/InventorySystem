-- إدخال 10 طلبيات مبيعات تجريبية متنوعة
-- Sample Sales Orders with diverse data

-- طلبية 1: طلبية كبيرة متعددة الأصناف
INSERT INTO sales_orders (
    order_number, order_date, order_status, customer_id, customer_name, customer_code,
    manual_document, currency_name, currency_code, exchange_rate, salesman,
    delivery_datetime, notes, total_amount, total_quantity, subtotal, tax, created_by
) VALUES (
    'O000001', '2024-01-15', 'جديد', 1, 'شركة الأندلس التجارية', 'C001',
    'SD-2024-001', 'ريال سعودي', 'SAR', 1.0, 'أحمد محمد',
    '2024-01-16 10:00:00', 'طلبية عاجلة - تسليم صباحي', 11500.00, 50, 10000.00, 1500.00, 1
);

-- أصناف الطلبية الأولى
INSERT INTO sales_order_items (
    order_id, item_status, barcode, product_code, product_name, warehouse,
    quantity, bonus_quantity, unit, unit_price, total_price, expiry_date, batch_number, item_notes
) VALUES 
(1, 'جديد', '1234567890123', 'P001', 'لابتوب ديل انسبايرون 15', 'المستودع الرئيسي', 10, 1, 'قطعة', 2500.00, 25000.00, '2025-12-31', 'BATCH001', 'ضمان سنتين'),
(1, 'جديد', '2345678901234', 'P002', 'ماوس لاسلكي لوجيتك', 'المستودع الرئيسي', 20, 5, 'قطعة', 150.00, 3000.00, '2026-06-30', 'BATCH002', 'لون أسود'),
(1, 'جديد', '3456789012345', 'P003', 'كيبورد ميكانيكي', 'المستودع الرئيسي', 15, 2, 'قطعة', 300.00, 4500.00, '2025-08-15', 'BATCH003', 'إضاءة RGB'),
(1, 'جديد', '4567890123456', 'P004', 'شاشة سامسونج 24 بوصة', 'المستودع الرئيسي', 5, 0, 'قطعة', 800.00, 4000.00, '2025-10-20', 'BATCH004', 'دقة 4K');

-- طلبية 2: طلبية متوسطة
INSERT INTO sales_orders (
    order_number, order_date, order_status, customer_id, customer_name, customer_code,
    manual_document, currency_name, currency_code, exchange_rate, salesman,
    delivery_datetime, notes, total_amount, total_quantity, subtotal, tax, created_by
) VALUES (
    'O000002', '2024-01-16', 'قيد التحضير', 2, 'مؤسسة النور للتقنية', 'C002',
    'SD-2024-002', 'ريال سعودي', 'SAR', 1.0, 'فاطمة أحمد',
    '2024-01-17 14:00:00', 'تسليم مساءً - مكتب العميل', 5750.00, 25, 5000.00, 750.00, 1
);

INSERT INTO sales_order_items (
    order_id, item_status, barcode, product_code, product_name, warehouse,
    quantity, bonus_quantity, unit, unit_price, total_price, expiry_date, batch_number, item_notes
) VALUES 
(2, 'قيد التحضير', '5678901234567', 'P005', 'طابعة HP ليزر', 'المستودع الرئيسي', 3, 0, 'قطعة', 1200.00, 3600.00, '2025-05-15', 'BATCH005', 'طباعة ملونة'),
(2, 'قيد التحضير', '6789012345678', 'P006', 'كرتونة ورق A4', 'المستودع الثانوي', 20, 2, 'كرتونة', 70.00, 1400.00, '2024-12-31', 'BATCH006', 'ورق عالي الجودة');

-- طلبية 3: طلبية صغيرة
INSERT INTO sales_orders (
    order_number, order_date, order_status, customer_id, customer_name, customer_code,
    manual_document, currency_name, currency_code, exchange_rate, salesman,
    delivery_datetime, notes, total_amount, total_quantity, subtotal, tax, created_by
) VALUES (
    'O000003', '2024-01-17', 'قيد التسليم', 3, 'متجر الإلكترونيات الحديثة', 'C003',
    'SD-2024-003', 'ريال سعودي', 'SAR', 1.0, 'محمد علي',
    '2024-01-18 09:00:00', 'تسليم صباحي - عنوان المتجر', 2300.00, 8, 2000.00, 300.00, 1
);

INSERT INTO sales_order_items (
    order_id, item_status, barcode, product_code, product_name, warehouse,
    quantity, bonus_quantity, unit, unit_price, total_price, expiry_date, batch_number, item_notes
) VALUES 
(3, 'قيد التسليم', '7890123456789', 'P007', 'سماعات بلوتوث', 'المستودع الرئيسي', 8, 1, 'قطعة', 250.00, 2000.00, '2025-03-20', 'BATCH007', 'مقاومة للماء');

-- طلبية 4: طلبية مسلمة
INSERT INTO sales_orders (
    order_number, order_date, order_status, customer_id, customer_name, customer_code,
    manual_document, currency_name, currency_code, exchange_rate, salesman,
    delivery_datetime, notes, total_amount, total_quantity, subtotal, tax, created_by
) VALUES (
    'O000004', '2024-01-18', 'مسلم', 4, 'شركة التقنيات المتقدمة', 'C004',
    'SD-2024-004', 'ريال سعودي', 'SAR', 1.0, 'سارة محمود',
    '2024-01-19 11:00:00', 'تم التسليم بنجاح - وقع العميل', 8050.00, 35, 7000.00, 1050.00, 1
);

INSERT INTO sales_order_items (
    order_id, item_status, barcode, product_code, product_name, warehouse,
    quantity, bonus_quantity, unit, unit_price, total_price, expiry_date, batch_number, item_notes
) VALUES 
(4, 'مسلم', '8901234567890', 'P008', 'راوتر واي فاي', 'المستودع الرئيسي', 15, 3, 'قطعة', 200.00, 3000.00, '2025-07-10', 'BATCH008', 'سرعة عالية'),
(4, 'مسلم', '9012345678901', 'P009', 'كابل شبكة 10 متر', 'المستودع الثانوي', 20, 5, 'قطعة', 200.00, 4000.00, '2026-01-15', 'BATCH009', 'كابل Cat6');

-- طلبية 5: طلبية بأصناف متنوعة
INSERT INTO sales_orders (
    order_number, order_date, order_status, customer_id, customer_name, customer_code,
    manual_document, currency_name, currency_code, exchange_rate, salesman,
    delivery_datetime, notes, total_amount, total_quantity, subtotal, tax, created_by
) VALUES (
    'O000005', '2024-01-19', 'جديد', 5, 'مكتبة الجامعة الأهلية', 'C005',
    'SD-2024-005', 'ريال سعودي', 'SAR', 1.0, 'خالد عبدالله',
    '2024-01-22 13:00:00', 'طلبية للمكتبة - معدات تعليمية', 15525.00, 60, 13500.00, 2025.00, 1
);

INSERT INTO sales_order_items (
    order_id, item_status, barcode, product_code, product_name, warehouse,
    quantity, bonus_quantity, unit, unit_price, total_price, expiry_date, batch_number, item_notes
) VALUES 
(5, 'جديد', '0123456789012', 'P010', 'بروجكتر تعليمي', 'المستودع الرئيسي', 5, 0, 'قطعة', 1500.00, 7500.00, '2025-09-30', 'BATCH010', 'دقة عالية'),
(5, 'جديد', '1234567890124', 'P011', 'سبورة ذكية', 'المستودع الرئيسي', 3, 0, 'قطعة', 2000.00, 6000.00, '2025-11-20', 'BATCH011', 'تفاعلية');

-- طلبية 6: طلبية عاجلة
INSERT INTO sales_orders (
    order_number, order_date, order_status, customer_id, customer_name, customer_code,
    manual_document, currency_name, currency_code, exchange_rate, salesman,
    delivery_datetime, notes, total_amount, total_quantity, subtotal, tax, created_by
) VALUES (
    'O000006', '2024-01-20', 'قيد التحضير', 6, 'مستشفى الملك فهد', 'C006',
    'SD-2024-006', 'ريال سعودي', 'SAR', 1.0, 'نورا سالم',
    '2024-01-20 16:00:00', 'طلبية عاجلة - تسليم نفس اليوم', 6900.00, 30, 6000.00, 900.00, 1
);

INSERT INTO sales_order_items (
    order_id, item_status, barcode, product_code, product_name, warehouse,
    quantity, bonus_quantity, unit, unit_price, total_price, expiry_date, batch_number, item_notes
) VALUES 
(6, 'قيد التحضير', '2345678901235', 'P012', 'جهاز كمبيوتر مكتبي', 'المستودع الرئيسي', 10, 1, 'قطعة', 600.00, 6000.00, '2025-04-25', 'BATCH012', 'للاستخدام الطبي');

-- طلبية 7: طلبية بكميات كبيرة
INSERT INTO sales_orders (
    order_number, order_date, order_status, customer_id, customer_name, customer_code,
    manual_document, currency_name, currency_code, exchange_rate, salesman,
    delivery_datetime, notes, total_amount, total_quantity, subtotal, tax, created_by
) VALUES (
    'O000007', '2024-01-21', 'جديد', 7, 'شركة البناء والتعمير', 'C007',
    'SD-2024-007', 'ريال سعودي', 'SAR', 1.0, 'عبدالرحمن أحمد',
    '2024-01-25 08:00:00', 'طلبية كبيرة - تسليم على دفعات', 23000.00, 100, 20000.00, 3000.00, 1
);

INSERT INTO sales_order_items (
    order_id, item_status, barcode, product_code, product_name, warehouse,
    quantity, bonus_quantity, unit, unit_price, total_price, expiry_date, batch_number, item_notes
) VALUES 
(7, 'جديد', '3456789012346', 'P013', 'جهاز لابتوب للمهندسين', 'المستودع الرئيسي', 25, 2, 'قطعة', 800.00, 20000.00, '2025-12-15', 'BATCH013', 'مواصفات عالية');

-- طلبية 8: طلبية بأسعار مختلفة
INSERT INTO sales_orders (
    order_number, order_date, order_status, customer_id, customer_name, customer_code,
    manual_document, currency_name, currency_code, exchange_rate, salesman,
    delivery_datetime, notes, total_amount, total_quantity, subtotal, tax, created_by
) VALUES (
    'O000008', '2024-01-22', 'قيد التسليم', 8, 'معهد التدريب التقني', 'C008',
    'SD-2024-008', 'ريال سعودي', 'SAR', 1.0, 'ليلى حسن',
    '2024-01-23 12:00:00', 'معدات تدريبية - معهد تقني', 9200.00, 40, 8000.00, 1200.00, 1
);

INSERT INTO sales_order_items (
    order_id, item_status, barcode, product_code, product_name, warehouse,
    quantity, bonus_quantity, unit, unit_price, total_price, expiry_date, batch_number, item_notes
) VALUES 
(8, 'قيد التسليم', '4567890123457', 'P014', 'تابلت تعليمي', 'المستودع الرئيسي', 20, 3, 'قطعة', 400.00, 8000.00, '2025-06-10', 'BATCH014', 'للطلاب');

-- طلبية 9: طلبية بمنتجات متخصصة
INSERT INTO sales_orders (
    order_number, order_date, order_status, customer_id, customer_name, customer_code,
    manual_document, currency_name, currency_code, exchange_rate, salesman,
    delivery_datetime, notes, total_amount, total_quantity, subtotal, tax, created_by
) VALUES (
    'O000009', '2024-01-23', 'مسلم', 9, 'مركز الأبحاث العلمية', 'C009',
    'SD-2024-009', 'ريال سعودي', 'SAR', 1.0, 'أمل عبدالعزيز',
    '2024-01-24 10:00:00', 'معدات بحثية متخصصة - تم التسليم', 18400.00, 20, 16000.00, 2400.00, 1
);

INSERT INTO sales_order_items (
    order_id, item_status, barcode, product_code, product_name, warehouse,
    quantity, bonus_quantity, unit, unit_price, total_price, expiry_date, batch_number, item_notes
) VALUES 
(9, 'مسلم', '5678901234568', 'P015', 'جهاز خادم عالي الأداء', 'المستودع الرئيسي', 2, 0, 'قطعة', 8000.00, 16000.00, '2026-02-28', 'BATCH015', 'للحوسبة العلمية');

-- طلبية 10: طلبية متنوعة الأصناف
INSERT INTO sales_orders (
    order_number, order_date, order_status, customer_id, customer_name, customer_code,
    manual_document, currency_name, currency_code, exchange_rate, salesman,
    delivery_datetime, notes, total_amount, total_quantity, subtotal, tax, created_by
) VALUES (
    'O000010', '2024-01-24', 'جديد', 10, 'شركة الاتصالات المتطورة', 'C010',
    'SD-2024-010', 'ريال سعودي', 'SAR', 1.0, 'يوسف محمد',
    '2024-01-26 15:00:00', 'معدات اتصالات - طلبية شاملة', 27600.00, 80, 24000.00, 3600.00, 1
);

INSERT INTO sales_order_items (
    order_id, item_status, barcode, product_code, product_name, warehouse,
    quantity, bonus_quantity, unit, unit_price, total_price, expiry_date, batch_number, item_notes
) VALUES 
(10, 'جديد', '6789012345679', 'P016', 'معدات شبكة متقدمة', 'المستودع الرئيسي', 15, 2, 'قطعة', 800.00, 12000.00, '2025-08-30', 'BATCH016', 'شبكة 5G'),
(10, 'جديد', '7890123456780', 'P017', 'أجهزة استقبال', 'المستودع الثانوي', 25, 5, 'قطعة', 300.00, 7500.00, '2025-10-15', 'BATCH017', 'تردد عالي'),
(10, 'جديد', '8901234567891', 'P018', 'كابلات ألياف بصرية', 'المستودع الرئيسي', 40, 8, 'متر', 112.50, 4500.00, '2026-03-20', 'BATCH018', 'سرعة فائقة');

-- إضافة تعليق ختامي
-- تم إدخال 10 طلبيات مبيعات متنوعة بإجمالي 387 قطعة وقيمة إجمالية تزيد عن 128,000 ريال سعودي
-- الطلبيات تغطي حالات مختلفة: جديد، قيد التحضير، قيد التسليم، مسلم
-- تتضمن أصناف متنوعة من الإلكترونيات والمعدات التقنية والمكتبية
