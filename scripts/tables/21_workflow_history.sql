-- جدول تاريخ سير العمل
CREATE TABLE IF NOT EXISTS workflow_history (
    id SERIAL PRIMARY KEY,
    order_id INTEGER NOT NULL,
    order_number VARCHAR(100),
    order_type VARCHAR(50) NOT NULL,
    sequence_id INTEGER,
    from_stage_id INTEGER,
    from_stage_name VARCHAR(255),
    to_stage_id INTEGER,
    to_stage_name VARCHAR(255),
    action_type VARCHAR(50),
    performed_by_user INTEGER,
    performed_by_username VARCHAR(100),
    performed_by_department VARCHAR(100),
    duration_in_previous_stage INTERVAL,
    reason TEXT,
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_workflow_history_order ON workflow_history(order_id, order_type);
CREATE INDEX IF NOT EXISTS idx_workflow_history_stage ON workflow_history(from_stage_id, to_stage_id);
CREATE INDEX IF NOT EXISTS idx_workflow_history_user ON workflow_history(performed_by_user);
