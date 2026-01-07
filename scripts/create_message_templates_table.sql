-- إنشاء جدول قوالب الرسائل
CREATE TABLE IF NOT EXISTS message_templates (
  id SERIAL PRIMARY KEY,
  template_name VARCHAR(255) NOT NULL,
  template_code VARCHAR(100) UNIQUE NOT NULL,
  template_category VARCHAR(100) NOT NULL, -- inventory, orders, customers, general
  message_content TEXT NOT NULL,
  variables JSONB, -- قائمة المتغيرات المتاحة
  is_active BOOLEAN DEFAULT true,
  is_system BOOLEAN DEFAULT false, -- القوالب النظامية لا يمكن حذفها
  usage_count INTEGER DEFAULT 0,
  last_used_at TIMESTAMP,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  created_by VARCHAR(255)
);

-- إنشاء جدول إحصائيات الرسائل اليومية
CREATE TABLE IF NOT EXISTS message_statistics (
  id SERIAL PRIMARY KEY,
  stat_date DATE NOT NULL,
  message_type VARCHAR(50) NOT NULL, -- sms, whatsapp
  total_sent INTEGER DEFAULT 0,
  total_delivered INTEGER DEFAULT 0,
  total_failed INTEGER DEFAULT 0,
  total_pending INTEGER DEFAULT 0,
  success_rate NUMERIC(5,2),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  UNIQUE(stat_date, message_type)
);

-- إنشاء جدول جدولة الرسائل
CREATE TABLE IF NOT EXISTS scheduled_messages (
  id SERIAL PRIMARY KEY,
  template_id INTEGER REFERENCES message_templates(id),
  recipient_type VARCHAR(50) NOT NULL, -- specific, group, all
  recipient_phones JSONB, -- قائمة أرقام الهواتف
  message_content TEXT NOT NULL,
  scheduled_time TIMESTAMP NOT NULL,
  repeat_type VARCHAR(50), -- once, daily, weekly, monthly
  repeat_until DATE,
  status VARCHAR(50) DEFAULT 'pending', -- pending, sent, cancelled
  sent_at TIMESTAMP,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  created_by VARCHAR(255)
);

-- إضافة فهارس لتحسين الأداء
CREATE INDEX IF NOT EXISTS idx_message_templates_category ON message_templates(template_category);
CREATE INDEX IF NOT EXISTS idx_message_templates_active ON message_templates(is_active);
CREATE INDEX IF NOT EXISTS idx_message_statistics_date ON message_statistics(stat_date);
CREATE INDEX IF NOT EXISTS idx_scheduled_messages_time ON scheduled_messages(scheduled_time);
CREATE INDEX IF NOT EXISTS idx_scheduled_messages_status ON scheduled_messages(status);

-- إدراج قوالب افتراضية
INSERT INTO message_templates (template_name, template_code, template_category, message_content, variables, is_system, created_by) VALUES
('تنبيه إعادة طلب المخزون', 'INVENTORY_REORDER', 'inventory', 
'🔔 تنبيه إعادة طلب

📦 المنتج: {product_name}
🔢 الكود: {product_code}
📊 المخزون الحالي: {current_stock}
⚠️ نقطة إعادة الطلب: {reorder_point}
🏭 المورد: {supplier_name}

يرجى اتخاذ الإجراء اللازم.',
'["product_name", "product_code", "current_stock", "reorder_point", "supplier_name"]'::jsonb,
true, 'system'),

('تأكيد طلبية جديدة', 'ORDER_CONFIRMATION', 'orders',
'✅ تم استلام طلبيتك

📋 رقم الطلبية: {order_number}
📅 التاريخ: {order_date}
💰 المبلغ الإجمالي: {total_amount} {currency}
🚚 موعد التسليم المتوقع: {delivery_date}

شكراً لتعاملكم معنا!',
'["order_number", "order_date", "total_amount", "currency", "delivery_date"]'::jsonb,
true, 'system'),

('تحديث حالة الطلبية', 'ORDER_STATUS_UPDATE', 'orders',
'📦 تحديث حالة الطلبية

📋 رقم الطلبية: {order_number}
🔄 الحالة الجديدة: {new_status}
📝 ملاحظات: {notes}

للاستفسار: اتصل بنا',
'["order_number", "new_status", "notes"]'::jsonb,
true, 'system'),

('رسالة ترحيبية للعميل', 'CUSTOMER_WELCOME', 'customers',
'🎉 مرحباً بك!

عزيزي {customer_name}،

نشكرك على انضمامك إلينا. نحن سعداء بخدمتك!

📱 رقم حسابك: {customer_code}
🌐 يمكنك تسجيل الدخول عبر: {portal_url}

نتطلع لخدمتك!',
'["customer_name", "customer_code", "portal_url"]'::jsonb,
true, 'system');

-- إنشاء دالة لتحديث الإحصائيات
CREATE OR REPLACE FUNCTION update_message_statistics()
RETURNS void AS $$
BEGIN
  -- تحديث إحصائيات WhatsApp
  INSERT INTO message_statistics (stat_date, message_type, total_sent, total_delivered, total_failed, total_pending, success_rate)
  SELECT 
    CURRENT_DATE,
    'whatsapp',
    COUNT(*),
    COUNT(*) FILTER (WHERE status = 'sent'),
    COUNT(*) FILTER (WHERE status = 'failed'),
    COUNT(*) FILTER (WHERE status = 'pending'),
    ROUND((COUNT(*) FILTER (WHERE status = 'sent')::NUMERIC / NULLIF(COUNT(*), 0) * 100), 2)
  FROM whatsapp_notification_log
  WHERE DATE(created_at) = CURRENT_DATE
  ON CONFLICT (stat_date, message_type) 
  DO UPDATE SET
    total_sent = EXCLUDED.total_sent,
    total_delivered = EXCLUDED.total_delivered,
    total_failed = EXCLUDED.total_failed,
    total_pending = EXCLUDED.total_pending,
    success_rate = EXCLUDED.success_rate;

  -- تحديث إحصائيات SMS (من جدول customer_notification_log)
  INSERT INTO message_statistics (stat_date, message_type, total_sent, total_delivered, total_failed, total_pending, success_rate)
  SELECT 
    CURRENT_DATE,
    'sms',
    COUNT(*),
    COUNT(*) FILTER (WHERE status = 'delivered'),
    COUNT(*) FILTER (WHERE status = 'failed'),
    COUNT(*) FILTER (WHERE status = 'pending'),
    ROUND((COUNT(*) FILTER (WHERE status = 'delivered')::NUMERIC / NULLIF(COUNT(*), 0) * 100), 2)
  FROM customer_notification_log
  WHERE DATE(created_at) = CURRENT_DATE
    AND notification_method = 'sms'
  ON CONFLICT (stat_date, message_type) 
  DO UPDATE SET
    total_sent = EXCLUDED.total_sent,
    total_delivered = EXCLUDED.total_delivered,
    total_failed = EXCLUDED.total_failed,
    total_pending = EXCLUDED.total_pending,
    success_rate = EXCLUDED.success_rate;
END;
$$ LANGUAGE plpgsql;

COMMENT ON TABLE message_templates IS 'قوالب الرسائل القابلة لإعادة الاستخدام';
COMMENT ON TABLE message_statistics IS 'إحصائيات الرسائل اليومية';
COMMENT ON TABLE scheduled_messages IS 'الرسائل المجدولة للإرسال';
