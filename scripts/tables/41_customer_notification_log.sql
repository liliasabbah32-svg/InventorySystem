-- جدول سجل إشعارات العملاء
CREATE TABLE IF NOT EXISTS customer_notification_log (
    id SERIAL PRIMARY KEY,
    customer_id INTEGER REFERENCES customers(id),
    order_id INTEGER,
    order_number VARCHAR(100),
    notification_type VARCHAR(50),
    notification_method VARCHAR(20),
    phone_number VARCHAR(50),
    message_content TEXT,
    status VARCHAR(50),
    error_message TEXT,
    provider_response JSONB,
    retry_count INTEGER DEFAULT 0,
    sent_at TIMESTAMP,
    delivered_at TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_customer_notification_log_customer ON customer_notification_log(customer_id);
CREATE INDEX IF NOT EXISTS idx_customer_notification_log_order ON customer_notification_log(order_id);
CREATE INDEX IF NOT EXISTS idx_customer_notification_log_status ON customer_notification_log(status);
