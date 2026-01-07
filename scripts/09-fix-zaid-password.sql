-- تحديث كلمة مرور المستخدم Zaid Salous
-- كلمة المرور الجديدة: 123456
-- SHA-256 hash: 8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92

UPDATE user_settings
SET password_hash = '8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92'
WHERE username = 'Zaid Salous';

-- التحقق من التحديث
SELECT username, full_name, email, 
       CASE 
         WHEN password_hash IS NOT NULL THEN 'كلمة المرور محدثة ✓'
         ELSE 'لا توجد كلمة مرور'
       END as password_status
FROM user_settings
WHERE username = 'Zaid Salous';
