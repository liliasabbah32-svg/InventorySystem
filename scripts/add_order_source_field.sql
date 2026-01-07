-- إضافة حقل مصدر الطلبية لجدول طلبيات المبيعات
ALTER TABLE sales_orders 
ADD COLUMN IF NOT EXISTS order_source VARCHAR(50) DEFAULT 'manual';

-- إضافة حقل مصدر الطلبية لجدول طلبيات المشتريات
ALTER TABLE purchase_orders 
ADD COLUMN IF NOT EXISTS order_source VARCHAR(50) DEFAULT 'manual';

-- إضافة تعليق توضيحي للحقل
COMMENT ON COLUMN sales_orders.order_source IS 'مصدر الطلبية: manual (إدخال يدوي), customer_portal (من الزبائن), api_import (استيراد API)';
COMMENT ON COLUMN purchase_orders.order_source IS 'مصدر الطلبية: manual (إدخال يدوي), supplier_portal (من الموردين), api_import (استيراد API)';

-- إنشاء فهرس لتسريع البحث حسب المصدر
CREATE INDEX IF NOT EXISTS idx_sales_orders_source ON sales_orders(order_source);
CREATE INDEX IF NOT EXISTS idx_purchase_orders_source ON purchase_orders(order_source);
