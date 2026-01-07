-- جدول إعدادات الدفعات
CREATE TABLE IF NOT EXISTS batch_settings (
    id SERIAL PRIMARY KEY,
    document_type VARCHAR(50) NOT NULL,
    mandatory_batch_selection BOOLEAN DEFAULT false,
    auto_select_fifo BOOLEAN DEFAULT true,
    allow_negative_stock BOOLEAN DEFAULT false,
    require_expiry_date BOOLEAN DEFAULT false,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(document_type)
);
