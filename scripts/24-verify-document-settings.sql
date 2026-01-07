-- التحقق من وجود جدول إعدادات السندات وإنشائه إذا لم يكن موجوداً
CREATE TABLE IF NOT EXISTS document_settings (
    id SERIAL PRIMARY KEY,
    document_type VARCHAR(50) NOT NULL,
    field_name VARCHAR(100) NOT NULL,
    display_name VARCHAR(100),
    display_order INTEGER DEFAULT 0,
    show_in_screen BOOLEAN DEFAULT true,
    show_in_print BOOLEAN DEFAULT true,
    is_required BOOLEAN DEFAULT false,
    field_type VARCHAR(50) DEFAULT 'text',
    validation_rules TEXT,
    default_value TEXT,
    mandatory_batch BOOLEAN DEFAULT false,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(document_type, field_name)
);

-- إنشاء فهرس لتسريع الاستعلامات
CREATE INDEX IF NOT EXISTS idx_document_settings_type ON document_settings(document_type);
CREATE INDEX IF NOT EXISTS idx_document_settings_order ON document_settings(document_type, display_order);

-- حذف الإعدادات القديمة إذا كانت موجودة
DELETE FROM document_settings;

-- إضافة الإعدادات الافتراضية لجميع أنواع السندات
-- 1. طلبية مبيعات (sales-order)
INSERT INTO document_settings (document_type, field_name, display_name, display_order, show_in_screen, show_in_print, is_required, field_type) VALUES
('sales-order', 'sequence', 'م', 1, true, true, true, 'text'),
('sales-order', 'barcode', 'الباركود', 2, true, false, false, 'text'),
('sales-order', 'product', 'الصنف', 3, true, true, true, 'text'),
('sales-order', 'unit', 'الوحدة', 4, true, true, true, 'text'),
('sales-order', 'quantity', 'الكمية', 5, true, true, true, 'number'),
('sales-order', 'expiry_date', 'تاريخ الصلاحية', 6, false, false, false, 'date'),
('sales-order', 'batch_number', 'رقم الباتش', 7, false, false, false, 'text'),
('sales-order', 'bonus', 'البونص', 8, false, false, false, 'number'),
('sales-order', 'discount', 'الخصم', 9, true, true, false, 'number'),
('sales-order', 'warehouse', 'المستودع', 10, true, false, false, 'text'),
('sales-order', 'price', 'السعر', 11, true, true, true, 'number'),
('sales-order', 'total', 'المبلغ', 12, true, true, true, 'number'),
('sales-order', 'item_notes', 'ملاحظة الصنف', 13, false, false, false, 'text');

-- 2. طلبية مشتريات (purchase-order)
INSERT INTO document_settings (document_type, field_name, display_name, display_order, show_in_screen, show_in_print, is_required, field_type) VALUES
('purchase-order', 'sequence', 'م', 1, true, true, true, 'text'),
('purchase-order', 'barcode', 'الباركود', 2, true, false, false, 'text'),
('purchase-order', 'product', 'الصنف', 3, true, true, true, 'text'),
('purchase-order', 'unit', 'الوحدة', 4, true, true, true, 'text'),
('purchase-order', 'quantity', 'الكمية', 5, true, true, true, 'number'),
('purchase-order', 'expiry_date', 'تاريخ الصلاحية', 6, true, true, false, 'date'),
('purchase-order', 'batch_number', 'رقم الباتش', 7, true, true, false, 'text'),
('purchase-order', 'bonus', 'البونص', 8, true, true, false, 'number'),
('purchase-order', 'warehouse', 'المستودع', 9, true, false, true, 'text'),
('purchase-order', 'price', 'السعر', 10, true, true, true, 'number'),
('purchase-order', 'total', 'المبلغ', 11, true, true, true, 'number'),
('purchase-order', 'item_notes', 'ملاحظة الصنف', 12, false, false, false, 'text');

-- 3. فاتورة مبيعات (sales-invoice)
INSERT INTO document_settings (document_type, field_name, display_name, display_order, show_in_screen, show_in_print, is_required, field_type) VALUES
('sales-invoice', 'sequence', 'م', 1, true, true, true, 'text'),
('sales-invoice', 'barcode', 'الباركود', 2, true, false, false, 'text'),
('sales-invoice', 'product', 'الصنف', 3, true, true, true, 'text'),
('sales-invoice', 'unit', 'الوحدة', 4, true, true, true, 'text'),
('sales-invoice', 'quantity', 'الكمية', 5, true, true, true, 'number'),
('sales-invoice', 'batch_number', 'رقم الباتش', 6, false, false, false, 'text'),
('sales-invoice', 'discount', 'الخصم', 7, true, true, false, 'number'),
('sales-invoice', 'tax', 'الضريبة', 8, true, true, false, 'number'),
('sales-invoice', 'price', 'السعر', 9, true, true, true, 'number'),
('sales-invoice', 'total', 'المبلغ', 10, true, true, true, 'number'),
('sales-invoice', 'item_notes', 'ملاحظة الصنف', 11, false, false, false, 'text');

-- 4. فاتورة مشتريات (purchase-invoice)
INSERT INTO document_settings (document_type, field_name, display_name, display_order, show_in_screen, show_in_print, is_required, field_type) VALUES
('purchase-invoice', 'sequence', 'م', 1, true, true, true, 'text'),
('purchase-invoice', 'barcode', 'الباركود', 2, true, false, false, 'text'),
('purchase-invoice', 'product', 'الصنف', 3, true, true, true, 'text'),
('purchase-invoice', 'unit', 'الوحدة', 4, true, true, true, 'text'),
('purchase-invoice', 'quantity', 'الكمية', 5, true, true, true, 'number'),
('purchase-invoice', 'expiry_date', 'تاريخ الصلاحية', 6, true, true, false, 'date'),
('purchase-invoice', 'batch_number', 'رقم الباتش', 7, true, true, false, 'text'),
('purchase-invoice', 'bonus', 'البونص', 8, true, true, false, 'number'),
('purchase-invoice', 'tax', 'الضريبة', 9, true, true, false, 'number'),
('purchase-invoice', 'price', 'السعر', 10, true, true, true, 'number'),
('purchase-invoice', 'total', 'المبلغ', 11, true, true, true, 'number'),
('purchase-invoice', 'item_notes', 'ملاحظة الصنف', 12, false, false, false, 'text');

-- 5. سند قبض (receipt)
INSERT INTO document_settings (document_type, field_name, display_name, display_order, show_in_screen, show_in_print, is_required, field_type) VALUES
('receipt', 'sequence', 'م', 1, true, true, true, 'text'),
('receipt', 'date', 'التاريخ', 2, true, true, true, 'date'),
('receipt', 'customer', 'العميل', 3, true, true, true, 'text'),
('receipt', 'amount', 'المبلغ', 4, true, true, true, 'number'),
('receipt', 'payment_method', 'طريقة الدفع', 5, true, true, true, 'text'),
('receipt', 'reference', 'المرجع', 6, true, true, false, 'text'),
('receipt', 'notes', 'الملاحظات', 7, true, true, false, 'text');

-- 6. سند دفع (payment)
INSERT INTO document_settings (document_type, field_name, display_name, display_order, show_in_screen, show_in_print, is_required, field_type) VALUES
('payment', 'sequence', 'م', 1, true, true, true, 'text'),
('payment', 'date', 'التاريخ', 2, true, true, true, 'date'),
('payment', 'supplier', 'المورد', 3, true, true, true, 'text'),
('payment', 'amount', 'المبلغ', 4, true, true, true, 'number'),
('payment', 'payment_method', 'طريقة الدفع', 5, true, true, true, 'text'),
('payment', 'reference', 'المرجع', 6, true, true, false, 'text'),
('payment', 'notes', 'الملاحظات', 7, true, true, false, 'text');

-- 7. إشعار دائن (credit-note)
INSERT INTO document_settings (document_type, field_name, display_name, display_order, show_in_screen, show_in_print, is_required, field_type) VALUES
('credit-note', 'sequence', 'م', 1, true, true, true, 'text'),
('credit-note', 'date', 'التاريخ', 2, true, true, true, 'date'),
('credit-note', 'customer', 'العميل', 3, true, true, true, 'text'),
('credit-note', 'product', 'الصنف', 4, true, true, true, 'text'),
('credit-note', 'quantity', 'الكمية', 5, true, true, true, 'number'),
('credit-note', 'price', 'السعر', 6, true, true, true, 'number'),
('credit-note', 'total', 'المبلغ', 7, true, true, true, 'number'),
('credit-note', 'reason', 'السبب', 8, true, true, true, 'text'),
('credit-note', 'notes', 'الملاحظات', 9, true, true, false, 'text');

-- 8. إشعار مدين (debit-note)
INSERT INTO document_settings (document_type, field_name, display_name, display_order, show_in_screen, show_in_print, is_required, field_type) VALUES
('debit-note', 'sequence', 'م', 1, true, true, true, 'text'),
('debit-note', 'date', 'التاريخ', 2, true, true, true, 'date'),
('debit-note', 'supplier', 'المورد', 3, true, true, true, 'text'),
('debit-note', 'product', 'الصنف', 4, true, true, true, 'text'),
('debit-note', 'quantity', 'الكمية', 5, true, true, true, 'number'),
('debit-note', 'price', 'السعر', 6, true, true, true, 'number'),
('debit-note', 'total', 'المبلغ', 7, true, true, true, 'number'),
('debit-note', 'reason', 'السبب', 8, true, true, true, 'text'),
('debit-note', 'notes', 'الملاحظات', 9, true, true, false, 'text');

-- التحقق من الإعدادات المضافة
SELECT 
    document_type,
    COUNT(*) as field_count,
    COUNT(CASE WHEN show_in_screen THEN 1 END) as screen_fields,
    COUNT(CASE WHEN show_in_print THEN 1 END) as print_fields,
    COUNT(CASE WHEN is_required THEN 1 END) as required_fields
FROM document_settings
GROUP BY document_type
ORDER BY document_type;
