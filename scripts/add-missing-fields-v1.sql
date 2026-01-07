-- ============================================
-- إضافة الحقول المفقودة إلى قاعدة البيانات
-- تاريخ: 2025-01-03
-- الإصدار: 1.0
-- ============================================

-- ============================================
-- 1. تحديث جدول العملاء (customers)
-- ============================================

-- إضافة الحقول المالية والتجارية
ALTER TABLE customers 
ADD COLUMN IF NOT EXISTS tax_number VARCHAR(50),
ADD COLUMN IF NOT EXISTS commercial_registration VARCHAR(50),
ADD COLUMN IF NOT EXISTS credit_limit NUMERIC(15, 2) DEFAULT 0,
ADD COLUMN IF NOT EXISTS payment_terms VARCHAR(100),
ADD COLUMN IF NOT EXISTS discount_percentage NUMERIC(5, 2) DEFAULT 0;

-- إضافة تعليقات على الأعمدة الجديدة
COMMENT ON COLUMN customers.tax_number IS 'الرقم الضريبي للعميل';
COMMENT ON COLUMN customers.commercial_registration IS 'رقم السجل التجاري';
COMMENT ON COLUMN customers.credit_limit IS 'الحد الائتماني المسموح به';
COMMENT ON COLUMN customers.payment_terms IS 'شروط الدفع (مثال: 30 يوم)';
COMMENT ON COLUMN customers.discount_percentage IS 'نسبة الخصم الافتراضية';

-- ============================================
-- 2. تحديث جدول المنتجات (products)
-- ============================================

-- إضافة حقول المعلومات الأساسية
ALTER TABLE products 
ADD COLUMN IF NOT EXISTS product_name_en VARCHAR(255),
ADD COLUMN IF NOT EXISTS subcategory VARCHAR(100),
ADD COLUMN IF NOT EXISTS brand VARCHAR(100),
ADD COLUMN IF NOT EXISTS model VARCHAR(100);

-- إضافة حقول التسعير
ALTER TABLE products 
ADD COLUMN IF NOT EXISTS average_cost NUMERIC(15, 2) DEFAULT 0,
ADD COLUMN IF NOT EXISTS selling_price NUMERIC(15, 2) DEFAULT 0,
ADD COLUMN IF NOT EXISTS wholesale_price NUMERIC(15, 2) DEFAULT 0,
ADD COLUMN IF NOT EXISTS retail_price NUMERIC(15, 2) DEFAULT 0,
ADD COLUMN IF NOT EXISTS tax_rate NUMERIC(5, 2) DEFAULT 0,
ADD COLUMN IF NOT EXISTS discount_rate NUMERIC(5, 2) DEFAULT 0;

-- إضافة حقول إدارة المخزون
ALTER TABLE products 
ADD COLUMN IF NOT EXISTS min_stock_level NUMERIC(15, 2) DEFAULT 0,
ADD COLUMN IF NOT EXISTS max_stock_level NUMERIC(15, 2) DEFAULT 0,
ADD COLUMN IF NOT EXISTS reorder_point NUMERIC(15, 2) DEFAULT 0,
ADD COLUMN IF NOT EXISTS location VARCHAR(255);

-- إضافة حقول التتبع
ALTER TABLE products 
ADD COLUMN IF NOT EXISTS shelf_life INTEGER,
ADD COLUMN IF NOT EXISTS expiry_tracking BOOLEAN DEFAULT FALSE,
ADD COLUMN IF NOT EXISTS batch_tracking BOOLEAN DEFAULT FALSE,
ADD COLUMN IF NOT EXISTS serial_tracking BOOLEAN DEFAULT FALSE;

-- إضافة حقول المورد
ALTER TABLE products 
ADD COLUMN IF NOT EXISTS supplier_id INTEGER,
ADD COLUMN IF NOT EXISTS supplier_name VARCHAR(255),
ADD COLUMN IF NOT EXISTS supplier_code VARCHAR(50);

-- إضافة حقول المواصفات
ALTER TABLE products 
ADD COLUMN IF NOT EXISTS country_of_origin VARCHAR(100),
ADD COLUMN IF NOT EXISTS weight NUMERIC(10, 2),
ADD COLUMN IF NOT EXISTS dimensions VARCHAR(100),
ADD COLUMN IF NOT EXISTS color VARCHAR(50),
ADD COLUMN IF NOT EXISTS size VARCHAR(50),
ADD COLUMN IF NOT EXISTS material VARCHAR(100),
ADD COLUMN IF NOT EXISTS warranty_period INTEGER;

-- إضافة حقول إضافية
ALTER TABLE products 
ADD COLUMN IF NOT EXISTS image_url TEXT,
ADD COLUMN IF NOT EXISTS notes TEXT;

-- إضافة تعليقات على الأعمدة الجديدة
COMMENT ON COLUMN products.product_name_en IS 'اسم المنتج بالإنجليزية';
COMMENT ON COLUMN products.subcategory IS 'التصنيف الفرعي';
COMMENT ON COLUMN products.brand IS 'العلامة التجارية';
COMMENT ON COLUMN products.model IS 'رقم الموديل';
COMMENT ON COLUMN products.average_cost IS 'متوسط التكلفة';
COMMENT ON COLUMN products.selling_price IS 'سعر البيع الافتراضي';
COMMENT ON COLUMN products.wholesale_price IS 'سعر الجملة';
COMMENT ON COLUMN products.retail_price IS 'سعر التجزئة';
COMMENT ON COLUMN products.tax_rate IS 'نسبة الضريبة %';
COMMENT ON COLUMN products.discount_rate IS 'نسبة الخصم %';
COMMENT ON COLUMN products.min_stock_level IS 'الحد الأدنى للمخزون';
COMMENT ON COLUMN products.max_stock_level IS 'الحد الأقصى للمخزون';
COMMENT ON COLUMN products.reorder_point IS 'نقطة إعادة الطلب';
COMMENT ON COLUMN products.location IS 'موقع التخزين';
COMMENT ON COLUMN products.shelf_life IS 'مدة الصلاحية بالأيام';
COMMENT ON COLUMN products.expiry_tracking IS 'تفعيل تتبع تاريخ الصلاحية';
COMMENT ON COLUMN products.batch_tracking IS 'تفعيل تتبع الدفعات';
COMMENT ON COLUMN products.serial_tracking IS 'تفعيل تتبع الأرقام التسلسلية';
COMMENT ON COLUMN products.supplier_id IS 'معرف المورد الافتراضي';
COMMENT ON COLUMN products.supplier_name IS 'اسم المورد';
COMMENT ON COLUMN products.supplier_code IS 'كود المورد';
COMMENT ON COLUMN products.country_of_origin IS 'بلد المنشأ';
COMMENT ON COLUMN products.weight IS 'الوزن (كجم)';
COMMENT ON COLUMN products.dimensions IS 'الأبعاد (طول × عرض × ارتفاع)';
COMMENT ON COLUMN products.color IS 'اللون';
COMMENT ON COLUMN products.size IS 'الحجم';
COMMENT ON COLUMN products.material IS 'المادة المصنوع منها';
COMMENT ON COLUMN products.warranty_period IS 'فترة الضمان بالأشهر';
COMMENT ON COLUMN products.image_url IS 'رابط صورة المنتج';
COMMENT ON COLUMN products.notes IS 'ملاحظات إضافية';

-- ============================================
-- 3. إضافة Foreign Keys
-- ============================================

-- ربط المنتج بالمورد
ALTER TABLE products 
ADD CONSTRAINT fk_products_supplier 
FOREIGN KEY (supplier_id) 
REFERENCES suppliers(id) 
ON DELETE SET NULL;

-- ============================================
-- 4. إضافة Indexes لتحسين الأداء
-- ============================================

-- Indexes لجدول العملاء
CREATE INDEX IF NOT EXISTS idx_customers_tax_number ON customers(tax_number);
CREATE INDEX IF NOT EXISTS idx_customers_commercial_registration ON customers(commercial_registration);
CREATE INDEX IF NOT EXISTS idx_customers_credit_limit ON customers(credit_limit);

-- Indexes لجدول المنتجات
CREATE INDEX IF NOT EXISTS idx_products_product_name_en ON products(product_name_en);
CREATE INDEX IF NOT EXISTS idx_products_subcategory ON products(subcategory);
CREATE INDEX IF NOT EXISTS idx_products_brand ON products(brand);
CREATE INDEX IF NOT EXISTS idx_products_model ON products(model);
CREATE INDEX IF NOT EXISTS idx_products_supplier_id ON products(supplier_id);
CREATE INDEX IF NOT EXISTS idx_products_supplier_code ON products(supplier_code);
CREATE INDEX IF NOT EXISTS idx_products_location ON products(location);
CREATE INDEX IF NOT EXISTS idx_products_expiry_tracking ON products(expiry_tracking);
CREATE INDEX IF NOT EXISTS idx_products_batch_tracking ON products(batch_tracking);
CREATE INDEX IF NOT EXISTS idx_products_serial_tracking ON products(serial_tracking);
CREATE INDEX IF NOT EXISTS idx_products_reorder_point ON products(reorder_point);

-- Indexes مركبة لتحسين الاستعلامات الشائعة
CREATE INDEX IF NOT EXISTS idx_products_category_subcategory ON products(category, subcategory);
CREATE INDEX IF NOT EXISTS idx_products_brand_model ON products(brand, model);
CREATE INDEX IF NOT EXISTS idx_products_stock_levels ON products(min_stock_level, max_stock_level, reorder_point);

-- ============================================
-- 5. تحديث البيانات الموجودة (اختياري)
-- ============================================

-- تعيين قيم افتراضية للحقول الجديدة في السجلات الموجودة
UPDATE products 
SET 
  expiry_tracking = FALSE,
  batch_tracking = FALSE,
  serial_tracking = FALSE,
  average_cost = 0,
  selling_price = 0,
  wholesale_price = 0,
  retail_price = 0,
  tax_rate = 0,
  discount_rate = 0,
  min_stock_level = 0,
  max_stock_level = 0,
  reorder_point = 0
WHERE 
  expiry_tracking IS NULL 
  OR batch_tracking IS NULL 
  OR serial_tracking IS NULL;

UPDATE customers 
SET 
  credit_limit = 0,
  discount_percentage = 0
WHERE 
  credit_limit IS NULL 
  OR discount_percentage IS NULL;

-- ============================================
-- 6. التحقق من النتائج
-- ============================================

-- عرض عدد الأعمدة في جدول العملاء
SELECT COUNT(*) as customer_columns_count 
FROM information_schema.columns 
WHERE table_name = 'customers';

-- عرض عدد الأعمدة في جدول المنتجات
SELECT COUNT(*) as product_columns_count 
FROM information_schema.columns 
WHERE table_name = 'products';

-- عرض جميع الأعمدة الجديدة في جدول المنتجات
SELECT column_name, data_type, is_nullable, column_default
FROM information_schema.columns 
WHERE table_name = 'products' 
  AND column_name IN (
    'product_name_en', 'subcategory', 'brand', 'model',
    'average_cost', 'selling_price', 'wholesale_price', 'retail_price',
    'tax_rate', 'discount_rate', 'min_stock_level', 'max_stock_level',
    'reorder_point', 'location', 'shelf_life', 'expiry_tracking',
    'batch_tracking', 'serial_tracking', 'supplier_id', 'supplier_name',
    'supplier_code', 'country_of_origin', 'weight', 'dimensions',
    'color', 'size', 'material', 'warranty_period', 'image_url', 'notes'
  )
ORDER BY ordinal_position;

-- عرض جميع الأعمدة الجديدة في جدول العملاء
SELECT column_name, data_type, is_nullable, column_default
FROM information_schema.columns 
WHERE table_name = 'customers' 
  AND column_name IN (
    'tax_number', 'commercial_registration', 'credit_limit',
    'payment_terms', 'discount_percentage'
  )
ORDER BY ordinal_position;

-- ============================================
-- نهاية السكريبت
-- ============================================

-- رسالة نجاح
DO $$
BEGIN
  RAISE NOTICE 'تم تنفيذ السكريبت بنجاح! تم إضافة جميع الحقول المفقودة.';
  RAISE NOTICE 'جدول العملاء: تم إضافة 5 حقول جديدة';
  RAISE NOTICE 'جدول المنتجات: تم إضافة 30 حقل جديد';
  RAISE NOTICE 'تم إنشاء Indexes لتحسين الأداء';
END $$;
