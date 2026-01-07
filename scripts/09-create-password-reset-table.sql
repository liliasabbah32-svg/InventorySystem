-- Create password reset requests table
CREATE TABLE IF NOT EXISTS password_reset_requests (
    id SERIAL PRIMARY KEY,
    email VARCHAR(255) NOT NULL UNIQUE,
    reset_code VARCHAR(6) NOT NULL,
    expires_at TIMESTAMP NOT NULL,
    used BOOLEAN DEFAULT false,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create index for faster lookups
CREATE INDEX IF NOT EXISTS idx_password_reset_email ON password_reset_requests(email);
CREATE INDEX IF NOT EXISTS idx_password_reset_code ON password_reset_requests(reset_code);
CREATE INDEX IF NOT EXISTS idx_password_reset_expires ON password_reset_requests(expires_at);

-- Add password_hash column to user_settings if not exists
ALTER TABLE user_settings 
ADD COLUMN IF NOT EXISTS password_hash VARCHAR(255);

-- Update existing users with hashed passwords (for demo purposes)
-- In production, users would need to reset their passwords
UPDATE user_settings 
SET password_hash = '$2a$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewdBPj/VcSAg/9qm' -- 'password123'
WHERE password_hash IS NULL;

COMMENT ON TABLE password_reset_requests IS 'جدول طلبات استعادة كلمة المرور';
COMMENT ON COLUMN password_reset_requests.email IS 'البريد الإلكتروني للمستخدم';
COMMENT ON COLUMN password_reset_requests.reset_code IS 'رمز التحقق (6 أرقام)';
COMMENT ON COLUMN password_reset_requests.expires_at IS 'تاريخ انتهاء صلاحية الرمز';
COMMENT ON COLUMN password_reset_requests.used IS 'هل تم استخدام الرمز';
