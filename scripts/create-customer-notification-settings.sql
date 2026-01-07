-- إنشاء جدول إعدادات إشعارات العملاء
CREATE TABLE IF NOT EXISTS customer_notification_settings (
  id SERIAL PRIMARY KEY,
  customer_id INTEGER NOT NULL REFERENCES customers(id) ON DELETE CASCADE,
  
  -- طريقة الإرسال
  notification_method VARCHAR(20) NOT NULL DEFAULT 'sms', -- 'sms', 'whatsapp', 'both'
  
  -- رقم الهاتف المفضل للإشعارات
  preferred_phone VARCHAR(50),
  
  -- إعدادات الإشعارات لكل حالة طلبية
  notify_on_received BOOLEAN DEFAULT true, -- عند استلام الطلبية
  notify_on_preparing BOOLEAN DEFAULT true, -- عند تحضير الطلبية
  notify_on_quality_check BOOLEAN DEFAULT true, -- عند التدقيق
  notify_on_ready_to_ship BOOLEAN DEFAULT true, -- جاهز للشحن
  notify_on_shipped BOOLEAN DEFAULT true, -- تم الشحن
  notify_on_delivered BOOLEAN DEFAULT false, -- تم التسليم
  notify_on_cancelled BOOLEAN DEFAULT true, -- تم الإلغاء
  
  -- إعدادات إضافية
  is_active BOOLEAN DEFAULT true,
  send_daily_summary BOOLEAN DEFAULT false, -- إرسال ملخص يومي
  daily_summary_time TIME DEFAULT '09:00:00', -- وقت إرسال الملخص اليومي
  
  -- تواريخ
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  
  -- فهرس فريد لكل عميل
  UNIQUE(customer_id)
);

-- إنشاء فهرس لتسريع البحث
CREATE INDEX IF NOT EXISTS idx_customer_notification_settings_customer_id 
ON customer_notification_settings(customer_id);

CREATE INDEX IF NOT EXISTS idx_customer_notification_settings_active 
ON customer_notification_settings(is_active);

-- إنشاء جدول سجل الإشعارات المرسلة
CREATE TABLE IF NOT EXISTS customer_notification_log (
  id SERIAL PRIMARY KEY,
  customer_id INTEGER NOT NULL REFERENCES customers(id) ON DELETE CASCADE,
  order_id INTEGER REFERENCES sales_orders(id) ON DELETE SET NULL,
  order_number VARCHAR(50),
  
  -- معلومات الإشعار
  notification_type VARCHAR(50) NOT NULL, -- 'received', 'preparing', 'quality_check', etc.
  notification_method VARCHAR(20) NOT NULL, -- 'sms', 'whatsapp'
  phone_number VARCHAR(50) NOT NULL,
  message_content TEXT NOT NULL,
  
  -- حالة الإرسال
  status VARCHAR(20) DEFAULT 'pending', -- 'pending', 'sent', 'failed', 'delivered'
  sent_at TIMESTAMP,
  delivered_at TIMESTAMP,
  error_message TEXT,
  
  -- معلومات إضافية
  provider_response JSONB, -- استجابة مزود الخدمة
  retry_count INTEGER DEFAULT 0,
  
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- إنشاء فهارس لجدول السجل
CREATE INDEX IF NOT EXISTS idx_notification_log_customer_id 
ON customer_notification_log(customer_id);

CREATE INDEX IF NOT EXISTS idx_notification_log_order_id 
ON customer_notification_log(order_id);

CREATE INDEX IF NOT EXISTS idx_notification_log_status 
ON customer_notification_log(status);

CREATE INDEX IF NOT EXISTS idx_notification_log_created_at 
ON customer_notification_log(created_at DESC);

-- إضافة تعليقات على الجداول
COMMENT ON TABLE customer_notification_settings IS 'إعدادات إشعارات العملاء عبر SMS و WhatsApp';
COMMENT ON TABLE customer_notification_log IS 'سجل الإشعارات المرسلة للعملاء';

-- إدراج إعدادات افتراضية للعملاء الموجودين
INSERT INTO customer_notification_settings (customer_id, preferred_phone, notification_method)
SELECT 
  id,
  COALESCE(whatsapp1, mobile1) as preferred_phone,
  CASE 
    WHEN whatsapp1 IS NOT NULL AND whatsapp1 != '' THEN 'whatsapp'
    ELSE 'sms'
  END as notification_method
FROM customers
WHERE id NOT IN (SELECT customer_id FROM customer_notification_settings)
ON CONFLICT (customer_id) DO NOTHING;
