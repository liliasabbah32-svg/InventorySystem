-- =====================================================
-- إعداد البنية الأساسية للنظام المالي المستقبلي
-- Preparing Financial Foundation for Future Accounting System
-- =====================================================

-- 1. إضافة حقول مالية للعملاء
ALTER TABLE customers ADD COLUMN IF NOT EXISTS credit_limit DECIMAL(15,2) DEFAULT 0;
ALTER TABLE customers ADD COLUMN IF NOT EXISTS current_balance DECIMAL(15,2) DEFAULT 0;
ALTER TABLE customers ADD COLUMN IF NOT EXISTS payment_terms_days INTEGER DEFAULT 30;
ALTER TABLE customers ADD COLUMN IF NOT EXISTS account_number VARCHAR(50);
ALTER TABLE customers ADD COLUMN IF NOT EXISTS tax_id VARCHAR(50);

-- 2. إضافة حقول مالية للموردين
ALTER TABLE suppliers ADD COLUMN IF NOT EXISTS credit_limit DECIMAL(15,2) DEFAULT 0;
ALTER TABLE suppliers ADD COLUMN IF NOT EXISTS current_balance DECIMAL(15,2) DEFAULT 0;
ALTER TABLE suppliers ADD COLUMN IF NOT EXISTS payment_terms_days INTEGER DEFAULT 30;
ALTER TABLE suppliers ADD COLUMN IF NOT EXISTS account_number VARCHAR(50);
ALTER TABLE suppliers ADD COLUMN IF NOT EXISTS tax_id VARCHAR(50);

-- 3. تحسين جدول الطلبيات لدعم المحاسبة
ALTER TABLE orders ADD COLUMN IF NOT EXISTS payment_status VARCHAR(20) DEFAULT 'pending';
ALTER TABLE orders ADD COLUMN IF NOT EXISTS payment_method VARCHAR(50);
ALTER TABLE orders ADD COLUMN IF NOT EXISTS due_date DATE;
ALTER TABLE orders ADD COLUMN IF NOT EXISTS paid_amount DECIMAL(15,2) DEFAULT 0;
ALTER TABLE orders ADD COLUMN IF NOT EXISTS remaining_amount DECIMAL(15,2) DEFAULT 0;
ALTER TABLE orders ADD COLUMN IF NOT EXISTS financial_year INTEGER;
ALTER TABLE orders ADD COLUMN IF NOT EXISTS financial_period INTEGER;

-- 4. إنشاء جدول العملات (للدعم المستقبلي)
CREATE TABLE IF NOT EXISTS currencies (
  id SERIAL PRIMARY KEY,
  code VARCHAR(3) UNIQUE NOT NULL,
  name VARCHAR(100) NOT NULL,
  symbol VARCHAR(10),
  exchange_rate DECIMAL(15,6) DEFAULT 1.0,
  is_base_currency BOOLEAN DEFAULT false,
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- إدراج العملات الأساسية
INSERT INTO currencies (code, name, symbol, is_base_currency, is_active) 
VALUES 
  ('SAR', 'ريال سعودي', 'ر.س', true, true),
  ('USD', 'دولار أمريكي', '$', false, true),
  ('EUR', 'يورو', '€', false, true)
ON CONFLICT (code) DO NOTHING;

-- 5. إنشاء جدول طرق الدفع
CREATE TABLE IF NOT EXISTS payment_methods (
  id SERIAL PRIMARY KEY,
  name VARCHAR(100) NOT NULL,
  name_en VARCHAR(100),
  type VARCHAR(50), -- cash, bank_transfer, credit_card, cheque, etc.
  is_active BOOLEAN DEFAULT true,
  requires_reference BOOLEAN DEFAULT false,
  account_code VARCHAR(50), -- للربط المستقبلي مع دليل الحسابات
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- إدراج طرق الدفع الأساسية
INSERT INTO payment_methods (name, name_en, type, is_active, requires_reference) 
VALUES 
  ('نقدي', 'Cash', 'cash', true, false),
  ('تحويل بنكي', 'Bank Transfer', 'bank_transfer', true, true),
  ('بطاقة ائتمان', 'Credit Card', 'credit_card', true, true),
  ('شيك', 'Cheque', 'cheque', true, true),
  ('آجل', 'Credit', 'credit', true, false)
ON CONFLICT DO NOTHING;

-- 6. إنشاء جدول الفترات المالية (للتحضير)
CREATE TABLE IF NOT EXISTS financial_periods (
  id SERIAL PRIMARY KEY,
  year INTEGER NOT NULL,
  period INTEGER NOT NULL, -- 1-12 for months
  start_date DATE NOT NULL,
  end_date DATE NOT NULL,
  is_closed BOOLEAN DEFAULT false,
  closed_by INTEGER REFERENCES users(id),
  closed_at TIMESTAMP,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  UNIQUE(year, period)
);

-- 7. إنشاء جدول إعدادات النظام المالي
CREATE TABLE IF NOT EXISTS financial_settings (
  id SERIAL PRIMARY KEY,
  setting_key VARCHAR(100) UNIQUE NOT NULL,
  setting_value TEXT,
  setting_type VARCHAR(50), -- string, number, boolean, json
  description TEXT,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- إدراج الإعدادات الأساسية
INSERT INTO financial_settings (setting_key, setting_value, setting_type, description) 
VALUES 
  ('base_currency', 'SAR', 'string', 'العملة الأساسية للنظام'),
  ('tax_rate', '15', 'number', 'نسبة الضريبة الافتراضية'),
  ('financial_year_start_month', '1', 'number', 'شهر بداية السنة المالية (1-12)'),
  ('enable_multi_currency', 'false', 'boolean', 'تفعيل دعم العملات المتعددة'),
  ('auto_generate_invoice_number', 'true', 'boolean', 'توليد رقم الفاتورة تلقائياً'),
  ('invoice_number_prefix', 'INV', 'string', 'بادئة رقم الفاتورة'),
  ('enable_cost_centers', 'false', 'boolean', 'تفعيل مراكز التكلفة')
ON CONFLICT (setting_key) DO NOTHING;

-- 8. إنشاء جدول مراكز التكلفة (للتحضير)
CREATE TABLE IF NOT EXISTS cost_centers (
  id SERIAL PRIMARY KEY,
  code VARCHAR(50) UNIQUE NOT NULL,
  name VARCHAR(200) NOT NULL,
  name_en VARCHAR(200),
  parent_id INTEGER REFERENCES cost_centers(id),
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 9. إضافة indexes للأداء
CREATE INDEX IF NOT EXISTS idx_orders_payment_status ON orders(payment_status);
CREATE INDEX IF NOT EXISTS idx_orders_due_date ON orders(due_date);
CREATE INDEX IF NOT EXISTS idx_orders_financial_year ON orders(financial_year);
CREATE INDEX IF NOT EXISTS idx_customers_account_number ON customers(account_number);
CREATE INDEX IF NOT EXISTS idx_suppliers_account_number ON suppliers(account_number);

-- 10. إنشاء view للتقارير المالية الأساسية
CREATE OR REPLACE VIEW financial_summary AS
SELECT 
  o.id,
  o.order_number,
  o.order_type,
  o.order_date,
  o.total_amount,
  o.paid_amount,
  o.remaining_amount,
  o.payment_status,
  o.due_date,
  CASE 
    WHEN o.order_type IN ('sales_order', 'sales_invoice') THEN c.name
    WHEN o.order_type IN ('purchase_order', 'purchase_invoice') THEN s.name
  END as party_name,
  CASE 
    WHEN o.order_type IN ('sales_order', 'sales_invoice') THEN c.account_number
    WHEN o.order_type IN ('purchase_order', 'purchase_invoice') THEN s.account_number
  END as party_account_number
FROM orders o
LEFT JOIN customers c ON o.customer_id = c.id
LEFT JOIN suppliers s ON o.supplier_id = s.id;

COMMENT ON TABLE currencies IS 'جدول العملات - للدعم المستقبلي للعملات المتعددة';
COMMENT ON TABLE payment_methods IS 'جدول طرق الدفع المتاحة في النظام';
COMMENT ON TABLE financial_periods IS 'جدول الفترات المالية - للإقفالات المحاسبية المستقبلية';
COMMENT ON TABLE financial_settings IS 'إعدادات النظام المالي';
COMMENT ON TABLE cost_centers IS 'مراكز التكلفة - للتحليل المالي المستقبلي';
