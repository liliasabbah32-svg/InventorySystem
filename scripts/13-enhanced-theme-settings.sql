-- Enhanced theme settings table with user-specific support
ALTER TABLE theme_settings ADD COLUMN IF NOT EXISTS user_id VARCHAR(255);
ALTER TABLE theme_settings ADD COLUMN IF NOT EXISTS card_style VARCHAR(20) DEFAULT 'elevated';
ALTER TABLE theme_settings ADD COLUMN IF NOT EXISTS button_style VARCHAR(20) DEFAULT 'rounded';
ALTER TABLE theme_settings ADD COLUMN IF NOT EXISTS animation_speed VARCHAR(20) DEFAULT 'normal';
ALTER TABLE theme_settings ADD COLUMN IF NOT EXISTS compact_mode BOOLEAN DEFAULT false;
ALTER TABLE theme_settings ADD COLUMN IF NOT EXISTS high_contrast BOOLEAN DEFAULT false;

-- Create index for user-specific theme settings
CREATE INDEX IF NOT EXISTS idx_theme_settings_user ON theme_settings(user_id);
CREATE INDEX IF NOT EXISTS idx_theme_settings_org_user ON theme_settings(organization_id, user_id);

-- Update existing theme settings to include new fields
UPDATE theme_settings 
SET 
  card_style = 'elevated',
  button_style = 'rounded',
  animation_speed = 'normal',
  compact_mode = false,
  high_contrast = false
WHERE card_style IS NULL;

-- Create user theme preferences table for additional settings
CREATE TABLE IF NOT EXISTS user_theme_preferences (
    id SERIAL PRIMARY KEY,
    user_id VARCHAR(255) NOT NULL,
    organization_id INTEGER,
    theme_settings_id INTEGER REFERENCES theme_settings(id),
    is_default BOOLEAN DEFAULT false,
    last_applied TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(user_id, organization_id)
);

-- Create indexes for user theme preferences
CREATE INDEX IF NOT EXISTS idx_user_theme_prefs_user ON user_theme_preferences(user_id);
CREATE INDEX IF NOT EXISTS idx_user_theme_prefs_org ON user_theme_preferences(organization_id);
CREATE INDEX IF NOT EXISTS idx_user_theme_prefs_theme ON user_theme_preferences(theme_settings_id);

-- Insert default user theme preferences for existing users
INSERT INTO user_theme_preferences (user_id, organization_id, theme_settings_id, is_default)
SELECT DISTINCT 
    'default_user' as user_id,
    1 as organization_id,
    ts.id as theme_settings_id,
    true as is_default
FROM theme_settings ts
WHERE ts.organization_id = 1
ON CONFLICT (user_id, organization_id) DO NOTHING;

-- Create function to get user theme settings
CREATE OR REPLACE FUNCTION get_user_theme_settings(p_user_id VARCHAR(255), p_organization_id INTEGER DEFAULT 1)
RETURNS TABLE (
    id INTEGER,
    organization_id INTEGER,
    user_id VARCHAR(255),
    theme_name VARCHAR(100),
    primary_color VARCHAR(7),
    secondary_color VARCHAR(7),
    accent_color VARCHAR(7),
    background_color VARCHAR(7),
    text_color VARCHAR(7),
    font_family VARCHAR(100),
    font_size INTEGER,
    font_weight INTEGER,
    line_height DECIMAL(3,2),
    letter_spacing DECIMAL(3,2),
    border_radius INTEGER,
    sidebar_width INTEGER,
    header_height INTEGER,
    dark_mode BOOLEAN,
    rtl_support BOOLEAN,
    card_style VARCHAR(20),
    button_style VARCHAR(20),
    animation_speed VARCHAR(20),
    compact_mode BOOLEAN,
    high_contrast BOOLEAN,
    created_at TIMESTAMP,
    updated_at TIMESTAMP
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        ts.id,
        ts.organization_id,
        ts.user_id,
        ts.theme_name,
        ts.primary_color,
        ts.secondary_color,
        ts.accent_color,
        ts.background_color,
        ts.text_color,
        ts.font_family,
        ts.font_size,
        ts.font_weight,
        ts.line_height,
        ts.letter_spacing,
        ts.border_radius,
        ts.sidebar_width,
        ts.header_height,
        ts.dark_mode,
        ts.rtl_support,
        ts.card_style,
        ts.button_style,
        ts.animation_speed,
        ts.compact_mode,
        ts.high_contrast,
        ts.created_at,
        ts.updated_at
    FROM theme_settings ts
    LEFT JOIN user_theme_preferences utp ON ts.id = utp.theme_settings_id
    WHERE (ts.user_id = p_user_id OR (ts.user_id IS NULL AND utp.user_id = p_user_id))
      AND ts.organization_id = p_organization_id
    ORDER BY ts.user_id NULLS LAST, ts.updated_at DESC
    LIMIT 1;
    
    -- If no user-specific theme found, return organization default
    IF NOT FOUND THEN
        RETURN QUERY
        SELECT 
            ts.id,
            ts.organization_id,
            ts.user_id,
            ts.theme_name,
            ts.primary_color,
            ts.secondary_color,
            ts.accent_color,
            ts.background_color,
            ts.text_color,
            ts.font_family,
            ts.font_size,
            ts.font_weight,
            ts.line_height,
            ts.letter_spacing,
            ts.border_radius,
            ts.sidebar_width,
            ts.header_height,
            ts.dark_mode,
            ts.rtl_support,
            ts.card_style,
            ts.button_style,
            ts.animation_speed,
            ts.compact_mode,
            ts.high_contrast,
            ts.created_at,
            ts.updated_at
        FROM theme_settings ts
        WHERE ts.organization_id = p_organization_id
          AND ts.user_id IS NULL
        ORDER BY ts.updated_at DESC
        LIMIT 1;
    END IF;
END;
$$ LANGUAGE plpgsql;

-- Create function to save user theme settings
CREATE OR REPLACE FUNCTION save_user_theme_settings(
    p_user_id VARCHAR(255),
    p_organization_id INTEGER,
    p_theme_name VARCHAR(100),
    p_primary_color VARCHAR(7),
    p_secondary_color VARCHAR(7),
    p_accent_color VARCHAR(7),
    p_background_color VARCHAR(7),
    p_text_color VARCHAR(7),
    p_font_family VARCHAR(100),
    p_font_size INTEGER,
    p_font_weight INTEGER,
    p_line_height DECIMAL(3,2),
    p_letter_spacing DECIMAL(3,2),
    p_border_radius INTEGER,
    p_sidebar_width INTEGER,
    p_header_height INTEGER,
    p_dark_mode BOOLEAN,
    p_rtl_support BOOLEAN,
    p_card_style VARCHAR(20),
    p_button_style VARCHAR(20),
    p_animation_speed VARCHAR(20),
    p_compact_mode BOOLEAN,
    p_high_contrast BOOLEAN
)
RETURNS TABLE (
    id INTEGER,
    organization_id INTEGER,
    user_id VARCHAR(255),
    updated_at TIMESTAMP
) AS $$
DECLARE
    theme_id INTEGER;
    pref_exists BOOLEAN;
BEGIN
    -- Check if user-specific theme settings already exist
    SELECT ts.id INTO theme_id
    FROM theme_settings ts
    WHERE ts.user_id = p_user_id AND ts.organization_id = p_organization_id;
    
    IF theme_id IS NOT NULL THEN
        -- Update existing user theme settings
        UPDATE theme_settings 
        SET 
            theme_name = p_theme_name,
            primary_color = p_primary_color,
            secondary_color = p_secondary_color,
            accent_color = p_accent_color,
            background_color = p_background_color,
            text_color = p_text_color,
            font_family = p_font_family,
            font_size = p_font_size,
            font_weight = p_font_weight,
            line_height = p_line_height,
            letter_spacing = p_letter_spacing,
            border_radius = p_border_radius,
            sidebar_width = p_sidebar_width,
            header_height = p_header_height,
            dark_mode = p_dark_mode,
            rtl_support = p_rtl_support,
            card_style = p_card_style,
            button_style = p_button_style,
            animation_speed = p_animation_speed,
            compact_mode = p_compact_mode,
            high_contrast = p_high_contrast,
            updated_at = CURRENT_TIMESTAMP
        WHERE ts.id = theme_id;
    ELSE
        -- Create new user theme settings
        INSERT INTO theme_settings (
            organization_id, user_id, theme_name, primary_color, secondary_color, accent_color,
            background_color, text_color, font_family, font_size, font_weight,
            line_height, letter_spacing, border_radius, sidebar_width, header_height,
            dark_mode, rtl_support, card_style, button_style, animation_speed,
            compact_mode, high_contrast
        ) VALUES (
            p_organization_id, p_user_id, p_theme_name, p_primary_color, p_secondary_color, p_accent_color,
            p_background_color, p_text_color, p_font_family, p_font_size, p_font_weight,
            p_line_height, p_letter_spacing, p_border_radius, p_sidebar_width, p_header_height,
            p_dark_mode, p_rtl_support, p_card_style, p_button_style, p_animation_speed,
            p_compact_mode, p_high_contrast
        )
        RETURNING theme_settings.id INTO theme_id;
    END IF;
    
    -- Update or create user theme preference
    SELECT EXISTS(
        SELECT 1 FROM user_theme_preferences 
        WHERE user_id = p_user_id AND organization_id = p_organization_id
    ) INTO pref_exists;
    
    IF pref_exists THEN
        UPDATE user_theme_preferences 
        SET 
            theme_settings_id = theme_id,
            last_applied = CURRENT_TIMESTAMP,
            updated_at = CURRENT_TIMESTAMP
        WHERE user_id = p_user_id AND organization_id = p_organization_id;
    ELSE
        INSERT INTO user_theme_preferences (user_id, organization_id, theme_settings_id, is_default)
        VALUES (p_user_id, p_organization_id, theme_id, true);
    END IF;
    
    -- Return the saved theme settings
    RETURN QUERY
    SELECT theme_id, p_organization_id, p_user_id, CURRENT_TIMESTAMP;
END;
$$ LANGUAGE plpgsql;
