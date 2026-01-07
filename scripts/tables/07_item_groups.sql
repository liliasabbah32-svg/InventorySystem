-- جدول مجموعات الأصناف
CREATE TABLE IF NOT EXISTS item_groups (
    id SERIAL PRIMARY KEY,
    group_number VARCHAR(50) UNIQUE,
    group_name VARCHAR(255) NOT NULL,
    description TEXT,
    parent_group_id INTEGER REFERENCES item_groups(id),
    organization_id INTEGER,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_item_groups_number ON item_groups(group_number);
CREATE INDEX IF NOT EXISTS idx_item_groups_name ON item_groups(group_name);
CREATE INDEX IF NOT EXISTS idx_item_groups_parent ON item_groups(parent_group_id);
