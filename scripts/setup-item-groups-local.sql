-- =====================================================
-- Script: Setup Item Groups Table and View (Local)
-- Description: Creates item_groups table and view for local development
-- =====================================================

-- Drop existing objects if they exist
DROP VIEW IF EXISTS item_groups_with_count CASCADE;
DROP TABLE IF EXISTS item_groups CASCADE;

-- Create item_groups table
CREATE TABLE item_groups (
  id SERIAL PRIMARY KEY,
  group_code VARCHAR(20) UNIQUE NOT NULL,
  group_name VARCHAR(100) NOT NULL,
  description TEXT,
  parent_group_id INTEGER REFERENCES item_groups(id) ON DELETE SET NULL,
  is_active BOOLEAN DEFAULT true,
  organization_id INTEGER DEFAULT 1,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create indexes for better performance
CREATE INDEX idx_item_groups_code ON item_groups(group_code);
CREATE INDEX idx_item_groups_name ON item_groups(group_name);
CREATE INDEX idx_item_groups_parent ON item_groups(parent_group_id);
CREATE INDEX idx_item_groups_active ON item_groups(is_active);

-- Create trigger to update updated_at automatically
CREATE OR REPLACE FUNCTION update_item_groups_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = CURRENT_TIMESTAMP;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_update_item_groups_updated_at
  BEFORE UPDATE ON item_groups
  FOR EACH ROW
  EXECUTE FUNCTION update_item_groups_updated_at();

-- Insert sample item groups
INSERT INTO item_groups (group_code, group_name, description, is_active) VALUES
('GRP001', 'الإلكترونيات', 'أجهزة إلكترونية ومعدات تقنية', true),
('GRP002', 'الملابس والأزياء', 'ملابس رجالية ونسائية وأطفال', true),
('GRP003', 'المواد الغذائية', 'أطعمة ومشروبات ومواد استهلاكية', true),
('GRP004', 'الأثاث والديكور', 'أثاث منزلي ومكتبي وديكورات', true),
('GRP005', 'الأدوات والمعدات', 'أدوات يدوية ومعدات صناعية', true),
('GRP006', 'مستلزمات طبية', 'أدوات ومعدات طبية وصحية', true),
('GRP007', 'مواد بناء', 'مواد ومعدات البناء والتشييد', true),
('GRP008', 'قطع غيار سيارات', 'قطع غيار ومستلزمات السيارات', true),
('GRP009', 'مستحضرات تجميل', 'منتجات العناية والتجميل', true),
('GRP010', 'كتب وقرطاسية', 'كتب ومستلزمات مكتبية', true)
ON CONFLICT (group_code) DO NOTHING;

-- Create view to get product count for each group
CREATE OR REPLACE VIEW item_groups_with_count AS
SELECT 
  ig.id,
  ig.group_code,
  ig.group_name,
  ig.description,
  ig.parent_group_id,
  ig.is_active,
  ig.organization_id,
  ig.created_at,
  ig.updated_at,
  COALESCE(p.product_count, 0) as product_count
FROM item_groups ig
LEFT JOIN (
  SELECT 
    category_id,
    COUNT(*) as product_count
  FROM products 
  WHERE status = 'نشط'
  GROUP BY category_id
) p ON ig.id = p.category_id
ORDER BY ig.created_at DESC;

-- Grant permissions (optional, adjust as needed)
-- GRANT SELECT, INSERT, UPDATE, DELETE ON item_groups TO your_user;
-- GRANT SELECT ON item_groups_with_count TO your_user;

-- Verify the setup
SELECT 'Item Groups Table Created Successfully' as status;
SELECT COUNT(*) as total_groups FROM item_groups;
SELECT * FROM item_groups_with_count LIMIT 5;
