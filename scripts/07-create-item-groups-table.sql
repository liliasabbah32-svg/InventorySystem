-- إنشاء جدول مجموعات الأصناف
CREATE TABLE IF NOT EXISTS item_groups (
    id SERIAL PRIMARY KEY,
    group_name VARCHAR(255) NOT NULL,
    group_code VARCHAR(50) UNIQUE NOT NULL,
    description TEXT,
    parent_group_id INTEGER REFERENCES item_groups(id),
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- إدراج بيانات نموذجية
INSERT INTO item_groups (group_name, group_code, description) VALUES
('الإلكترونيات', 'ELEC', 'مجموعة الأجهزة الإلكترونية'),
('الملابس', 'CLOTH', 'مجموعة الملابس والأزياء'),
('الأغذية', 'FOOD', 'مجموعة المواد الغذائية'),
('الكتب', 'BOOKS', 'مجموعة الكتب والمطبوعات'),
('الأثاث', 'FURN', 'مجموعة الأثاث والديكور');

-- إنشاء فهرس للبحث السريع
CREATE INDEX IF NOT EXISTS idx_item_groups_code ON item_groups(group_code);
CREATE INDEX IF NOT EXISTS idx_item_groups_parent ON item_groups(parent_group_id);
