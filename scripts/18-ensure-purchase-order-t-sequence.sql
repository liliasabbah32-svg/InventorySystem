-- Ensure purchase order numbers start with T and follow sequential numbering
-- This script will update existing orders and set up proper sequencing

-- First, let's see what we have
SELECT 'Current Purchase Orders' as info, 
       COUNT(*) as total_orders,
       MIN(order_number) as min_number,
       MAX(order_number) as max_number
FROM purchase_orders 
WHERE order_number IS NOT NULL;

-- Update any existing purchase orders that don't start with T
UPDATE purchase_orders 
SET order_number = 'T' || LPAD(
    CASE 
        WHEN order_number ~ '^[0-9]+$' THEN order_number::text
        ELSE REGEXP_REPLACE(order_number, '[^0-9]', '', 'g')
    END, 7, '0'
)
WHERE order_number IS NOT NULL 
  AND order_number != '' 
  AND order_number NOT LIKE 'T%';

-- If there are no purchase orders yet, insert a dummy record to establish sequence
INSERT INTO purchase_orders (
    order_number, 
    order_date, 
    supplier_name, 
    total_amount,
    workflow_status,
    created_at
) 
SELECT 'T0000001', CURRENT_DATE, 'نظام البداية', 0, 'cancelled', NOW()
WHERE NOT EXISTS (SELECT 1 FROM purchase_orders WHERE order_number LIKE 'T%');

-- Clean up the dummy record if it was the only one
DELETE FROM purchase_orders 
WHERE order_number = 'T0000001' 
  AND supplier_name = 'نظام البداية' 
  AND total_amount = 0
  AND (SELECT COUNT(*) FROM purchase_orders WHERE order_number LIKE 'T%') > 1;

-- Verify the final result
SELECT 'Final Purchase Orders' as info,
       COUNT(*) as total_orders,
       MIN(order_number) as min_number,
       MAX(order_number) as max_number
FROM purchase_orders 
WHERE order_number LIKE 'T%';

-- Show sample of purchase order numbers
SELECT order_number, order_date, supplier_name, total_amount
FROM purchase_orders 
WHERE order_number LIKE 'T%'
ORDER BY order_number
LIMIT 10;
