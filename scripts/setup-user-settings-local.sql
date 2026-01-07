-- ========================================
-- Script لإنشاء جدول user_settings وإدخال بيانات تجريبية
-- للاستخدام المحلي (Local Development)
-- ========================================

-- 1. إنشاء جدول user_settings
CREATE TABLE IF NOT EXISTS user_settings (
    id SERIAL PRIMARY KEY,
    user_id VARCHAR(255) UNIQUE NOT NULL,
    username VARCHAR(100) UNIQUE NOT NULL,
    password_hash VARCHAR(255),
    email VARCHAR(255),
    full_name VARCHAR(255),
    phone VARCHAR(50),
    role VARCHAR(50),
    department VARCHAR(100),
    organization_id INTEGER DEFAULT 1,
    permissions JSONB,
    is_active BOOLEAN DEFAULT true,
    theme_preference VARCHAR(20) DEFAULT 'light',
    language VARCHAR(10) DEFAULT 'ar',
    timezone VARCHAR(50) DEFAULT 'Asia/Riyadh',
    date_format VARCHAR(20) DEFAULT 'DD/MM/YYYY',
    time_format VARCHAR(20) DEFAULT '24h',
    notifications_enabled BOOLEAN DEFAULT true,
    email_notifications BOOLEAN DEFAULT true,
    sms_notifications BOOLEAN DEFAULT false,
    sidebar_collapsed BOOLEAN DEFAULT false,
    dashboard_layout JSONB,
    avatar_url TEXT,
    last_login TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 2. إنشاء الفهارس
CREATE INDEX IF NOT EXISTS idx_user_settings_user_id ON user_settings(user_id);
CREATE INDEX IF NOT EXISTS idx_user_settings_username ON user_settings(username);
CREATE INDEX IF NOT EXISTS idx_user_settings_email ON user_settings(email);
CREATE INDEX IF NOT EXISTS idx_user_settings_organization ON user_settings(organization_id);
CREATE INDEX IF NOT EXISTS idx_user_settings_active ON user_settings(is_active);

-- 3. حذف البيانات القديمة (إذا كانت موجودة)
TRUNCATE TABLE user_settings RESTART IDENTITY CASCADE;

-- 4. إدخال بيانات تجريبية
-- ملاحظة: كلمة المرور لجميع المستخدمين هي "admin123"
-- password_hash تم توليده باستخدام SHA-256

INSERT INTO user_settings (
    user_id,
    username,
    email,
    password_hash,
    full_name,
    phone,
    role,
    department,
    organization_id,
    is_active,
    permissions,
    email_notifications,
    sms_notifications,
    notifications_enabled,
    language,
    timezone,
    theme_preference,
    created_at,
    updated_at
) VALUES 
-- مدير النظام الرئيسي
(
    'admin_001',
    'admin',
    'admin@company.com',
    '240be518fabd2724ddb6f04eeb1da5967448d7e831c08c8fa822809f74c720a9', -- admin123
    'مدير النظام',
    '+966501234567',
    'مدير النظام',
    'الإدارة',
    1,
    true,
    '{"users": {"create": true, "read": true, "update": true, "delete": true}, "products": {"create": true, "read": true, "update": true, "delete": true}, "orders": {"create": true, "read": true, "update": true, "delete": true}, "inventory": {"create": true, "read": true, "update": true, "delete": true}, "reports": {"create": true, "read": true, "update": true, "delete": true}, "settings": {"create": true, "read": true, "update": true, "delete": true}, "admin": true}',
    true,
    true,
    true,
    'ar',
    'Asia/Riyadh',
    'slate',
    NOW(),
    NOW()
),

-- مدير المبيعات
(
    'sales_manager_001',
    'ahmed.mohamed',
    'ahmed.mohamed@company.com',
    '240be518fabd2724ddb6f04eeb1da5967448d7e831c08c8fa822809f74c720a9', -- admin123
    'أحمد محمد',
    '+966502345678',
    'مدير المبيعات',
    'المبيعات',
    1,
    true,
    '{"orders": {"create": true, "read": true, "update": true, "delete": false}, "customers": {"create": true, "read": true, "update": true, "delete": false}, "products": {"create": false, "read": true, "update": false, "delete": false}, "reports": {"create": false, "read": true, "update": false, "delete": false}}',
    true,
    true,
    true,
    'ar',
    'Asia/Riyadh',
    'blue',
    NOW(),
    NOW()
),

-- مدير المشتريات
(
    'purchase_manager_001',
    'fatima.ali',
    'fatima.ali@company.com',
    '240be518fabd2724ddb6f04eeb1da5967448d7e831c08c8fa822809f74c720a9', -- admin123
    'فاطمة علي',
    '+966503456789',
    'مدير المشتريات',
    'المشتريات',
    1,
    true,
    '{"purchase_orders": {"create": true, "read": true, "update": true, "delete": false}, "suppliers": {"create": true, "read": true, "update": true, "delete": false}, "products": {"create": true, "read": true, "update": true, "delete": false}, "inventory": {"create": false, "read": true, "update": false, "delete": false}}',
    true,
    false,
    true,
    'ar',
    'Asia/Riyadh',
    'green',
    NOW(),
    NOW()
),

-- مدير المخزون
(
    'inventory_manager_001',
    'omar.salem',
    'omar.salem@company.com',
    '240be518fabd2724ddb6f04eeb1da5967448d7e831c08c8fa822809f74c720a9', -- admin123
    'عمر سالم',
    '+966504567890',
    'مدير المخزون',
    'المخزون',
    1,
    true,
    '{"inventory": {"create": true, "read": true, "update": true, "delete": false}, "products": {"create": false, "read": true, "update": true, "delete": false}, "warehouses": {"create": true, "read": true, "update": true, "delete": false}, "reports": {"create": false, "read": true, "update": false, "delete": false}}',
    true,
    true,
    true,
    'ar',
    'Asia/Riyadh',
    'orange',
    NOW(),
    NOW()
),

-- محاسب
(
    'accountant_001',
    'sara.ahmed',
    'sara.ahmed@company.com',
    '240be518fabd2724ddb6f04eeb1da5967448d7e831c08c8fa822809f74c720a9', -- admin123
    'سارة أحمد',
    '+966505678901',
    'محاسب',
    'المحاسبة',
    1,
    true,
    '{"orders": {"create": false, "read": true, "update": false, "delete": false}, "reports": {"create": true, "read": true, "update": false, "delete": false}, "customers": {"create": false, "read": true, "update": false, "delete": false}, "suppliers": {"create": false, "read": true, "update": false, "delete": false}}',
    true,
    false,
    true,
    'ar',
    'Asia/Riyadh',
    'purple',
    NOW(),
    NOW()
),

-- موظف مبيعات
(
    'sales_employee_001',
    'khalid.hassan',
    'khalid.hassan@company.com',
    '240be518fabd2724ddb6f04eeb1da5967448d7e831c08c8fa822809f74c720a9', -- admin123
    'خالد حسن',
    '+966506789012',
    'موظف مبيعات',
    'المبيعات',
    1,
    true,
    '{"orders": {"create": true, "read": true, "update": true, "delete": false}, "customers": {"create": true, "read": true, "update": true, "delete": false}, "products": {"create": false, "read": true, "update": false, "delete": false}}',
    true,
    true,
    true,
    'ar',
    'Asia/Riyadh',
    'light',
    NOW(),
    NOW()
);

-- 5. إنشاء trigger لتحديث updated_at تلقائياً
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ language 'plpgsql';

DROP TRIGGER IF EXISTS update_user_settings_updated_at ON user_settings;
CREATE TRIGGER update_user_settings_updated_at
    BEFORE UPDATE ON user_settings
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- 6. التحقق من البيانات المدخلة
SELECT 
    id,
    username,
    email,
    full_name,
    role,
    department,
    is_active,
    created_at
FROM user_settings 
ORDER BY id;

-- 7. عرض إحصائيات
SELECT 
    COUNT(*) as total_users,
    COUNT(CASE WHEN is_active = true THEN 1 END) as active_users,
    COUNT(CASE WHEN is_active = false THEN 1 END) as inactive_users,
    COUNT(DISTINCT department) as departments_count,
    COUNT(DISTINCT role) as roles_count
FROM user_settings;

-- ========================================
-- ملاحظات مهمة:
-- ========================================
-- 1. كلمة المرور لجميع المستخدمين: admin123
-- 2. password_hash مشفر بـ SHA-256
-- 3. يمكنك تسجيل الدخول بأي من المستخدمين التاليين:
--    - admin / admin123
--    - ahmed.mohamed / admin123
--    - fatima.ali / admin123
--    - omar.salem / admin123
--    - sara.ahmed / admin123
--    - khalid.hassan / admin123
-- 4. لتغيير كلمة المرور، استخدم SHA-256 hash
-- 5. الصلاحيات محددة في حقل permissions بصيغة JSON
-- ========================================
