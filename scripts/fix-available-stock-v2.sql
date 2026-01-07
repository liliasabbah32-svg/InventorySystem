-- Fix available_stock calculation in product_stock table
-- This script ensures available_stock is calculated correctly

-- First, update existing records to have correct available_stock
UPDATE product_stock 
SET available_stock = GREATEST(0, COALESCE(current_stock, 0) - COALESCE(reserved_stock, 0))
WHERE available_stock IS NULL OR available_stock != GREATEST(0, COALESCE(current_stock, 0) - COALESCE(reserved_stock, 0));

-- Create or replace a trigger function to automatically calculate available_stock
CREATE OR REPLACE FUNCTION calculate_available_stock()
RETURNS TRIGGER AS $$
BEGIN
    -- Calculate available_stock as current_stock minus reserved_stock, minimum 0
    NEW.available_stock = GREATEST(0, COALESCE(NEW.current_stock, 0) - COALESCE(NEW.reserved_stock, 0));
    
    -- Set timestamps
    IF TG_OP = 'INSERT' THEN
        NEW.created_at = COALESCE(NEW.created_at, CURRENT_TIMESTAMP);
    END IF;
    
    NEW.updated_at = CURRENT_TIMESTAMP;
    NEW.last_updated = CURRENT_TIMESTAMP;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Drop existing trigger if it exists
DROP TRIGGER IF EXISTS trigger_calculate_available_stock ON product_stock;

-- Create trigger to automatically calculate available_stock on INSERT and UPDATE
CREATE TRIGGER trigger_calculate_available_stock
    BEFORE INSERT OR UPDATE ON product_stock
    FOR EACH ROW
    EXECUTE FUNCTION calculate_available_stock();

-- Verify the fix by checking a few records
SELECT 
    product_id,
    current_stock,
    reserved_stock,
    available_stock,
    GREATEST(0, COALESCE(current_stock, 0) - COALESCE(reserved_stock, 0)) as calculated_available
FROM product_stock 
LIMIT 5;
