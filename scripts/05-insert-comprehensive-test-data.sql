-- إدخال بيانات تجريبية شاملة لجميع مكونات النظام

-- 1. إدخال المستخدمين
INSERT INTO user_settings (username, full_name, email, password_hash, department, role, is_active, last_login) VALUES
('admin', 'مدير النظام', 'admin@company.com', '$2b$10$hash1', 'الإدارة', 'admin', true, CURRENT_TIMESTAMP),
('sales_manager', 'مدير المبيعات', 'sales@company.com', '$2b$10$hash2', 'المبيعات', 'manager', true, CURRENT_TIMESTAMP - INTERVAL '2 hours'),
('purchase_manager', 'مدير المشتريات', 'purchase@company.com', '$2b$10$hash3', 'المشتريات', 'manager', true, CURRENT_TIMESTAMP - INTERVAL '1 day'),
('warehouse_manager', 'مدير المخزن', 'warehouse@company.com', '$2b$10$hash4', 'المخزن', 'manager', true, CURRENT_TIMESTAMP - INTERVAL '3 hours'),
('finance_manager', 'مدير المالية', 'finance@company.com', '$2b$10$hash5', 'المالية', 'manager', true, CURRENT_TIMESTAMP - INTERVAL '5 hours'),
('sales_user1', 'أحمد محمد', 'ahmed@company.com', '$2b$10$hash6', 'المبيعات', 'user', true, CURRENT_TIMESTAMP - INTERVAL '30 minutes'),
('sales_user2', 'فاطمة علي', 'fatima@company.com', '$2b$10$hash7', 'المبيعات', 'user', true, CURRENT_TIMESTAMP - INTERVAL '1 hour'),
('purchase_user1', 'محمد حسن', 'mohamed@company.com', '$2b$10$hash8', 'المشتريات', 'user', true, CURRENT_TIMESTAMP - INTERVAL '2 hours'),
('warehouse_user1', 'سارة أحمد', 'sara@company.com', '$2b$10$hash9', 'المخزن', 'user', true, CURRENT_TIMESTAMP - INTERVAL '4 hours'),
('finance_user1', 'خالد عبدالله', 'khalid@company.com', '$2b$10$hash10', 'المالية', 'user', true, CURRENT_TIMESTAMP - INTERVAL '6 hours');

-- 2. إدخال العملاء
INSERT INTO customers (customer_name, contact_person, phone, email, address, city, country, customer_type, credit_limit, payment_terms, is_active) VALUES
('شركة الأمل للتجارة', 'أحمد الأمل', '966501234567', 'info@alamal.com', 'شارع الملك فهد', 'الرياض', 'السعودية', 'corporate', 100000.00, 30, true),
('مؤسسة النور', 'فاطمة النور', '966502345678', 'contact@alnoor.com', 'طريق الملك عبدالعزيز', 'جدة', 'السعودية', 'corporate', 75000.00, 45, true),
('متجر الخير', 'محمد الخير', '966503456789', 'sales@alkheir.com', 'شارع العليا', 'الدمام', 'السعودية', 'retail', 25000.00, 15, true),
('شركة التقدم', 'سارة التقدم', '966504567890', 'info@altaqadum.com', 'حي الملز', 'الرياض', 'السعودية', 'corporate', 150000.00, 60, true),
('مجموعة الازدهار', 'خالد الازدهار', '966505678901', 'contact@alezdehar.com', 'شارع التحلية', 'جدة', 'السعودية', 'corporate', 200000.00, 30, true);

-- 3. إدخال الموردين
INSERT INTO suppliers (supplier_name, contact_person, phone, email, address, city, country, supplier_type, payment_terms, is_active) VALUES
('مصنع الجودة للإلكترونيات', 'أحمد الجودة', '966511234567', 'info@quality-electronics.com', 'المنطقة الصناعية الأولى', 'الرياض', 'السعودية', 'manufacturer', 30, true),
('شركة التوريد المتقدم', 'فاطمة التوريد', '966512345678', 'sales@advanced-supply.com', 'المنطقة الصناعية الثانية', 'جدة', 'السعودية', 'distributor', 45, true),
('مؤسسة الإمداد الشامل', 'محمد الإمداد', '966513456789', 'contact@comprehensive-supply.com', 'المدينة الصناعية', 'الدمام', 'السعودية', 'wholesaler', 60, true),
('شركة التكنولوجيا الحديثة', 'سارة التكنولوجيا', '966514567890', 'info@modern-tech.com', 'حي التقنية', 'الرياض', 'السعودية', 'manufacturer', 30, true),
('مجموعة الابتكار', 'خالد الابتكار', '966515678901', 'sales@innovation-group.com', 'مدينة الملك عبدالعزيز', 'الرياض', 'السعودية', 'distributor', 45, true);

-- 4. إدخال فئات المنتجات
INSERT INTO product_categories (category_name, category_name_en, description, parent_category_id, is_active) VALUES
('إلكترونيات', 'Electronics', 'جميع المنتجات الإلكترونية', NULL, true),
('أجهزة كمبيوتر', 'Computers', 'أجهزة الكمبيوتر واللابتوب', 1, true),
('هواتف ذكية', 'Smartphones', 'الهواتف الذكية والأجهزة اللوحية', 1, true),
('أجهزة منزلية', 'Home Appliances', 'الأجهزة المنزلية الكهربائية', NULL, true),
('مكاتب وأثاث', 'Office Furniture', 'أثاث المكاتب والمنازل', NULL, true);

-- 5. إدخال المنتجات
INSERT INTO products (product_code, product_name, product_name_en, description, category_id, unit_of_measure, unit_price, cost_price, minimum_stock, maximum_stock, reorder_point, supplier_id, barcode, is_active) VALUES
('COMP001', 'لابتوب ديل انسبايرون 15', 'Dell Inspiron 15 Laptop', 'لابتوب ديل انسبايرون 15 بوصة، معالج i5، ذاكرة 8GB', 2, 'قطعة', 2500.00, 2000.00, 5, 50, 10, 1, '1234567890123', true),
('PHONE001', 'آيفون 14 برو', 'iPhone 14 Pro', 'آيفون 14 برو 128GB، لون أزرق', 3, 'قطعة', 4500.00, 3800.00, 3, 30, 8, 2, '2345678901234', true),
('PHONE002', 'سامسونج جالاكسي S23', 'Samsung Galaxy S23', 'سامسونج جالاكسي S23 256GB، لون أسود', 3, 'قطعة', 3200.00, 2700.00, 5, 40, 12, 2, '3456789012345', true),
('HOME001', 'ثلاجة إل جي 18 قدم', 'LG Refrigerator 18ft', 'ثلاجة إل جي 18 قدم، نوفروست، لون فضي', 4, 'قطعة', 1800.00, 1500.00, 2, 20, 5, 3, '4567890123456', true),
('DESK001', 'مكتب خشبي فاخر', 'Luxury Wooden Desk', 'مكتب خشبي فاخر بأدراج، مقاس 160x80 سم', 5, 'قطعة', 1200.00, 900.00, 3, 25, 8, 4, '5678901234567', true);

-- 6. إدخال المخزون الحالي
INSERT INTO inventory (product_id, warehouse_location, current_stock, reserved_stock, available_stock, last_updated) VALUES
(1, 'المخزن الرئيسي - A1', 25, 5, 20, CURRENT_TIMESTAMP),
(2, 'المخزن الرئيسي - B2', 15, 3, 12, CURRENT_TIMESTAMP),
(3, 'المخزن الرئيسي - B3', 20, 2, 18, CURRENT_TIMESTAMP),
(4, 'المخزن الرئيسي - C1', 8, 1, 7, CURRENT_TIMESTAMP),
(5, 'المخزن الرئيسي - D1', 12, 0, 12, CURRENT_TIMESTAMP);

-- 7. إدخال طلبيات المبيعات
INSERT INTO sales_orders (order_number, customer_id, customer_name, order_date, delivery_date, status, total_amount, discount_amount, tax_amount, final_amount, payment_status, notes, created_by, department) VALUES
('SO-2024-001', 1, 'شركة الأمل للتجارة', CURRENT_DATE - INTERVAL '5 days', CURRENT_DATE + INTERVAL '10 days', 'confirmed', 7500.00, 250.00, 1087.50, 8337.50, 'pending', 'طلبية عاجلة للعميل المميز', 'sales_manager', 'المبيعات'),
('SO-2024-002', 2, 'مؤسسة النور', CURRENT_DATE - INTERVAL '3 days', CURRENT_DATE + INTERVAL '7 days', 'pending', 9600.00, 0.00, 1440.00, 11040.00, 'pending', 'طلبية منتجات إلكترونية', 'sales_user1', 'المبيعات'),
('SO-2024-003', 3, 'متجر الخير', CURRENT_DATE - INTERVAL '2 days', CURRENT_DATE + INTERVAL '5 days', 'processing', 3200.00, 100.00, 465.00, 3565.00, 'partial', 'طلبية هواتف ذكية', 'sales_user2', 'المبيعات'),
('SO-2024-004', 4, 'شركة التقدم', CURRENT_DATE - INTERVAL '1 day', CURRENT_DATE + INTERVAL '14 days', 'confirmed', 12000.00, 500.00, 1725.00, 13225.00, 'pending', 'طلبية أجهزة مكتبية', 'sales_manager', 'المبيعات'),
('SO-2024-005', 5, 'مجموعة الازدهار', CURRENT_DATE, CURRENT_DATE + INTERVAL '21 days', 'draft', 18000.00, 1000.00, 2550.00, 19550.00, 'pending', 'طلبية كبيرة متعددة المنتجات', 'sales_user1', 'المبيعات');

-- 8. إدخال تفاصيل طلبيات المبيعات
INSERT INTO sales_order_items (order_id, product_id, product_code, product_name, quantity, unit_price, discount_amount, total_amount) VALUES
-- طلبية SO-2024-001
(1, 1, 'COMP001', 'لابتوب ديل انسبايرون 15', 3, 2500.00, 250.00, 7250.00),
-- طلبية SO-2024-002
(2, 2, 'PHONE001', 'آيفون 14 برو', 2, 4500.00, 0.00, 9000.00),
(2, 5, 'DESK001', 'مكتب خشبي فاخر', 1, 1200.00, 0.00, 1200.00),
-- طلبية SO-2024-003
(3, 3, 'PHONE002', 'سامسونج جالاكسي S23', 1, 3200.00, 100.00, 3100.00),
-- طلبية SO-2024-004
(4, 1, 'COMP001', 'لابتوب ديل انسبايرون 15', 2, 2500.00, 0.00, 5000.00),
(4, 4, 'HOME001', 'ثلاجة إل جي 18 قدم', 2, 1800.00, 200.00, 3400.00),
(4, 5, 'DESK001', 'مكتب خشبي فاخر', 3, 1200.00, 300.00, 3300.00),
-- طلبية SO-2024-005
(5, 2, 'PHONE001', 'آيفون 14 برو', 4, 4500.00, 1000.00, 17000.00),
(5, 3, 'PHONE002', 'سامسونج جالاكسي S23', 1, 3200.00, 0.00, 3200.00);

-- 9. إدخال طلبيات الشراء
INSERT INTO purchase_orders (order_number, supplier_id, supplier_name, order_date, expected_delivery_date, status, total_amount, discount_amount, tax_amount, final_amount, payment_status, notes, created_by, department) VALUES
('PO-2024-001', 1, 'مصنع الجودة للإلكترونيات', CURRENT_DATE - INTERVAL '7 days', CURRENT_DATE + INTERVAL '14 days', 'confirmed', 20000.00, 1000.00, 2850.00, 21850.00, 'pending', 'طلبية تجديد مخزون اللابتوب', 'purchase_manager', 'المشتريات'),
('PO-2024-002', 2, 'شركة التوريد المتقدم', CURRENT_DATE - INTERVAL '4 days', CURRENT_DATE + INTERVAL '10 days', 'pending', 38000.00, 2000.00, 5400.00, 41400.00, 'pending', 'طلبية هواتف ذكية للموسم', 'purchase_user1', 'المشتريات'),
('PO-2024-003', 3, 'مؤسسة الإمداد الشامل', CURRENT_DATE - INTERVAL '2 days', CURRENT_DATE + INTERVAL '21 days', 'processing', 15000.00, 500.00, 2175.00, 16675.00, 'partial', 'طلبية أجهزة منزلية', 'purchase_manager', 'المشتريات'),
('PO-2024-004', 4, 'شركة التكنولوجيا الحديثة', CURRENT_DATE - INTERVAL '1 day', CURRENT_DATE + INTERVAL '7 days', 'confirmed', 27000.00, 1500.00, 3825.00, 29325.00, 'pending', 'طلبية منتجات تقنية متنوعة', 'purchase_user1', 'المشتريات'),
('PO-2024-005', 5, 'مجموعة الابتكار', CURRENT_DATE, CURRENT_DATE + INTERVAL '30 days', 'draft', 45000.00, 3000.00, 6300.00, 48300.00, 'pending', 'طلبية كبيرة للربع القادم', 'purchase_manager', 'المشتريات');

-- 10. إدخال تفاصيل طلبيات الشراء
INSERT INTO purchase_order_items (order_id, product_id, product_code, product_name, quantity, unit_cost, discount_amount, total_amount) VALUES
-- طلبية PO-2024-001
(1, 1, 'COMP001', 'لابتوب ديل انسبايرون 15', 10, 2000.00, 1000.00, 19000.00),
-- طلبية PO-2024-002
(2, 2, 'PHONE001', 'آيفون 14 برو', 10, 3800.00, 2000.00, 36000.00),
-- طلبية PO-2024-003
(3, 4, 'HOME001', 'ثلاجة إل جي 18 قدم', 10, 1500.00, 500.00, 14500.00),
-- طلبية PO-2024-004
(4, 3, 'PHONE002', 'سامسونج جالاكسي S23', 10, 2700.00, 1500.00, 25500.00),
-- طلبية PO-2024-005
(5, 1, 'COMP001', 'لابتوب ديل انسبايرون 15', 15, 2000.00, 2000.00, 28000.00),
(5, 5, 'DESK001', 'مكتب خشبي فاخر', 20, 900.00, 1000.00, 17000.00);

-- 11. إدخال حالات workflow للطلبيات
INSERT INTO order_workflow_status (order_id, order_type, order_number, sequence_id, current_stage_id, current_step_order, assigned_to_department, stage_start_time, priority_level, is_overdue) VALUES
(1, 'sales', 'SO-2024-001', 1, 2, 2, 'المبيعات', CURRENT_TIMESTAMP - INTERVAL '2 days', 'high', false),
(2, 'sales', 'SO-2024-002', 1, 1, 1, 'المبيعات', CURRENT_TIMESTAMP - INTERVAL '1 day', 'normal', false),
(3, 'sales', 'SO-2024-003', 1, 3, 3, 'المخزن', CURRENT_TIMESTAMP - INTERVAL '6 hours', 'normal', false),
(4, 'sales', 'SO-2024-004', 1, 2, 2, 'المبيعات', CURRENT_TIMESTAMP - INTERVAL '12 hours', 'urgent', false),
(5, 'sales', 'SO-2024-005', 1, 1, 1, 'المبيعات', CURRENT_TIMESTAMP - INTERVAL '30 minutes', 'normal', false),
(1, 'purchase', 'PO-2024-001', 2, 6, 2, 'المشتريات', CURRENT_TIMESTAMP - INTERVAL '3 days', 'normal', false),
(2, 'purchase', 'PO-2024-002', 2, 5, 1, 'المشتريات', CURRENT_TIMESTAMP - INTERVAL '2 days', 'high', false),
(3, 'purchase', 'PO-2024-003', 2, 7, 3, 'المخزن', CURRENT_TIMESTAMP - INTERVAL '1 day', 'normal', false),
(4, 'purchase', 'PO-2024-004', 2, 6, 2, 'المشتريات', CURRENT_TIMESTAMP - INTERVAL '8 hours', 'normal', false),
(5, 'purchase', 'PO-2024-005', 2, 5, 1, 'المشتريات', CURRENT_TIMESTAMP - INTERVAL '1 hour', 'low', false);

-- 12. إدخال تاريخ workflow
INSERT INTO workflow_history (order_id, order_type, order_number, sequence_id, from_stage_id, to_stage_id, from_stage_name, to_stage_name, action_type, performed_by_username, performed_by_department, reason, notes, created_at) VALUES
-- تاريخ طلبيات المبيعات
(1, 'sales', 'SO-2024-001', 1, NULL, 1, NULL, 'طلبية جديدة', 'advance', 'sales_manager', 'المبيعات', NULL, 'تم إنشاء الطلبية', CURRENT_TIMESTAMP - INTERVAL '5 days'),
(1, 'sales', 'SO-2024-001', 1, 1, 2, 'طلبية جديدة', 'مراجعة وتأكيد', 'advance', 'sales_manager', 'المبيعات', NULL, 'تم مراجعة الطلبية وتأكيدها', CURRENT_TIMESTAMP - INTERVAL '3 days'),
(2, 'sales', 'SO-2024-002', 1, NULL, 1, NULL, 'طلبية جديدة', 'advance', 'sales_user1', 'المبيعات', NULL, 'تم إنشاء الطلبية', CURRENT_TIMESTAMP - INTERVAL '3 days'),
(3, 'sales', 'SO-2024-003', 1, NULL, 1, NULL, 'طلبية جديدة', 'advance', 'sales_user2', 'المبيعات', NULL, 'تم إنشاء الطلبية', CURRENT_TIMESTAMP - INTERVAL '2 days'),
(3, 'sales', 'SO-2024-003', 1, 1, 2, 'طلبية جديدة', 'مراجعة وتأكيد', 'advance', 'sales_manager', 'المبيعات', NULL, 'تم تأكيد الطلبية', CURRENT_TIMESTAMP - INTERVAL '1 day'),
(3, 'sales', 'SO-2024-003', 1, 2, 3, 'مراجعة وتأكيد', 'تحضير وتجهيز', 'advance', 'warehouse_manager', 'المخزن', NULL, 'تم نقل الطلبية للمخزن', CURRENT_TIMESTAMP - INTERVAL '6 hours'),
-- تاريخ طلبيات الشراء
(1, 'purchase', 'PO-2024-001', 2, NULL, 5, NULL, 'طلبية شراء جديدة', 'advance', 'purchase_manager', 'المشتريات', NULL, 'تم إنشاء طلبية الشراء', CURRENT_TIMESTAMP - INTERVAL '7 days'),
(1, 'purchase', 'PO-2024-001', 2, 5, 6, 'طلبية شراء جديدة', 'مراجعة وتأكيد', 'advance', 'purchase_manager', 'المشتريات', NULL, 'تم مراجعة وتأكيد الطلبية', CURRENT_TIMESTAMP - INTERVAL '4 days'),
(2, 'purchase', 'PO-2024-002', 2, NULL, 5, NULL, 'طلبية شراء جديدة', 'advance', 'purchase_user1', 'المشتريات', NULL, 'تم إنشاء طلبية الشراء', CURRENT_TIMESTAMP - INTERVAL '4 days'),
(3, 'purchase', 'PO-2024-003', 2, NULL, 5, NULL, 'طلبية شراء جديدة', 'advance', 'purchase_manager', 'المشتريات', NULL, 'تم إنشاء طلبية الشراء', CURRENT_TIMESTAMP - INTERVAL '2 days'),
(3, 'purchase', 'PO-2024-003', 2, 5, 6, 'طلبية شراء جديدة', 'مراجعة وتأكيد', 'advance', 'purchase_manager', 'المشتريات', NULL, 'تم تأكيد الطلبية', CURRENT_TIMESTAMP - INTERVAL '1 day'),
(3, 'purchase', 'PO-2024-003', 2, 6, 7, 'مراجعة وتأكيد', 'استلام وفحص', 'advance', 'warehouse_manager', 'المخزن', NULL, 'تم استلام البضاعة', CURRENT_TIMESTAMP - INTERVAL '1 day');

-- 13. إدخال التنبيهات
INSERT INTO notifications (title, message, type, priority, target_user, target_department, target_role, related_order_id, related_order_type, is_read, created_at) VALUES
('طلبية مبيعات جديدة', 'تم إنشاء طلبية مبيعات جديدة SO-2024-005 بقيمة 19,550 ريال', 'order_created', 'normal', NULL, 'المبيعات', NULL, 5, 'sales', false, CURRENT_TIMESTAMP - INTERVAL '30 minutes'),
('طلبية تحتاج موافقة', 'طلبية المبيعات SO-2024-004 تحتاج موافقة عاجلة - القيمة: 13,225 ريال', 'approval_required', 'urgent', NULL, 'المبيعات', 'manager', 4, 'sales', false, CURRENT_TIMESTAMP - INTERVAL '12 hours'),
('طلبية جاهزة للتسليم', 'طلبية المبيعات SO-2024-003 جاهزة للتسليم من المخزن', 'order_ready', 'high', NULL, 'المخزن', NULL, 3, 'sales', false, CURRENT_TIMESTAMP - INTERVAL '6 hours'),
('وصول بضاعة جديدة', 'تم استلام بضاعة طلبية الشراء PO-2024-003 في المخزن', 'goods_received', 'normal', NULL, 'المخزن', NULL, 3, 'purchase', true, CURRENT_TIMESTAMP - INTERVAL '1 day'),
('طلبية شراء تحتاج مراجعة', 'طلبية الشراء PO-2024-002 تحتاج مراجعة - القيمة: 41,400 ريال', 'review_required', 'high', NULL, 'المشتريات', 'manager', 2, 'purchase', false, CURRENT_TIMESTAMP - INTERVAL '2 days'),
('تنبيه مخزون منخفض', 'مخزون المنتج "ثلاجة إل جي 18 قدم" أصبح أقل من الحد الأدنى', 'low_stock', 'high', NULL, 'المخزن', NULL, NULL, NULL, false, CURRENT_TIMESTAMP - INTERVAL '3 hours'),
('تنبيه عام للنظام', 'تم تحديث النظام بنجاح وإضافة ميزات جديدة', 'system', 'normal', NULL, NULL, NULL, NULL, NULL, false, CURRENT_TIMESTAMP - INTERVAL '1 day');

-- 14. إدخال صلاحيات المستخدمين
INSERT INTO user_permissions (user_id, module_name, can_view, can_create, can_edit, can_delete, can_approve) VALUES
-- صلاحيات المدير العام
(1, 'dashboard', true, true, true, true, true),
(1, 'sales_orders', true, true, true, true, true),
(1, 'purchase_orders', true, true, true, true, true),
(1, 'inventory', true, true, true, true, true),
(1, 'products', true, true, true, true, true),
(1, 'customers', true, true, true, true, true),
(1, 'suppliers', true, true, true, true, true),
(1, 'reports', true, true, true, true, true),
(1, 'settings', true, true, true, true, true),
(1, 'workflow', true, true, true, true, true),
(1, 'notifications', true, true, true, true, true),
-- صلاحيات مدير المبيعات
(2, 'dashboard', true, false, false, false, false),
(2, 'sales_orders', true, true, true, true, true),
(2, 'inventory', true, false, false, false, false),
(2, 'products', true, false, true, false, false),
(2, 'customers', true, true, true, false, false),
(2, 'reports', true, false, false, false, false),
(2, 'workflow', true, true, true, false, true),
(2, 'notifications', true, true, true, false, false),
-- صلاحيات مدير المشتريات
(3, 'dashboard', true, false, false, false, false),
(3, 'purchase_orders', true, true, true, true, true),
(3, 'inventory', true, false, false, false, false),
(3, 'products', true, true, true, false, false),
(3, 'suppliers', true, true, true, false, false),
(3, 'reports', true, false, false, false, false),
(3, 'workflow', true, true, true, false, true),
(3, 'notifications', true, true, true, false, false);

-- تحديث إحصائيات الجداول
ANALYZE user_settings;
ANALYZE customers;
ANALYZE suppliers;
ANALYZE products;
ANALYZE inventory;
ANALYZE sales_orders;
ANALYZE sales_order_items;
ANALYZE purchase_orders;
ANALYZE purchase_order_items;
ANALYZE order_workflow_status;
ANALYZE workflow_history;
ANALYZE notifications;
ANALYZE user_permissions;

-- رسالة تأكيد
SELECT 'تم إدخال البيانات التجريبية الشاملة بنجاح!' as status;
