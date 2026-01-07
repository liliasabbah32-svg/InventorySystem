-- إنشاء مستخدم مدير افتراضي
-- Create default admin user

-- إدراج مستخدم مدير افتراضي
INSERT INTO user_settings (
    user_id,
    username,
    email,
    password_hash,
    full_name,
    role,
    department,
    organization_id,
    permissions,
    is_active,
    created_at,
    updated_at
) VALUES (
    'ADMIN001',
    'admin',
    'admin@company.com',
    '$2a$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', -- password: password
    'مدير النظام',
    'مدير النظام',
    'الإدارة',
    1,
    '["جميع الصلاحيات"]',
    true,
    NOW(),
    NOW()
) ON CONFLICT (username) DO UPDATE SET
    password_hash = EXCLUDED.password_hash,
    updated_at = NOW();

-- إدراج مستخدم للاختبار
INSERT INTO user_settings (
    user_id,
    username,
    email,
    password_hash,
    full_name,
    role,
    department,
    organization_id,
    permissions,
    is_active,
    created_at,
    updated_at
) VALUES (
    'USER001',
    'user',
    'user@company.com',
    '$2a$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', -- password: password
    'مستخدم عادي',
    'موظف',
    'المبيعات',
    1,
    '["المبيعات", "التقارير", "الزبائن", "الأصناف"]',
    true,
    NOW(),
    NOW()
) ON CONFLICT (username) DO UPDATE SET
    password_hash = EXCLUDED.password_hash,
    updated_at = NOW();

-- تسجيل العملية في سجل التدقيق
INSERT INTO audit_logs (
    user_id,
    user_name,
    action,
    module,
    status,
    details,
    timestamp,
    created_at
) VALUES (
    'SYSTEM',
    'النظام',
    'create_default_users',
    'user_management',
    'success',
    'تم إنشاء المستخدمين الافتراضيين - admin (كلمة المرور: password) و user (كلمة المرور: password)',
    NOW(),
    NOW()
);
