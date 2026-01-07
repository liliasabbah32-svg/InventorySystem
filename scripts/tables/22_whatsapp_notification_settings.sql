-- جدول إعدادات إشعارات WhatsApp
CREATE TABLE IF NOT EXISTS whatsapp_notification_settings (
    id SERIAL PRIMARY KEY,
    is_enabled BOOLEAN DEFAULT true,
    phone_numbers JSONB,
    message_template TEXT,
    notification_threshold VARCHAR(50) DEFAULT 'reorder_point',
    send_daily_summary BOOLEAN DEFAULT false,
    daily_summary_time TIME DEFAULT '09:00:00',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
