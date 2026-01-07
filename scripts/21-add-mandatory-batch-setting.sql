-- إضافة إعداد الباتش الإجباري في إعدادات السندات
-- Add mandatory batch setting to document settings

-- إضافة عمود جديد لتحديد ما إذا كان الباتش إجباري
ALTER TABLE document_settings 
ADD COLUMN IF NOT EXISTS mandatory_batch BOOLEAN DEFAULT false;

-- إضافة إعداد الباتش الإجباري لجميع أنواع السندات
INSERT INTO document_settings (document_type, field_name, display_name, display_order, show_in_screen, show_in_print, is_required, field_type, mandatory_batch) VALUES
('sales-order', 'mandatory_batch_setting', 'الباتش إجباري في الحركة', 100, true, false, false, 'boolean', false),
('purchase-order', 'mandatory_batch_setting', 'الباتش إجباري في الحركة', 100, true, false, false, 'boolean', false),
('sales-invoice', 'mandatory_batch_setting', 'الباتش إجباري في الحركة', 100, true, false, false, 'boolean', false),
('purchase-invoice', 'mandatory_batch_setting', 'الباتش إجباري في الحركة', 100, true, false, false, 'boolean', false)
ON CONFLICT (document_type, field_name) DO UPDATE SET
  display_name = EXCLUDED.display_name,
  display_order = EXCLUDED.display_order,
  mandatory_batch = EXCLUDED.mandatory_batch;

-- إضافة جدول إعدادات الباتش العامة
CREATE TABLE IF NOT EXISTS batch_settings (
    id SERIAL PRIMARY KEY,
    document_type VARCHAR(100) NOT NULL,
    mandatory_batch_selection BOOLEAN DEFAULT false,
    auto_select_fifo BOOLEAN DEFAULT true,
    allow_negative_stock BOOLEAN DEFAULT false,
    require_expiry_date BOOLEAN DEFAULT false,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(document_type)
);

-- إدراج الإعدادات الافتراضية للباتش
INSERT INTO batch_settings (document_type, mandatory_batch_selection, auto_select_fifo, allow_negative_stock, require_expiry_date) VALUES
('sales-order', false, true, false, false),
('purchase-order', false, true, false, true),
('sales-invoice', false, true, false, false),
('purchase-invoice', false, true, false, true)
ON CONFLICT (document_type) DO NOTHING;

-- إنشاء فهرس للأداء
CREATE INDEX IF NOT EXISTS idx_batch_settings_document_type ON batch_settings(document_type);

-- إنشاء trigger للتحديث التلقائي
CREATE OR REPLACE FUNCTION update_batch_settings_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS update_batch_settings_updated_at ON batch_settings;
CREATE TRIGGER update_batch_settings_updated_at
    BEFORE UPDATE ON batch_settings
    FOR EACH ROW
    EXECUTE FUNCTION update_batch_settings_updated_at();

COMMENT ON TABLE batch_settings IS 'جدول إعدادات الباتش - يحدد ما إذا كان الباتش إجباري في كل نوع سند';
