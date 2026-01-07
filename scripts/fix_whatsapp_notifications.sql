-- إصلاح وتحديث جداول إشعارات WhatsApp
-- هذا السكريبت آمن ويمكن تشغيله عدة مرات

-- التأكد من وجود جدول الإعدادات بالبنية الصحيحة
DO $$ 
BEGIN
    -- حذف الجدول القديم إذا كان موجوداً بنية مختلفة
    IF EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'whatsapp_notification_settings' 
        AND column_name = 'phone_numbers' 
        AND data_type = 'jsonb'
    ) THEN
        -- تحويل phone_numbers من jsonb إلى text[]
        ALTER TABLE whatsapp_notification_settings 
        ALTER COLUMN phone_numbers TYPE text[] 
        USING CASE 
            WHEN jsonb_typeof(phone_numbers) = 'array' 
            THEN ARRAY(SELECT jsonb_array_elements_text(phone_numbers))
            ELSE '{}'::text[]
        END;
    END IF;
END $$;

-- إنشاء أو تحديث جدول الإعدادات
CREATE TABLE IF NOT EXISTS whatsapp_notification_settings (
    id SERIAL PRIMARY KEY,
    is_enabled BOOLEAN DEFAULT false,
    phone_numbers TEXT[] DEFAULT '{}',
    notification_threshold VARCHAR(50) DEFAULT 'at_reorder_point',
    message_template TEXT DEFAULT '🔔 تنبيه إعادة طلب

📦 المنتج: {product_name}
🔢 الكود: {product_code}
📊 المخزون الحالي: {current_stock}
⚠️ نقطة إعادة الطلب: {reorder_point}
🏭 المورد: {supplier_name}

يرجى اتخاذ الإجراء اللازم.',
    send_daily_summary BOOLEAN DEFAULT false,
    daily_summary_time TIME DEFAULT '09:00:00',
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

-- إنشاء أو تحديث جدول السجل
CREATE TABLE IF NOT EXISTS whatsapp_notification_log (
    id SERIAL PRIMARY KEY,
    product_id INTEGER REFERENCES products(id) ON DELETE CASCADE,
    product_code VARCHAR(100),
    product_name VARCHAR(255),
    phone_number VARCHAR(20),
    message_content TEXT,
    status VARCHAR(20) DEFAULT 'pending',
    error_message TEXT,
    sent_at TIMESTAMP,
    created_at TIMESTAMP DEFAULT NOW()
);

-- إنشاء الفهارس للأداء الأفضل
CREATE INDEX IF NOT EXISTS idx_whatsapp_log_product_id ON whatsapp_notification_log(product_id);
CREATE INDEX IF NOT EXISTS idx_whatsapp_log_status ON whatsapp_notification_log(status);
CREATE INDEX IF NOT EXISTS idx_whatsapp_log_created_at ON whatsapp_notification_log(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_whatsapp_log_sent_at ON whatsapp_notification_log(sent_at DESC);

-- إدراج الإعدادات الافتراضية إذا لم تكن موجودة
INSERT INTO whatsapp_notification_settings (
    is_enabled,
    phone_numbers,
    notification_threshold,
    message_template,
    send_daily_summary,
    daily_summary_time
)
SELECT 
    false,
    '{}',
    'at_reorder_point',
    '🔔 تنبيه إعادة طلب

📦 المنتج: {product_name}
🔢 الكود: {product_code}
📊 المخزون الحالي: {current_stock}
⚠️ نقطة إعادة الطلب: {reorder_point}
🏭 المورد: {supplier_name}

يرجى اتخاذ الإجراء اللازم.',
    false,
    '09:00:00'
WHERE NOT EXISTS (SELECT 1 FROM whatsapp_notification_settings LIMIT 1);

-- إضافة التعليقات التوضيحية
COMMENT ON TABLE whatsapp_notification_settings IS 'إعدادات إشعارات WhatsApp عند وصول المخزون لنقطة إعادة الطلب';
COMMENT ON TABLE whatsapp_notification_log IS 'سجل جميع إشعارات WhatsApp المرسلة للمخزون';

COMMENT ON COLUMN whatsapp_notification_settings.is_enabled IS 'تفعيل/تعطيل نظام الإشعارات';
COMMENT ON COLUMN whatsapp_notification_settings.phone_numbers IS 'قائمة أرقام الهواتف المستقبلة للإشعارات';
COMMENT ON COLUMN whatsapp_notification_settings.notification_threshold IS 'متى يتم إرسال الإشعار (at_reorder_point, below_reorder_point)';
COMMENT ON COLUMN whatsapp_notification_settings.message_template IS 'قالب الرسالة مع المتغيرات الديناميكية';
COMMENT ON COLUMN whatsapp_notification_settings.send_daily_summary IS 'إرسال ملخص يومي';
COMMENT ON COLUMN whatsapp_notification_settings.daily_summary_time IS 'وقت إرسال الملخص اليومي';

COMMENT ON COLUMN whatsapp_notification_log.status IS 'حالة الإشعار: pending, sent, failed';
COMMENT ON COLUMN whatsapp_notification_log.sent_at IS 'وقت إرسال الإشعار الفعلي';
