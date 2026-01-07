-- Create customer users table
CREATE TABLE IF NOT EXISTS customer_users (
  id SERIAL PRIMARY KEY,
  customer_id INTEGER NOT NULL REFERENCES customers(id) ON DELETE CASCADE,
  username VARCHAR(100) UNIQUE NOT NULL,
  password_hash TEXT NOT NULL,
  email VARCHAR(255),
  is_active BOOLEAN DEFAULT true,
  last_login TIMESTAMP,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create customer permissions table
CREATE TABLE IF NOT EXISTS customer_permissions (
  id SERIAL PRIMARY KEY,
  customer_user_id INTEGER NOT NULL REFERENCES customer_users(id) ON DELETE CASCADE,
  can_view_orders BOOLEAN DEFAULT true,
  can_create_orders BOOLEAN DEFAULT true,
  can_view_balance BOOLEAN DEFAULT true,
  can_view_products BOOLEAN DEFAULT true,
  can_view_prices BOOLEAN DEFAULT true,
  can_view_stock BOOLEAN DEFAULT true,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  UNIQUE(customer_user_id)
);

-- Create customer sessions table
CREATE TABLE IF NOT EXISTS customer_sessions (
  id SERIAL PRIMARY KEY,
  customer_user_id INTEGER NOT NULL REFERENCES customer_users(id) ON DELETE CASCADE,
  session_token TEXT UNIQUE NOT NULL,
  expires_at TIMESTAMP NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create indexes for better performance
CREATE INDEX IF NOT EXISTS idx_customer_users_customer_id ON customer_users(customer_id);
CREATE INDEX IF NOT EXISTS idx_customer_users_username ON customer_users(username);
CREATE INDEX IF NOT EXISTS idx_customer_sessions_token ON customer_sessions(session_token);
CREATE INDEX IF NOT EXISTS idx_customer_sessions_user_id ON customer_sessions(customer_user_id);

-- Add trigger to update updated_at timestamp
CREATE OR REPLACE FUNCTION update_customer_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = CURRENT_TIMESTAMP;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_customer_users_updated_at
  BEFORE UPDATE ON customer_users
  FOR EACH ROW
  EXECUTE FUNCTION update_customer_updated_at();

CREATE TRIGGER update_customer_permissions_updated_at
  BEFORE UPDATE ON customer_permissions
  FOR EACH ROW
  EXECUTE FUNCTION update_customer_updated_at();
