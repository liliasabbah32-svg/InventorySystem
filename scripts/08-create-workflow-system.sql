-- إنشاء نظام إدارة المراحل والتسلسل
-- Workflow System Tables

-- جدول المراحل الأساسية
CREATE TABLE IF NOT EXISTS workflow_stages (
    id SERIAL PRIMARY KEY,
    stage_code VARCHAR(20) UNIQUE NOT NULL,
    stage_name VARCHAR(100) NOT NULL,
    stage_name_en VARCHAR(100),
    description TEXT,
    stage_type VARCHAR(20) DEFAULT 'normal', -- 'start', 'normal', 'end', 'conditional'
    stage_color VARCHAR(7) DEFAULT '#3B82F6', -- لون المرحلة في الواجهة
    icon_name VARCHAR(50) DEFAULT 'circle',
    is_active BOOLEAN DEFAULT true,
    requires_approval BOOLEAN DEFAULT false,
    max_duration_hours INTEGER, -- الحد الأقصى للبقاء في هذه المرحلة
    auto_advance BOOLEAN DEFAULT false, -- الانتقال التلقائي للمرحلة التالية
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- جدول تسلسل المراحل
CREATE TABLE IF NOT EXISTS workflow_sequences (
    id SERIAL PRIMARY KEY,
    sequence_name VARCHAR(100) NOT NULL,
    sequence_type VARCHAR(20) NOT NULL, -- 'sales_order', 'purchase_order', 'custom'
    description TEXT,
    is_default BOOLEAN DEFAULT false,
    is_active BOOLEAN DEFAULT true,
    created_by INTEGER,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- جدول خطوات التسلسل
CREATE TABLE IF NOT EXISTS workflow_sequence_steps (
    id SERIAL PRIMARY KEY,
    sequence_id INTEGER REFERENCES workflow_sequences(id) ON DELETE CASCADE,
    stage_id INTEGER REFERENCES workflow_stages(id),
    step_order INTEGER NOT NULL,
    is_optional BOOLEAN DEFAULT false,
    conditions TEXT, -- شروط JSON للانتقال
    next_stage_id INTEGER REFERENCES workflow_stages(id),
    alternative_stage_id INTEGER REFERENCES workflow_stages(id), -- مرحلة بديلة في حالة الرفض
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- جدول ربط الأقسام بالمراحل
CREATE TABLE IF NOT EXISTS department_stages (
    id SERIAL PRIMARY KEY,
    department_name VARCHAR(100) NOT NULL,
    stage_id INTEGER REFERENCES workflow_stages(id),
    is_default_stage BOOLEAN DEFAULT false, -- المرحلة الافتراضية للقسم
    can_initiate BOOLEAN DEFAULT false, -- يمكن للقسم بدء الطلبيات في هذه المرحلة
    can_approve BOOLEAN DEFAULT false, -- يمكن للقسم الموافقة على هذه المرحلة
    can_reject BOOLEAN DEFAULT false, -- يمكن للقسم رفض هذه المرحلة
    notification_enabled BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- جدول ربط الموظفين بالمراحل
CREATE TABLE IF NOT EXISTS employee_stages (
    id SERIAL PRIMARY KEY,
    user_id INTEGER NOT NULL,
    username VARCHAR(100) NOT NULL,
    stage_id INTEGER REFERENCES workflow_stages(id),
    department_name VARCHAR(100) NOT NULL,
    is_primary_responsible BOOLEAN DEFAULT false, -- المسؤول الأساسي
    can_approve BOOLEAN DEFAULT false,
    can_reject BOOLEAN DEFAULT false,
    can_reassign BOOLEAN DEFAULT false,
    notification_enabled BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- جدول حالة الطلبيات في التسلسل
CREATE TABLE IF NOT EXISTS order_workflow_status (
    id SERIAL PRIMARY KEY,
    order_id INTEGER NOT NULL,
    order_type VARCHAR(20) NOT NULL, -- 'sales', 'purchase'
    order_number VARCHAR(50) NOT NULL,
    sequence_id INTEGER REFERENCES workflow_sequences(id),
    current_stage_id INTEGER REFERENCES workflow_stages(id),
    current_step_order INTEGER DEFAULT 1,
    assigned_to_user INTEGER,
    assigned_to_department VARCHAR(100),
    stage_start_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    expected_completion_time TIMESTAMP,
    is_overdue BOOLEAN DEFAULT false,
    priority_level VARCHAR(20) DEFAULT 'normal', -- 'low', 'normal', 'high', 'urgent'
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- جدول سجل انتقال المراحل (محسن)
DROP TABLE IF EXISTS workflow_history;
CREATE TABLE workflow_history (
    id SERIAL PRIMARY KEY,
    order_id INTEGER NOT NULL,
    order_type VARCHAR(20) NOT NULL,
    order_number VARCHAR(50) NOT NULL,
    sequence_id INTEGER REFERENCES workflow_sequences(id),
    from_stage_id INTEGER REFERENCES workflow_stages(id),
    to_stage_id INTEGER REFERENCES workflow_stages(id),
    from_stage_name VARCHAR(100),
    to_stage_name VARCHAR(100),
    action_type VARCHAR(20) NOT NULL, -- 'advance', 'reject', 'return', 'reassign'
    performed_by_user INTEGER,
    performed_by_username VARCHAR(100),
    performed_by_department VARCHAR(100),
    duration_in_previous_stage INTERVAL,
    reason TEXT,
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- جدول إعدادات التنبيهات
CREATE TABLE IF NOT EXISTS workflow_notifications (
    id SERIAL PRIMARY KEY,
    stage_id INTEGER REFERENCES workflow_stages(id),
    notification_type VARCHAR(20) NOT NULL, -- 'arrival', 'overdue', 'completion', 'rejection'
    recipient_type VARCHAR(20) NOT NULL, -- 'assigned_user', 'department', 'manager', 'custom'
    recipient_identifier VARCHAR(100), -- user_id, department_name, or email
    notification_method VARCHAR(20) DEFAULT 'system', -- 'system', 'email', 'sms', 'whatsapp'
    message_template TEXT,
    delay_minutes INTEGER DEFAULT 0, -- تأخير الإشعار بالدقائق
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- إدراج المراحل الأساسية
INSERT INTO workflow_stages (stage_code, stage_name, stage_name_en, description, stage_type, stage_color, icon_name, requires_approval, max_duration_hours) VALUES
('NEW', 'طلبية جديدة', 'New Order', 'طلبية جديدة تم استلامها', 'start', '#10B981', 'plus-circle', false, 24),
('REVIEW', 'قيد المراجعة', 'Under Review', 'طلبية قيد المراجعة من قبل المختص', 'normal', '#F59E0B', 'eye', false, 48),
('APPROVED', 'معتمدة', 'Approved', 'طلبية معتمدة وجاهزة للتنفيذ', 'normal', '#3B82F6', 'check-circle', true, 12),
('IN_PROGRESS', 'قيد التنفيذ', 'In Progress', 'طلبية قيد التنفيذ', 'normal', '#8B5CF6', 'clock', false, 72),
('READY_SHIP', 'جاهزة للشحن', 'Ready to Ship', 'طلبية جاهزة للشحن', 'normal', '#06B6D4', 'truck', false, 24),
('SHIPPED', 'تم الشحن', 'Shipped', 'تم شحن الطلبية', 'normal', '#84CC16', 'send', false, 48),
('DELIVERED', 'تم التسليم', 'Delivered', 'تم تسليم الطلبية للعميل', 'end', '#22C55E', 'check-circle-2', false, null),
('REJECTED', 'مرفوضة', 'Rejected', 'طلبية مرفوضة', 'end', '#EF4444', 'x-circle', false, null),
('CANCELLED', 'ملغية', 'Cancelled', 'طلبية ملغية', 'end', '#6B7280', 'minus-circle', false, null),
('ON_HOLD', 'معلقة', 'On Hold', 'طلبية معلقة مؤقتاً', 'normal', '#F97316', 'pause-circle', false, null);

-- إنشاء تسلسل افتراضي لطلبيات المبيعات
INSERT INTO workflow_sequences (sequence_name, sequence_type, description, is_default, is_active) VALUES
('تسلسل طلبيات المبيعات الافتراضي', 'sales_order', 'التسلسل الافتراضي لمعالجة طلبيات المبيعات', true, true),
('تسلسل طلبيات الشراء الافتراضي', 'purchase_order', 'التسلسل الافتراضي لمعالجة طلبيات الشراء', true, true);

-- إنشاء خطوات التسلسل لطلبيات المبيعات
INSERT INTO workflow_sequence_steps (sequence_id, stage_id, step_order, next_stage_id, alternative_stage_id) VALUES
-- تسلسل طلبيات المبيعات
(1, (SELECT id FROM workflow_stages WHERE stage_code = 'NEW'), 1, (SELECT id FROM workflow_stages WHERE stage_code = 'REVIEW'), (SELECT id FROM workflow_stages WHERE stage_code = 'REJECTED')),
(1, (SELECT id FROM workflow_stages WHERE stage_code = 'REVIEW'), 2, (SELECT id FROM workflow_stages WHERE stage_code = 'APPROVED'), (SELECT id FROM workflow_stages WHERE stage_code = 'REJECTED')),
(1, (SELECT id FROM workflow_stages WHERE stage_code = 'APPROVED'), 3, (SELECT id FROM workflow_stages WHERE stage_code = 'IN_PROGRESS'), (SELECT id FROM workflow_stages WHERE stage_code = 'ON_HOLD')),
(1, (SELECT id FROM workflow_stages WHERE stage_code = 'IN_PROGRESS'), 4, (SELECT id FROM workflow_stages WHERE stage_code = 'READY_SHIP'), (SELECT id FROM workflow_stages WHERE stage_code = 'ON_HOLD')),
(1, (SELECT id FROM workflow_stages WHERE stage_code = 'READY_SHIP'), 5, (SELECT id FROM workflow_stages WHERE stage_code = 'SHIPPED'), null),
(1, (SELECT id FROM workflow_stages WHERE stage_code = 'SHIPPED'), 6, (SELECT id FROM workflow_stages WHERE stage_code = 'DELIVERED'), null),

-- تسلسل طلبيات الشراء
(2, (SELECT id FROM workflow_stages WHERE stage_code = 'NEW'), 1, (SELECT id FROM workflow_stages WHERE stage_code = 'REVIEW'), (SELECT id FROM workflow_stages WHERE stage_code = 'REJECTED')),
(2, (SELECT id FROM workflow_stages WHERE stage_code = 'REVIEW'), 2, (SELECT id FROM workflow_stages WHERE stage_code = 'APPROVED'), (SELECT id FROM workflow_stages WHERE stage_code = 'REJECTED')),
(2, (SELECT id FROM workflow_stages WHERE stage_code = 'APPROVED'), 3, (SELECT id FROM workflow_stages WHERE stage_code = 'IN_PROGRESS'), null),
(2, (SELECT id FROM workflow_stages WHERE stage_code = 'IN_PROGRESS'), 4, (SELECT id FROM workflow_stages WHERE stage_code = 'DELIVERED'), null);

-- ربط الأقسام بالمراحل
INSERT INTO department_stages (department_name, stage_id, is_default_stage, can_initiate, can_approve, can_reject, notification_enabled) VALUES
-- قسم المبيعات
('المبيعات', (SELECT id FROM workflow_stages WHERE stage_code = 'NEW'), true, true, false, false, true),
('المبيعات', (SELECT id FROM workflow_stages WHERE stage_code = 'REVIEW'), false, false, true, true, true),
('المبيعات', (SELECT id FROM workflow_stages WHERE stage_code = 'READY_SHIP'), false, false, true, false, true),

-- قسم المشتريات  
('المشتريات', (SELECT id FROM workflow_stages WHERE stage_code = 'NEW'), true, true, false, false, true),
('المشتريات', (SELECT id FROM workflow_stages WHERE stage_code = 'REVIEW'), false, false, true, true, true),

-- قسم المحاسبة
('المحاسبة', (SELECT id FROM workflow_stages WHERE stage_code = 'APPROVED'), true, false, true, true, true),

-- قسم المستودعات
('المستودعات', (SELECT id FROM workflow_stages WHERE stage_code = 'IN_PROGRESS'), true, false, true, false, true),
('المستودعات', (SELECT id FROM workflow_stages WHERE stage_code = 'READY_SHIP'), false, false, true, false, true),

-- الإدارة
('الإدارة', (SELECT id FROM workflow_stages WHERE stage_code = 'APPROVED'), false, false, true, true, true);

-- إعدادات التنبيهات الأساسية
INSERT INTO workflow_notifications (stage_id, notification_type, recipient_type, recipient_identifier, notification_method, message_template, delay_minutes) VALUES
-- تنبيهات وصول طلبيات جديدة
((SELECT id FROM workflow_stages WHERE stage_code = 'NEW'), 'arrival', 'department', 'المبيعات', 'system', 'وصلت طلبية جديدة رقم {order_number} تحتاج للمراجعة', 0),
((SELECT id FROM workflow_stages WHERE stage_code = 'REVIEW'), 'arrival', 'department', 'المبيعات', 'system', 'طلبية رقم {order_number} جاهزة للمراجعة', 0),
((SELECT id FROM workflow_stages WHERE stage_code = 'APPROVED'), 'arrival', 'department', 'المستودعات', 'system', 'طلبية رقم {order_number} معتمدة وجاهزة للتنفيذ', 0),

-- تنبيهات التأخير
((SELECT id FROM workflow_stages WHERE stage_code = 'REVIEW'), 'overdue', 'department', 'المبيعات', 'system', 'طلبية رقم {order_number} متأخرة في المراجعة', 60),
((SELECT id FROM workflow_stages WHERE stage_code = 'IN_PROGRESS'), 'overdue', 'department', 'المستودعات', 'system', 'طلبية رقم {order_number} متأخرة في التنفيذ', 120);

-- إنشاء الفهارس لتحسين الأداء
CREATE INDEX IF NOT EXISTS idx_workflow_sequences_type ON workflow_sequences(sequence_type);
CREATE INDEX IF NOT EXISTS idx_workflow_sequence_steps_sequence ON workflow_sequence_steps(sequence_id, step_order);
CREATE INDEX IF NOT EXISTS idx_department_stages_dept ON department_stages(department_name);
CREATE INDEX IF NOT EXISTS idx_employee_stages_user ON employee_stages(user_id, stage_id);
CREATE INDEX IF NOT EXISTS idx_order_workflow_status_order ON order_workflow_status(order_id, order_type);
CREATE INDEX IF NOT EXISTS idx_order_workflow_status_stage ON order_workflow_status(current_stage_id);
CREATE INDEX IF NOT EXISTS idx_workflow_history_order ON workflow_history(order_id, order_type);
CREATE INDEX IF NOT EXISTS idx_workflow_notifications_stage ON workflow_notifications(stage_id, notification_type);

-- إضافة حقول workflow للطلبيات الموجودة
ALTER TABLE sales_orders ADD COLUMN IF NOT EXISTS workflow_sequence_id INTEGER REFERENCES workflow_sequences(id);
ALTER TABLE purchase_orders ADD COLUMN IF NOT EXISTS workflow_sequence_id INTEGER REFERENCES workflow_sequences(id);

-- تحديث الطلبيات الموجودة لتستخدم التسلسل الافتراضي
UPDATE sales_orders SET workflow_sequence_id = 1 WHERE workflow_sequence_id IS NULL;
UPDATE purchase_orders SET workflow_sequence_id = 2 WHERE workflow_sequence_id IS NULL;
