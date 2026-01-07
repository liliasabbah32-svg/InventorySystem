-- جدول سجل إشعارات WhatsApp
CREATE TABLE IF NOT EXISTS whatsapp_notification_log (
    id SERIAL PRIMARY KEY,
    product_id INTEGER REFERENCES products(id),
    product_code VARCHAR(100),
    product_name VARCHAR(255),
    phone_number VARCHAR(50),
    message_content TEXT,
    status VARCHAR(50),
    error_message TEXT,
    sent_at TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_whatsapp_log_product ON whatsapp_notification_log(product_id);
CREATE INDEX IF NOT EXISTS idx_whatsapp_log_status ON whatsapp_notification_log(status);
CREATE INDEX IF NOT EXISTS idx_whatsapp_log_sent ON whatsapp_notification_log(sent_at);
