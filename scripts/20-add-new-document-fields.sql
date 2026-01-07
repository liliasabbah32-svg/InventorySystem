-- إضافة الحقول الجديدة إلى إعدادات السندات
-- Adding new fields to document settings

-- إضافة الحقول الجديدة لطلبيات المبيعات
INSERT INTO document_settings (document_type, field_name, display_name, display_order, show_in_screen, show_in_print, is_required) VALUES
('sales-order', 'expiry_date', 'تاريخ الصلاحية', 10, false, false, false),
('sales-order', 'batch_number', 'رقم الباتش', 11, false, false, false),
('sales-order', 'bonus', 'البونص', 12, false, false, false),
('sales-order', 'length', 'الطول', 13, false, false, false),
('sales-order', 'width', 'العرض', 14, false, false, false),
('sales-order', 'count', 'العد', 15, false, false, false),
('sales-order', 'color', 'اللون', 16, false, false, false),
('sales-order', 'discount', 'الخصم', 17, false, false, false),
('sales-order', 'item_notes', 'ملاحظة الصنف', 18, false, false, false)
ON CONFLICT (document_type, field_name) DO UPDATE SET
  display_name = EXCLUDED.display_name,
  display_order = EXCLUDED.display_order;

-- إضافة الحقول الجديدة لطلبيات المشتريات
INSERT INTO document_settings (document_type, field_name, display_name, display_order, show_in_screen, show_in_print, is_required) VALUES
('purchase-order', 'expiry_date', 'تاريخ الصلاحية', 10, false, false, false),
('purchase-order', 'batch_number', 'رقم الباتش', 11, false, false, false),
('purchase-order', 'bonus', 'البونص', 12, false, false, false),
('purchase-order', 'length', 'الطول', 13, false, false, false),
('purchase-order', 'width', 'العرض', 14, false, false, false),
('purchase-order', 'count', 'العد', 15, false, false, false),
('purchase-order', 'color', 'اللون', 16, false, false, false),
('purchase-order', 'discount', 'الخصم', 17, false, false, false),
('purchase-order', 'item_notes', 'ملاحظة الصنف', 18, false, false, false)
ON CONFLICT (document_type, field_name) DO UPDATE SET
  display_name = EXCLUDED.display_name,
  display_order = EXCLUDED.display_order;

-- إضافة الحقول الجديدة لفواتير المبيعات
INSERT INTO document_settings (document_type, field_name, display_name, display_order, show_in_screen, show_in_print, is_required) VALUES
('sales-invoice', 'sequence', 'التسلسل', 1, true, true, true),
('sales-invoice', 'barcode', 'الباركود', 2, true, false, false),
('sales-invoice', 'product', 'رقم الصنف واسمه', 3, true, true, true),
('sales-invoice', 'unit', 'الوحدة', 4, true, true, true),
('sales-invoice', 'quantity', 'الكمية', 5, true, true, true),
('sales-invoice', 'price', 'السعر', 6, true, true, true),
('sales-invoice', 'total', 'المبلغ', 7, true, true, true),
('sales-invoice', 'warehouse', 'المستودع', 8, true, false, false),
('sales-invoice', 'notes', 'ملاحظات', 9, false, false, false),
('sales-invoice', 'expiry_date', 'تاريخ الصلاحية', 10, false, false, false),
('sales-invoice', 'batch_number', 'رقم الباتش', 11, false, false, false),
('sales-invoice', 'bonus', 'البونص', 12, false, false, false),
('sales-invoice', 'length', 'الطول', 13, false, false, false),
('sales-invoice', 'width', 'العرض', 14, false, false, false),
('sales-invoice', 'count', 'العد', 15, false, false, false),
('sales-invoice', 'color', 'اللون', 16, false, false, false),
('sales-invoice', 'discount', 'الخصم', 17, false, false, false),
('sales-invoice', 'item_notes', 'ملاحظة الصنف', 18, false, false, false)
ON CONFLICT (document_type, field_name) DO UPDATE SET
  display_name = EXCLUDED.display_name,
  display_order = EXCLUDED.display_order;

-- إضافة الحقول الجديدة لفواتير المشتريات
INSERT INTO document_settings (document_type, field_name, display_name, display_order, show_in_screen, show_in_print, is_required) VALUES
('purchase-invoice', 'sequence', 'التسلسل', 1, true, true, true),
('purchase-invoice', 'barcode', 'الباركود', 2, true, false, false),
('purchase-invoice', 'product', 'رقم الصنف واسمه', 3, true, true, true),
('purchase-invoice', 'unit', 'الوحدة', 4, true, true, true),
('purchase-invoice', 'quantity', 'الكمية', 5, true, true, true),
('purchase-invoice', 'price', 'السعر', 6, true, true, true),
('purchase-invoice', 'total', 'المبلغ', 7, true, true, true),
('purchase-invoice', 'warehouse', 'المستودع', 8, true, false, false),
('purchase-invoice', 'notes', 'ملاحظات', 9, false, false, false),
('purchase-invoice', 'expiry_date', 'تاريخ الصلاحية', 10, false, false, false),
('purchase-invoice', 'batch_number', 'رقم الباتش', 11, false, false, false),
('purchase-invoice', 'bonus', 'البونص', 12, false, false, false),
('purchase-invoice', 'length', 'الطول', 13, false, false, false),
('purchase-invoice', 'width', 'العرض', 14, false, false, false),
('purchase-invoice', 'count', 'العد', 15, false, false, false),
('purchase-invoice', 'color', 'اللون', 16, false, false, false),
('purchase-invoice', 'discount', 'الخصم', 17, false, false, false),
('purchase-invoice', 'item_notes', 'ملاحظة الصنف', 18, false, false, false)
ON CONFLICT (document_type, field_name) DO UPDATE SET
  display_name = EXCLUDED.display_name,
  display_order = EXCLUDED.display_order;

-- تحديث ترتيب الحقول الموجودة لتتناسب مع الحقول الجديدة
UPDATE document_settings SET display_order = 19 WHERE field_name = 'warehouse' AND document_type IN ('sales-order', 'purchase-order');
UPDATE document_settings SET display_order = 20 WHERE field_name = 'price' AND document_type IN ('sales-order', 'purchase-order');
UPDATE document_settings SET display_order = 21 WHERE field_name = 'total' AND document_type IN ('sales-order', 'purchase-order');
UPDATE document_settings SET display_order = 22 WHERE field_name = 'notes' AND document_type IN ('sales-order', 'purchase-order');

COMMENT ON TABLE document_settings IS 'جدول إعدادات حقول السندات - يحدد الحقول المعروضة في كل نوع سند مع الحقول الجديدة المضافة';
