-- نسخة احتياطية من البيانات
-- تم إنشاؤها في: $(date)

-- تصدير بيانات العملاء
SELECT 'INSERT INTO customers VALUES' || string_agg(
    '(' || 
    COALESCE(id::text, 'NULL') || ',' ||
    COALESCE('''' || customer_code || '''', 'NULL') || ',' ||
    COALESCE('''' || replace(customer_name, '''', '''''') || '''', 'NULL') || ',' ||
    COALESCE('''' || email || '''', 'NULL') || ',' ||
    COALESCE('''' || mobile1 || '''', 'NULL') || ',' ||
    COALESCE('''' || mobile2 || '''', 'NULL') || ',' ||
    COALESCE('''' || whatsapp1 || '''', 'NULL') || ',' ||
    COALESCE('''' || whatsapp2 || '''', 'NULL') || ',' ||
    COALESCE('''' || replace(address, '''', '''''') || '''', 'NULL') || ',' ||
    COALESCE('''' || city || '''', 'NULL') || ',' ||
    COALESCE('''' || business_nature || '''', 'NULL') || ',' ||
    COALESCE('''' || classifications || '''', 'NULL') || ',' ||
    COALESCE('''' || status || '''', 'NULL') || ',' ||
    COALESCE('''' || salesman || '''', 'NULL') || ',' ||
    COALESCE('''' || account_opening_date || '''', 'NULL') || ',' ||
    COALESCE('''' || replace(general_notes, '''', '''''') || '''', 'NULL') || ',' ||
    COALESCE('''' || replace(movement_notes, '''', '''''') || '''', 'NULL') || ',' ||
    COALESCE('''' || api_number || '''', 'NULL') || ',' ||
    COALESCE('''' || attachments || '''', 'NULL') || ',' ||
    COALESCE('''' || created_at || '''', 'NULL') ||
    ')', 
    E',\n'
) || ';'
FROM customers;

-- تصدير بيانات الموردين  
SELECT 'INSERT INTO suppliers VALUES' || string_agg(
    '(' || 
    COALESCE(id::text, 'NULL') || ',' ||
    COALESCE('''' || supplier_code || '''', 'NULL') || ',' ||
    COALESCE('''' || replace(supplier_name, '''', '''''') || '''', 'NULL') || ',' ||
    COALESCE('''' || email || '''', 'NULL') || ',' ||
    COALESCE('''' || mobile1 || '''', 'NULL') || ',' ||
    COALESCE('''' || mobile2 || '''', 'NULL') || ',' ||
    COALESCE('''' || whatsapp1 || '''', 'NULL') || ',' ||
    COALESCE('''' || whatsapp2 || '''', 'NULL') || ',' ||
    COALESCE('''' || replace(address, '''', '''''') || '''', 'NULL') || ',' ||
    COALESCE('''' || city || '''', 'NULL') || ',' ||
    COALESCE('''' || business_nature || '''', 'NULL') || ',' ||
    COALESCE('''' || classifications || '''', 'NULL') || ',' ||
    COALESCE('''' || status || '''', 'NULL') || ',' ||
    COALESCE('''' || salesman || '''', 'NULL') || ',' ||
    COALESCE('''' || account_opening_date || '''', 'NULL') || ',' ||
    COALESCE('''' || replace(general_notes, '''', '''''') || '''', 'NULL') || ',' ||
    COALESCE('''' || replace(movement_notes, '''', '''''') || '''', 'NULL') || ',' ||
    COALESCE('''' || api_number || '''', 'NULL') || ',' ||
    COALESCE('''' || web_username || '''', 'NULL') || ',' ||
    COALESCE('''' || web_password || '''', 'NULL') || ',' ||
    COALESCE('''' || attachments || '''', 'NULL') || ',' ||
    COALESCE('''' || created_at || '''', 'NULL') ||
    ')', 
    E',\n'
) || ';'
FROM suppliers;

-- تصدير بيانات المنتجات
SELECT 'INSERT INTO products VALUES' || string_agg(
    '(' || 
    COALESCE(id::text, 'NULL') || ',' ||
    COALESCE('''' || product_code || '''', 'NULL') || ',' ||
    COALESCE('''' || replace(product_name, '''', '''''') || '''', 'NULL') || ',' ||
    COALESCE('''' || replace(description, '''', '''''') || '''', 'NULL') || ',' ||
    COALESCE('''' || barcode || '''', 'NULL') || ',' ||
    COALESCE('''' || category || '''', 'NULL') || ',' ||
    COALESCE('''' || product_type || '''', 'NULL') || ',' ||
    COALESCE('''' || main_unit || '''', 'NULL') || ',' ||
    COALESCE('''' || secondary_unit || '''', 'NULL') || ',' ||
    COALESCE(conversion_factor::text, 'NULL') || ',' ||
    COALESCE('''' || manufacturer_number || '''', 'NULL') || ',' ||
    COALESCE('''' || original_number || '''', 'NULL') || ',' ||
    COALESCE('''' || currency || '''', 'NULL') || ',' ||
    COALESCE(last_purchase_price::text, 'NULL') || ',' ||
    COALESCE(order_quantity::text, 'NULL') || ',' ||
    COALESCE(max_quantity::text, 'NULL') || ',' ||
    COALESCE(has_colors::text, 'NULL') || ',' ||
    COALESCE(has_batch::text, 'NULL') || ',' ||
    COALESCE(has_expiry::text, 'NULL') || ',' ||
    COALESCE('''' || status || '''', 'NULL') || ',' ||
    COALESCE('''' || classifications || '''', 'NULL') || ',' ||
    COALESCE('''' || replace(general_notes, '''', '''''') || '''', 'NULL') || ',' ||
    COALESCE('''' || product_image || '''', 'NULL') || ',' ||
    COALESCE('''' || attachments || '''', 'NULL') || ',' ||
    COALESCE('''' || entry_date || '''', 'NULL') || ',' ||
    COALESCE('''' || created_at || '''', 'NULL') ||
    ')', 
    E',\n'
) || ';'
FROM products;
