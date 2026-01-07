-- Create WhatsApp notification settings table
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

-- Create WhatsApp notification log table
CREATE TABLE IF NOT EXISTS whatsapp_notification_log (
  id SERIAL PRIMARY KEY,
  product_id INTEGER REFERENCES products(id) ON DELETE CASCADE,
  product_code VARCHAR(100),
  product_name VARCHAR(255),
  phone_number VARCHAR(20),
  message_content TEXT,
  status VARCHAR(20) DEFAULT 'pending', -- pending, sent, failed
  error_message TEXT,
  sent_at TIMESTAMP,
  created_at TIMESTAMP DEFAULT NOW()
);

-- Create index for faster queries
CREATE INDEX IF NOT EXISTS idx_whatsapp_log_product_id ON whatsapp_notification_log(product_id);
CREATE INDEX IF NOT EXISTS idx_whatsapp_log_status ON whatsapp_notification_log(status);
CREATE INDEX IF NOT EXISTS idx_whatsapp_log_created_at ON whatsapp_notification_log(created_at DESC);

-- Insert default settings
INSERT INTO whatsapp_notification_settings (
  is_enabled,
  phone_numbers,
  message_template
) VALUES (
  false,
  '{}',
  '🔔 تنبيه إعادة طلب

📦 المنتج: {product_name}
🔢 الكود: {product_code}
📊 المخزون الحالي: {current_stock}
⚠️ نقطة إعادة الطلب: {reorder_point}
🏭 المورد: {supplier_name}

يرجى اتخاذ الإجراء اللازم.'
) ON CONFLICT DO NOTHING;

-- Add comment to tables
COMMENT ON TABLE whatsapp_notification_settings IS 'Settings for WhatsApp notifications when inventory reaches reorder point';
COMMENT ON TABLE whatsapp_notification_log IS 'Log of all WhatsApp notifications sent for inventory reorder alerts';
