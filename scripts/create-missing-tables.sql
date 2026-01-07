-- Creating missing tables for theme_settings and user_settings
CREATE TABLE IF NOT EXISTS theme_settings (
    id SERIAL PRIMARY KEY,
    organization_id INTEGER,
    theme_name VARCHAR(100) DEFAULT 'default',
    primary_color VARCHAR(7) DEFAULT '#3b82f6',
    secondary_color VARCHAR(7) DEFAULT '#64748b',
    accent_color VARCHAR(7) DEFAULT '#10b981',
    background_color VARCHAR(7) DEFAULT '#ffffff',
    text_color VARCHAR(7) DEFAULT '#1f2937',
    font_family VARCHAR(100) DEFAULT 'Inter',
    font_size INTEGER DEFAULT 14,
    font_weight INTEGER DEFAULT 400,
    line_height DECIMAL(3,2) DEFAULT 1.5,
    letter_spacing DECIMAL(3,2) DEFAULT 0.0,
    border_radius INTEGER DEFAULT 8,
    sidebar_width INTEGER DEFAULT 256,
    header_height INTEGER DEFAULT 64,
    dark_mode BOOLEAN DEFAULT false,
    rtl_support BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS user_settings (
    id SERIAL PRIMARY KEY,
    user_id VARCHAR(255) NOT NULL,
    organization_id INTEGER,
    username VARCHAR(100) NOT NULL,
    email VARCHAR(255) NOT NULL,
    full_name VARCHAR(255),
    role VARCHAR(100) DEFAULT 'user',
    department VARCHAR(100),
    phone VARCHAR(20),
    avatar_url TEXT,
    language VARCHAR(10) DEFAULT 'ar',
    timezone VARCHAR(50) DEFAULT 'Asia/Riyadh',
    date_format VARCHAR(20) DEFAULT 'DD/MM/YYYY',
    time_format VARCHAR(10) DEFAULT '24h',
    notifications_enabled BOOLEAN DEFAULT true,
    email_notifications BOOLEAN DEFAULT true,
    sms_notifications BOOLEAN DEFAULT false,
    theme_preference VARCHAR(20) DEFAULT 'light',
    sidebar_collapsed BOOLEAN DEFAULT false,
    dashboard_layout JSONB DEFAULT '{}',
    permissions JSONB DEFAULT '{}',
    last_login TIMESTAMP,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(user_id, organization_id)
);

-- Create indexes for better performance
CREATE INDEX IF NOT EXISTS idx_theme_settings_org ON theme_settings(organization_id);
CREATE INDEX IF NOT EXISTS idx_user_settings_user ON user_settings(user_id);
CREATE INDEX IF NOT EXISTS idx_user_settings_org ON user_settings(organization_id);
CREATE INDEX IF NOT EXISTS idx_user_settings_email ON user_settings(email);

-- Insert default theme settings
INSERT INTO theme_settings (organization_id, theme_name) 
VALUES (1, 'default') 
ON CONFLICT DO NOTHING;
