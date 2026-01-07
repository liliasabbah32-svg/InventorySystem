-- إضافة الأعمدة المفقودة لجدول المنتجات
-- Adding missing columns to products table

-- إضافة الأعمدة الأساسية المفقودة
-- Adding missing basic columns
ALTER TABLE products 
ADD COLUMN IF NOT EXISTS product_name_en VARCHAR(255),
ADD COLUMN IF NOT EXISTS subcategory VARCHAR(100),
ADD COLUMN IF NOT EXISTS brand VARCHAR(100),
ADD COLUMN IF NOT EXISTS model VARCHAR(100);

-- إضافة أعمدة الأسعار
-- Adding price columns
ALTER TABLE products 
ADD COLUMN IF NOT EXISTS selling_price DECIMAL(15,2) DEFAULT 0,
ADD COLUMN IF NOT EXISTS wholesale_price DECIMAL(15,2) DEFAULT 0,
ADD COLUMN IF NOT EXISTS retail_price DECIMAL(15,2) DEFAULT 0,
ADD COLUMN IF NOT EXISTS average_cost DECIMAL(15,2) DEFAULT 0;

-- إضافة أعمدة الضرائب والخصومات
-- Adding tax and discount columns
ALTER TABLE products 
ADD COLUMN IF NOT EXISTS tax_rate DECIMAL(5,2) DEFAULT 0,
ADD COLUMN IF NOT EXISTS discount_rate DECIMAL(5,2) DEFAULT 0;

-- إضافة أعمدة إدارة المخزون
-- Adding inventory management columns
ALTER TABLE products 
ADD COLUMN IF NOT EXISTS min_stock_level DECIMAL(15,2) DEFAULT 0,
ADD COLUMN IF NOT EXISTS max_stock_level DECIMAL(15,2) DEFAULT 0,
ADD COLUMN IF NOT EXISTS reorder_point DECIMAL(15,2) DEFAULT 0,
ADD COLUMN IF NOT EXISTS location VARCHAR(100),
ADD COLUMN IF NOT EXISTS shelf_life INTEGER DEFAULT 0;

-- إضافة أعمدة بيانات المورد
-- Adding supplier data columns
ALTER TABLE products 
ADD COLUMN IF NOT EXISTS supplier_name VARCHAR(255),
ADD COLUMN IF NOT EXISTS supplier_code VARCHAR(50),
ADD COLUMN IF NOT EXISTS supplier_product_code VARCHAR(100),
ADD COLUMN IF NOT EXISTS lead_time INTEGER DEFAULT 0;

-- إضافة أعمدة تفاصيل المستودعات
-- Adding warehouse details columns
ALTER TABLE products 
ADD COLUMN IF NOT EXISTS available_quantity DECIMAL(15,2) DEFAULT 0,
ADD COLUMN IF NOT EXISTS reserved_quantity DECIMAL(15,2) DEFAULT 0,
ADD COLUMN IF NOT EXISTS actual_balance DECIMAL(15,2) DEFAULT 0,
ADD COLUMN IF NOT EXISTS inventory_value DECIMAL(15,2) DEFAULT 0,
ADD COLUMN IF NOT EXISTS warehouse_name VARCHAR(100),
ADD COLUMN IF NOT EXISTS stock_status VARCHAR(50) DEFAULT 'متاح',
ADD COLUMN IF NOT EXISTS batch_number VARCHAR(100),
ADD COLUMN IF NOT EXISTS expiry_date DATE,
ADD COLUMN IF NOT EXISTS serial_number VARCHAR(100);

-- إضافة أعمدة إضافية
-- Adding additional columns
ALTER TABLE products 
ADD COLUMN IF NOT EXISTS additional_notes TEXT,
ADD COLUMN IF NOT EXISTS updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP;

-- إنشاء فهرس على product_code إذا لم يكن موجوداً
-- Create index on product_code if not exists
CREATE UNIQUE INDEX IF NOT EXISTS idx_products_product_code ON products(product_code);

-- تحديث الأعمدة الموجودة لتكون متوافقة
-- Update existing columns to be compatible
ALTER TABLE products 
ALTER COLUMN conversion_factor SET DEFAULT 1,
ALTER COLUMN last_purchase_price SET DEFAULT 0;

-- إضافة قيود للتحقق من صحة البيانات
-- Add constraints for data validation
ALTER TABLE products 
ADD CONSTRAINT IF NOT EXISTS chk_conversion_factor CHECK (conversion_factor > 0),
ADD CONSTRAINT IF NOT EXISTS chk_prices_positive CHECK (
    selling_price >= 0 AND 
    wholesale_price >= 0 AND 
    retail_price >= 0 AND 
    last_purchase_price >= 0
);

COMMENT ON TABLE products IS 'جدول المنتجات مع جميع التفاصيل المطلوبة';
COMMENT ON COLUMN products.product_name_en IS 'اسم المنتج بالإنجليزية';
COMMENT ON COLUMN products.selling_price IS 'سعر البيع';
COMMENT ON COLUMN products.wholesale_price IS 'سعر الجملة';
COMMENT ON COLUMN products.retail_price IS 'سعر التجزئة';
