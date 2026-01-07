-- إصلاح هيكل جدول مجموعات الأصناف وتوحيده
-- حذف الجدول الموجود وإعادة إنشاؤه بهيكل موحد

DROP TABLE IF EXISTS item_groups CASCADE;

-- إنشاء جدول مجموعات الأصناف بهيكل موحد
CREATE TABLE item_groups (
    id SERIAL PRIMARY KEY,
    group_code VARCHAR(50) UNIQUE NOT NULL,
    group_name VARCHAR(255) NOT NULL,
    description TEXT,
    parent_group_id INTEGER REFERENCES item_groups(id),
    is_active BOOLEAN DEFAULT true,
    organization_id INTEGER DEFAULT 1,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- إنشاء فهارس للبحث السريع
CREATE INDEX idx_item_groups_code ON item_groups(group_code);
CREATE INDEX idx_item_groups_name ON item_groups(group_name);
CREATE INDEX idx_item_groups_parent ON item_groups(parent_group_id);
CREATE INDEX idx_item_groups_active ON item_groups(is_active);

-- إدراج بيانات نموذجية
INSERT INTO item_groups (group_code, group_name, description, is_active) VALUES
('ELEC001', 'الإلكترونيات', 'مجموعة الأجهزة الإلكترونية والتقنية', true),
('CLOTH001', 'الملابس والأزياء', 'مجموعة الملابس الرجالية والنسائية', true),
('FOOD001', 'المواد الغذائية', 'مجموعة الأطعمة والمشروبات', true),
('BOOKS001', 'الكتب والمطبوعات', 'مجموعة الكتب والمجلات', true),
('FURN001', 'الأثاث والديكور', 'مجموعة الأثاث المنزلي والمكتبي', true),
('TOOLS001', 'الأدوات والمعدات', 'مجموعة الأدوات اليدوية والمعدات', true);

-- إنشاء view لحساب عدد المنتجات في كل مجموعة
CREATE OR REPLACE VIEW item_groups_with_count AS
SELECT 
    ig.*,
    COALESCE(p.product_count, 0) as product_count
FROM item_groups ig
LEFT JOIN (
    SELECT 
        category as group_code,
        COUNT(*) as product_count
    FROM products 
    WHERE status = 'نشط'
    GROUP BY category
) p ON ig.group_code = p.group_code
ORDER BY ig.created_at DESC;
