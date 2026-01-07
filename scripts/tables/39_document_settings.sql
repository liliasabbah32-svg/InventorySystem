-- جدول إعدادات المستندات
CREATE TABLE IF NOT EXISTS document_settings (
    id SERIAL PRIMARY KEY,
    document_type VARCHAR(50) NOT NULL,
    field_name VARCHAR(100) NOT NULL,
    field_type VARCHAR(50) NOT NULL,
    display_name VARCHAR(255),
    default_value TEXT,
    is_required BOOLEAN DEFAULT false,
    show_in_screen BOOLEAN DEFAULT true,
    show_in_print BOOLEAN DEFAULT true,
    display_order INTEGER,
    validation_rules TEXT,
    mandatory_batch BOOLEAN DEFAULT false,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(document_type, field_name)
);

CREATE INDEX IF NOT EXISTS idx_document_settings_type ON document_settings(document_type);
