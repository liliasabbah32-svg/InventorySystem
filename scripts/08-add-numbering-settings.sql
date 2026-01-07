-- إضافة حقول البادئات وبداية الترقيم إلى جدول إعدادات النظام
-- Add prefix and start number fields to system_settings table

-- إضافة حقول البادئات (Prefixes)
ALTER TABLE system_settings 
ADD COLUMN IF NOT EXISTS customer_prefix VARCHAR(10) DEFAULT 'C',
ADD COLUMN IF NOT EXISTS supplier_prefix VARCHAR(10) DEFAULT 'S',
ADD COLUMN IF NOT EXISTS item_group_prefix VARCHAR(10) DEFAULT 'G',
ADD COLUMN IF NOT EXISTS item_prefix VARCHAR(10) DEFAULT 'I';

-- إضافة حقول بداية الترقيم للتعريفات (Optional - can be NULL)
ALTER TABLE system_settings 
ADD COLUMN IF NOT EXISTS customer_start INTEGER DEFAULT NULL,
ADD COLUMN IF NOT EXISTS supplier_start INTEGER DEFAULT NULL,
ADD COLUMN IF NOT EXISTS item_group_start INTEGER DEFAULT NULL,
ADD COLUMN IF NOT EXISTS item_start INTEGER DEFAULT NULL;

-- إضافة حقول بداية الترقيم للسندات (Required - NOT NULL with default)
ALTER TABLE system_settings 
ADD COLUMN IF NOT EXISTS invoice_start INTEGER DEFAULT 1 NOT NULL,
ADD COLUMN IF NOT EXISTS order_start INTEGER DEFAULT 1 NOT NULL,
ADD COLUMN IF NOT EXISTS purchase_start INTEGER DEFAULT 1 NOT NULL;

-- تحديث السجل الموجود بالقيم الافتراضية إذا لم تكن موجودة
UPDATE system_settings 
SET 
    customer_prefix = COALESCE(customer_prefix, 'C'),
    supplier_prefix = COALESCE(supplier_prefix, 'S'),
    item_group_prefix = COALESCE(item_group_prefix, 'G'),
    item_prefix = COALESCE(item_prefix, 'I'),
    invoice_start = COALESCE(invoice_start, 1),
    order_start = COALESCE(order_start, 1),
    purchase_start = COALESCE(purchase_start, 1)
WHERE id = 1;

-- إضافة تعليقات على الأعمدة للتوضيح
COMMENT ON COLUMN system_settings.customer_prefix IS 'بادئة رقم العميل (مثال: C)';
COMMENT ON COLUMN system_settings.supplier_prefix IS 'بادئة رقم المورد (مثال: S)';
COMMENT ON COLUMN system_settings.item_group_prefix IS 'بادئة رقم مجموعة الأصناف (مثال: G)';
COMMENT ON COLUMN system_settings.item_prefix IS 'بادئة رقم الصنف (مثال: I)';
COMMENT ON COLUMN system_settings.customer_start IS 'بداية ترقيم العملاء (اختياري)';
COMMENT ON COLUMN system_settings.supplier_start IS 'بداية ترقيم الموردين (اختياري)';
COMMENT ON COLUMN system_settings.item_group_start IS 'بداية ترقيم مجموعات الأصناف (اختياري)';
COMMENT ON COLUMN system_settings.item_start IS 'بداية ترقيم الأصناف (اختياري)';
COMMENT ON COLUMN system_settings.invoice_start IS 'بداية ترقيم الفواتير (إجباري)';
COMMENT ON COLUMN system_settings.order_start IS 'بداية ترقيم أوامر البيع (إجباري)';
COMMENT ON COLUMN system_settings.purchase_start IS 'بداية ترقيم أوامر الشراء (إجباري)';
