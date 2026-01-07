-- إضافة المستخدم زيد سلعوس إلى قاعدة البيانات
INSERT INTO user_settings (
    user_id, username, full_name, email, role, department,
    password_hash, is_active, organization_id, permissions,
    created_at, updated_at
) VALUES (
    'U004',
    'Zaid Salous',
    'زيد سلعوس',
    'zaid.salous@gmail.com',
    'مدير النظام',
    'الإدارة',
    'WlhjMDU5NTU3MDIy', -- Base64 encoded password for ZXc059557022
    true,
    1,
    '["جميع الصلاحيات"]'::jsonb,
    NOW(),
    NOW()
) ON CONFLICT (user_id) DO UPDATE SET
    username = EXCLUDED.username,
    full_name = EXCLUDED.full_name,
    email = EXCLUDED.email,
    role = EXCLUDED.role,
    department = EXCLUDED.department,
    password_hash = EXCLUDED.password_hash,
    is_active = EXCLUDED.is_active,
    permissions = EXCLUDED.permissions,
    updated_at = NOW();

-- إضافة باقي المستخدمين التجريبيين
INSERT INTO user_settings (
    user_id, username, full_name, email, role, department,
    password_hash, is_active, organization_id, permissions,
    created_at, updated_at
) VALUES 
(
    'U001',
    'admin',
    'المدير العام',
    'admin@company.com',
    'مدير النظام',
    'الإدارة',
    'YWRtaW4xMjM=', -- Base64 encoded password for admin123
    true,
    1,
    '["جميع الصلاحيات"]'::jsonb,
    NOW(),
    NOW()
),
(
    'U002',
    'sales',
    'مدير المبيعات',
    'sales@company.com',
    'مدير المبيعات',
    'المبيعات',
    'c2FsZXMxMjM=', -- Base64 encoded password for sales123
    true,
    1,
    '["المبيعات", "التقارير", "الزبائن", "الأصناف"]'::jsonb,
    NOW(),
    NOW()
),
(
    'U003',
    'accountant',
    'المحاسب الرئيسي',
    'accountant@company.com',
    'محاسب',
    'المحاسبة',
    'YWNjMTIz', -- Base64 encoded password for acc123
    true,
    1,
    '["المحاسبة", "التقارير المالية", "أسعار الصرف"]'::jsonb,
    NOW(),
    NOW()
)
ON CONFLICT (user_id) DO UPDATE SET
    username = EXCLUDED.username,
    full_name = EXCLUDED.full_name,
    email = EXCLUDED.email,
    role = EXCLUDED.role,
    department = EXCLUDED.department,
    password_hash = EXCLUDED.password_hash,
    is_active = EXCLUDED.is_active,
    permissions = EXCLUDED.permissions,
    updated_at = NOW();

-- تحديث آخر تسجيل دخول للمستخدم زيد
UPDATE user_settings 
SET last_login = NOW(), updated_at = NOW()
WHERE user_id = 'U004' OR email = 'zaid.salous@gmail.com';
