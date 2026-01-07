-- إنشاء جدول التنبيهات
CREATE TABLE IF NOT EXISTS notifications (
    id SERIAL PRIMARY KEY,
    notification_type VARCHAR(50) NOT NULL, -- 'order_stage_change', 'order_overdue', 'order_assigned', 'order_rejected'
    title VARCHAR(255) NOT NULL,
    message TEXT NOT NULL,
    recipient_user_id INTEGER,
    recipient_department VARCHAR(100),
    recipient_role VARCHAR(50),
    related_order_id INTEGER,
    related_order_type VARCHAR(20), -- 'sales', 'purchase'
    related_order_number VARCHAR(100),
    stage_id INTEGER,
    priority_level VARCHAR(20) DEFAULT 'normal', -- 'low', 'normal', 'high', 'urgent'
    is_read BOOLEAN DEFAULT false,
    is_sent BOOLEAN DEFAULT false,
    send_email BOOLEAN DEFAULT false,
    send_sms BOOLEAN DEFAULT false,
    send_whatsapp BOOLEAN DEFAULT false,
    scheduled_send_time TIMESTAMP,
    sent_at TIMESTAMP,
    read_at TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (stage_id) REFERENCES workflow_stages(id),
    INDEX idx_notifications_recipient (recipient_user_id, recipient_department),
    INDEX idx_notifications_order (related_order_id, related_order_type),
    INDEX idx_notifications_unread (is_read, created_at),
    INDEX idx_notifications_type (notification_type, created_at)
);

-- إنشاء جدول قوالب التنبيهات
CREATE TABLE IF NOT EXISTS notification_templates (
    id SERIAL PRIMARY KEY,
    template_code VARCHAR(100) UNIQUE NOT NULL,
    template_name VARCHAR(255) NOT NULL,
    notification_type VARCHAR(50) NOT NULL,
    title_template VARCHAR(255) NOT NULL,
    message_template TEXT NOT NULL,
    default_priority VARCHAR(20) DEFAULT 'normal',
    send_email BOOLEAN DEFAULT false,
    send_sms BOOLEAN DEFAULT false,
    send_whatsapp BOOLEAN DEFAULT false,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- إنشاء جدول إعدادات التنبيهات للمستخدمين
CREATE TABLE IF NOT EXISTS user_notification_settings (
    id SERIAL PRIMARY KEY,
    user_id INTEGER,
    department VARCHAR(100),
    notification_type VARCHAR(50) NOT NULL,
    email_enabled BOOLEAN DEFAULT true,
    sms_enabled BOOLEAN DEFAULT false,
    whatsapp_enabled BOOLEAN DEFAULT false,
    in_app_enabled BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(user_id, department, notification_type)
);

-- إنشاء جدول قواعد التنبيهات التلقائية
CREATE TABLE IF NOT EXISTS notification_rules (
    id SERIAL PRIMARY KEY,
    rule_name VARCHAR(255) NOT NULL,
    rule_type VARCHAR(50) NOT NULL, -- 'stage_change', 'overdue_check', 'assignment'
    trigger_condition TEXT, -- JSON condition
    target_stage_id INTEGER,
    target_department VARCHAR(100),
    target_role VARCHAR(50),
    hours_delay INTEGER DEFAULT 0,
    template_code VARCHAR(100) NOT NULL,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (target_stage_id) REFERENCES workflow_stages(id),
    FOREIGN KEY (template_code) REFERENCES notification_templates(template_code)
);

-- إدراج قوالب التنبيهات الافتراضية
INSERT INTO notification_templates (template_code, template_name, notification_type, title_template, message_template, default_priority, send_email) VALUES
('ORDER_STAGE_ADVANCE', 'تقدم الطلبية للمرحلة التالية', 'order_stage_change', 'تم تقدم الطلبية {{order_number}}', 'تم تقدم الطلبية رقم {{order_number}} من مرحلة {{from_stage}} إلى مرحلة {{to_stage}}', 'normal', true),
('ORDER_ASSIGNED', 'تعيين طلبية جديدة', 'order_assigned', 'طلبية جديدة {{order_number}}', 'تم تعيين الطلبية رقم {{order_number}} إليك في مرحلة {{stage_name}}. المبلغ: {{total_amount}}', 'high', true),
('ORDER_OVERDUE', 'طلبية متأخرة', 'order_overdue', 'طلبية متأخرة {{order_number}}', 'الطلبية رقم {{order_number}} متأخرة في مرحلة {{stage_name}} منذ {{hours_overdue}} ساعة', 'urgent', true),
('ORDER_REJECTED', 'رفض طلبية', 'order_rejected', 'تم رفض الطلبية {{order_number}}', 'تم رفض الطلبية رقم {{order_number}} في مرحلة {{stage_name}}. السبب: {{reason}}', 'high', true),
('ORDER_COMPLETED', 'اكتمال طلبية', 'order_completed', 'اكتملت الطلبية {{order_number}}', 'تم إكمال الطلبية رقم {{order_number}} بنجاح. إجمالي المدة: {{total_duration}}', 'normal', true);

-- إدراج قواعد التنبيهات الافتراضية
INSERT INTO notification_rules (rule_name, rule_type, trigger_condition, target_department, template_code) VALUES
('إشعار تقدم الطلبية', 'stage_change', '{"action": "advance"}', null, 'ORDER_STAGE_ADVANCE'),
('إشعار تعيين طلبية', 'assignment', '{"action": "assign"}', null, 'ORDER_ASSIGNED'),
('فحص الطلبيات المتأخرة', 'overdue_check', '{"hours_threshold": 24}', null, 'ORDER_OVERDUE'),
('إشعار رفض الطلبية', 'stage_change', '{"action": "reject"}', null, 'ORDER_REJECTED'),
('إشعار اكتمال الطلبية', 'stage_change', '{"action": "complete"}', null, 'ORDER_COMPLETED');

-- إنشاء فهارس إضافية للأداء
CREATE INDEX IF NOT EXISTS idx_notifications_priority ON notifications(priority_level, created_at);
CREATE INDEX IF NOT EXISTS idx_notifications_scheduled ON notifications(scheduled_send_time) WHERE scheduled_send_time IS NOT NULL;
CREATE INDEX IF NOT EXISTS idx_notification_rules_active ON notification_rules(is_active, rule_type);
