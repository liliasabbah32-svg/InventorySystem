-- إنشاء جداول الإعدادات المفقودة

-- جدول إعدادات المستخدمين
CREATE TABLE IF NOT EXISTS user_settings (
    id SERIAL PRIMARY KEY,
    user_id VARCHAR(255) UNIQUE NOT NULL,
    username VARCHAR(255) NOT NULL,
    full_name VARCHAR(255) NOT NULL,
    email VARCHAR(255) NOT NULL,
    phone VARCHAR(50),
    role VARCHAR(100) NOT NULL,
    department VARCHAR(100) NOT NULL,
    language VARCHAR(10) DEFAULT 'ar',
    theme VARCHAR(20) DEFAULT 'light',
    notifications_enabled BOOLEAN DEFAULT true,
    email_notifications BOOLEAN DEFAULT true,
    is_active BOOLEAN DEFAULT true,
    last_login TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- جدول إعدادات الطباعة
CREATE TABLE IF NOT EXISTS print_settings (
    id SERIAL PRIMARY KEY,
    document_type VARCHAR(100) NOT NULL,
    printer_name VARCHAR(255),
    font_family VARCHAR(100) DEFAULT 'Arial',
    font_size INTEGER DEFAULT 12,
    paper_size VARCHAR(50) DEFAULT 'A4',
    orientation VARCHAR(20) DEFAULT 'portrait',
    show_logo BOOLEAN DEFAULT true,
    show_header BOOLEAN DEFAULT true,
    show_footer BOOLEAN DEFAULT true,
    show_barcode BOOLEAN DEFAULT false,
    show_qr BOOLEAN DEFAULT false,
    margin_top DECIMAL(5,2) DEFAULT 1.5,
    margin_bottom DECIMAL(5,2) DEFAULT 1.5,
    margin_left DECIMAL(5,2) DEFAULT 1.0,
    margin_right DECIMAL(5,2) DEFAULT 1.0,
    line_spacing DECIMAL(3,2) DEFAULT 1.0,
    copies INTEGER DEFAULT 1,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- جدول إعدادات التخصيص
CREATE TABLE IF NOT EXISTS theme_settings (
    id SERIAL PRIMARY KEY,
    user_id VARCHAR(255),
    color_scheme VARCHAR(50) DEFAULT 'emerald',
    primary_color VARCHAR(7) DEFAULT '#059669',
    accent_color VARCHAR(7) DEFAULT '#10b981',
    font_size INTEGER DEFAULT 14,
    font_family VARCHAR(100) DEFAULT 'var(--font-geist-sans)',
    border_radius INTEGER DEFAULT 8,
    shadows BOOLEAN DEFAULT true,
    animations BOOLEAN DEFAULT true,
    compact_mode BOOLEAN DEFAULT false,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- جدول إعدادات السندات
CREATE TABLE IF NOT EXISTS document_settings (
    id SERIAL PRIMARY KEY,
    document_type VARCHAR(100) NOT NULL,
    field_name VARCHAR(100) NOT NULL,
    display_name VARCHAR(100) NOT NULL,
    display_order INTEGER NOT NULL,
    show_in_screen BOOLEAN DEFAULT true,
    show_in_print BOOLEAN DEFAULT true,
    is_required BOOLEAN DEFAULT false,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(document_type, field_name)
);

-- إدراج البيانات الافتراضية لإعدادات السندات
INSERT INTO document_settings (document_type, field_name, display_name, display_order, show_in_screen, show_in_print) VALUES
('sales-order', 'sequence', 'م', 1, true, true),
('sales-order', 'barcode', 'الباركود', 2, true, false),
('sales-order', 'product', 'الصنف', 3, true, true),
('sales-order', 'unit', 'الوحدة', 4, true, true),
('sales-order', 'quantity', 'الكمية', 5, true, true),
('sales-order', 'price', 'السعر', 6, true, true),
('sales-order', 'total', 'المبلغ', 7, true, true),
('sales-order', 'warehouse', 'المستودع', 8, true, false),
('sales-order', 'notes', 'ملاحظات', 9, false, false);

-- إدراج إعدادات طباعة افتراضية
INSERT INTO print_settings (document_type, printer_name, font_family, font_size, paper_size) VALUES
('sales-order', 'default', 'Arial', 12, 'A4'),
('purchase-order', 'default', 'Arial', 12, 'A4'),
('invoice', 'default', 'Arial', 12, 'A4');

-- إدراج إعدادات تخصيص افتراضية
INSERT INTO theme_settings (user_id, color_scheme, primary_color, accent_color) VALUES
('default', 'emerald', '#059669', '#10b981');
