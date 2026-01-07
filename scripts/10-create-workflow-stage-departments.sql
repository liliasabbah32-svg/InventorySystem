-- إنشاء جدول ربط المراحل بالأقسام
CREATE TABLE IF NOT EXISTS workflow_stage_departments (
    id SERIAL PRIMARY KEY,
    stage_id INTEGER NOT NULL,
    department_name VARCHAR(100) NOT NULL,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (stage_id) REFERENCES workflow_stages(id),
    UNIQUE(stage_id, department_name)
);

-- إدراج بيانات تجريبية لربط المراحل بالأقسام
INSERT INTO workflow_stage_departments (stage_id, department_name) VALUES
(1, 'المبيعات'),
(2, 'المحاسبة'),
(3, 'المستودعات'),
(4, 'الشحن'),
(5, 'المبيعات'),
(6, 'المشتريات'),
(7, 'المحاسبة'),
(8, 'المستودعات'),
(9, 'الاستلام'),
(10, 'المشتريات');

-- إنشاء فهرس للأداء
CREATE INDEX IF NOT EXISTS idx_workflow_stage_departments_active ON workflow_stage_departments(stage_id, is_active);
