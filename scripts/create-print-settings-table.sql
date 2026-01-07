-- إنشاء جدول إعدادات الطباعة
CREATE TABLE IF NOT EXISTS print_settings (
    id SERIAL PRIMARY KEY,
    company_id INTEGER DEFAULT 1,
    
    -- إعدادات الطابعة الافتراضية
    default_printer VARCHAR(255),
    paper_size VARCHAR(50) DEFAULT 'A4',
    orientation VARCHAR(20) DEFAULT 'portrait',
    
    -- إعدادات الهوامش
    margin_top DECIMAL(5,2) DEFAULT 2.0,
    margin_bottom DECIMAL(5,2) DEFAULT 2.0,
    margin_left DECIMAL(5,2) DEFAULT 2.0,
    margin_right DECIMAL(5,2) DEFAULT 2.0,
    
    -- إعدادات الخط
    font_family VARCHAR(100) DEFAULT 'Arial',
    font_size INTEGER DEFAULT 12,
    
    -- إعدادات الرأس والتذييل
    show_header BOOLEAN DEFAULT true,
    show_footer BOOLEAN DEFAULT true,
    header_text TEXT,
    footer_text TEXT,
    
    -- إعدادات الشعار
    show_logo BOOLEAN DEFAULT true,
    logo_position VARCHAR(20) DEFAULT 'top-right',
    logo_size VARCHAR(20) DEFAULT 'medium',
    
    -- إعدادات الألوان
    use_colors BOOLEAN DEFAULT true,
    primary_color VARCHAR(7) DEFAULT '#000000',
    secondary_color VARCHAR(7) DEFAULT '#666666',
    
    -- إعدادات التقارير
    show_page_numbers BOOLEAN DEFAULT true,
    show_print_date BOOLEAN DEFAULT true,
    show_company_info BOOLEAN DEFAULT true,
    
    -- إعدادات الفواتير
    invoice_template VARCHAR(50) DEFAULT 'standard',
    show_payment_terms BOOLEAN DEFAULT true,
    show_bank_details BOOLEAN DEFAULT true,
    
    -- إعدادات أخرى
    auto_print BOOLEAN DEFAULT false,
    print_copies INTEGER DEFAULT 1,
    
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- إدراج إعدادات افتراضية
INSERT INTO print_settings (
    default_printer,
    paper_size,
    orientation,
    font_family,
    font_size,
    header_text,
    footer_text,
    primary_color,
    secondary_color
) VALUES (
    'Default Printer',
    'A4',
    'portrait',
    'Arial',
    12,
    'شركة إدارة المخزون والطلبيات',
    'جميع الحقوق محفوظة © 2024',
    '#000000',
    '#666666'
) ON CONFLICT DO NOTHING;
