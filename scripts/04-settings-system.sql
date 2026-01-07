-- نظام الإعدادات الشامل
-- Comprehensive Settings System

-- إنشاء جدول إعدادات النظام
CREATE TABLE IF NOT EXISTS system_settings (
    id SERIAL PRIMARY KEY,
    setting_key VARCHAR(100) UNIQUE NOT NULL,
    setting_value TEXT,
    setting_type VARCHAR(20) DEFAULT 'string' CHECK (setting_type IN ('string', 'number', 'boolean', 'json')),
    category VARCHAR(50) NOT NULL,
    description TEXT,
    is_public BOOLEAN DEFAULT false,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- إنشاء جدول إعدادات المستخدمين
CREATE TABLE IF NOT EXISTS user_settings (
    id SERIAL PRIMARY KEY,
    user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    setting_key VARCHAR(100) NOT NULL,
    setting_value TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(user_id, setting_key)
);

-- إنشاء جدول إعدادات الطباعة
CREATE TABLE IF NOT EXISTS print_settings (
    id SERIAL PRIMARY KEY,
    template_name VARCHAR(100) UNIQUE NOT NULL,
    document_type VARCHAR(50) NOT NULL,
    paper_size VARCHAR(20) DEFAULT 'A4',
    orientation VARCHAR(20) DEFAULT 'portrait',
    margins JSONB DEFAULT '{"top": 20, "right": 20, "bottom": 20, "left": 20}',
    header_template TEXT,
    footer_template TEXT,
    css_styles TEXT,
    is_default BOOLEAN DEFAULT false,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- إنشاء جدول إعدادات API
CREATE TABLE IF NOT EXISTS api_settings (
    id SERIAL PRIMARY KEY,
    service_name VARCHAR(100) UNIQUE NOT NULL,
    api_url VARCHAR(500),
    api_key VARCHAR(500),
    api_secret VARCHAR(500),
    configuration JSONB,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- إدراج إعدادات النظام الافتراضية
INSERT INTO system_settings (setting_key, setting_value, setting_type, category, description, is_public) VALUES
-- إعدادات الشركة
('company_name', 'شركة التقنية المتقدمة', 'string', 'company', 'اسم الشركة', true),
('company_address', 'الرياض، المملكة العربية السعودية', 'string', 'company', 'عنوان الشركة', true),
('company_phone', '+966501234567', 'string', 'company', 'هاتف الشركة', true),
('company_email', 'info@company.com', 'string', 'company', 'بريد الشركة الإلكتروني', true),
('company_tax_number', '123456789', 'string', 'company', 'الرقم الضريبي للشركة', false),
('company_logo_url', '/images/logo.png', 'string', 'company', 'شعار الشركة', true),

-- إعدادات النظام
('default_currency', 'SAR', 'string', 'system', 'العملة الافتراضية', true),
('default_language', 'ar', 'string', 'system', 'اللغة الافتراضية', true),
('date_format', 'DD/MM/YYYY', 'string', 'system', 'تنسيق التاريخ', true),
('time_format', '24', 'string', 'system', 'تنسيق الوقت', true),
('timezone', 'Asia/Riyadh', 'string', 'system', 'المنطقة الزمنية', true),

-- إعدادات المخزون
('auto_generate_product_codes', 'true', 'boolean', 'inventory', 'إنشاء أكواد المنتجات تلقائياً', false),
('low_stock_alert_enabled', 'true', 'boolean', 'inventory', 'تفعيل تنبيهات المخزون المنخفض', false),
('negative_stock_allowed', 'false', 'boolean', 'inventory', 'السماح بالمخزون السالب', false),

-- إعدادات المبيعات
('auto_generate_sales_order_numbers', 'true', 'boolean', 'sales', 'إنشاء أرقام طلبيات المبيعات تلقائياً', false),
('default_payment_terms', '30', 'number', 'sales', 'شروط الدفع الافتراضية (بالأيام)', false),
('default_tax_rate', '15', 'number', 'sales', 'معدل الضريبة الافتراضي (%)', false),

-- إعدادات الشراء
('auto_generate_purchase_order_numbers', 'true', 'boolean', 'purchase', 'إنشاء أرقام طلبيات الشراء تلقائياً', false),
('purchase_approval_required', 'true', 'boolean', 'purchase', 'مطلوب موافقة على طلبيات الشراء', false),
('purchase_approval_limit', '10000', 'number', 'purchase', 'حد الموافقة على طلبيات الشراء', false)

ON CONFLICT (setting_key) DO NOTHING;

-- إدراج قوالب الطباعة الافتراضية
INSERT INTO print_settings (template_name, document_type, header_template, footer_template, css_styles) VALUES
('sales_order_default', 'sales_order', 
'<div class="header"><h2>طلبية مبيعات</h2><p>{{company_name}}</p></div>',
'<div class="footer"><p>شكراً لتعاملكم معنا</p></div>',
'body { font-family: Arial, sans-serif; direction: rtl; } .header { text-align: center; margin-bottom: 20px; }'),

('purchase_order_default', 'purchase_order',
'<div class="header"><h2>طلبية شراء</h2><p>{{company_name}}</p></div>',
'<div class="footer"><p>مع تحيات إدارة الشراء</p></div>',
'body { font-family: Arial, sans-serif; direction: rtl; } .header { text-align: center; margin-bottom: 20px; }'),

('invoice_default', 'invoice',
'<div class="header"><h2>فاتورة</h2><p>{{company_name}}</p></div>',
'<div class="footer"><p>الرقم الضريبي: {{tax_number}}</p></div>',
'body { font-family: Arial, sans-serif; direction: rtl; } .header { text-align: center; margin-bottom: 20px; }')

ON CONFLICT (template_name) DO NOTHING;

-- إنشاء triggers لتحديث timestamps
CREATE TRIGGER update_system_settings_updated_at BEFORE UPDATE ON system_settings FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_user_settings_updated_at BEFORE UPDATE ON user_settings FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_print_settings_updated_at BEFORE UPDATE ON print_settings FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER update_api_settings_updated_at BEFORE UPDATE ON api_settings FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- إنشاء فهارس للأداء
CREATE INDEX IF NOT EXISTS idx_system_settings_category ON system_settings(category);
CREATE INDEX IF NOT EXISTS idx_user_settings_user ON user_settings(user_id);
CREATE INDEX IF NOT EXISTS idx_print_settings_type ON print_settings(document_type);
