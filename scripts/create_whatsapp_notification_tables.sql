-- Create table for WhatsApp notification settings if it doesn't exist
CREATE TABLE IF NOT EXISTS whatsapp_notification_settings (
  id SERIAL PRIMARY KEY,
  is_enabled BOOLEAN DEFAULT false,
  phone_numbers JSONB DEFAULT '[]'::jsonb,
  notification_threshold VARCHAR(50) DEFAULT 'at_reorder_point',
  message_template TEXT,
  send_daily_summary BOOLEAN DEFAULT false,
  daily_summary_time TIME DEFAULT '09:00',
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);

-- Create table for WhatsApp notification logs
CREATE TABLE IF NOT EXISTS whatsapp_notification_log (
  id SERIAL PRIMARY KEY,
  product_id INTEGER REFERENCES products(id),
  product_code VARCHAR(255),
  product_name VARCHAR(255),
  phone_number VARCHAR(50),
  message_content TEXT,
  status VARCHAR(50) DEFAULT 'pending',
  error_message TEXT,
  sent_at TIMESTAMP,
  created_at TIMESTAMP DEFAULT NOW()
);

-- Create index for faster queries
CREATE INDEX IF NOT EXISTS idx_whatsapp_log_product_id ON whatsapp_notification_log(product_id);
CREATE INDEX IF NOT EXISTS idx_whatsapp_log_status ON whatsapp_notification_log(status);
CREATE INDEX IF NOT EXISTS idx_whatsapp_log_created_at ON whatsapp_notification_log(created_at DESC);

-- Add comment
COMMENT ON TABLE whatsapp_notification_settings IS 'Settings for WhatsApp notifications when inventory reaches reorder point';
COMMENT ON TABLE whatsapp_notification_log IS 'Log of all WhatsApp notifications sent for inventory reorder alerts';
