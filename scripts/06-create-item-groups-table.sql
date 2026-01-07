-- Create item_groups table for product categorization
CREATE TABLE IF NOT EXISTS item_groups (
  id SERIAL PRIMARY KEY,
  group_number VARCHAR(20) UNIQUE NOT NULL,
  group_name VARCHAR(100) NOT NULL,
  description TEXT,
  status VARCHAR(20) DEFAULT 'نشط',
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create index for better performance
CREATE INDEX IF NOT EXISTS idx_item_groups_number ON item_groups(group_number);
CREATE INDEX IF NOT EXISTS idx_item_groups_name ON item_groups(group_name);

-- Insert some sample item groups
INSERT INTO item_groups (group_number, group_name, description, status) VALUES
('GRP001', 'الإلكترونيات', 'أجهزة إلكترونية ومعدات تقنية', 'نشط'),
('GRP002', 'الملابس والأزياء', 'ملابس رجالية ونسائية وأطفال', 'نشط'),
('GRP003', 'المواد الغذائية', 'أطعمة ومشروبات ومواد استهلاكية', 'نشط'),
('GRP004', 'الأثاث والديكور', 'أثاث منزلي ومكتبي وديكورات', 'نشط'),
('GRP005', 'الأدوات والمعدات', 'أدوات يدوية ومعدات صناعية', 'نشط')
ON CONFLICT (group_number) DO NOTHING;

-- Add a view to get product count for each group
CREATE OR REPLACE VIEW item_groups_with_count AS
SELECT 
  ig.*,
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
