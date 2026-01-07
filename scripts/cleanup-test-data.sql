-- مسح جميع البيانات التجريبية والبدء من جديد
-- Clean up all test data and start fresh

-- 1. مسح البيانات التجريبية من الجداول الرئيسية
-- Delete test data from main tables

-- مسح طلبيات البيع التجريبية
DELETE FROM sales_order_items WHERE sales_order_id IN (
    SELECT id FROM sales_orders WHERE order_number LIKE 'SO-%' OR customer_name LIKE '%Test%' OR customer_name LIKE '%تجريبي%'
);

DELETE FROM sales_orders WHERE order_number LIKE 'SO-%' OR customer_name LIKE '%Test%' OR customer_name LIKE '%تجريبي%';

-- مسح طلبيات الشراء التجريبية
DELETE FROM purchase_order_items WHERE purchase_order_id IN (
    SELECT id FROM purchase_orders WHERE order_number LIKE 'PO-%' OR supplier_name LIKE '%Test%' OR supplier_name LIKE '%تجريبي%'
);

DELETE FROM purchase_orders WHERE order_number LIKE 'PO-%' OR supplier_name LIKE '%Test%' OR supplier_name LIKE '%تجريبي%';

-- مسح حركات المخزون التجريبية
DELETE FROM inventory_transactions WHERE reference_type IN ('test', 'demo', 'sample');

-- مسح المنتجات التجريبية
DELETE FROM product_stock WHERE product_id IN (
    SELECT id FROM products WHERE product_code LIKE 'TEST%' OR product_name LIKE '%Test%' OR product_name LIKE '%تجريبي%'
);

DELETE FROM products WHERE product_code LIKE 'TEST%' OR product_name LIKE '%Test%' OR product_name LIKE '%تجريبي%';

-- مسح العملاء التجريبيين
DELETE FROM customers WHERE customer_code LIKE 'C00%' OR customer_name LIKE '%Test%' OR customer_name LIKE '%تجريبي%' OR email LIKE '%example.%';

-- مسح الموردين التجريبيين
DELETE FROM suppliers WHERE supplier_code LIKE 'SUP00%' OR supplier_name LIKE '%Test%' OR supplier_name LIKE '%تجريبي%' OR email LIKE '%example.%';

-- مسح المجموعات التجريبية
DELETE FROM item_groups WHERE group_name LIKE '%Test%' OR group_name LIKE '%تجريبي%' OR group_number LIKE 'GRP00%';

-- مسح المستودعات التجريبية
DELETE FROM warehouses WHERE warehouse_code LIKE 'WH00%' OR warehouse_name LIKE '%Test%' OR warehouse_name LIKE '%تجريبي%';

-- مسح الوحدات التجريبية
DELETE FROM units WHERE unit_code LIKE 'UNIT00%' OR unit_name LIKE '%Test%' OR unit_name LIKE '%تجريبي%';

-- 2. إعادة تعيين المتسلسلات
-- Reset sequences

-- إعادة تعيين متسلسل المنتجات
SELECT setval('products_id_seq', 1, false);

-- إعادة تعيين متسلسل العملاء
SELECT setval('customers_id_seq', 1, false);

-- إعادة تعيين متسلسل الموردين
SELECT setval('suppliers_id_seq', 1, false);

-- إعادة تعيين متسلسل طلبيات البيع
SELECT setval('sales_orders_id_seq', 1, false);

-- إعادة تعيين متسلسل طلبيات الشراء
SELECT setval('purchase_orders_id_seq', 1, false);

-- إعادة تعيين متسلسل المجموعات
SELECT setval('item_groups_id_seq', 1, false);

-- إعادة تعيين متسلسل المستودعات
SELECT setval('warehouses_id_seq', 1, false);

-- إعادة تعيين متسلسل الوحدات
SELECT setval('units_id_seq', 1, false);

-- 3. إدراج البيانات الأساسية المطلوبة
-- Insert essential basic data

-- إدراج الوحدات الأساسية
INSERT INTO units (unit_name, unit_name_en, unit_code, description, is_active) VALUES
('قطعة', 'Piece', 'PCS', 'وحدة القطعة الواحدة', true),
('كيلو', 'Kilogram', 'KG', 'وحدة الكيلو جرام', true),
('لتر', 'Liter', 'LTR', 'وحدة اللتر', true),
('متر', 'Meter', 'MTR', 'وحدة المتر', true),
('صندوق', 'Box', 'BOX', 'وحدة الصندوق', true),
('كرتون', 'Carton', 'CTN', 'وحدة الكرتون', true),
('زوج', 'Pair', 'PAIR', 'وحدة الزوج', true),
('علبة', 'Can', 'CAN', 'وحدة العلبة', true),
('كيس', 'Bag', 'BAG', 'وحدة الكيس', true),
('دزينة', 'Dozen', 'DOZ', 'وحدة الدزينة (12 قطعة)', true);

-- إدراج المستودعات الأساسية
INSERT INTO warehouses (warehouse_name, warehouse_name_en, warehouse_code, location, description, is_active) VALUES
('المستودع الرئيسي', 'Main Warehouse', 'MAIN', 'المنطقة الصناعية', 'المستودع الرئيسي للشركة', true),
('مستودع البيع', 'Sales Warehouse', 'SALES', 'منطقة المبيعات', 'مستودع خاص بالمبيعات', true),
('مستودع الاستلام', 'Receiving Warehouse', 'REC', 'منطقة الاستلام', 'مستودع استلام البضائع الجديدة', true);

-- إدراج مجموعات الأصناف الأساسية
INSERT INTO item_groups (group_name, group_number, description, is_active, organization_id) VALUES
('مجموعة عامة', 'GEN', 'مجموعة عامة للأصناف غير المصنفة', true, 1),
('إلكترونيات', 'ELEC', 'الأجهزة والمعدات الإلكترونية', true, 1),
('ملابس', 'CLOTH', 'الملابس والمنسوجات', true, 1),
('أغذية', 'FOOD', 'المواد الغذائية والمشروبات', true, 1),
('أدوات منزلية', 'HOME', 'الأدوات والمعدات المنزلية', true, 1);

-- إدراج أسعار الصرف الأساسية
INSERT INTO exchange_rates (currency_code, currency_name, exchange_rate, buy_rate, sell_rate, organization_id) VALUES
('SAR', 'ريال سعودي', 1.00, 1.00, 1.00, 1),
('USD', 'دولار أمريكي', 3.75, 3.74, 3.76, 1),
('EUR', 'يورو', 4.10, 4.08, 4.12, 1),
('GBP', 'جنيه إسترليني', 4.75, 4.73, 4.77, 1);

-- 4. تحديث الإعدادات العامة
-- Update general settings

-- تحديث إعدادات النظام
UPDATE system_settings SET
    company_name = 'اسم الشركة',
    company_name_en = 'Company Name',
    company_address = 'عنوان الشركة',
    company_phone = '+966-XX-XXXXXXX',
    company_email = 'info@company.com',
    default_currency = 'SAR',
    language = 'ar',
    timezone = 'Asia/Riyadh',
    date_format = 'DD/MM/YYYY',
    time_format = '24',
    auto_numbering = true,
    order_prefix = 'ORD',
    invoice_prefix = 'INV',
    purchase_prefix = 'PUR'
WHERE id = 1;

-- إدراج إعدادات النظام إذا لم تكن موجودة
INSERT INTO system_settings (
    company_name, company_name_en, company_address, company_phone, company_email,
    default_currency, language, timezone, date_format, time_format,
    auto_numbering, order_prefix, invoice_prefix, purchase_prefix,
    organization_id
)
SELECT 
    'اسم الشركة', 'Company Name', 'عنوان الشركة', '+966-XX-XXXXXXX', 'info@company.com',
    'SAR', 'ar', 'Asia/Riyadh', 'DD/MM/YYYY', '24',
    true, 'ORD', 'INV', 'PUR', 1
WHERE NOT EXISTS (SELECT 1 FROM system_settings WHERE organization_id = 1);

-- 5. تنظيف سجلات التدقيق القديمة
-- Clean old audit logs

DELETE FROM audit_logs WHERE created_at < NOW() - INTERVAL '30 days';
DELETE FROM error_logs WHERE created_at < NOW() - INTERVAL '30 days';

-- 6. تحديث الإحصائيات
-- Update statistics

ANALYZE products;
ANALYZE customers;
ANALYZE suppliers;
ANALYZE sales_orders;
ANALYZE purchase_orders;
ANALYZE product_stock;
ANALYZE inventory_transactions;

-- رسالة تأكيد
SELECT 'تم مسح البيانات التجريبية بنجاح وإعداد النظام للبيانات الحقيقية' as status;
