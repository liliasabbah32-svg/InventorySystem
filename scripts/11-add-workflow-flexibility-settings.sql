-- إضافة إعدادات مرونة نظام المراحل
-- Adding Workflow Flexibility Settings

-- إضافة حقول المرونة لجدول المراحل
ALTER TABLE workflow_stages 
ADD COLUMN IF NOT EXISTS is_optional BOOLEAN DEFAULT false,
ADD COLUMN IF NOT EXISTS requires_previous_approval BOOLEAN DEFAULT false,
ADD COLUMN IF NOT EXISTS can_skip BOOLEAN DEFAULT false,
ADD COLUMN IF NOT EXISTS skip_conditions TEXT; -- شروط JSON لتخطي المرحلة

-- إضافة حقول المرونة لجدول خطوات التسلسل
ALTER TABLE workflow_sequence_steps 
ADD COLUMN IF NOT EXISTS can_skip BOOLEAN DEFAULT false,
ADD COLUMN IF NOT EXISTS skip_conditions TEXT,
ADD COLUMN IF NOT EXISTS requires_approval_from_previous BOOLEAN DEFAULT false;

-- إضافة إعدادات نظام المراحل للإعدادات العامة
INSERT INTO general_settings (setting_key, setting_value, setting_type, category, description, is_public) 
VALUES 
('workflow_system_mandatory', 'true', 'boolean', 'workflow', 'هل نظام المراحل إجباري أم اختياري', false),
('workflow_allow_skip_stages', 'false', 'boolean', 'workflow', 'السماح بتخطي المراحل الاختيارية', false),
('workflow_require_approval_notes', 'true', 'boolean', 'workflow', 'إجبار كتابة ملاحظات عند الموافقة', false),
('workflow_require_rejection_reason', 'true', 'boolean', 'workflow', 'إجبار كتابة سبب عند الرفض', false),
('workflow_auto_assign_to_department', 'true', 'boolean', 'workflow', 'تعيين تلقائي للأقسام المختصة', false),
('workflow_send_notifications', 'true', 'boolean', 'workflow', 'إرسال تنبيهات تلقائية', true),
('workflow_track_time_in_stages', 'true', 'boolean', 'workflow', 'تتبع الوقت المستغرق في كل مرحلة', false),
('workflow_allow_parallel_processing', 'false', 'boolean', 'workflow', 'السماح بالمعالجة المتوازية', false)
ON CONFLICT (setting_key) DO UPDATE SET 
    setting_value = EXCLUDED.setting_value,
    description = EXCLUDED.description,
    updated_at = CURRENT_TIMESTAMP;

-- تحديث المراحل الموجودة بالإعدادات الجديدة
UPDATE workflow_stages SET 
    is_optional = CASE 
        WHEN stage_code IN ('ON_HOLD', 'READY_SHIP') THEN true 
        ELSE false 
    END,
    requires_previous_approval = CASE 
        WHEN stage_code IN ('APPROVED', 'SHIPPED', 'DELIVERED') THEN true 
        ELSE false 
    END,
    can_skip = CASE 
        WHEN stage_code IN ('ON_HOLD', 'READY_SHIP') THEN true 
        ELSE false 
    END;

-- تحديث خطوات التسلسل بالإعدادات الجديدة
UPDATE workflow_sequence_steps SET 
    can_skip = CASE 
        WHEN stage_id IN (SELECT id FROM workflow_stages WHERE stage_code IN ('ON_HOLD', 'READY_SHIP')) THEN true 
        ELSE false 
    END,
    requires_approval_from_previous = CASE 
        WHEN stage_id IN (SELECT id FROM workflow_stages WHERE stage_code IN ('APPROVED', 'SHIPPED', 'DELIVERED')) THEN true 
        ELSE false 
    END;

-- إضافة جدول إعدادات المراحل المخصصة لكل شركة/مؤسسة
CREATE TABLE IF NOT EXISTS workflow_stage_settings (
    id SERIAL PRIMARY KEY,
    stage_id INTEGER REFERENCES workflow_stages(id) ON DELETE CASCADE,
    company_id INTEGER DEFAULT 1, -- للمؤسسات المتعددة
    is_enabled BOOLEAN DEFAULT true,
    is_optional BOOLEAN DEFAULT false,
    requires_approval BOOLEAN DEFAULT false,
    requires_previous_approval BOOLEAN DEFAULT false,
    can_skip BOOLEAN DEFAULT false,
    skip_conditions TEXT, -- شروط JSON
    max_duration_hours INTEGER,
    warning_hours INTEGER, -- تحذير قبل انتهاء المدة
    escalation_hours INTEGER, -- تصعيد بعد انتهاء المدة
    escalation_to_user INTEGER,
    escalation_to_department VARCHAR(100),
    custom_fields TEXT, -- حقول مخصصة JSON
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(stage_id, company_id)
);

-- إضافة جدول قواعد الانتقال المرن بين المراحل
CREATE TABLE IF NOT EXISTS workflow_transition_rules (
    id SERIAL PRIMARY KEY,
    from_stage_id INTEGER REFERENCES workflow_stages(id),
    to_stage_id INTEGER REFERENCES workflow_stages(id),
    sequence_id INTEGER REFERENCES workflow_sequences(id),
    rule_type VARCHAR(20) NOT NULL, -- 'automatic', 'conditional', 'manual', 'approval_required'
    conditions TEXT, -- شروط JSON للانتقال
    required_role VARCHAR(50), -- الدور المطلوب للموافقة
    required_department VARCHAR(100), -- القسم المطلوب للموافقة
    approval_count INTEGER DEFAULT 1, -- عدد الموافقات المطلوبة
    can_reject BOOLEAN DEFAULT true,
    rejection_returns_to_stage INTEGER REFERENCES workflow_stages(id),
    is_active BOOLEAN DEFAULT true,
    priority INTEGER DEFAULT 1, -- أولوية القاعدة
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- إدراج قواعد الانتقال الافتراضية
INSERT INTO workflow_transition_rules (from_stage_id, to_stage_id, sequence_id, rule_type, required_department, approval_count) VALUES
-- قواعد تسلسل المبيعات
((SELECT id FROM workflow_stages WHERE stage_code = 'NEW'), (SELECT id FROM workflow_stages WHERE stage_code = 'REVIEW'), 1, 'automatic', 'المبيعات', 1),
((SELECT id FROM workflow_stages WHERE stage_code = 'REVIEW'), (SELECT id FROM workflow_stages WHERE stage_code = 'APPROVED'), 1, 'approval_required', 'المبيعات', 1),
((SELECT id FROM workflow_stages WHERE stage_code = 'APPROVED'), (SELECT id FROM workflow_stages WHERE stage_code = 'IN_PROGRESS'), 1, 'approval_required', 'المحاسبة', 1),
((SELECT id FROM workflow_stages WHERE stage_code = 'IN_PROGRESS'), (SELECT id FROM workflow_stages WHERE stage_code = 'READY_SHIP'), 1, 'manual', 'المستودعات', 1),
((SELECT id FROM workflow_stages WHERE stage_code = 'READY_SHIP'), (SELECT id FROM workflow_stages WHERE stage_code = 'SHIPPED'), 1, 'manual', 'المستودعات', 1),
((SELECT id FROM workflow_stages WHERE stage_code = 'SHIPPED'), (SELECT id FROM workflow_stages WHERE stage_code = 'DELIVERED'), 1, 'automatic', null, 0);

-- إضافة جدول سجل قرارات المراحل
CREATE TABLE IF NOT EXISTS workflow_stage_decisions (
    id SERIAL PRIMARY KEY,
    order_id INTEGER NOT NULL,
    order_type VARCHAR(20) NOT NULL,
    stage_id INTEGER REFERENCES workflow_stages(id),
    decision_type VARCHAR(20) NOT NULL, -- 'approve', 'reject', 'skip', 'hold', 'escalate'
    decision_by_user INTEGER,
    decision_by_username VARCHAR(100),
    decision_by_department VARCHAR(100),
    decision_reason TEXT,
    decision_notes TEXT,
    previous_stage_id INTEGER REFERENCES workflow_stages(id),
    next_stage_id INTEGER REFERENCES workflow_stages(id),
    time_spent_minutes INTEGER,
    is_automatic BOOLEAN DEFAULT false,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- إنشاء الفهارس الجديدة
CREATE INDEX IF NOT EXISTS idx_workflow_stage_settings_stage ON workflow_stage_settings(stage_id, company_id);
CREATE INDEX IF NOT EXISTS idx_workflow_transition_rules_stages ON workflow_transition_rules(from_stage_id, to_stage_id);
CREATE INDEX IF NOT EXISTS idx_workflow_stage_decisions_order ON workflow_stage_decisions(order_id, order_type);
CREATE INDEX IF NOT EXISTS idx_workflow_stage_decisions_stage ON workflow_stage_decisions(stage_id, decision_type);

-- إضافة تعليقات للجداول الجديدة
COMMENT ON TABLE workflow_stage_settings IS 'إعدادات مخصصة لكل مرحلة حسب الشركة';
COMMENT ON TABLE workflow_transition_rules IS 'قواعد الانتقال المرن بين المراحل';
COMMENT ON TABLE workflow_stage_decisions IS 'سجل قرارات المراحل والموافقات';

COMMENT ON COLUMN workflow_stages.is_optional IS 'هل المرحلة اختيارية أم إجبارية';
COMMENT ON COLUMN workflow_stages.requires_previous_approval IS 'هل تتطلب موافقة من المرحلة السابقة';
COMMENT ON COLUMN workflow_stages.can_skip IS 'هل يمكن تخطي هذه المرحلة';
COMMENT ON COLUMN workflow_stages.skip_conditions IS 'شروط تخطي المرحلة (JSON)';
