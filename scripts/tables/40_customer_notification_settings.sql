-- جدول إعدادات إشعارات العملاء
CREATE TABLE IF NOT EXISTS customer_notification_settings (
    id SERIAL PRIMARY KEY,
    customer_id INTEGER REFERENCES customers(id) ON DELETE CASCADE,
    notification_method VARCHAR(20) DEFAULT 'whatsapp',
    preferred_phone VARCHAR(50),
    is_active BOOLEAN DEFAULT true,
    notify_on_received BOOLEAN DEFAULT true,
    notify_on_preparing BOOLEAN DEFAULT true,
    notify_on_quality_check BOOLEAN DEFAULT false,
    notify_on_ready_to_ship BOOLEAN DEFAULT true,
    notify_on_shipped BOOLEAN DEFAULT true,
    notify_on_delivered BOOLEAN DEFAULT true,
    notify_on_cancelled BOOLEAN DEFAULT true,
    send_daily_summary BOOLEAN DEFAULT false,
    daily_summary_time TIME DEFAULT '18:00:00',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(customer_id)
);

CREATE INDEX IF NOT EXISTS idx_customer_notification_customer ON customer_notification_settings(customer_id);
