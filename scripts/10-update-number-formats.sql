-- Update existing data to match the 8-character format (PREFIX + 7 digits)
-- This ensures all existing records follow the O0000001 and C0000001 format

-- Update customer codes to 8-character format
UPDATE customers 
SET customer_code = 'C' || LPAD(REGEXP_REPLACE(customer_code, '[^0-9]', '', 'g'), 7, '0')
WHERE customer_code IS NOT NULL AND customer_code != '';

-- Update sales order numbers to 8-character format  
UPDATE sales_orders 
SET order_number = 'O' || LPAD(REGEXP_REPLACE(order_number, '[^0-9]', '', 'g'), 7, '0')
WHERE order_number IS NOT NULL AND order_number != '' AND order_number NOT LIKE 'O%';

-- Update supplier codes to 8-character format
UPDATE suppliers 
SET supplier_code = 'S' || LPAD(REGEXP_REPLACE(supplier_code, '[^0-9]', '', 'g'), 7, '0')
WHERE supplier_code IS NOT NULL AND supplier_code != '';

-- Update purchase order numbers to 8-character format
UPDATE purchase_orders 
SET order_number = 'T' || LPAD(REGEXP_REPLACE(order_number, '[^0-9]', '', 'g'), 7, '0')
WHERE order_number IS NOT NULL AND order_number != '' AND order_number NOT LIKE 'T%';

-- Verify the updates
SELECT 'Customers' as table_name, COUNT(*) as count, 
       MIN(customer_code) as min_code, MAX(customer_code) as max_code
FROM customers WHERE customer_code IS NOT NULL
UNION ALL
SELECT 'Sales Orders' as table_name, COUNT(*) as count,
       MIN(order_number) as min_code, MAX(order_number) as max_code  
FROM sales_orders WHERE order_number IS NOT NULL
UNION ALL
SELECT 'Suppliers' as table_name, COUNT(*) as count,
       MIN(supplier_code) as min_code, MAX(supplier_code) as max_code
FROM suppliers WHERE supplier_code IS NOT NULL
UNION ALL
SELECT 'Purchase Orders' as table_name, COUNT(*) as count,
       MIN(order_number) as min_code, MAX(order_number) as max_code
FROM purchase_orders WHERE order_number IS NOT NULL;
