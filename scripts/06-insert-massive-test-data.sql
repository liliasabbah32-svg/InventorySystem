-- إنشاء بيانات ضخمة للاختبار (100 ضعف البيانات الأساسية)
-- Massive test data generation (100x base data)

-- إنشاء 10,000 عميل
-- Generate 10,000 customers
DO $$
BEGIN
    FOR i IN 1..10000 LOOP
        INSERT INTO customers (name, email, phone, address, city, country, customer_type, credit_limit, payment_terms, tax_number, contact_person, notes, created_at, updated_at)
        VALUES (
            'عميل رقم ' || i,
            'customer' || i || '@example.com',
            '+966' || LPAD((500000000 + i)::text, 9, '0'),
            'العنوان رقم ' || i || ', حي التجارة',
            CASE (i % 5)
                WHEN 0 THEN 'الرياض'
                WHEN 1 THEN 'جدة'
                WHEN 2 THEN 'الدمام'
                WHEN 3 THEN 'مكة'
                ELSE 'المدينة'
            END,
            'المملكة العربية السعودية',
            CASE (i % 3)
                WHEN 0 THEN 'retail'
                WHEN 1 THEN 'wholesale'
                ELSE 'corporate'
            END,
            (RANDOM() * 900000 + 100000)::DECIMAL(15,2),
            CASE (i % 4)
                WHEN 0 THEN 'net_30'
                WHEN 1 THEN 'net_15'
                WHEN 2 THEN 'cash'
                ELSE 'net_60'
            END,
            '3' || LPAD(i::text, 14, '0'),
            'مسؤول الاتصال ' || i,
            'ملاحظات العميل رقم ' || i,
            NOW() - INTERVAL '1 day' * (RANDOM() * 365),
            NOW()
        );
    END LOOP;
END $$;

-- إنشاء 5,000 مورد
-- Generate 5,000 suppliers
DO $$
BEGIN
    FOR i IN 1..5000 LOOP
        INSERT INTO suppliers (name, email, phone, address, city, country, supplier_type, payment_terms, tax_number, contact_person, bank_details, notes, created_at, updated_at)
        VALUES (
            'مورد رقم ' || i,
            'supplier' || i || '@example.com',
            '+966' || LPAD((400000000 + i)::text, 9, '0'),
            'العنوان رقم ' || i || ', المنطقة الصناعية',
            CASE (i % 4)
                WHEN 0 THEN 'الرياض'
                WHEN 1 THEN 'جدة'
                WHEN 2 THEN 'الدمام'
                ELSE 'الخبر'
            END,
            'المملكة العربية السعودية',
            CASE (i % 3)
                WHEN 0 THEN 'manufacturer'
                WHEN 1 THEN 'distributor'
                ELSE 'importer'
            END,
            CASE (i % 3)
                WHEN 0 THEN 'net_30'
                WHEN 1 THEN 'net_45'
                ELSE 'net_60'
            END,
            '4' || LPAD(i::text, 14, '0'),
            'مدير المبيعات ' || i,
            'البنك الأهلي - حساب رقم ' || (1000000000 + i),
            'ملاحظات المورد رقم ' || i,
            NOW() - INTERVAL '1 day' * (RANDOM() * 365),
            NOW()
        );
    END LOOP;
END $$;

-- إنشاء 50,000 منتج
-- Generate 50,000 products
DO $$
DECLARE
    supplier_ids INTEGER[];
    random_supplier_id INTEGER;
BEGIN
    -- الحصول على معرفات الموردين
    SELECT ARRAY(SELECT id FROM suppliers LIMIT 5000) INTO supplier_ids;
    
    FOR i IN 1..50000 LOOP
        -- اختيار مورد عشوائي
        random_supplier_id := supplier_ids[1 + (RANDOM() * (array_length(supplier_ids, 1) - 1))::INTEGER];
        
        INSERT INTO products (name, description, sku, barcode, category, unit, cost_price, selling_price, stock_quantity, min_stock_level, max_stock_level, supplier_id, location, expiry_date, batch_number, notes, created_at, updated_at)
        VALUES (
            'منتج رقم ' || i,
            'وصف تفصيلي للمنتج رقم ' || i || ' - منتج عالي الجودة',
            'SKU-' || LPAD(i::text, 8, '0'),
            '6' || LPAD(i::text, 12, '0'),
            CASE (i % 10)
                WHEN 0 THEN 'إلكترونيات'
                WHEN 1 THEN 'ملابس'
                WHEN 2 THEN 'أغذية'
                WHEN 3 THEN 'مستحضرات تجميل'
                WHEN 4 THEN 'أدوات منزلية'
                WHEN 5 THEN 'كتب'
                WHEN 6 THEN 'رياضة'
                WHEN 7 THEN 'ألعاب'
                WHEN 8 THEN 'سيارات'
                ELSE 'متنوعة'
            END,
            CASE (i % 5)
                WHEN 0 THEN 'قطعة'
                WHEN 1 THEN 'كيلو'
                WHEN 2 THEN 'متر'
                WHEN 3 THEN 'لتر'
                ELSE 'علبة'
            END,
            (RANDOM() * 900 + 100)::DECIMAL(10,2),
            (RANDOM() * 1800 + 200)::DECIMAL(10,2),
            (RANDOM() * 9000 + 1000)::INTEGER,
            (RANDOM() * 90 + 10)::INTEGER,
            (RANDOM() * 900 + 100)::INTEGER,
            random_supplier_id,
            'مستودع ' || CASE (i % 5) WHEN 0 THEN 'أ' WHEN 1 THEN 'ب' WHEN 2 THEN 'ج' WHEN 3 THEN 'د' ELSE 'هـ' END || ' - رف ' || (i % 100 + 1),
            CASE WHEN i % 3 = 0 THEN NOW() + INTERVAL '1 year' * RANDOM() ELSE NULL END,
            CASE WHEN i % 4 = 0 THEN 'BATCH-' || LPAD(i::text, 6, '0') ELSE NULL END,
            'ملاحظات المنتج رقم ' || i,
            NOW() - INTERVAL '1 day' * (RANDOM() * 365),
            NOW()
        );
    END LOOP;
END $$;

-- إنشاء 20,000 طلبية مبيعات
-- Generate 20,000 sales orders
DO $$
DECLARE
    customer_ids INTEGER[];
    product_ids INTEGER[];
    random_customer_id INTEGER;
    random_product_id INTEGER;
    order_id INTEGER;
    items_count INTEGER;
BEGIN
    -- الحصول على معرفات العملاء والمنتجات
    SELECT ARRAY(SELECT id FROM customers LIMIT 10000) INTO customer_ids;
    SELECT ARRAY(SELECT id FROM products LIMIT 50000) INTO product_ids;
    
    FOR i IN 1..20000 LOOP
        -- اختيار عميل عشوائي
        random_customer_id := customer_ids[1 + (RANDOM() * (array_length(customer_ids, 1) - 1))::INTEGER];
        
        -- إنشاء طلبية
        INSERT INTO sales_orders (order_number, customer_id, order_date, delivery_date, status, total_amount, discount, tax_amount, notes, created_by, created_at, updated_at)
        VALUES (
            'SO-' || TO_CHAR(NOW(), 'YYYY') || '-' || LPAD(i::text, 6, '0'),
            random_customer_id,
            NOW() - INTERVAL '1 day' * (RANDOM() * 180),
            NOW() + INTERVAL '1 day' * (RANDOM() * 30 + 1),
            CASE (i % 6)
                WHEN 0 THEN 'pending'
                WHEN 1 THEN 'confirmed'
                WHEN 2 THEN 'processing'
                WHEN 3 THEN 'shipped'
                WHEN 4 THEN 'delivered'
                ELSE 'cancelled'
            END,
            0, -- سيتم تحديثه لاحقاً
            (RANDOM() * 1000)::DECIMAL(10,2),
            0, -- سيتم حسابه لاحقاً
            'ملاحظات الطلبية رقم ' || i,
            1, -- المستخدم الأول
            NOW() - INTERVAL '1 day' * (RANDOM() * 180),
            NOW()
        ) RETURNING id INTO order_id;
        
        -- إضافة عناصر للطلبية (1-10 عناصر لكل طلبية)
        items_count := (RANDOM() * 9 + 1)::INTEGER;
        FOR j IN 1..items_count LOOP
            random_product_id := product_ids[1 + (RANDOM() * (array_length(product_ids, 1) - 1))::INTEGER];
            
            INSERT INTO sales_order_items (order_id, product_id, quantity, unit_price, total_price, notes)
            SELECT 
                order_id,
                random_product_id,
                (RANDOM() * 19 + 1)::INTEGER,
                p.selling_price,
                (RANDOM() * 19 + 1)::INTEGER * p.selling_price,
                'عنصر رقم ' || j || ' في الطلبية ' || i
            FROM products p WHERE p.id = random_product_id;
        END LOOP;
        
        -- تحديث إجمالي الطلبية
        UPDATE sales_orders 
        SET total_amount = (
            SELECT COALESCE(SUM(total_price), 0) 
            FROM sales_order_items 
            WHERE order_id = sales_orders.id
        ),
        tax_amount = (
            SELECT COALESCE(SUM(total_price), 0) * 0.15 
            FROM sales_order_items 
            WHERE order_id = sales_orders.id
        )
        WHERE id = order_id;
    END LOOP;
END $$;

-- إنشاء 15,000 طلبية شراء
-- Generate 15,000 purchase orders
DO $$
DECLARE
    supplier_ids INTEGER[];
    product_ids INTEGER[];
    random_supplier_id INTEGER;
    random_product_id INTEGER;
    order_id INTEGER;
    items_count INTEGER;
BEGIN
    -- الحصول على معرفات الموردين والمنتجات
    SELECT ARRAY(SELECT id FROM suppliers LIMIT 5000) INTO supplier_ids;
    SELECT ARRAY(SELECT id FROM products LIMIT 50000) INTO product_ids;
    
    FOR i IN 1..15000 LOOP
        -- اختيار مورد عشوائي
        random_supplier_id := supplier_ids[1 + (RANDOM() * (array_length(supplier_ids, 1) - 1))::INTEGER];
        
        -- إنشاء طلبية شراء
        INSERT INTO purchase_orders (order_number, supplier_id, order_date, expected_delivery_date, status, total_amount, discount, tax_amount, notes, created_by, created_at, updated_at)
        VALUES (
            'PO-' || TO_CHAR(NOW(), 'YYYY') || '-' || LPAD(i::text, 6, '0'),
            random_supplier_id,
            NOW() - INTERVAL '1 day' * (RANDOM() * 120),
            NOW() + INTERVAL '1 day' * (RANDOM() * 45 + 5),
            CASE (i % 5)
                WHEN 0 THEN 'pending'
                WHEN 1 THEN 'approved'
                WHEN 2 THEN 'ordered'
                WHEN 3 THEN 'received'
                ELSE 'cancelled'
            END,
            0, -- سيتم تحديثه لاحقاً
            (RANDOM() * 2000)::DECIMAL(10,2),
            0, -- سيتم حسابه لاحقاً
            'ملاحظات طلبية الشراء رقم ' || i,
            1, -- المستخدم الأول
            NOW() - INTERVAL '1 day' * (RANDOM() * 120),
            NOW()
        ) RETURNING id INTO order_id;
        
        -- إضافة عناصر لطلبية الشراء (1-8 عناصر لكل طلبية)
        items_count := (RANDOM() * 7 + 1)::INTEGER;
        FOR j IN 1..items_count LOOP
            random_product_id := product_ids[1 + (RANDOM() * (array_length(product_ids, 1) - 1))::INTEGER];
            
            INSERT INTO purchase_order_items (order_id, product_id, quantity, unit_price, total_price, notes)
            SELECT 
                order_id,
                random_product_id,
                (RANDOM() * 99 + 1)::INTEGER,
                p.cost_price,
                (RANDOM() * 99 + 1)::INTEGER * p.cost_price,
                'عنصر رقم ' || j || ' في طلبية الشراء ' || i
            FROM products p WHERE p.id = random_product_id;
        END LOOP;
        
        -- تحديث إجمالي طلبية الشراء
        UPDATE purchase_orders 
        SET total_amount = (
            SELECT COALESCE(SUM(total_price), 0) 
            FROM purchase_order_items 
            WHERE order_id = purchase_orders.id
        ),
        tax_amount = (
            SELECT COALESCE(SUM(total_price), 0) * 0.15 
            FROM purchase_order_items 
            WHERE order_id = purchase_orders.id
        )
        WHERE id = order_id;
    END LOOP;
END $$;

-- إنشاء 50,000 حركة مخزون
-- Generate 50,000 inventory movements
DO $$
DECLARE
    product_ids INTEGER[];
    random_product_id INTEGER;
BEGIN
    SELECT ARRAY(SELECT id FROM products LIMIT 50000) INTO product_ids;
    
    FOR i IN 1..50000 LOOP
        random_product_id := product_ids[1 + (RANDOM() * (array_length(product_ids, 1) - 1))::INTEGER];
        
        INSERT INTO inventory_movements (product_id, movement_type, quantity, reference_type, reference_id, notes, created_by, created_at)
        VALUES (
            random_product_id,
            CASE (i % 6)
                WHEN 0 THEN 'in'
                WHEN 1 THEN 'out'
                WHEN 2 THEN 'adjustment'
                WHEN 3 THEN 'transfer'
                WHEN 4 THEN 'return'
                ELSE 'damaged'
            END,
            (RANDOM() * 199 - 99)::INTEGER, -- من -99 إلى +100
            CASE (i % 4)
                WHEN 0 THEN 'sales_order'
                WHEN 1 THEN 'purchase_order'
                WHEN 2 THEN 'adjustment'
                ELSE 'transfer'
            END,
            (RANDOM() * 1000 + 1)::INTEGER,
            'حركة مخزون رقم ' || i,
            1,
            NOW() - INTERVAL '1 day' * (RANDOM() * 365)
        );
    END LOOP;
END $$;

-- إنشاء 30,000 تنبيه
-- Generate 30,000 notifications
DO $$
BEGIN
    FOR i IN 1..30000 LOOP
        INSERT INTO notifications (title, message, type, priority, department, role, user_id, is_read, created_at, read_at)
        VALUES (
            CASE (i % 8)
                WHEN 0 THEN 'طلبية جديدة'
                WHEN 1 THEN 'نفاد المخزون'
                WHEN 2 THEN 'تأخير في التسليم'
                WHEN 3 THEN 'موافقة مطلوبة'
                WHEN 4 THEN 'دفعة مستحقة'
                WHEN 5 THEN 'تحديث الحالة'
                WHEN 6 THEN 'تنبيه أمني'
                ELSE 'رسالة عامة'
            END,
            'رسالة التنبيه رقم ' || i || ' - تحتاج إلى اتخاذ إجراء فوري',
            CASE (i % 5)
                WHEN 0 THEN 'info'
                WHEN 1 THEN 'warning'
                WHEN 2 THEN 'error'
                WHEN 3 THEN 'success'
                ELSE 'system'
            END,
            CASE (i % 3)
                WHEN 0 THEN 'low'
                WHEN 1 THEN 'medium'
                ELSE 'high'
            END,
            CASE (i % 6)
                WHEN 0 THEN 'sales'
                WHEN 1 THEN 'purchasing'
                WHEN 2 THEN 'inventory'
                WHEN 3 THEN 'finance'
                WHEN 4 THEN 'management'
                ELSE 'it'
            END,
            CASE (i % 4)
                WHEN 0 THEN 'admin'
                WHEN 1 THEN 'manager'
                WHEN 2 THEN 'user'
                ELSE 'viewer'
            END,
            CASE WHEN i % 5 = 0 THEN (i % 10 + 1) ELSE NULL END,
            RANDOM() < 0.3, -- 30% مقروءة
            NOW() - INTERVAL '1 day' * (RANDOM() * 90),
            CASE WHEN RANDOM() < 0.3 THEN NOW() - INTERVAL '1 day' * (RANDOM() * 30) ELSE NULL END
        );
    END LOOP;
END $$;

-- إنشاء 10,000 حالة workflow
-- Generate 10,000 workflow states
DO $$
DECLARE
    order_ids INTEGER[];
    random_order_id INTEGER;
BEGIN
    SELECT ARRAY(SELECT id FROM sales_orders LIMIT 20000) INTO order_ids;
    
    FOR i IN 1..10000 LOOP
        random_order_id := order_ids[1 + (RANDOM() * (array_length(order_ids, 1) - 1))::INTEGER];
        
        INSERT INTO workflow_states (entity_type, entity_id, current_stage, previous_stage, next_possible_stages, stage_data, created_by, created_at, updated_at)
        VALUES (
            'sales_order',
            random_order_id,
            CASE (i % 6)
                WHEN 0 THEN 'pending'
                WHEN 1 THEN 'confirmed'
                WHEN 2 THEN 'processing'
                WHEN 3 THEN 'shipped'
                WHEN 4 THEN 'delivered'
                ELSE 'cancelled'
            END,
            CASE (i % 6)
                WHEN 0 THEN NULL
                WHEN 1 THEN 'pending'
                WHEN 2 THEN 'confirmed'
                WHEN 3 THEN 'processing'
                WHEN 4 THEN 'shipped'
                ELSE 'processing'
            END,
            CASE (i % 6)
                WHEN 0 THEN '["confirmed", "cancelled"]'
                WHEN 1 THEN '["processing", "cancelled"]'
                WHEN 2 THEN '["shipped", "cancelled"]'
                WHEN 3 THEN '["delivered", "cancelled"]'
                WHEN 4 THEN '[]'
                ELSE '[]'
            END,
            '{"notes": "حالة workflow رقم ' || i || '", "timestamp": "' || NOW() || '"}',
            1,
            NOW() - INTERVAL '1 day' * (RANDOM() * 60),
            NOW()
        );
    END LOOP;
END $$;

-- تحديث إحصائيات الجداول
-- Update table statistics
ANALYZE customers;
ANALYZE suppliers;
ANALYZE products;
ANALYZE sales_orders;
ANALYZE sales_order_items;
ANALYZE purchase_orders;
ANALYZE purchase_order_items;
ANALYZE inventory_movements;
ANALYZE notifications;
ANALYZE workflow_states;

-- عرض ملخص البيانات المُدخلة
-- Display summary of inserted data
SELECT 
    'العملاء' as الجدول, COUNT(*) as عدد_السجلات FROM customers
UNION ALL
SELECT 'الموردين', COUNT(*) FROM suppliers
UNION ALL
SELECT 'المنتجات', COUNT(*) FROM products
UNION ALL
SELECT 'طلبيات المبيعات', COUNT(*) FROM sales_orders
UNION ALL
SELECT 'عناصر طلبيات المبيعات', COUNT(*) FROM sales_order_items
UNION ALL
SELECT 'طلبيات الشراء', COUNT(*) FROM purchase_orders
UNION ALL
SELECT 'عناصر طلبيات الشراء', COUNT(*) FROM purchase_order_items
UNION ALL
SELECT 'حركات المخزون', COUNT(*) FROM inventory_movements
UNION ALL
SELECT 'التنبيهات', COUNT(*) FROM notifications
UNION ALL
SELECT 'حالات Workflow', COUNT(*) FROM workflow_states;
