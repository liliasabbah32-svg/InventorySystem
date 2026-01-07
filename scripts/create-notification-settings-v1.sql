-- Creating notification settings table for WhatsApp alerts
CREATE TABLE IF NOT EXISTS inventory_notification_settings (
  id SERIAL PRIMARY KEY,
  notification_type VARCHAR(50) NOT NULL DEFAULT 'reorder_alert',
  is_enabled BOOLEAN NOT NULL DEFAULT true,
  phone_numbers TEXT[] NOT NULL DEFAULT '{}',
  notification_threshold VARCHAR(50) NOT NULL DEFAULT 'at_reorder_point',
  message_template TEXT,
  send_daily_summary BOOLEAN NOT NULL DEFAULT false,
  daily_summary_time TIME DEFAULT '09:00:00',
  created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Create index for faster lookups
CREATE INDEX IF NOT EXISTS idx_notification_settings_type ON inventory_notification_settings(notification_type);
CREATE INDEX IF NOT EXISTS idx_notification_settings_enabled ON inventory_notification_settings(is_enabled);

-- Insert default settings
INSERT INTO inventory_notification_settings (
  notification_type,
  is_enabled,
  phone_numbers,
  notification_threshold,
  message_template,
  send_daily_summary
) VALUES (
  'reorder_alert',
  true,
  ARRAY['+966500000000'],
  'at_reorder_point',
  'تنبيه مخزون 📦
المنتج: {product_name}
الكود: {product_code}
المخزون الحالي: {current_stock}
نقطة إعادة الطلب: {reorder_point}
يرجى إعادة الطلب من المورد.',
  false
) ON CONFLICT DO NOTHING;

-- Create notification log table
CREATE TABLE IF NOT EXISTS inventory_notification_log (
  id SERIAL PRIMARY KEY,
  product_id INTEGER REFERENCES products(id) ON DELETE CASCADE,
  product_code VARCHAR(100),
  product_name VARCHAR(255),
  notification_type VARCHAR(50) NOT NULL,
  phone_number VARCHAR(20) NOT NULL,
  message_content TEXT NOT NULL,
  status VARCHAR(20) NOT NULL DEFAULT 'pending',
  twilio_message_id VARCHAR(100),
  error_message TEXT,
  sent_at TIMESTAMP WITH TIME ZONE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Create indexes for notification log
CREATE INDEX IF NOT EXISTS idx_notification_log_product ON inventory_notification_log(product_id);
CREATE INDEX IF NOT EXISTS idx_notification_log_status ON inventory_notification_log(status);
CREATE INDEX IF NOT EXISTS idx_notification_log_created ON inventory_notification_log(created_at DESC);

-- Add comment
COMMENT ON TABLE inventory_notification_settings IS 'إعدادات إشعارات WhatsApp للمخزون';
COMMENT ON TABLE inventory_notification_log IS 'سجل إشعارات WhatsApp المرسلة';
