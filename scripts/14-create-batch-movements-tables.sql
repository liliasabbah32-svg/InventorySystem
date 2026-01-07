-- إنشاء جداول حركات الدفعات
-- Create batch movements tables

-- جدول حركات الدفعات (lot_transactions) - تم إنشاؤه مسبقاً لكن نتأكد من وجوده
CREATE TABLE IF NOT EXISTS lot_transactions (
    id SERIAL PRIMARY KEY,
    lot_id INTEGER NOT NULL REFERENCES lots(id) ON DELETE CASCADE,
    transaction_type VARCHAR(50) NOT NULL CHECK (transaction_type IN ('purchase', 'sale', 'adjustment', 'transfer', 'status_change', 'return')),
    quantity DECIMAL(15,3) DEFAULT 0,
    unit_price DECIMAL(15,2) DEFAULT 0,
    total_amount DECIMAL(15,2) DEFAULT 0,
    warehouse_id INTEGER REFERENCES warehouses(id),
    reference_number VARCHAR(100),
    notes TEXT,
    old_status VARCHAR(50),
    new_status VARCHAR(50),
    created_by INTEGER REFERENCES users(id),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- فهارس لتحسين الأداء
CREATE INDEX IF NOT EXISTS idx_lot_transactions_lot_id ON lot_transactions(lot_id);
CREATE INDEX IF NOT EXISTS idx_lot_transactions_type ON lot_transactions(transaction_type);
CREATE INDEX IF NOT EXISTS idx_lot_transactions_date ON lot_transactions(created_at);
CREATE INDEX IF NOT EXISTS idx_lot_transactions_warehouse ON lot_transactions(warehouse_id);

-- جدول تفاصيل حركات الدفعات (للحركات المعقدة)
CREATE TABLE IF NOT EXISTS lot_transaction_details (
    id SERIAL PRIMARY KEY,
    transaction_id INTEGER NOT NULL REFERENCES lot_transactions(id) ON DELETE CASCADE,
    detail_type VARCHAR(50) NOT NULL,
    detail_value TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- فهرس لتفاصيل الحركات
CREATE INDEX IF NOT EXISTS idx_lot_transaction_details_transaction ON lot_transaction_details(transaction_id);

-- جدول إعدادات حركات الدفعات
CREATE TABLE IF NOT EXISTS batch_movement_settings (
    id SERIAL PRIMARY KEY,
    user_id INTEGER REFERENCES users(id),
    setting_key VARCHAR(100) NOT NULL,
    setting_value TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(user_id, setting_key)
);

-- فهرس لإعدادات المستخدم
CREATE INDEX IF NOT EXISTS idx_batch_movement_settings_user ON batch_movement_settings(user_id);

-- إضافة بيانات تجريبية لحركات الدفعات
INSERT INTO lot_transactions (lot_id, transaction_type, quantity, unit_price, total_amount, warehouse_id, reference_number, notes, created_by, created_at)
SELECT 
    l.id,
    CASE 
        WHEN random() < 0.3 THEN 'purchase'
        WHEN random() < 0.6 THEN 'sale'
        WHEN random() < 0.8 THEN 'adjustment'
        ELSE 'transfer'
    END,
    ROUND((random() * 100 + 10)::numeric, 2),
    ROUND((random() * 50 + 5)::numeric, 2),
    ROUND((random() * 5000 + 50)::numeric, 2),
    (SELECT id FROM warehouses ORDER BY random() LIMIT 1),
    'REF-' || LPAD((random() * 9999)::int::text, 4, '0'),
    CASE 
        WHEN random() < 0.5 THEN 'حركة تلقائية للاختبار'
        ELSE 'تعديل مخزون'
    END,
    1,
    CURRENT_TIMESTAMP - (random() * interval '30 days')
FROM lots l
WHERE NOT EXISTS (
    SELECT 1 FROM lot_transactions WHERE lot_id = l.id
)
LIMIT 50;

-- إضافة إعدادات افتراضية لحركات الدفعات
INSERT INTO batch_movement_settings (user_id, setting_key, setting_value)
VALUES 
    (1, 'default_warehouse', '1'),
    (1, 'auto_calculate_totals', 'true'),
    (1, 'require_reference_number', 'false'),
    (1, 'default_transaction_type', 'adjustment')
ON CONFLICT (user_id, setting_key) DO NOTHING;

-- تحديث الطوابع الزمنية
CREATE OR REPLACE FUNCTION update_lot_transactions_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ language 'plpgsql';

-- إنشاء المشغل للتحديث التلقائي
DROP TRIGGER IF EXISTS update_lot_transactions_updated_at ON lot_transactions;
CREATE TRIGGER update_lot_transactions_updated_at
    BEFORE UPDATE ON lot_transactions
    FOR EACH ROW
    EXECUTE FUNCTION update_lot_transactions_updated_at();

-- إنشاء مشغل مماثل لإعدادات حركات الدفعات
DROP TRIGGER IF EXISTS update_batch_movement_settings_updated_at ON batch_movement_settings;
CREATE TRIGGER update_batch_movement_settings_updated_at
    BEFORE UPDATE ON batch_movement_settings
    FOR EACH ROW
    EXECUTE FUNCTION update_lot_transactions_updated_at();
