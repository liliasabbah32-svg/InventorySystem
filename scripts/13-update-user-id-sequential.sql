-- تحديث جدول user_settings لجعل user_id رقم تسلسلي
-- Update user_settings table to make user_id sequential

-- إضافة عمود جديد للرقم التسلسلي
ALTER TABLE user_settings ADD COLUMN IF NOT EXISTS user_sequence_id SERIAL;

-- تحديث البيانات الموجودة لتعيين أرقام تسلسلية
UPDATE user_settings 
SET user_sequence_id = ROW_NUMBER() OVER (ORDER BY created_at)
WHERE user_sequence_id IS NULL;

-- إنشاء دالة لتوليد رقم المستخدم التسلسلي
CREATE OR REPLACE FUNCTION generate_user_id()
RETURNS TRIGGER AS $$
BEGIN
    -- إذا لم يتم تحديد user_id، قم بتوليده تلقائياً
    IF NEW.user_id IS NULL OR NEW.user_id = '' THEN
        NEW.user_id := 'U' || LPAD(NEW.user_sequence_id::text, 4, '0');
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- إنشاء trigger لتوليد user_id تلقائياً
DROP TRIGGER IF EXISTS trigger_generate_user_id ON user_settings;
CREATE TRIGGER trigger_generate_user_id
    BEFORE INSERT ON user_settings
    FOR EACH ROW
    EXECUTE FUNCTION generate_user_id();

-- تحديث البيانات الموجودة لتطبيق النمط الجديد
UPDATE user_settings 
SET user_id = 'U' || LPAD(user_sequence_id::text, 4, '0')
WHERE user_id NOT LIKE 'U%' OR LENGTH(user_id) != 5;

-- إنشاء فهرس على العمود الجديد
CREATE INDEX IF NOT EXISTS idx_user_settings_sequence_id ON user_settings(user_sequence_id);
