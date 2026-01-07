-- إصلاح شامل لجميع تناقضات إعدادات النظام
-- Comprehensive fix for all system settings inconsistencies

-- ===== 1. إصلاح جدول إعدادات المستخدمين =====
-- Fix user_settings table inconsistencies

-- إضافة الحقول المفقودة إلى جدول user_settings
ALTER TABLE user_settings 
ADD COLUMN IF NOT EXISTS organization_id INTEGER DEFAULT 1,
ADD COLUMN IF NOT EXISTS avatar_url TEXT,
ADD COLUMN IF NOT EXISTS timezone VARCHAR(50) DEFAULT 'Asia/Riyadh',
ADD COLUMN IF NOT EXISTS date_format VARCHAR(20) DEFAULT 'DD/MM/YYYY',
ADD COLUMN IF NOT EXISTS time_format VARCHAR(10) DEFAULT '24h',
ADD COLUMN IF NOT EXISTS sms_notifications BOOLEAN DEFAULT false,
ADD COLUMN IF NOT EXISTS theme_preference VARCHAR(20) DEFAULT 'light',
ADD COLUMN IF NOT EXISTS sidebar_collapsed BOOLEAN DEFAULT false,
ADD COLUMN IF NOT EXISTS dashboard_layout JSONB DEFAULT '{}',
ADD COLUMN IF NOT EXISTS permissions JSONB DEFAULT '{}';

-- تحديث نوع البيانات لـ user_id ليكون متسق
-- Update user_id data type to be consistent
DO $$
BEGIN
    -- تحقق من نوع البيانات الحالي
    IF EXISTS (
        SELECT 1 FROM information_schema.columns 
        WHERE table_name = 'user_settings' 
        AND column_name = 'user_id' 
        AND data_type = 'integer'
    ) THEN
        -- تحويل من INTEGER إلى VARCHAR
        ALTER TABLE user_settings ALTER COLUMN user_id TYPE VARCHAR(255) USING user_id::VARCHAR;
    END IF;
END $$;

-- ===== 2. إصلاح جدول إعدادات النظام =====
-- Fix system_settings table inconsistencies

-- إضافة الحقول المفقودة
ALTER TABLE system_settings 
ADD COLUMN IF NOT EXISTS logo_url TEXT,
ADD COLUMN IF NOT EXISTS favicon_url TEXT,
ADD COLUMN IF NOT EXISTS primary_color VARCHAR(7) DEFAULT '#059669',
ADD COLUMN IF NOT EXISTS secondary_color VARCHAR(7) DEFAULT '#64748b',
ADD COLUMN IF NOT EXISTS language VARCHAR(10) DEFAULT 'ar',
ADD COLUMN IF NOT EXISTS timezone VARCHAR(50) DEFAULT 'Asia/Riyadh',
ADD COLUMN IF NOT EXISTS date_format VARCHAR(20) DEFAULT 'DD/MM/YYYY',
ADD COLUMN IF NOT EXISTS time_format VARCHAR(10) DEFAULT '24h',
ADD COLUMN IF NOT EXISTS backup_enabled BOOLEAN DEFAULT true,
ADD COLUMN IF NOT EXISTS backup_frequency VARCHAR(20) DEFAULT 'daily',
ADD COLUMN IF NOT EXISTS maintenance_mode BOOLEAN DEFAULT false,
ADD COLUMN IF NOT EXISTS max_users INTEGER DEFAULT 100,
ADD COLUMN IF NOT EXISTS session_timeout INTEGER DEFAULT 60;

-- ===== 3. إصلاح جدول إعدادات الطباعة =====
-- Fix print_settings table inconsistencies

-- إضافة الحقول المفقودة
ALTER TABLE print_settings 
ADD COLUMN IF NOT EXISTS show_logo BOOLEAN DEFAULT true,
ADD COLUMN IF NOT EXISTS show_header BOOLEAN DEFAULT true,
ADD COLUMN IF NOT EXISTS show_footer BOOLEAN DEFAULT true,
ADD COLUMN IF NOT EXISTS show_barcode BOOLEAN DEFAULT false,
ADD COLUMN IF NOT EXISTS show_qr BOOLEAN DEFAULT false,
ADD COLUMN IF NOT EXISTS line_spacing DECIMAL(3,2) DEFAULT 1.0,
ADD COLUMN IF NOT EXISTS margin_top DECIMAL(5,2) DEFAULT 1.5,
ADD COLUMN IF NOT EXISTS margin_bottom DECIMAL(5,2) DEFAULT 1.5,
ADD COLUMN IF NOT EXISTS margin_left DECIMAL(5,2) DEFAULT 1.0,
ADD COLUMN IF NOT EXISTS margin_right DECIMAL(5,2) DEFAULT 1.0;

-- تحديث أسماء الحقول لتتطابق مع API
-- Update column names to match API
DO $$
BEGIN
    -- تحديث margins_top إلى margin_top
    IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'print_settings' AND column_name = 'margins_top') THEN
        ALTER TABLE print_settings RENAME COLUMN margins_top TO margin_top;
    END IF;
    
    IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'print_settings' AND column_name = 'margins_bottom') THEN
        ALTER TABLE print_settings RENAME COLUMN margins_bottom TO margin_bottom;
    END IF;
    
    IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'print_settings' AND column_name = 'margins_left') THEN
        ALTER TABLE print_settings RENAME COLUMN margins_left TO margin_left;
    END IF;
    
    IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'print_settings' AND column_name = 'margins_right') THEN
        ALTER TABLE print_settings RENAME COLUMN margins_right TO margin_right;
    END IF;
END $$;

-- ===== 4. إصلاح جدول إعدادات التخصيص =====
-- Fix theme_settings table inconsistencies

-- التأكد من وجود جميع الحقول المطلوبة
ALTER TABLE theme_settings 
ADD COLUMN IF NOT EXISTS user_id VARCHAR(255),
ADD COLUMN IF NOT EXISTS color_scheme VARCHAR(50) DEFAULT 'emerald',
ADD COLUMN IF NOT EXISTS shadows BOOLEAN DEFAULT true,
ADD COLUMN IF NOT EXISTS animations BOOLEAN DEFAULT true,
ADD COLUMN IF NOT EXISTS compact_mode BOOLEAN DEFAULT false;

-- ===== 5. إصلاح جدول الإعدادات العامة =====
-- Fix general_settings table inconsistencies

-- إضافة الحقول المفقودة
ALTER TABLE general_settings 
ADD COLUMN IF NOT EXISTS display_order INTEGER DEFAULT 0,
ADD COLUMN IF NOT EXISTS validation_rules TEXT,
ADD COLUMN IF NOT EXISTS default_value TEXT;

-- ===== 6. إنشاء جدول إعدادات السندات إذا لم يكن موجوداً =====
-- Create document_settings table if not exists

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

-- ===== 7. إضافة الفهارس المفقودة =====
-- Add missing indexes

CREATE INDEX IF NOT EXISTS idx_user_settings_organization ON user_settings(organization_id);
CREATE INDEX IF NOT EXISTS idx_user_settings_active ON user_settings(is_active);
CREATE INDEX IF NOT EXISTS idx_print_settings_document_type ON print_settings(document_type);
CREATE INDEX IF NOT EXISTS idx_theme_settings_user ON theme_settings(user_id);
CREATE INDEX IF NOT EXISTS idx_general_settings_public ON general_settings(is_public);
CREATE INDEX IF NOT EXISTS idx_document_settings_type ON document_settings(document_type);

-- ===== 8. إدراج البيانات الافتراضية المفقودة =====
-- Insert missing default data

-- إعدادات السندات الافتراضية
INSERT INTO document_settings (document_type, field_name, display_name, display_order, show_in_screen, show_in_print, is_required) VALUES
('sales-order', 'sequence', 'م', 1, true, true, true),
('sales-order', 'barcode', 'الباركود', 2, true, false, false),
('sales-order', 'product', 'الصنف', 3, true, true, true),
('sales-order', 'unit', 'الوحدة', 4, true, true, true),
('sales-order', 'quantity', 'الكمية', 5, true, true, true),
('sales-order', 'price', 'السعر', 6, true, true, true),
('sales-order', 'total', 'المبلغ', 7, true, true, true),
('sales-order', 'warehouse', 'المستودع', 8, true, false, false),
('sales-order', 'notes', 'ملاحظات', 9, false, false, false),
('purchase-order', 'sequence', 'م', 1, true, true, true),
('purchase-order', 'barcode', 'الباركود', 2, true, false, false),
('purchase-order', 'product', 'الصنف', 3, true, true, true),
('purchase-order', 'unit', 'الوحدة', 4, true, true, true),
('purchase-order', 'quantity', 'الكمية', 5, true, true, true),
('purchase-order', 'price', 'السعر', 6, true, true, true),
('purchase-order', 'total', 'المبلغ', 7, true, true, true),
('purchase-order', 'warehouse', 'المستودع', 8, true, false, false),
('purchase-order', 'notes', 'ملاحظات', 9, false, false, false)
ON CONFLICT (document_type, field_name) DO NOTHING;

-- إعدادات طباعة افتراضية محدثة
INSERT INTO print_settings (
    document_type, printer_name, font_family, font_size, paper_size, orientation,
    show_logo, show_header, show_footer, show_barcode, show_qr,
    margin_top, margin_bottom, margin_left, margin_right, line_spacing, copies
) VALUES
('sales-order', 'default', 'Arial', 12, 'A4', 'portrait', true, true, true, false, false, 1.5, 1.5, 1.0, 1.0, 1.0, 1),
('purchase-order', 'default', 'Arial', 12, 'A4', 'portrait', true, true, true, false, false, 1.5, 1.5, 1.0, 1.0, 1.0, 1),
('invoice', 'default', 'Arial', 12, 'A4', 'portrait', true, true, true, true, true, 1.5, 1.5, 1.0, 1.0, 1.0, 1)
ON CONFLICT (document_type) DO UPDATE SET
    show_logo = EXCLUDED.show_logo,
    show_header = EXCLUDED.show_header,
    show_footer = EXCLUDED.show_footer,
    show_barcode = EXCLUDED.show_barcode,
    show_qr = EXCLUDED.show_qr,
    margin_top = EXCLUDED.margin_top,
    margin_bottom = EXCLUDED.margin_bottom,
    margin_left = EXCLUDED.margin_left,
    margin_right = EXCLUDED.margin_right,
    line_spacing = EXCLUDED.line_spacing,
    updated_at = CURRENT_TIMESTAMP;

-- إعدادات عامة إضافية
INSERT INTO general_settings (setting_key, setting_value, setting_type, category, description, is_public) VALUES
('app_version', '1.0.0', 'string', 'system', 'إصدار التطبيق', true),
('maintenance_message', 'النظام قيد الصيانة', 'string', 'system', 'رسالة الصيانة', true),
('max_upload_size', '10', 'number', 'system', 'الحد الأقصى لحجم الملف (MB)', false),
('allowed_file_types', 'jpg,jpeg,png,pdf,doc,docx,xls,xlsx', 'string', 'system', 'أنواع الملفات المسموحة', false),
('auto_backup_time', '02:00', 'string', 'system', 'وقت النسخ الاحتياطي التلقائي', false),
('password_min_length', '8', 'number', 'security', 'الحد الأدنى لطول كلمة المرور', false),
('login_attempts_limit', '5', 'number', 'security', 'عدد محاولات تسجيل الدخول المسموحة', false),
('session_warning_time', '5', 'number', 'ui', 'وقت تحذير انتهاء الجلسة (دقائق)', false)
ON CONFLICT (setting_key) DO NOTHING;

-- ===== 9. إنشاء views للاستعلامات المعقدة =====
-- Create views for complex queries

-- عرض شامل لإعدادات المستخدم
CREATE OR REPLACE VIEW user_settings_view AS
SELECT 
    us.id,
    us.user_id,
    us.organization_id,
    us.username,
    us.email,
    us.full_name,
    us.role,
    us.department,
    us.phone,
    us.avatar_url,
    us.language,
    us.timezone,
    us.date_format,
    us.time_format,
    us.notifications_enabled,
    us.email_notifications,
    us.sms_notifications,
    us.theme_preference,
    us.sidebar_collapsed,
    us.dashboard_layout,
    us.permissions,
    us.last_login,
    us.is_active,
    us.created_at,
    us.updated_at,
    ts.theme_name,
    ts.primary_color,
    ts.accent_color,
    ts.font_family,
    ts.font_size,
    ts.border_radius
FROM user_settings us
LEFT JOIN theme_settings ts ON ts.organization_id = us.organization_id;

-- عرض شامل لإعدادات النظام
CREATE OR REPLACE VIEW system_settings_view AS
SELECT 
    ss.*,
    COUNT(us.id) as total_users,
    COUNT(CASE WHEN us.is_active = true THEN 1 END) as active_users
FROM system_settings ss
LEFT JOIN user_settings us ON us.organization_id = 1
GROUP BY ss.id;

-- ===== 10. إنشاء functions للتحقق من صحة البيانات =====
-- Create validation functions

-- دالة للتحقق من صحة إعدادات المستخدم
CREATE OR REPLACE FUNCTION validate_user_settings(
    p_user_id VARCHAR(255),
    p_email VARCHAR(255),
    p_role VARCHAR(100)
) RETURNS BOOLEAN AS $$
BEGIN
    -- التحقق من وجود user_id
    IF p_user_id IS NULL OR LENGTH(p_user_id) = 0 THEN
        RETURN FALSE;
    END IF;
    
    -- التحقق من صحة البريد الإلكتروني
    IF p_email IS NULL OR p_email !~ '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$' THEN
        RETURN FALSE;
    END IF;
    
    -- التحقق من صحة الدور
    IF p_role NOT IN ('admin', 'manager', 'user', 'viewer', 'مدير النظام', 'مدير المبيعات', 'مدير المشتريات', 'محاسب', 'مندوب مبيعات', 'موظف مخازن') THEN
        RETURN FALSE;
    END IF;
    
    RETURN TRUE;
END;
$$ LANGUAGE plpgsql;

-- دالة للتحقق من صحة إعدادات الطباعة
CREATE OR REPLACE FUNCTION validate_print_settings(
    p_document_type VARCHAR(100),
    p_paper_size VARCHAR(50),
    p_font_size INTEGER
) RETURNS BOOLEAN AS $$
BEGIN
    -- التحقق من نوع السند
    IF p_document_type IS NULL OR LENGTH(p_document_type) = 0 THEN
        RETURN FALSE;
    END IF;
    
    -- التحقق من حجم الورق
    IF p_paper_size NOT IN ('A4', 'A5', 'Letter', 'Legal') THEN
        RETURN FALSE;
    END IF;
    
    -- التحقق من حجم الخط
    IF p_font_size IS NULL OR p_font_size < 8 OR p_font_size > 72 THEN
        RETURN FALSE;
    END IF;
    
    RETURN TRUE;
END;
$$ LANGUAGE plpgsql;

-- ===== 11. إنشاء triggers للتحديث التلقائي =====
-- Create triggers for automatic updates

-- trigger لتحديث updated_at تلقائياً
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- تطبيق trigger على جميع جداول الإعدادات
DROP TRIGGER IF EXISTS update_user_settings_updated_at ON user_settings;
CREATE TRIGGER update_user_settings_updated_at
    BEFORE UPDATE ON user_settings
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

DROP TRIGGER IF EXISTS update_system_settings_updated_at ON system_settings;
CREATE TRIGGER update_system_settings_updated_at
    BEFORE UPDATE ON system_settings
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

DROP TRIGGER IF EXISTS update_print_settings_updated_at ON print_settings;
CREATE TRIGGER update_print_settings_updated_at
    BEFORE UPDATE ON print_settings
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

DROP TRIGGER IF EXISTS update_theme_settings_updated_at ON theme_settings;
CREATE TRIGGER update_theme_settings_updated_at
    BEFORE UPDATE ON theme_settings
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

DROP TRIGGER IF EXISTS update_general_settings_updated_at ON general_settings;
CREATE TRIGGER update_general_settings_updated_at
    BEFORE UPDATE ON general_settings
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

DROP TRIGGER IF EXISTS update_document_settings_updated_at ON document_settings;
CREATE TRIGGER update_document_settings_updated_at
    BEFORE UPDATE ON document_settings
    FOR EACH ROW
    EXECUTE FUNCTION update_document_settings_updated_at_column();

-- دالة خاصة لجدول document_settings
CREATE OR REPLACE FUNCTION update_document_settings_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- ===== 12. إنشاء constraints إضافية للتحقق من صحة البيانات =====
-- Add additional constraints for data validation

-- قيود على جدول user_settings
ALTER TABLE user_settings 
ADD CONSTRAINT IF NOT EXISTS chk_user_settings_email 
CHECK (email ~ '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$');

ALTER TABLE user_settings 
ADD CONSTRAINT IF NOT EXISTS chk_user_settings_phone 
CHECK (phone IS NULL OR LENGTH(phone) >= 10);

-- قيود على جدول print_settings
ALTER TABLE print_settings 
ADD CONSTRAINT IF NOT EXISTS chk_print_settings_font_size 
CHECK (font_size >= 8 AND font_size <= 72);

ALTER TABLE print_settings 
ADD CONSTRAINT IF NOT EXISTS chk_print_settings_copies 
CHECK (copies >= 1 AND copies <= 10);

-- قيود على جدول theme_settings
ALTER TABLE theme_settings 
ADD CONSTRAINT IF NOT EXISTS chk_theme_settings_font_size 
CHECK (font_size >= 10 AND font_size <= 24);

ALTER TABLE theme_settings 
ADD CONSTRAINT IF NOT EXISTS chk_theme_settings_border_radius 
CHECK (border_radius >= 0 AND border_radius <= 50);

-- ===== 13. تحديث البيانات الموجودة لتتطابق مع البنية الجديدة =====
-- Update existing data to match new structure

-- تحديث إعدادات المستخدمين الموجودة
UPDATE user_settings 
SET 
    organization_id = COALESCE(organization_id, 1),
    timezone = COALESCE(timezone, 'Asia/Riyadh'),
    date_format = COALESCE(date_format, 'DD/MM/YYYY'),
    time_format = COALESCE(time_format, '24h'),
    theme_preference = COALESCE(theme_preference, 'light'),
    dashboard_layout = COALESCE(dashboard_layout, '{}'),
    permissions = COALESCE(permissions, '{}')
WHERE organization_id IS NULL 
   OR timezone IS NULL 
   OR date_format IS NULL 
   OR time_format IS NULL 
   OR theme_preference IS NULL 
   OR dashboard_layout IS NULL 
   OR permissions IS NULL;

-- تحديث إعدادات النظام الموجودة
UPDATE system_settings 
SET 
    language = COALESCE(language, 'ar'),
    timezone = COALESCE(timezone, 'Asia/Riyadh'),
    date_format = COALESCE(date_format, 'DD/MM/YYYY'),
    time_format = COALESCE(time_format, '24h'),
    primary_color = COALESCE(primary_color, '#059669'),
    secondary_color = COALESCE(secondary_color, '#64748b'),
    backup_enabled = COALESCE(backup_enabled, true),
    backup_frequency = COALESCE(backup_frequency, 'daily'),
    max_users = COALESCE(max_users, 100),
    session_timeout = COALESCE(session_timeout, 60)
WHERE language IS NULL 
   OR timezone IS NULL 
   OR primary_color IS NULL 
   OR backup_enabled IS NULL;

-- ===== 14. إنشاء stored procedures للعمليات المعقدة =====
-- Create stored procedures for complex operations

-- إجراء لنسخ إعدادات المستخدم
CREATE OR REPLACE FUNCTION copy_user_settings(
    source_user_id VARCHAR(255),
    target_user_id VARCHAR(255)
) RETURNS BOOLEAN AS $$
DECLARE
    source_settings RECORD;
BEGIN
    -- الحصول على إعدادات المستخدم المصدر
    SELECT * INTO source_settings 
    FROM user_settings 
    WHERE user_id = source_user_id;
    
    IF NOT FOUND THEN
        RETURN FALSE;
    END IF;
    
    -- نسخ الإعدادات للمستخدم الهدف
    INSERT INTO user_settings (
        user_id, organization_id, username, email, full_name, role, department,
        phone, avatar_url, language, timezone, date_format, time_format,
        notifications_enabled, email_notifications, sms_notifications,
        theme_preference, sidebar_collapsed, dashboard_layout, permissions, is_active
    ) VALUES (
        target_user_id, source_settings.organization_id, 
        source_settings.username || '_copy', source_settings.email || '_copy',
        source_settings.full_name || ' (نسخة)', source_settings.role, source_settings.department,
        source_settings.phone, source_settings.avatar_url, source_settings.language,
        source_settings.timezone, source_settings.date_format, source_settings.time_format,
        source_settings.notifications_enabled, source_settings.email_notifications,
        source_settings.sms_notifications, source_settings.theme_preference,
        source_settings.sidebar_collapsed, source_settings.dashboard_layout,
        source_settings.permissions, true
    ) ON CONFLICT (user_id) DO UPDATE SET
        organization_id = EXCLUDED.organization_id,
        role = EXCLUDED.role,
        department = EXCLUDED.department,
        language = EXCLUDED.language,
        timezone = EXCLUDED.timezone,
        date_format = EXCLUDED.date_format,
        time_format = EXCLUDED.time_format,
        notifications_enabled = EXCLUDED.notifications_enabled,
        email_notifications = EXCLUDED.email_notifications,
        sms_notifications = EXCLUDED.sms_notifications,
        theme_preference = EXCLUDED.theme_preference,
        sidebar_collapsed = EXCLUDED.sidebar_collapsed,
        dashboard_layout = EXCLUDED.dashboard_layout,
        permissions = EXCLUDED.permissions,
        updated_at = CURRENT_TIMESTAMP;
    
    RETURN TRUE;
END;
$$ LANGUAGE plpgsql;

-- إجراء لإعادة تعيين إعدادات المستخدم للافتراضية
CREATE OR REPLACE FUNCTION reset_user_settings_to_default(
    p_user_id VARCHAR(255)
) RETURNS BOOLEAN AS $$
BEGIN
    UPDATE user_settings 
    SET 
        language = 'ar',
        timezone = 'Asia/Riyadh',
        date_format = 'DD/MM/YYYY',
        time_format = '24h',
        notifications_enabled = true,
        email_notifications = true,
        sms_notifications = false,
        theme_preference = 'light',
        sidebar_collapsed = false,
        dashboard_layout = '{}',
        permissions = '{}',
        updated_at = CURRENT_TIMESTAMP
    WHERE user_id = p_user_id;
    
    RETURN FOUND;
END;
$$ LANGUAGE plpgsql;

-- ===== 15. إنشاء تقرير للتحقق من سلامة البيانات =====
-- Create data integrity check report

CREATE OR REPLACE FUNCTION check_settings_data_integrity()
RETURNS TABLE(
    table_name TEXT,
    issue_type TEXT,
    issue_count BIGINT,
    description TEXT
) AS $$
BEGIN
    -- التحقق من المستخدمين بدون إعدادات
    RETURN QUERY
    SELECT 
        'user_settings'::TEXT,
        'missing_settings'::TEXT,
        COUNT(*)::BIGINT,
        'مستخدمون بدون إعدادات'::TEXT
    FROM users u
    LEFT JOIN user_settings us ON u.username = us.user_id
    WHERE us.id IS NULL;
    
    -- التحقق من إعدادات المستخدمين بدون بريد إلكتروني صحيح
    RETURN QUERY
    SELECT 
        'user_settings'::TEXT,
        'invalid_email'::TEXT,
        COUNT(*)::BIGINT,
        'إعدادات مستخدمين ببريد إلكتروني غير صحيح'::TEXT
    FROM user_settings
    WHERE email IS NULL OR email !~ '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$';
    
    -- التحقق من إعدادات الطباعة بدون نوع سند
    RETURN QUERY
    SELECT 
        'print_settings'::TEXT,
        'missing_document_type'::TEXT,
        COUNT(*)::BIGINT,
        'إعدادات طباعة بدون نوع سند'::TEXT
    FROM print_settings
    WHERE document_type IS NULL OR LENGTH(document_type) = 0;
    
    -- التحقق من إعدادات التخصيص بدون منظمة
    RETURN QUERY
    SELECT 
        'theme_settings'::TEXT,
        'missing_organization'::TEXT,
        COUNT(*)::BIGINT,
        'إعدادات تخصيص بدون منظمة'::TEXT
    FROM theme_settings
    WHERE organization_id IS NULL;
    
END;
$$ LANGUAGE plpgsql;

-- تشغيل تقرير سلامة البيانات
-- SELECT * FROM check_settings_data_integrity();

COMMENT ON SCRIPT IS 'إصلاح شامل لجميع تناقضات إعدادات النظام - يوحد البنية بين قاعدة البيانات والـ API والمكونات';
