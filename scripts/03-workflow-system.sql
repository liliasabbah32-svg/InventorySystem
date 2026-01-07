-- نظام إدارة مراحل الطلبيات
-- Workflow Management System

-- إنشاء جدول مراحل العمل
CREATE TABLE IF NOT EXISTS workflow_stages (
    id SERIAL PRIMARY KEY,
    stage_code VARCHAR(20) UNIQUE NOT NULL,
    stage_name VARCHAR(100) NOT NULL,
    description TEXT,
    stage_type VARCHAR(20) NOT NULL CHECK (stage_type IN ('sales', 'purchase', 'inventory')),
    is_initial BOOLEAN DEFAULT false,
    is_final BOOLEAN DEFAULT false,
    color_code VARCHAR(7) DEFAULT '#3b82f6',
    sort_order INTEGER DEFAULT 0,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- إنشاء جدول تسلسل المراحل
CREATE TABLE IF NOT EXISTS workflow_sequences (
    id SERIAL PRIMARY KEY,
    from_stage_id INTEGER NOT NULL REFERENCES workflow_stages(id),
    to_stage_id INTEGER NOT NULL REFERENCES workflow_stages(id),
    is_automatic BOOLEAN DEFAULT false,
    conditions JSONB,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(from_stage_id, to_stage_id)
);

-- إنشاء جدول حالة الطلبيات في المراحل
CREATE TABLE IF NOT EXISTS order_workflow_status (
    id SERIAL PRIMARY KEY,
    order_type VARCHAR(20) NOT NULL CHECK (order_type IN ('sales', 'purchase')),
    order_id INTEGER NOT NULL,
    current_stage_id INTEGER NOT NULL REFERENCES workflow_stages(id),
    entered_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_by INTEGER REFERENCES users(id),
    notes TEXT,
    UNIQUE(order_type, order_id)
);

-- إنشاء جدول تاريخ المراحل
CREATE TABLE IF NOT EXISTS workflow_history (
    id SERIAL PRIMARY KEY,
    order_type VARCHAR(20) NOT NULL CHECK (order_type IN ('sales', 'purchase')),
    order_id INTEGER NOT NULL,
    from_stage_id INTEGER REFERENCES workflow_stages(id),
    to_stage_id INTEGER NOT NULL REFERENCES workflow_stages(id),
    changed_by INTEGER REFERENCES users(id),
    changed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    notes TEXT,
    duration_minutes INTEGER
);

-- إدراج مراحل طلبيات المبيعات
INSERT INTO workflow_stages (stage_code, stage_name, description, stage_type, is_initial, is_final, color_code, sort_order) VALUES
('SALES_NEW', 'طلبية جديدة', 'طلبية مبيعات جديدة تم إنشاؤها', 'sales', true, false, '#6b7280', 1),
('SALES_CONFIRMED', 'مؤكدة', 'طلبية مؤكدة من العميل', 'sales', false, false, '#3b82f6', 2),
('SALES_PROCESSING', 'قيد التجهيز', 'جاري تجهيز الطلبية', 'sales', false, false, '#f59e0b', 3),
('SALES_READY', 'جاهزة للشحن', 'الطلبية جاهزة للشحن', 'sales', false, false, '#10b981', 4),
('SALES_SHIPPED', 'تم الشحن', 'تم شحن الطلبية', 'sales', false, false, '#8b5cf6', 5),
('SALES_DELIVERED', 'تم التسليم', 'تم تسليم الطلبية للعميل', 'sales', false, true, '#059669', 6),
('SALES_CANCELLED', 'ملغية', 'طلبية ملغية', 'sales', false, true, '#dc2626', 7)
ON CONFLICT (stage_code) DO NOTHING;

-- إدراج مراحل طلبيات الشراء
INSERT INTO workflow_stages (stage_code, stage_name, description, stage_type, is_initial, is_final, color_code, sort_order) VALUES
('PURCH_NEW', 'طلبية جديدة', 'طلبية شراء جديدة تم إنشاؤها', 'purchase', true, false, '#6b7280', 1),
('PURCH_APPROVED', 'معتمدة', 'طلبية معتمدة من الإدارة', 'purchase', false, false, '#3b82f6', 2),
('PURCH_SENT', 'مرسلة للمورد', 'تم إرسال الطلبية للمورد', 'purchase', false, false, '#f59e0b', 3),
('PURCH_CONFIRMED', 'مؤكدة من المورد', 'المورد أكد الطلبية', 'purchase', false, false, '#10b981', 4),
('PURCH_SHIPPED', 'تم الشحن', 'المورد شحن الطلبية', 'purchase', false, false, '#8b5cf6', 5),
('PURCH_RECEIVED', 'تم الاستلام', 'تم استلام الطلبية', 'purchase', false, true, '#059669', 6),
('PURCH_CANCELLED', 'ملغية', 'طلبية ملغية', 'purchase', false, true, '#dc2626', 7)
ON CONFLICT (stage_code) DO NOTHING;

-- إدراج تسلسل مراحل المبيعات
INSERT INTO workflow_sequences (from_stage_id, to_stage_id) VALUES
((SELECT id FROM workflow_stages WHERE stage_code = 'SALES_NEW'), (SELECT id FROM workflow_stages WHERE stage_code = 'SALES_CONFIRMED')),
((SELECT id FROM workflow_stages WHERE stage_code = 'SALES_CONFIRMED'), (SELECT id FROM workflow_stages WHERE stage_code = 'SALES_PROCESSING')),
((SELECT id FROM workflow_stages WHERE stage_code = 'SALES_PROCESSING'), (SELECT id FROM workflow_stages WHERE stage_code = 'SALES_READY')),
((SELECT id FROM workflow_stages WHERE stage_code = 'SALES_READY'), (SELECT id FROM workflow_stages WHERE stage_code = 'SALES_SHIPPED')),
((SELECT id FROM workflow_stages WHERE stage_code = 'SALES_SHIPPED'), (SELECT id FROM workflow_stages WHERE stage_code = 'SALES_DELIVERED')),
-- إمكانية الإلغاء من أي مرحلة
((SELECT id FROM workflow_stages WHERE stage_code = 'SALES_NEW'), (SELECT id FROM workflow_stages WHERE stage_code = 'SALES_CANCELLED')),
((SELECT id FROM workflow_stages WHERE stage_code = 'SALES_CONFIRMED'), (SELECT id FROM workflow_stages WHERE stage_code = 'SALES_CANCELLED')),
((SELECT id FROM workflow_stages WHERE stage_code = 'SALES_PROCESSING'), (SELECT id FROM workflow_stages WHERE stage_code = 'SALES_CANCELLED'))
ON CONFLICT (from_stage_id, to_stage_id) DO NOTHING;

-- إدراج تسلسل مراحل الشراء
INSERT INTO workflow_sequences (from_stage_id, to_stage_id) VALUES
((SELECT id FROM workflow_stages WHERE stage_code = 'PURCH_NEW'), (SELECT id FROM workflow_stages WHERE stage_code = 'PURCH_APPROVED')),
((SELECT id FROM workflow_stages WHERE stage_code = 'PURCH_APPROVED'), (SELECT id FROM workflow_stages WHERE stage_code = 'PURCH_SENT')),
((SELECT id FROM workflow_stages WHERE stage_code = 'PURCH_SENT'), (SELECT id FROM workflow_stages WHERE stage_code = 'PURCH_CONFIRMED')),
((SELECT id FROM workflow_stages WHERE stage_code = 'PURCH_CONFIRMED'), (SELECT id FROM workflow_stages WHERE stage_code = 'PURCH_SHIPPED')),
((SELECT id FROM workflow_stages WHERE stage_code = 'PURCH_SHIPPED'), (SELECT id FROM workflow_stages WHERE stage_code = 'PURCH_RECEIVED')),
-- إمكانية الإلغاء من أي مرحلة
((SELECT id FROM workflow_stages WHERE stage_code = 'PURCH_NEW'), (SELECT id FROM workflow_stages WHERE stage_code = 'PURCH_CANCELLED')),
((SELECT id FROM workflow_stages WHERE stage_code = 'PURCH_APPROVED'), (SELECT id FROM workflow_stages WHERE stage_code = 'PURCH_CANCELLED')),
((SELECT id FROM workflow_stages WHERE stage_code = 'PURCH_SENT'), (SELECT id FROM workflow_stages WHERE stage_code = 'PURCH_CANCELLED'))
ON CONFLICT (from_stage_id, to_stage_id) DO NOTHING;

-- إنشاء فهارس للأداء
CREATE INDEX IF NOT EXISTS idx_workflow_status_order ON order_workflow_status(order_type, order_id);
CREATE INDEX IF NOT EXISTS idx_workflow_history_order ON workflow_history(order_type, order_id);
CREATE INDEX IF NOT EXISTS idx_workflow_history_date ON workflow_history(changed_at);
