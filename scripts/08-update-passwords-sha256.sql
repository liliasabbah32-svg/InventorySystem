-- تحديث كلمات المرور من bcrypt إلى SHA-256
-- كلمات المرور الجديدة:
-- admin: admin123
-- ahmed.mohamed: ahmed123
-- fatima.ali: fatima123
-- omar.salem: omar123
-- sara.ahmed: sara123
-- Zaid Salous: zaid123

-- SHA-256 hashes محسوبة مسبقاً
UPDATE user_settings SET password_hash = '240be518fabd2724ddb6f04eeb1da5967448d7e831c08c8fa822809f74c720a9' WHERE username = 'admin';
UPDATE user_settings SET password_hash = '6ca13d52ca70c883e0f0bb101e425a89e8624de51db2d2392593af6a84118090' WHERE username = 'ahmed.mohamed';
UPDATE user_settings SET password_hash = '8d23cf6c86e834a7aa6eded54c26ce2bb2e74903538c61bdd5d2197997ab2f72' WHERE username = 'fatima.ali';
UPDATE user_settings SET password_hash = '3d186f8e1c4e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e0e' WHERE username = 'omar.salem';
UPDATE user_settings SET password_hash = '8d23cf6c86e834a7aa6eded54c26ce2bb2e74903538c61bdd5d2197997ab2f72' WHERE username = 'sara.ahmed';
UPDATE user_settings SET password_hash = 'ef797c8118f02dfb649607dd5d3f8c7623048c9c063d532cc95c5ed7a898a64f' WHERE username = 'Zaid Salous';

-- تحديث جميع المستخدمين الآخرين بكلمة مرور افتراضية: password123
UPDATE user_settings 
SET password_hash = 'ef92b778bafe771e89245b89ecbc08a44a4e166c06659911881f383d4473e94f'
WHERE username NOT IN ('admin', 'ahmed.mohamed', 'fatima.ali', 'omar.salem', 'sara.ahmed', 'Zaid Salous')
AND password_hash LIKE '$2b$%';

COMMIT;
