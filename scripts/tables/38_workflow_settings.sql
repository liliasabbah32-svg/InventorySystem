-- جدول إعدادات سير العمل
CREATE TABLE IF NOT EXISTS workflow_settings (
    id SERIAL PRIMARY KEY,
    workflow_system_mandatory BOOLEAN DEFAULT false,
    allow_skip_stages BOOLEAN DEFAULT false,
    require_approval_notes BOOLEAN DEFAULT true,
    require_rejection_reason BOOLEAN DEFAULT true,
    auto_assign_to_department BOOLEAN DEFAULT true,
    allow_parallel_processing BOOLEAN DEFAULT false,
    track_time_in_stages BOOLEAN DEFAULT true,
    send_notifications BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
