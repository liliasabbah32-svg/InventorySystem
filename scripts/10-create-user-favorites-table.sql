-- إنشاء جدول المفضلة للمستخدمين
CREATE TABLE IF NOT EXISTS user_favorites (
  id SERIAL PRIMARY KEY,
  user_id VARCHAR(255) NOT NULL,
  favorite_type VARCHAR(50) NOT NULL, -- 'screen' أو 'report' أو 'action'
  favorite_name VARCHAR(255) NOT NULL, -- اسم الشاشة أو التقرير
  favorite_title VARCHAR(255) NOT NULL, -- العنوان المعروض
  favorite_icon VARCHAR(50), -- اسم الأيقونة
  favorite_component VARCHAR(100) NOT NULL, -- اسم المكون للفتح
  favorite_color VARCHAR(50), -- لون الاختصار
  display_order INTEGER DEFAULT 0, -- ترتيب العرض
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  UNIQUE(user_id, favorite_component)
);

-- إنشاء فهرس للبحث السريع
CREATE INDEX IF NOT EXISTS idx_user_favorites_user_id ON user_favorites(user_id);
CREATE INDEX IF NOT EXISTS idx_user_favorites_display_order ON user_favorites(user_id, display_order);

-- إضافة بعض المفضلة الافتراضية للمستخدمين الحاليين
INSERT INTO user_favorites (user_id, favorite_type, favorite_name, favorite_title, favorite_icon, favorite_component, favorite_color, display_order)
SELECT 
  user_id,
  'screen',
  'sales-orders',
  'طلبيات المبيعات',
  'ShoppingCart',
  'sales-orders',
  'bg-blue-500',
  1
FROM user_settings
WHERE NOT EXISTS (
  SELECT 1 FROM user_favorites WHERE user_id = user_settings.user_id AND favorite_component = 'sales-orders'
)
ON CONFLICT (user_id, favorite_component) DO NOTHING;

INSERT INTO user_favorites (user_id, favorite_type, favorite_name, favorite_title, favorite_icon, favorite_component, favorite_color, display_order)
SELECT 
  user_id,
  'screen',
  'purchase-orders',
  'طلبيات المشتريات',
  'Truck',
  'purchase-orders',
  'bg-green-500',
  2
FROM user_settings
WHERE NOT EXISTS (
  SELECT 1 FROM user_favorites WHERE user_id = user_settings.user_id AND favorite_component = 'purchase-orders'
)
ON CONFLICT (user_id, favorite_component) DO NOTHING;

INSERT INTO user_favorites (user_id, favorite_type, favorite_name, favorite_title, favorite_icon, favorite_component, favorite_color, display_order)
SELECT 
  user_id,
  'screen',
  'products',
  'الأصناف',
  'Package',
  'products',
  'bg-purple-500',
  3
FROM user_settings
WHERE NOT EXISTS (
  SELECT 1 FROM user_favorites WHERE user_id = user_settings.user_id AND favorite_component = 'products'
)
ON CONFLICT (user_id, favorite_component) DO NOTHING;

INSERT INTO user_favorites (user_id, favorite_type, favorite_name, favorite_title, favorite_icon, favorite_component, favorite_color, display_order)
SELECT 
  user_id,
  'report',
  'order-reports',
  'تقارير الطلبيات',
  'BarChart3',
  'order-reports',
  'bg-orange-500',
  4
FROM user_settings
WHERE NOT EXISTS (
  SELECT 1 FROM user_favorites WHERE user_id = user_settings.user_id AND favorite_component = 'order-reports'
)
ON CONFLICT (user_id, favorite_component) DO NOTHING;
