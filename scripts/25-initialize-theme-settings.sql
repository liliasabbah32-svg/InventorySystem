-- Initialize default theme settings for the organization
-- This ensures the theme API always has data to return

-- Check if theme_settings table exists and has data
DO $$
BEGIN
  -- Insert default theme settings if none exist
  IF NOT EXISTS (SELECT 1 FROM theme_settings WHERE organization_id = 1 AND (user_id IS NULL OR user_id = '')) THEN
    INSERT INTO theme_settings (
      organization_id,
      user_id,
      theme_name,
      primary_color,
      secondary_color,
      accent_color,
      background_color,
      text_color,
      font_family,
      font_size,
      font_weight,
      line_height,
      letter_spacing,
      border_radius,
      sidebar_width,
      header_height,
      dark_mode,
      rtl_support,
      card_style,
      button_style,
      animation_speed,
      compact_mode,
      high_contrast,
      created_at,
      updated_at
    ) VALUES (
      1,                              -- organization_id
      NULL,                           -- user_id (NULL for organization default)
      'default',                      -- theme_name
      '#059669',                      -- primary_color (emerald-600)
      '#64748b',                      -- secondary_color (slate-500)
      '#10b981',                      -- accent_color (emerald-500)
      '#ffffff',                      -- background_color
      '#1f2937',                      -- text_color (gray-800)
      'var(--font-geist-sans)',       -- font_family
      14,                             -- font_size
      400,                            -- font_weight
      1.5,                            -- line_height
      0.0,                            -- letter_spacing
      8,                              -- border_radius
      256,                            -- sidebar_width
      64,                             -- header_height
      false,                          -- dark_mode
      true,                           -- rtl_support
      'elevated',                     -- card_style
      'rounded',                      -- button_style
      'normal',                       -- animation_speed
      false,                          -- compact_mode
      false,                          -- high_contrast
      CURRENT_TIMESTAMP,              -- created_at
      CURRENT_TIMESTAMP               -- updated_at
    );
    
    RAISE NOTICE 'Default theme settings created successfully';
  ELSE
    RAISE NOTICE 'Theme settings already exist, skipping initialization';
  END IF;
END $$;

-- Verify the data
SELECT 
  id,
  organization_id,
  user_id,
  theme_name,
  primary_color,
  rtl_support,
  created_at
FROM theme_settings
WHERE organization_id = 1 AND (user_id IS NULL OR user_id = '')
ORDER BY created_at DESC
LIMIT 1;
