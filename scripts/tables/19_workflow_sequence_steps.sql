-- جدول خطوات تسلسل سير العمل
CREATE TABLE IF NOT EXISTS workflow_sequence_steps (
    id SERIAL PRIMARY KEY,
    sequence_id INTEGER REFERENCES workflow_sequences(id) ON DELETE CASCADE,
    stage_id INTEGER REFERENCES workflow_stages(id),
    step_order INTEGER NOT NULL,
    next_stage_id INTEGER REFERENCES workflow_stages(id),
    alternative_stage_id INTEGER REFERENCES workflow_stages(id),
    is_optional BOOLEAN DEFAULT false,
    conditions TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_workflow_sequence_steps_sequence ON workflow_sequence_steps(sequence_id);
CREATE INDEX IF NOT EXISTS idx_workflow_sequence_steps_stage ON workflow_sequence_steps(stage_id);
CREATE INDEX IF NOT EXISTS idx_workflow_sequence_steps_order ON workflow_sequence_steps(step_order);
