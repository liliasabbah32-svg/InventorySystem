-- إنشاء جدول رسائل الواتساب
CREATE TABLE IF NOT EXISTS whatsapp_messages (
    id SERIAL PRIMARY KEY,
    recipient_phone VARCHAR(20) NOT NULL,
    recipient_name VARCHAR(255),
    message_type VARCHAR(20) NOT NULL, -- 'text', 'template', 'media', 'document', 'interactive'
    message_content TEXT NOT NULL,
    template_name VARCHAR(100),
    template_params JSONB,
    media_url TEXT,
    status VARCHAR(20) DEFAULT 'pending', -- 'pending', 'sent', 'delivered', 'read', 'failed'
    whatsapp_message_id VARCHAR(255),
    error_message TEXT,
    sent_at TIMESTAMP,
    delivered_at TIMESTAMP,
    read_at TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_whatsapp_messages_phone (recipient_phone),
    INDEX idx_whatsapp_messages_status (status),
    INDEX idx_whatsapp_messages_created (created_at DESC)
);

-- إنشاء جدول قوالب رسائل الواتساب
CREATE TABLE IF NOT EXISTS whatsapp_templates (
    id SERIAL PRIMARY KEY,
    template_code VARCHAR(100) UNIQUE NOT NULL,
    template_name VARCHAR(255) NOT NULL,
    template_category VARCHAR(50) NOT NULL, -- 'order', 'invoice', 'notification', 'marketing'
    message_template TEXT NOT NULL,
    language VARCHAR(10) DEFAULT 'ar',
    has_media BOOLEAN DEFAULT false,
    media_type VARCHAR(20), -- 'image', 'document', 'video'
    button_type VARCHAR(20), -- 'none', 'call_to_action', 'quick_reply'
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- إنشاء جدول استفسارات العملاء عبر الواتساب
CREATE TABLE IF NOT EXISTS whatsapp_customer_inquiries (
    id SERIAL PRIMARY KEY,
    customer_phone VARCHAR(20) NOT NULL,
    customer_name VARCHAR(255),
    inquiry_type VARCHAR(50) NOT NULL, -- 'order_status', 'product_info', 'new_order', 'complaint', 'general'
    inquiry_message TEXT NOT NULL,
    related_order_id INTEGER,
    related_order_number VARCHAR(100),
    status VARCHAR(20) DEFAULT 'pending', -- 'pending', 'in_progress', 'resolved', 'closed'
    assigned_to_user_id INTEGER,
    assigned_to_department VARCHAR(100),
    response_message TEXT,
    responded_at TIMESTAMP,
    responded_by_user_id INTEGER,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_whatsapp_inquiries_phone (customer_phone),
    INDEX idx_whatsapp_inquiries_status (status),
    INDEX idx_whatsapp_inquiries_type (inquiry_type)
);

-- إدراج قوالب رسائل افتراضية
INSERT INTO whatsapp_templates (template_code, template_name, template_category, message_template, language) VALUES
('ORDER_CONFIRMATION', 'تأكيد الطلبية', 'order', 'مرحباً {{customer_name}}، تم استلام طلبيتك رقم {{order_number}} بنجاح. إجمالي المبلغ: {{total_amount}}. سيتم التواصل معك قريباً.', 'ar'),
('ORDER_STATUS_UPDATE', 'تحديث حالة الطلبية', 'order', 'عزيزي {{customer_name}}، طلبيتك رقم {{order_number}} الآن في مرحلة: {{stage_name}}. {{additional_info}}', 'ar'),
('ORDER_READY', 'الطلبية جاهزة', 'order', 'مرحباً {{customer_name}}، طلبيتك رقم {{order_number}} جاهزة للاستلام. يرجى المرور على فرعنا في أقرب وقت.', 'ar'),
('ORDER_DELIVERED', 'تم التوصيل', 'order', 'شكراً لك {{customer_name}}! تم توصيل طلبيتك رقم {{order_number}} بنجاح. نتمنى أن تنال إعجابك.', 'ar'),
('INVOICE_SENT', 'إرسال فاتورة', 'invoice', 'عزيزي {{customer_name}}، نرفق لك فاتورتك رقم {{invoice_number}} بمبلغ {{total_amount}}. شكراً لتعاملك معنا.', 'ar'),
('PAYMENT_REMINDER', 'تذكير بالدفع', 'invoice', 'مرحباً {{customer_name}}، نذكرك بفاتورة رقم {{invoice_number}} بمبلغ {{total_amount}}. تاريخ الاستحقاق: {{due_date}}.', 'ar'),
('PAYMENT_RECEIVED', 'تأكيد استلام الدفع', 'invoice', 'شكراً {{customer_name}}! تم استلام دفعتك بمبلغ {{amount}} للفاتورة رقم {{invoice_number}}.', 'ar'),
('WELCOME_MESSAGE', 'رسالة ترحيب', 'marketing', 'مرحباً بك في {{company_name}}! نحن سعداء بخدمتك. للاستفسار عن منتجاتنا أو تقديم طلبية، يرجى الرد على هذه الرسالة.', 'ar'),
('PRODUCT_INQUIRY_RESPONSE', 'الرد على استفسار منتج', 'notification', 'مرحباً {{customer_name}}، بخصوص استفسارك عن {{product_name}}: {{response_message}}', 'ar'),
('GENERAL_NOTIFICATION', 'إشعار عام', 'notification', 'عزيزي {{customer_name}}، {{notification_message}}', 'ar');

-- إنشاء فهارس إضافية للأداء
CREATE INDEX IF NOT EXISTS idx_whatsapp_messages_whatsapp_id ON whatsapp_messages(whatsapp_message_id);
CREATE INDEX IF NOT EXISTS idx_whatsapp_templates_category ON whatsapp_templates(template_category);
CREATE INDEX IF NOT EXISTS idx_whatsapp_inquiries_order ON whatsapp_customer_inquiries(related_order_id);

COMMENT ON TABLE whatsapp_messages IS 'سجل جميع رسائل الواتساب المرسلة من النظام';
COMMENT ON TABLE whatsapp_templates IS 'قوالب رسائل الواتساب المعتمدة';
COMMENT ON TABLE whatsapp_customer_inquiries IS 'استفسارات وطلبات العملاء الواردة عبر الواتساب';
