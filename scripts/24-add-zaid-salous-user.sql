-- إضافة المستخدم Zaid Salous كمدير للنظام
-- كلمة المرور: admin123

-- حذف المستخدم إذا كان موجوداً مسبقاً
DELETE FROM user_settings WHERE username = 'zaid.salous' OR email = 'zaid.salous@company.com';
DELETE FROM user_settings WHERE username = 'admin' OR email = 'admin@company.com';

-- إضافة المستخدم Zaid Salous
INSERT INTO user_settings (
    user_id,
    username,
    email,
    password_hash,
    full_name,
    role,
    department,
    organization_id,
    is_active,
    permissions,
    email_notifications,
    sms_notifications,
    notifications_enabled,
    sidebar_collapsed,
    language,
    timezone,
    date_format,
    time_format,
    theme_preference,
    dashboard_layout,
    created_at,
    updated_at
) VALUES (
    'zaid_salous_001',
    'zaid.salous',
    'zaid.salous@company.com',
    '$2b$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', -- password
    'Zaid Salous',
    'مدير النظام',
    'إدارة النظام',
    1,
    true,
    '{"users": {"create": true, "read": true, "update": true, "delete": true}, "products": {"create": true, "read": true, "update": true, "delete": true}, "orders": {"create": true, "read": true, "update": true, "delete": true}, "inventory": {"create": true, "read": true, "update": true, "delete": true}, "reports": {"create": true, "read": true, "update": true, "delete": true}, "settings": {"create": true, "read": true, "update": true, "delete": true}, "admin": {"create": true, "read": true, "update": true, "delete": true}}',
    true,
    true,
    true,
    false,
    'ar',
    'Asia/Riyadh',
    'DD/MM/YYYY',
    '24h',
    'slate',
    '{"layout": "default", "widgets": ["dashboard", "orders", "inventory", "reports"]}',
    NOW(),
    NOW()
);

-- إضافة مستخدم مدير إضافي للاختبار
INSERT INTO user_settings (
    user_id,
    username,
    email,
    password_hash,
    full_name,
    role,
    department,
    organization_id,
    is_active,
    permissions,
    email_notifications,
    sms_notifications,
    notifications_enabled,
    sidebar_collapsed,
    language,
    timezone,
    date_format,
    time_format,
    theme_preference,
    dashboard_layout,
    created_at,
    updated_at
) VALUES (
    'admin_user_001',
    'admin',
    'admin@company.com',
    '$2b$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', -- password
    'مدير النظام',
    'مدير النظام',
    'إدارة النظام',
    1,
    true,
    '{"users": {"create": true, "read": true, "update": true, "delete": true}, "products": {"create": true, "read": true, "update": true, "delete": true}, "orders": {"create": true, "read": true, "update": true, "delete": true}, "inventory": {"create": true, "read": true, "update": true, "delete": true}, "reports": {"create": true, "read": true, "update": true, "delete": true}, "settings": {"create": true, "read": true, "update": true, "delete": true}, "admin": {"create": true, "read": true, "update": true, "delete": true}}',
    true,
    true,
    true,
    false,
    'ar',
    'Asia/Riyadh',
    'DD/MM/YYYY',
    '24h',
    'slate',
    '{"layout": "default", "widgets": ["dashboard", "orders", "inventory", "reports"]}',
    NOW(),
    NOW()
);

-- التحقق من إضافة المستخدمين
SELECT 
    username,
    email,
    full_name,
    role,
    is_active,
    created_at
FROM user_settings 
WHERE username IN ('zaid.salous', 'admin')
ORDER BY created_at DESC;
