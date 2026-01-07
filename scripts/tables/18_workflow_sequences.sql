-- جدول تسلسلات سير العمل
CREATE TABLE IF NOT EXISTS workflow_sequences (
    id SERIAL PRIMARY KEY,
    sequence_name VARCHAR(255) NOT NULL,
    sequence_type VARCHAR(50) NOT NULL,
    description TEXT,
    is_default BOOLEAN DEFAULT false,
    is_active BOOLEAN DEFAULT true,
    created_by INTEGER,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_workflow_sequences_type ON workflow_sequences(sequence_type);
CREATE INDEX IF NOT EXISTS idx_workflow_sequences_default ON workflow_sequences(is_default);
