-- إدراج إعدادات المظهر الافتراضية للمؤسسة
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
  '#059669', -- primary_color (emerald)
  '#64748b', -- secondary_color (slate)
  '#10b981', -- accent_color (emerald light)
  '#ffffff', -- background_color
  '#1f2937', -- text_color
  'var(--font-geist-sans)', -- font_family
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
) ON CONFLICT (organization_id, COALESCE(user_id, '')) 
DO UPDATE SET
  theme_name = EXCLUDED.theme_name,
  primary_color = EXCLUDED.primary_color,
  secondary_color = EXCLUDED.secondary_color,
  accent_color = EXCLUDED.accent_color,
  background_color = EXCLUDED.background_color,
  text_color = EXCLUDED.text_color,
  font_family = EXCLUDED.font_family,
  font_size = EXCLUDED.font_size,
  font_weight = EXCLUDED.font_weight,
  line_height = EXCLUDED.line_height,
  letter_spacing = EXCLUDED.letter_spacing,
  border_radius = EXCLUDED.border_radius,
  sidebar_width = EXCLUDED.sidebar_width,
  header_height = EXCLUDED.header_height,
  dark_mode = EXCLUDED.dark_mode,
  rtl_support = EXCLUDED.rtl_support,
  card_style = EXCLUDED.card_style,
  button_style = EXCLUDED.button_style,
  animation_speed = EXCLUDED.animation_speed,
  compact_mode = EXCLUDED.compact_mode,
  high_contrast = EXCLUDED.high_contrast,
  updated_at = CURRENT_TIMESTAMP;

-- إدراج بعض الأنظمة الملونة الإضافية
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
) VALUES 
-- Blue theme
(1, 'system_blue', 'blue', '#0891b2', '#64748b', '#06b6d4', '#ffffff', '#1f2937', 'var(--font-geist-sans)', 14, 400, 1.5, 0.0, 8, 256, 64, false, true, 'elevated', 'rounded', 'normal', false, false, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
-- Purple theme  
(1, 'system_purple', 'purple', '#7c3aed', '#64748b', '#a855f7', '#ffffff', '#1f2937', 'var(--font-geist-sans)', 14, 400, 1.5, 0.0, 8, 256, 64, false, true, 'elevated', 'rounded', 'normal', false, false, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
-- Orange theme
(1, 'system_orange', 'orange', '#ea580c', '#64748b', '#f97316', '#ffffff', '#1f2937', 'var(--font-geist-sans)', 14, 400, 1.5, 0.0, 8, 256, 64, false, true, 'elevated', 'rounded', 'normal', false, false, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP)
ON CONFLICT (organization_id, COALESCE(user_id, '')) 
DO UPDATE SET
  theme_name = EXCLUDED.theme_name,
  primary_color = EXCLUDED.primary_color,
  secondary_color = EXCLUDED.secondary_color,
  accent_color = EXCLUDED.accent_color,
  updated_at = CURRENT_TIMESTAMP;

-- التحقق من البيانات المدرجة
SELECT 
  id,
  organization_id,
  user_id,
  theme_name,
  primary_color,
  accent_color,
  created_at
FROM theme_settings 
WHERE organization_id = 1
ORDER BY created_at DESC;
