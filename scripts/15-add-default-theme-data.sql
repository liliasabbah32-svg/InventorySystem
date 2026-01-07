-- إضافة بيانات المظهر الافتراضية
-- Add default theme data

-- إدراج المظهر الافتراضي للمؤسسة
-- Insert default organization theme
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
  1, -- organization_id
  NULL, -- user_id (NULL for organization default)
  'default', -- theme_name
  '#3b82f6', -- primary_color (blue)
  '#64748b', -- secondary_color (slate)
  '#10b981', -- accent_color (emerald)
  '#ffffff', -- background_color (white)
  '#1f2937', -- text_color (gray-800)
  'Inter', -- font_family
  14, -- font_size
  400, -- font_weight
  1.5, -- line_height
  0.0, -- letter_spacing
  8, -- border_radius
  256, -- sidebar_width
  64, -- header_height
  false, -- dark_mode
  true, -- rtl_support
  'elevated', -- card_style
  'rounded', -- button_style
  'normal', -- animation_speed
  false, -- compact_mode
  false, -- high_contrast
  CURRENT_TIMESTAMP,
  CURRENT_TIMESTAMP
) ON CONFLICT DO NOTHING;

-- إدراج مظهر داكن كخيار إضافي
-- Insert dark theme as additional option
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
  1, -- organization_id
  'dark_theme_template', -- user_id (template for dark theme)
  'dark', -- theme_name
  '#3b82f6', -- primary_color (blue)
  '#64748b', -- secondary_color (slate)
  '#10b981', -- accent_color (emerald)
  '#0f172a', -- background_color (slate-900)
  '#f1f5f9', -- text_color (slate-100)
  'Inter', -- font_family
  14, -- font_size
  400, -- font_weight
  1.5, -- line_height
  0.0, -- letter_spacing
  8, -- border_radius
  256, -- sidebar_width
  64, -- header_height
  true, -- dark_mode
  true, -- rtl_support
  'elevated', -- card_style
  'rounded', -- button_style
  'normal', -- animation_speed
  false, -- compact_mode
  false, -- high_contrast
  CURRENT_TIMESTAMP,
  CURRENT_TIMESTAMP
) ON CONFLICT DO NOTHING;

-- التحقق من البيانات المدرجة
-- Verify inserted data
SELECT 
  id,
  organization_id,
  user_id,
  theme_name,
  primary_color,
  dark_mode,
  created_at
FROM theme_settings 
WHERE organization_id = 1
ORDER BY created_at DESC;
