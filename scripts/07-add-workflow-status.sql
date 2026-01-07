-- إضافة حقول الـ workflow للطلبيات
ALTER TABLE sales_orders ADD COLUMN IF NOT EXISTS workflow_status VARCHAR(50) DEFAULT 'pending';
ALTER TABLE purchase_orders ADD COLUMN IF NOT EXISTS workflow_status VARCHAR(50) DEFAULT 'pending';

-- تحديث الطلبيات الموجودة
UPDATE sales_orders SET workflow_status = 'pending' WHERE workflow_status IS NULL;
UPDATE purchase_orders SET workflow_status = 'pending' WHERE workflow_status IS NULL;

-- إنشاء جدول تتبع الـ workflow
CREATE TABLE IF NOT EXISTS workflow_history (
    id SERIAL PRIMARY KEY,
    order_type VARCHAR(20) NOT NULL, -- 'sales' or 'purchase'
    order_id INTEGER NOT NULL,
    order_number VARCHAR(20) NOT NULL,
    previous_status VARCHAR(50),
    new_status VARCHAR(50) NOT NULL,
    changed_by VARCHAR(100),
    change_reason TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
