-- إنشاء جداول الطلبيات المفقودة
CREATE TABLE IF NOT EXISTS sales_orders (
    id SERIAL PRIMARY KEY,
    order_number VARCHAR(50) UNIQUE NOT NULL,
    order_date DATE NOT NULL DEFAULT CURRENT_DATE,
    customer_id INTEGER,
    customer_name VARCHAR(255),
    financial_status VARCHAR(100),
    order_status VARCHAR(100) DEFAULT 'قيد المعالجة',
    manual_document VARCHAR(100),
    currency_name VARCHAR(50) DEFAULT 'ريال سعودي',
    currency_code VARCHAR(10) DEFAULT 'SAR',
    exchange_rate DECIMAL(10,4) DEFAULT 1.0000,
    salesman VARCHAR(255),
    delivery_datetime TIMESTAMP,
    total_amount DECIMAL(15,2) DEFAULT 0,
    notes TEXT,
    attachments TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS purchase_orders (
    id SERIAL PRIMARY KEY,
    order_number VARCHAR(50) UNIQUE NOT NULL,
    order_date DATE NOT NULL DEFAULT CURRENT_DATE,
    supplier_id INTEGER,
    supplier_name VARCHAR(255),
    manual_document VARCHAR(100),
    currency_name VARCHAR(50) DEFAULT 'ريال سعودي',
    currency_code VARCHAR(10) DEFAULT 'SAR',
    exchange_rate DECIMAL(10,4) DEFAULT 1.0000,
    salesman VARCHAR(255),
    expected_delivery_date DATE,
    total_amount DECIMAL(15,2) DEFAULT 0,
    notes TEXT,
    attachments TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- إدراج بيانات تجريبية للطلبيات
INSERT INTO sales_orders (order_number, customer_name, financial_status, order_status, salesman, total_amount) VALUES
('SO-2024-001', 'شركة الأمل التجارية', 'مدفوع', 'مكتمل', 'أحمد محمد', 15000.00),
('SO-2024-002', 'مؤسسة النور', 'غير مدفوع', 'قيد المعالجة', 'سارة أحمد', 8500.00),
('SO-2024-003', 'شركة الفجر', 'مدفوع جزئياً', 'قيد التسليم', 'محمد علي', 12300.00);

INSERT INTO purchase_orders (order_number, supplier_name, salesman, expected_delivery_date, total_amount) VALUES
('PO-2024-001', 'شركة التوريدات المتقدمة', 'أحمد محمد', '2024-12-25', 25000.00),
('PO-2024-002', 'مؤسسة الإمداد', 'سارة أحمد', '2024-12-30', 18500.00);
