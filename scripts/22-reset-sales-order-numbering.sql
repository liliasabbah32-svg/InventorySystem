-- Reset sales order numbering to start from O0000001
-- This script will update existing sales orders to use the new format

-- First, let's see what we have
SELECT 'Current sales orders:' as info;
SELECT order_number, created_at FROM sales_orders ORDER BY created_at;

-- Update existing sales orders to use the new 7-digit format
-- This will renumber existing orders starting from O0000001
DO $$
DECLARE
    order_record RECORD;
    counter INTEGER := 1;
    new_order_number TEXT;
BEGIN
    -- Loop through all sales orders ordered by creation date
    FOR order_record IN 
        SELECT id, order_number, created_at 
        FROM sales_orders 
        ORDER BY created_at ASC
    LOOP
        -- Generate new order number with 7-digit padding
        new_order_number := 'O' || LPAD(counter::TEXT, 7, '0');
        
        -- Update the order with the new number
        UPDATE sales_orders 
        SET order_number = new_order_number 
        WHERE id = order_record.id;
        
        -- Also update any related order_items
        UPDATE order_items 
        SET order_number = new_order_number 
        WHERE order_type = 'sales' AND order_id = order_record.id;
        
        counter := counter + 1;
    END LOOP;
    
    RAISE NOTICE 'Updated % sales orders with new numbering format', counter - 1;
END $$;

-- Show the updated results
SELECT 'Updated sales orders:' as info;
SELECT order_number, created_at FROM sales_orders ORDER BY order_number;
