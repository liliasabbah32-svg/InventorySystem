-- Create WhatsApp notification settings table if not exists
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

-- Create inventory notification log table if not exists
CREATE TABLE IF NOT EXISTS inventory_notification_log (
  id SERIAL PRIMARY KEY,
  product_code VARCHAR(100),
  product_name VARCHAR(255),
  phone_number VARCHAR(20),
  status VARCHAR(20) DEFAULT 'pending',
  sent_at TIMESTAMP,
  error_message TEXT,
  created_at TIMESTAMP DEFAULT NOW()
);

-- Create index for faster queries
CREATE INDEX IF NOT EXISTS idx_notification_log_product_code ON inventory_notification_log(product_code);
CREATE INDEX IF NOT EXISTS idx_notification_log_created_at ON inventory_notification_log(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_notification_log_status ON inventory_notification_log(status);

-- Insert default settings if table is empty
INSERT INTO whatsapp_notification_settings (
  is_enabled,
  phone_numbers,
  notification_threshold,
  message_template,
  send_daily_summary,
  daily_summary_time
)
SELECT 
  false,
  '[]'::jsonb,
  'at_reorder_point',
  '🔔 *تنبيه إعادة طلب*

📦 *المنتج:* {product_name}
🔢 *الكود:* {product_code}
📊 *المخزون الحالي:* {current_stock}
⚠️ *نقطة إعادة الطلب:* {reorder_point}

⏰ *الوقت:* ' || TO_CHAR(NOW(), 'YYYY-MM-DD HH24:MI:SS') || '

✅ يرجى اتخاذ الإجراء اللازم لإعادة طلب هذا المنتج.',
  false,
  '09:00'::time
WHERE NOT EXISTS (SELECT 1 FROM whatsapp_notification_settings);

COMMENT ON TABLE whatsapp_notification_settings IS 'إعدادات إشعارات WhatsApp لإعادة الطلب التلقائي';
COMMENT ON TABLE inventory_notification_log IS 'سجل إشعارات WhatsApp المرسلة للمخزون';
