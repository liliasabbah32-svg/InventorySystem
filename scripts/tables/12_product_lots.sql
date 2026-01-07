-- جدول اللوتات/الدفعات
CREATE TYPE lot_status AS ENUM ('active', 'reserved', 'expired', 'damaged', 'returned', 'quarantine');

CREATE TABLE IF NOT EXISTS product_lots (
    id SERIAL PRIMARY KEY,
    product_id INTEGER REFERENCES products(id) ON DELETE CASCADE,
    lot_number VARCHAR(100) NOT NULL,
    supplier_id INTEGER REFERENCES suppliers(id),
    purchase_order_id INTEGER,
    initial_quantity NUMERIC(15,2) NOT NULL,
    current_quantity NUMERIC(15,2) NOT NULL,
    available_quantity NUMERIC(15,2) NOT NULL,
    reserved_quantity NUMERIC(15,2) DEFAULT 0,
    unit_cost NUMERIC(15,2),
    manufacturing_date DATE,
    expiry_date DATE,
    status lot_status DEFAULT 'active',
    status_changed_by VARCHAR(255),
    status_changed_at TIMESTAMP WITH TIME ZONE,
    status_notes TEXT,
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(product_id, lot_number)
);

CREATE INDEX IF NOT EXISTS idx_product_lots_product ON product_lots(product_id);
CREATE INDEX IF NOT EXISTS idx_product_lots_lot_number ON product_lots(lot_number);
CREATE INDEX IF NOT EXISTS idx_product_lots_status ON product_lots(status);
CREATE INDEX IF NOT EXISTS idx_product_lots_expiry ON product_lots(expiry_date);
