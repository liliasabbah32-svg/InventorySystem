-- إصلاح مشكلة عدم تطابق أسماء الحقول بين API والمكونات
-- توحيد أسماء الحقول في قاعدة البيانات

-- تحديث جدول مجموعات الأصناف لاستخدام group_number بدلاً من group_code
ALTER TABLE item_groups 
RENAME COLUMN group_code TO group_number;

-- تحديث الفهارس
DROP INDEX IF EXISTS idx_item_groups_code;
CREATE INDEX idx_item_groups_number ON item_groups(group_number);

-- تحديث العرض (view) لاستخدام group_number
DROP VIEW IF EXISTS item_groups_with_count;
CREATE OR REPLACE VIEW item_groups_with_count AS
SELECT 
    ig.*,
    COALESCE(p.product_count, 0) as product_count
FROM item_groups ig
LEFT JOIN (
    SELECT 
        category as group_number,
        COUNT(*) as product_count
    FROM products 
    WHERE status = 'نشط'
    GROUP BY category
) p ON ig.group_number = p.group_number
ORDER BY ig.created_at DESC;

-- تحديث البيانات الموجودة لتتطابق مع التنسيق الجديد
UPDATE item_groups 
SET group_number = CASE 
    WHEN group_number LIKE 'ELEC%' THEN 'G0000001'
    WHEN group_number LIKE 'CLOTH%' THEN 'G0000002'
    WHEN group_number LIKE 'FOOD%' THEN 'G0000003'
    WHEN group_number LIKE 'BOOKS%' THEN 'G0000004'
    WHEN group_number LIKE 'FURN%' THEN 'G0000005'
    WHEN group_number LIKE 'TOOLS%' THEN 'G0000006'
    ELSE group_number
END
WHERE group_number LIKE '%001';
