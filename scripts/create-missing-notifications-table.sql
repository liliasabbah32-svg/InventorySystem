-- إنشاء جدول التنبيهات إذا لم يكن موجوداً
CREATE TABLE IF NOT EXISTS notifications (
    id SERIAL PRIMARY KEY,
    notification_type VARCHAR(50) NOT NULL,
    title VARCHAR(255) NOT NULL,
    message TEXT NOT NULL,
    recipient_user_id INTEGER,
    recipient_department VARCHAR(100),
    recipient_role VARCHAR(100),
    related_order_id INTEGER,
    related_order_type VARCHAR(20),
    related_order_number VARCHAR(50),
    stage_id INTEGER,
    priority_level VARCHAR(20) DEFAULT 'normal' CHECK (priority_level IN ('low', 'normal', 'high', 'urgent')),
    is_read BOOLEAN DEFAULT FALSE,
    is_sent BOOLEAN DEFAULT FALSE,
    send_email BOOLEAN DEFAULT FALSE,
    send_sms BOOLEAN DEFAULT FALSE,
    send_whatsapp BOOLEAN DEFAULT FALSE,
    scheduled_send_time TIMESTAMP,
    sent_at TIMESTAMP,
    read_at TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- إنشاء جدول قوالب التنبيهات
CREATE TABLE IF NOT EXISTS notification_templates (
    id SERIAL PRIMARY KEY,
    template_code VARCHAR(50) UNIQUE NOT NULL,
    template_name VARCHAR(255) NOT NULL,
    notification_type VARCHAR(50) NOT NULL,
    title_template TEXT NOT NULL,
    message_template TEXT NOT NULL,
    default_priority VARCHAR(20) DEFAULT 'normal',
    send_email BOOLEAN DEFAULT FALSE,
    send_sms BOOLEAN DEFAULT FALSE,
    send_whatsapp BOOLEAN DEFAULT FALSE,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- إدراج قوالب التنبيهات الأساسية
INSERT INTO notification_templates (template_code, template_name, notification_type, title_template, message_template, default_priority) VALUES
('ORDER_ASSIGNED', 'تعيين طلبية', 'order_advance', 'تم تعيين طلبية {{order_number}}', 'تم تقديم طلبية رقم {{order_number}} من مرحلة {{from_stage}} إلى مرحلة {{to_stage}} بواسطة {{performed_by}}', 'normal'),
('ORDER_REJECTED', 'رفض طلبية', 'order_rejection', 'تم رفض طلبية {{order_number}}', 'تم رفض طلبية رقم {{order_number}} في مرحلة {{stage_name}} بواسطة {{performed_by}}. السبب: {{reason}}', 'high'),
('ORDER_OVERDUE', 'طلبية متأخرة', 'order_overdue', 'طلبية متأخرة {{order_number}}', 'طلبية رقم {{order_number}} متأخرة في مرحلة {{stage_name}} لمدة {{hours_overdue}} ساعة', 'urgent')
ON CONFLICT (template_code) DO NOTHING;

-- إنشاء فهارس للأداء
CREATE INDEX IF NOT EXISTS idx_notifications_recipient_user ON notifications(recipient_user_id);
CREATE INDEX IF NOT EXISTS idx_notifications_recipient_dept ON notifications(recipient_department);
CREATE INDEX IF NOT EXISTS idx_notifications_is_read ON notifications(is_read);
CREATE INDEX IF NOT EXISTS idx_notifications_created_at ON notifications(created_at);
CREATE INDEX IF NOT EXISTS idx_notifications_priority ON notifications(priority_level);

-- إنشاء trigger لتحديث updated_at
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER update_notifications_updated_at 
    BEFORE UPDATE ON notifications 
    FOR EACH ROW 
    EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_notification_templates_updated_at 
    BEFORE UPDATE ON notification_templates 
    FOR EACH ROW 
    EXECUTE FUNCTION update_updated_at_column();
