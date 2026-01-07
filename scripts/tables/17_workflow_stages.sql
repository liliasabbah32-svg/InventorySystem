-- جدول مراحل سير العمل
CREATE TABLE IF NOT EXISTS workflow_stages (
    id SERIAL PRIMARY KEY,
    stage_code VARCHAR(50) UNIQUE NOT NULL,
    stage_name VARCHAR(255) NOT NULL,
    stage_name_en VARCHAR(255),
    stage_type VARCHAR(50),
    description TEXT,
    stage_color VARCHAR(20),
    icon_name VARCHAR(50),
    requires_approval BOOLEAN DEFAULT false,
    auto_advance BOOLEAN DEFAULT false,
    max_duration_hours INTEGER,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_workflow_stages_code ON workflow_stages(stage_code);
CREATE INDEX IF NOT EXISTS idx_workflow_stages_type ON workflow_stages(stage_type);
