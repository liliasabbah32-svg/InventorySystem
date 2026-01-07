-- جدول الإعدادات العامة
CREATE TABLE IF NOT EXISTS general_settings (
    id SERIAL PRIMARY KEY,
    organization_id INTEGER,
    setting_key VARCHAR(100) NOT NULL,
    setting_value TEXT,
    setting_type VARCHAR(50) DEFAULT 'string',
    category VARCHAR(50),
    description TEXT,
    is_public BOOLEAN DEFAULT false,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(organization_id, setting_key)
);

CREATE INDEX IF NOT EXISTS idx_general_settings_key ON general_settings(setting_key);
CREATE INDEX IF NOT EXISTS idx_general_settings_category ON general_settings(category);
