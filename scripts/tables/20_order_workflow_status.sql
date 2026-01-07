-- جدول حالة سير العمل للطلبيات
CREATE TABLE IF NOT EXISTS order_workflow_status (
    id SERIAL PRIMARY KEY,
    order_id INTEGER NOT NULL,
    order_number VARCHAR(100),
    order_type VARCHAR(50) NOT NULL,
    sequence_id INTEGER REFERENCES workflow_sequences(id),
    current_stage_id INTEGER REFERENCES workflow_stages(id),
    current_step_order INTEGER,
    assigned_to_user INTEGER,
    assigned_to_department VARCHAR(100),
    priority_level VARCHAR(20) DEFAULT 'normal',
    stage_start_time TIMESTAMP,
    expected_completion_time TIMESTAMP,
    is_overdue BOOLEAN DEFAULT false,
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_order_workflow_order ON order_workflow_status(order_id, order_type);
CREATE INDEX IF NOT EXISTS idx_order_workflow_stage ON order_workflow_status(current_stage_id);
CREATE INDEX IF NOT EXISTS idx_order_workflow_assigned ON order_workflow_status(assigned_to_user);
