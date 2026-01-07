-- Fix theme settings table structure and create required functions

-- First, add missing columns to theme_settings table
ALTER TABLE theme_settings 
ADD COLUMN IF NOT EXISTS user_id CHARACTER VARYING,
ADD COLUMN IF NOT EXISTS card_style CHARACTER VARYING DEFAULT 'elevated',
ADD COLUMN IF NOT EXISTS button_style CHARACTER VARYING DEFAULT 'rounded',
ADD COLUMN IF NOT EXISTS animation_speed CHARACTER VARYING DEFAULT 'normal',
ADD COLUMN IF NOT EXISTS compact_mode BOOLEAN DEFAULT false,
ADD COLUMN IF NOT EXISTS high_contrast BOOLEAN DEFAULT false;

-- Create function to get user theme settings
CREATE OR REPLACE FUNCTION get_user_theme_settings(
    p_user_id CHARACTER VARYING,
    p_organization_id INTEGER
)
RETURNS TABLE (
    id INTEGER,
    organization_id INTEGER,
    user_id CHARACTER VARYING,
    theme_name CHARACTER VARYING,
    primary_color CHARACTER VARYING,
    secondary_color CHARACTER VARYING,
    accent_color CHARACTER VARYING,
    background_color CHARACTER VARYING,
    text_color CHARACTER VARYING,
    font_family CHARACTER VARYING,
    font_size INTEGER,
    font_weight INTEGER,
    line_height NUMERIC,
    letter_spacing NUMERIC,
    border_radius INTEGER,
    sidebar_width INTEGER,
    header_height INTEGER,
    dark_mode BOOLEAN,
    rtl_support BOOLEAN,
    card_style CHARACTER VARYING,
    button_style CHARACTER VARYING,
    animation_speed CHARACTER VARYING,
    compact_mode BOOLEAN,
    high_contrast BOOLEAN,
    created_at TIMESTAMP WITHOUT TIME ZONE,
    updated_at TIMESTAMP WITHOUT TIME ZONE
) AS $$
BEGIN
    -- First try to get user-specific settings
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
    WHERE ts.user_id = p_user_id 
      AND ts.organization_id = p_organization_id
    ORDER BY ts.updated_at DESC
    LIMIT 1;
    
    -- If no user-specific settings found, return organization defaults
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
        WHERE ts.user_id IS NULL 
          AND ts.organization_id = p_organization_id
        ORDER BY ts.updated_at DESC
        LIMIT 1;
    END IF;
END;
$$ LANGUAGE plpgsql;

-- Create function to save user theme settings
CREATE OR REPLACE FUNCTION save_user_theme_settings(
    p_user_id CHARACTER VARYING,
    p_organization_id INTEGER,
    p_theme_name CHARACTER VARYING DEFAULT 'default',
    p_primary_color CHARACTER VARYING DEFAULT '#3b82f6',
    p_secondary_color CHARACTER VARYING DEFAULT '#64748b',
    p_accent_color CHARACTER VARYING DEFAULT '#10b981',
    p_background_color CHARACTER VARYING DEFAULT '#ffffff',
    p_text_color CHARACTER VARYING DEFAULT '#1f2937',
    p_font_family CHARACTER VARYING DEFAULT 'Inter',
    p_font_size INTEGER DEFAULT 14,
    p_font_weight INTEGER DEFAULT 400,
    p_line_height NUMERIC DEFAULT 1.5,
    p_letter_spacing NUMERIC DEFAULT 0.0,
    p_border_radius INTEGER DEFAULT 8,
    p_sidebar_width INTEGER DEFAULT 256,
    p_header_height INTEGER DEFAULT 64,
    p_dark_mode BOOLEAN DEFAULT false,
    p_rtl_support BOOLEAN DEFAULT true,
    p_card_style CHARACTER VARYING DEFAULT 'elevated',
    p_button_style CHARACTER VARYING DEFAULT 'rounded',
    p_animation_speed CHARACTER VARYING DEFAULT 'normal',
    p_compact_mode BOOLEAN DEFAULT false,
    p_high_contrast BOOLEAN DEFAULT false
)
RETURNS TABLE (
    id INTEGER,
    organization_id INTEGER,
    user_id CHARACTER VARYING,
    theme_name CHARACTER VARYING,
    primary_color CHARACTER VARYING,
    secondary_color CHARACTER VARYING,
    accent_color CHARACTER VARYING,
    background_color CHARACTER VARYING,
    text_color CHARACTER VARYING,
    font_family CHARACTER VARYING,
    font_size INTEGER,
    font_weight INTEGER,
    line_height NUMERIC,
    letter_spacing NUMERIC,
    border_radius INTEGER,
    sidebar_width INTEGER,
    header_height INTEGER,
    dark_mode BOOLEAN,
    rtl_support BOOLEAN,
    card_style CHARACTER VARYING,
    button_style CHARACTER VARYING,
    animation_speed CHARACTER VARYING,
    compact_mode BOOLEAN,
    high_contrast BOOLEAN,
    created_at TIMESTAMP WITHOUT TIME ZONE,
    updated_at TIMESTAMP WITHOUT TIME ZONE
) AS $$
DECLARE
    existing_id INTEGER;
BEGIN
    -- Check if user-specific settings already exist
    SELECT ts.id INTO existing_id
    FROM theme_settings ts
    WHERE ts.user_id = p_user_id 
      AND ts.organization_id = p_organization_id;
    
    IF existing_id IS NOT NULL THEN
        -- Update existing settings
        RETURN QUERY
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
        WHERE theme_settings.id = existing_id
        RETURNING 
            theme_settings.id,
            theme_settings.organization_id,
            theme_settings.user_id,
            theme_settings.theme_name,
            theme_settings.primary_color,
            theme_settings.secondary_color,
            theme_settings.accent_color,
            theme_settings.background_color,
            theme_settings.text_color,
            theme_settings.font_family,
            theme_settings.font_size,
            theme_settings.font_weight,
            theme_settings.line_height,
            theme_settings.letter_spacing,
            theme_settings.border_radius,
            theme_settings.sidebar_width,
            theme_settings.header_height,
            theme_settings.dark_mode,
            theme_settings.rtl_support,
            theme_settings.card_style,
            theme_settings.button_style,
            theme_settings.animation_speed,
            theme_settings.compact_mode,
            theme_settings.high_contrast,
            theme_settings.created_at,
            theme_settings.updated_at;
    ELSE
        -- Insert new settings
        RETURN QUERY
        INSERT INTO theme_settings (
            organization_id, user_id, theme_name, primary_color, secondary_color, accent_color,
            background_color, text_color, font_family, font_size, font_weight,
            line_height, letter_spacing, border_radius, sidebar_width, header_height,
            dark_mode, rtl_support, card_style, button_style, animation_speed,
            compact_mode, high_contrast
        ) VALUES (
            p_organization_id, p_user_id, p_theme_name, p_primary_color, p_secondary_color, 
            p_accent_color, p_background_color, p_text_color, p_font_family, 
            p_font_size, p_font_weight, p_line_height, p_letter_spacing, 
            p_border_radius, p_sidebar_width, p_header_height, p_dark_mode, 
            p_rtl_support, p_card_style, p_button_style, p_animation_speed,
            p_compact_mode, p_high_contrast
        )
        RETURNING 
            theme_settings.id,
            theme_settings.organization_id,
            theme_settings.user_id,
            theme_settings.theme_name,
            theme_settings.primary_color,
            theme_settings.secondary_color,
            theme_settings.accent_color,
            theme_settings.background_color,
            theme_settings.text_color,
            theme_settings.font_family,
            theme_settings.font_size,
            theme_settings.font_weight,
            theme_settings.line_height,
            theme_settings.letter_spacing,
            theme_settings.border_radius,
            theme_settings.sidebar_width,
            theme_settings.header_height,
            theme_settings.dark_mode,
            theme_settings.rtl_support,
            theme_settings.card_style,
            theme_settings.button_style,
            theme_settings.animation_speed,
            theme_settings.compact_mode,
            theme_settings.high_contrast,
            theme_settings.created_at,
            theme_settings.updated_at;
    END IF;
END;
$$ LANGUAGE plpgsql;

-- Insert default organization theme settings if none exist
INSERT INTO theme_settings (
    organization_id, theme_name, primary_color, secondary_color, accent_color,
    background_color, text_color, font_family, font_size, font_weight,
    line_height, letter_spacing, border_radius, sidebar_width, header_height,
    dark_mode, rtl_support, card_style, button_style, animation_speed,
    compact_mode, high_contrast
) 
SELECT 
    1, 'default', '#3b82f6', '#64748b', '#10b981',
    '#ffffff', '#1f2937', 'Inter', 14, 400,
    1.5, 0.0, 8, 256, 64,
    false, true, 'elevated', 'rounded', 'normal',
    false, false
WHERE NOT EXISTS (
    SELECT 1 FROM theme_settings WHERE organization_id = 1 AND user_id IS NULL
);

COMMIT;
