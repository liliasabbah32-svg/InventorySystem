-- إنشاء جدول إعدادات السندات
-- Create document_settings table

CREATE TABLE IF NOT EXISTS document_settings (
    id SERIAL PRIMARY KEY,
    document_type VARCHAR(100) NOT NULL,
    field_name VARCHAR(100) NOT NULL,
    display_name VARCHAR(100) NOT NULL,
    display_order INTEGER NOT NULL,
    show_in_screen BOOLEAN DEFAULT true,
    show_in_print BOOLEAN DEFAULT true,
    is_required BOOLEAN DEFAULT false,
    field_type VARCHAR(50) DEFAULT 'text',
    validation_rules TEXT,
    default_value TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(document_type, field_name)
);

-- إضافة الفهارس
CREATE INDEX IF NOT EXISTS idx_document_settings_type ON document_settings(document_type);

-- إدراج البيانات الافتراضية لإعدادات السندات
INSERT INTO document_settings (document_type, field_name, display_name, display_order, show_in_screen, show_in_print, is_required) VALUES
('sales-order', 'sequence', 'التسلسل', 1, true, true, true),
('sales-order', 'barcode', 'الباركود', 2, true, false, false),
('sales-order', 'product', 'رقم الصنف واسمه', 3, true, true, true),
('sales-order', 'unit', 'الوحدة', 4, true, true, true),
('sales-order', 'quantity', 'الكمية', 5, true, true, true),
('sales-order', 'price', 'السعر', 6, true, true, true),
('sales-order', 'total', 'المبلغ', 7, true, true, true),
('sales-order', 'warehouse', 'المستودع', 8, true, false, false),
('sales-order', 'notes', 'ملاحظات', 9, false, false, false),
('purchase-order', 'sequence', 'التسلسل', 1, true, true, true),
('purchase-order', 'barcode', 'الباركود', 2, true, false, false),
('purchase-order', 'product', 'رقم الصنف واسمه', 3, true, true, true),
('purchase-order', 'unit', 'الوحدة', 4, true, true, true),
('purchase-order', 'quantity', 'الكمية', 5, true, true, true),
('purchase-order', 'price', 'السعر', 6, true, true, true),
('purchase-order', 'total', 'المبلغ', 7, true, true, true),
('purchase-order', 'warehouse', 'المستودع', 8, true, false, false),
('purchase-order', 'notes', 'ملاحظات', 9, false, false, false)
ON CONFLICT (document_type, field_name) DO NOTHING;

-- إنشاء trigger للتحديث التلقائي
CREATE OR REPLACE FUNCTION update_document_settings_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS update_document_settings_updated_at ON document_settings;
CREATE TRIGGER update_document_settings_updated_at
    BEFORE UPDATE ON document_settings
    FOR EACH ROW
    EXECUTE FUNCTION update_document_settings_updated_at_column();

COMMENT ON TABLE document_settings IS 'جدول إعدادات حقول السندات - يحدد الحقول المعروضة في كل نوع سند';
