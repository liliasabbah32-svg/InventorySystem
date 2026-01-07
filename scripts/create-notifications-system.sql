-- إنشاء جدول الإشعارات الرئيسي
CREATE TABLE IF NOT EXISTS notifications (
  id SERIAL PRIMARY KEY,
  notification_type VARCHAR(50) NOT NULL,
  title VARCHAR(255) NOT NULL,
  message TEXT NOT NULL,
  recipient_user_id INTEGER,
  recipient_department VARCHAR(100),
  recipient_role VARCHAR(50),
  related_order_id INTEGER,
  related_order_type VARCHAR(20),
  related_order_number VARCHAR(50),
  stage_id INTEGER,
  priority_level VARCHAR(20) DEFAULT 'normal' CHECK (priority_level IN ('low', 'normal', 'high', 'urgent')),
  is_read BOOLEAN DEFAULT false,
  is_sent BOOLEAN DEFAULT false,
  send_email BOOLEAN DEFAULT false,
  send_sms BOOLEAN DEFAULT false,
  send_whatsapp BOOLEAN DEFAULT false,
  scheduled_send_time TIMESTAMP WITH TIME ZONE,
  sent_at TIMESTAMP WITH TIME ZONE,
  read_at TIMESTAMP WITH TIME ZONE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
  
  -- Foreign key constraints
  FOREIGN KEY (stage_id) REFERENCES workflow_stages(id) ON DELETE SET NULL
);

-- إنشاء جدول قوالب الإشعارات
CREATE TABLE IF NOT EXISTS notification_templates (
  id SERIAL PRIMARY KEY,
  template_code VARCHAR(50) UNIQUE NOT NULL,
  template_name VARCHAR(255) NOT NULL,
  notification_type VARCHAR(50) NOT NULL,
  title_template TEXT NOT NULL,
  message_template TEXT NOT NULL,
  default_priority VARCHAR(20) DEFAULT 'normal' CHECK (default_priority IN ('low', 'normal', 'high', 'urgent')),
  send_email BOOLEAN DEFAULT false,
  send_sms BOOLEAN DEFAULT false,
  send_whatsapp BOOLEAN DEFAULT false,
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- إنشاء جدول قواعد الإشعارات
CREATE TABLE IF NOT EXISTS notification_rules (
  id SERIAL PRIMARY KEY,
  rule_name VARCHAR(255) NOT NULL,
  rule_type VARCHAR(50) NOT NULL,
  trigger_condition TEXT NOT NULL,
  target_stage_id INTEGER,
  target_department VARCHAR(100),
  target_role VARCHAR(50),
  hours_delay INTEGER DEFAULT 0,
  template_code VARCHAR(50) NOT NULL,
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
  
  -- Foreign key constraints
  FOREIGN KEY (target_stage_id) REFERENCES workflow_stages(id) ON DELETE SET NULL,
  FOREIGN KEY (template_code) REFERENCES notification_templates(template_code) ON DELETE CASCADE
);

-- إنشاء فهارس لتحسين الأداء
CREATE INDEX IF NOT EXISTS idx_notifications_recipient_user ON notifications(recipient_user_id);
CREATE INDEX IF NOT EXISTS idx_notifications_recipient_dept ON notifications(recipient_department);
CREATE INDEX IF NOT EXISTS idx_notifications_is_read ON notifications(is_read);
CREATE INDEX IF NOT EXISTS idx_notifications_created_at ON notifications(created_at);
CREATE INDEX IF NOT EXISTS idx_notifications_priority ON notifications(priority_level);
CREATE INDEX IF NOT EXISTS idx_notifications_related_order ON notifications(related_order_id, related_order_type);

-- إدراج قوالب الإشعارات الأساسية
INSERT INTO notification_templates (template_code, template_name, notification_type, title_template, message_template, default_priority, send_email, send_sms, send_whatsapp) VALUES
('ORDER_ASSIGNED', 'تعيين طلبية', 'order_advance', 'تم تعيين طلبية {{order_number}}', 'تم تقديم طلبية رقم {{order_number}} من مرحلة {{from_stage}} إلى مرحلة {{to_stage}} بقيمة {{total_amount}} بواسطة {{performed_by}}', 'normal', true, false, false),
('ORDER_REJECTED', 'رفض طلبية', 'order_rejection', 'تم رفض طلبية {{order_number}}', 'تم رفض طلبية رقم {{order_number}} في مرحلة {{stage_name}} للسبب: {{reason}} بواسطة {{performed_by}}', 'high', true, true, false),
('ORDER_OVERDUE', 'طلبية متأخرة', 'order_overdue', 'طلبية {{order_number}} متأخرة', 'طلبية رقم {{order_number}} متأخرة في مرحلة {{stage_name}} لمدة {{hours_overdue}} ساعة. العميل: {{partner_name}}, القيمة: {{total_amount}}', 'urgent', true, true, true),
('ORDER_APPROVED', 'موافقة على طلبية', 'order_approval', 'تم الموافقة على طلبية {{order_number}}', 'تم الموافقة على طلبية رقم {{order_number}} في مرحلة {{stage_name}} بواسطة {{performed_by}}', 'normal', true, false, false),
('SYSTEM_NOTIFICATION', 'إشعار النظام', 'system', '{{title}}', '{{message}}', 'low', false, false, false);

-- إدراج قواعد الإشعارات الأساسية
INSERT INTO notification_rules (rule_name, rule_type, trigger_condition, target_department, template_code, is_active) VALUES
('إشعار المبيعات عند التقدم', 'stage_advance', 'order_type = ''sales''', 'المبيعات', 'ORDER_ASSIGNED', true),
('إشعار المشتريات عند التقدم', 'stage_advance', 'order_type = ''purchase''', 'المشتريات', 'ORDER_ASSIGNED', true),
('إشعار الطلبيات المتأخرة', 'overdue_check', 'hours_overdue > 24', null, 'ORDER_OVERDUE', true);

-- إنشاء trigger لتحديث updated_at
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER update_notifications_updated_at BEFORE UPDATE ON notifications FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_notification_templates_updated_at BEFORE UPDATE ON notification_templates FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_notification_rules_updated_at BEFORE UPDATE ON notification_rules FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- إدراج بعض الإشعارات التجريبية للاختبار
INSERT INTO notifications (notification_type, title, message, recipient_department, priority_level, related_order_number, stage_id) VALUES
('order_advance', 'تم تقديم طلبية مبيعات', 'تم تقديم طلبية رقم SO-2024-001 إلى مرحلة الموافقة', 'المبيعات', 'normal', 'SO-2024-001', 1),
('order_overdue', 'طلبية متأخرة', 'طلبية رقم PO-2024-005 متأخرة في مرحلة المراجعة', 'المشتريات', 'high', 'PO-2024-005', 2),
('system', 'تحديث النظام', 'تم تحديث النظام بنجاح إلى الإصدار 2.1.0', null, 'low', null, null);
