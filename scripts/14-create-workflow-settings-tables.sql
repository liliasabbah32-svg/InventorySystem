-- إنشاء جدول إعدادات النظام العامة
CREATE TABLE IF NOT EXISTS workflow_settings (
    id INTEGER PRIMARY KEY DEFAULT 1,
    workflow_system_mandatory BOOLEAN DEFAULT true,
    allow_skip_stages BOOLEAN DEFAULT false,
    require_approval_notes BOOLEAN DEFAULT true,
    require_rejection_reason BOOLEAN DEFAULT true,
    auto_assign_to_department BOOLEAN DEFAULT true,
    send_notifications BOOLEAN DEFAULT true,
    track_time_in_stages BOOLEAN DEFAULT true,
    allow_parallel_processing BOOLEAN DEFAULT false,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- إنشاء جدول إعدادات مرونة المراحل
CREATE TABLE IF NOT EXISTS stage_flexibility_settings (
    id SERIAL PRIMARY KEY,
    stage_id INTEGER NOT NULL,
    is_optional BOOLEAN DEFAULT false,
    requires_approval BOOLEAN DEFAULT true,
    requires_previous_approval BOOLEAN DEFAULT true,
    can_skip BOOLEAN DEFAULT false,
    skip_conditions TEXT,
    max_duration_hours INTEGER,
    warning_hours INTEGER,
    escalation_hours INTEGER,
    escalation_to_department VARCHAR(100),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(stage_id)
);

-- إدراج الإعدادات الافتراضية
INSERT INTO workflow_settings (id) VALUES (1) ON CONFLICT (id) DO NOTHING;

-- إنشاء فهارس للأداء
CREATE INDEX IF NOT EXISTS idx_stage_flexibility_stage_id ON stage_flexibility_settings(stage_id);
