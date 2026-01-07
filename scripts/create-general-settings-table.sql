-- Create general_settings table
CREATE TABLE IF NOT EXISTS general_settings (
    id SERIAL PRIMARY KEY,
    company_name VARCHAR(255) NOT NULL DEFAULT '',
    company_address TEXT DEFAULT '',
    company_phone VARCHAR(50) DEFAULT '',
    company_email VARCHAR(255) DEFAULT '',
    company_website VARCHAR(255) DEFAULT '',
    default_language VARCHAR(10) DEFAULT 'ar',
    default_currency VARCHAR(10) DEFAULT 'SAR',
    timezone VARCHAR(50) DEFAULT 'Asia/Riyadh',
    date_format VARCHAR(20) DEFAULT 'DD/MM/YYYY',
    time_format VARCHAR(10) DEFAULT '24',
    decimal_places INTEGER DEFAULT 2,
    enable_notifications BOOLEAN DEFAULT true,
    enable_email_alerts BOOLEAN DEFAULT true,
    backup_frequency VARCHAR(20) DEFAULT 'daily',
    auto_backup BOOLEAN DEFAULT true,
    system_maintenance_mode BOOLEAN DEFAULT false,
    max_login_attempts INTEGER DEFAULT 5,
    session_timeout INTEGER DEFAULT 30,
    enable_audit_log BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Insert default settings if none exist
INSERT INTO general_settings (
    company_name, default_language, default_currency, timezone
) 
SELECT 'شركة إدارة المخزون والطلبيات', 'ar', 'SAR', 'Asia/Riyadh'
WHERE NOT EXISTS (SELECT 1 FROM general_settings);
