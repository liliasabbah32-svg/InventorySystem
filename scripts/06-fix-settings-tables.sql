-- إصلاح جداول الإعدادات
-- Fix Settings Tables Script

-- حذف الجداول الموجودة إذا كانت موجودة
DROP TABLE IF EXISTS api_settings CASCADE;
DROP TABLE IF EXISTS general_settings CASCADE;
DROP TABLE IF EXISTS print_settings CASCADE;
DROP TABLE IF EXISTS user_settings CASCADE;
DROP TABLE IF EXISTS system_settings CASCADE;

-- إنشاء جدول إعدادات النظام الرئيسي
CREATE TABLE system_settings (
    id SERIAL PRIMARY KEY,
    company_name VARCHAR(255) NOT NULL DEFAULT 'شركة النظام المتكامل',
    company_name_en VARCHAR(255) DEFAULT 'Integrated System Company',
    company_address TEXT DEFAULT 'الرياض، المملكة العربية السعودية',
    company_phone VARCHAR(50) DEFAULT '+966501234567',
    company_email VARCHAR(100) DEFAULT 'info@company.com',
    company_website VARCHAR(100) DEFAULT 'www.company.com',
    tax_number VARCHAR(50) DEFAULT '123456789',
    commercial_register VARCHAR(50) DEFAULT 'CR123456789',
    
    -- إعدادات الترقيم
    numbering_system VARCHAR(20) DEFAULT 'auto' CHECK (numbering_system IN ('auto', 'manual')),
    invoice_prefix VARCHAR(10) DEFAULT 'O',
    order_prefix VARCHAR(10) DEFAULT 'O',
    purchase_prefix VARCHAR(10) DEFAULT 'T',
    auto_numbering BOOLEAN DEFAULT true,
    
    -- إعدادات النظام
    default_currency VARCHAR(10) DEFAULT 'SAR',
    date_format VARCHAR(20) DEFAULT 'DD/MM/YYYY',
    time_format VARCHAR(20) DEFAULT '24h',
    language VARCHAR(10) DEFAULT 'ar',
    timezone VARCHAR(50) DEFAULT 'Asia/Riyadh',
    fiscal_year_start DATE DEFAULT '2024-01-01',
    
    -- إعدادات العمل
    working_days JSONB DEFAULT '["sunday","monday","tuesday","wednesday","thursday"]',
    working_hours VARCHAR(50) DEFAULT '08:00-17:00',
    session_timeout INTEGER DEFAULT 60,
    
    -- إعدادات الأمان
    password_policy VARCHAR(100) DEFAULT 'medium',
    two_factor_auth BOOLEAN DEFAULT false,
    audit_log BOOLEAN DEFAULT true,
    
    -- إعدادات الطباعة
    default_printer VARCHAR(100),
    paper_size VARCHAR(20) DEFAULT 'A4',
    print_logo BOOLEAN DEFAULT true,
    print_footer BOOLEAN DEFAULT true,
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- إدراج البيانات الافتراضية
INSERT INTO system_settings (id) VALUES (1) ON CONFLICT (id) DO NOTHING;

-- إنشاء جدول الإعدادات العامة
CREATE TABLE general_settings (
    id SERIAL PRIMARY KEY,
    setting_key VARCHAR(100) NOT NULL UNIQUE,
    setting_value TEXT,
    setting_type VARCHAR(50) DEFAULT 'string',
    category VARCHAR(50) NOT NULL,
    description TEXT,
    is_public BOOLEAN DEFAULT false,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- إدراج الإعدادات العامة الافتراضية
INSERT INTO general_settings (setting_key, setting_value, setting_type, category, description) VALUES
('default_country', 'السعودية', 'string', 'system', 'الدولة الافتراضية'),
('whatsapp_number', '+966501234567', 'string', 'business', 'رقم الواتس آب للشركة'),
('support_email', 'support@company.com', 'string', 'business', 'إيميل الدعم الفني'),
('backup_frequency', 'daily', 'string', 'system', 'تكرار النسخ الاحتياطي'),
('max_file_size', '10', 'number', 'system', 'الحد الأقصى لحجم الملف (MB)'),
('enable_notifications', 'true', 'boolean', 'ui', 'تفعيل الإشعارات'),
('session_timeout', '60', 'number', 'system', 'انتهاء الجلسة (دقيقة)')
ON CONFLICT (setting_key) DO NOTHING;

-- إنشاء الفهارس
CREATE INDEX IF NOT EXISTS idx_general_settings_category ON general_settings(category);
CREATE INDEX IF NOT EXISTS idx_general_settings_key ON general_settings(setting_key);
