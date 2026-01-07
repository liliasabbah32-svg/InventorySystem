-- Add missing fields to sales_orders table
ALTER TABLE sales_orders 
ADD COLUMN IF NOT EXISTS invoice_number VARCHAR(50),
ADD COLUMN IF NOT EXISTS barcode VARCHAR(100);

-- Add missing fields to sales_order_items table  
ALTER TABLE sales_order_items
ADD COLUMN IF NOT EXISTS item_status VARCHAR(50) DEFAULT 'متوفر',
ADD COLUMN IF NOT EXISTS barcode VARCHAR(100),
ADD COLUMN IF NOT EXISTS warehouse VARCHAR(100) DEFAULT 'المستودع الرئيسي',
ADD COLUMN IF NOT EXISTS bonus_quantity DECIMAL(10,3) DEFAULT 0,
ADD COLUMN IF NOT EXISTS unit VARCHAR(50) DEFAULT 'قطعة',
ADD COLUMN IF NOT EXISTS expiry_date DATE,
ADD COLUMN IF NOT EXISTS batch_number VARCHAR(100);

-- Add missing fields to purchase_order_items table
ALTER TABLE purchase_order_items
ADD COLUMN IF NOT EXISTS barcode VARCHAR(100),
ADD COLUMN IF NOT EXISTS warehouse VARCHAR(100) DEFAULT 'المستودع الرئيسي',
ADD COLUMN IF NOT EXISTS bonus_quantity DECIMAL(10,3) DEFAULT 0,
ADD COLUMN IF NOT EXISTS unit VARCHAR(50) DEFAULT 'قطعة',
ADD COLUMN IF NOT EXISTS expiry_date DATE,
ADD COLUMN IF NOT EXISTS batch_number VARCHAR(100);

-- Update sales_orders with sample data
INSERT INTO sales_orders (
    order_number, order_date, customer_id, customer_name, salesman, 
    total_amount, currency_code, currency_name, exchange_rate, 
    order_status, financial_status, delivery_datetime, notes
) VALUES 
('SO-2024-001', '2024-01-15', 1, 'شركة الأمل للتجارة', 'محمد أحمد', 
 15000.00, 'SAR', 'ريال سعودي', 1.0000, 
 'pending', 'unpaid', '2024-01-20 10:00:00', 'طلبية عاجلة'),
('SO-2024-002', '2024-01-16', 2, 'مؤسسة النور التجارية', 'علي حسن', 
 8500.00, 'USD', 'دولار أمريكي', 3.75, 
 'completed', 'paid', '2024-01-18 14:00:00', 'تم التسليم بنجاح')
ON CONFLICT (order_number) DO NOTHING;

-- Insert sample sales order items
INSERT INTO sales_order_items (
    sales_order_id, product_name, product_code, quantity, unit_price, 
    total_price, item_status, barcode, warehouse, bonus_quantity, 
    unit, expiry_date, batch_number
) VALUES 
(1, 'لابتوب ديل XPS 13', 'DELL-XPS13', 5, 3000.00, 15000.00, 
 'متوفر', '1234567890123', 'المستودع الرئيسي', 0, 'قطعة', '2025-12-31', 'BATCH001'),
(2, 'طابعة HP LaserJet', 'HP-LJ1020', 10, 850.00, 8500.00, 
 'متوفر', '9876543210987', 'المستودع الرئيسي', 1, 'قطعة', '2026-06-30', 'BATCH002')
ON CONFLICT DO NOTHING;

-- Update purchase_orders with sample data
INSERT INTO purchase_orders (
    order_number, order_date, supplier_id, supplier_name, salesman,
    total_amount, currency_code, currency_name, exchange_rate,
    workflow_status, expected_delivery_date, notes
) VALUES 
('PO-2024-001', '2024-01-10', 1, 'مصنع الجودة للمواد', 'خالد محمد',
 25000.00, 'SAR', 'ريال سعودي', 1.0000,
 'pending', '2024-01-25', 'طلبية مواد خام'),
('PO-2024-002', '2024-01-12', 2, 'شركة التميز للتوريد', 'أحمد علي',
 12000.00, 'USD', 'دولار أمريكي', 3.75,
 'received', '2024-01-20', 'تم الاستلام كاملاً')
ON CONFLICT (order_number) DO NOTHING;

-- Insert sample purchase order items
INSERT INTO purchase_order_items (
    purchase_order_id, product_name, product_code, quantity, unit_price,
    total_price, barcode, warehouse, bonus_quantity, unit, 
    expiry_date, batch_number
) VALUES 
(1, 'مواد خام - بلاستيك', 'RAW-PLASTIC', 100, 250.00, 25000.00,
 '5555666677778', 'مستودع المواد الخام', 5, 'كيلو', '2025-12-31', 'RAW001'),
(2, 'قطع غيار إلكترونية', 'ELEC-PARTS', 50, 240.00, 12000.00,
 '4444555566667', 'مستودع قطع الغيار', 2, 'قطعة', '2026-12-31', 'ELEC001')
ON CONFLICT DO NOTHING;
