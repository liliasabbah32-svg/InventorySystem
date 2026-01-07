-- Create table for Pervasive database connection settings
CREATE TABLE IF NOT EXISTS pervasive_settings (
  id SERIAL PRIMARY KEY,
  connection_name VARCHAR(255) NOT NULL UNIQUE,
  connection_type VARCHAR(50) NOT NULL DEFAULT 'odbc', -- 'odbc' or 'api'
  api_url VARCHAR(500),
  database_name VARCHAR(255) NOT NULL,
  username VARCHAR(255) NOT NULL,
  password_encrypted TEXT NOT NULL,
  odbc_driver VARCHAR(255) DEFAULT 'Pervasive ODBC Engine Interface',
  odbc_dsn VARCHAR(255),
  connection_string TEXT,
  is_active BOOLEAN DEFAULT true,
  is_default BOOLEAN DEFAULT false,
  timeout_seconds INTEGER DEFAULT 30,
  max_retries INTEGER DEFAULT 3,
  last_test_at TIMESTAMP,
  last_test_status VARCHAR(50),
  last_test_message TEXT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  created_by INTEGER,
  updated_by INTEGER
);

-- Create index for faster lookups
CREATE INDEX IF NOT EXISTS idx_pervasive_settings_active ON pervasive_settings(is_active);
CREATE INDEX IF NOT EXISTS idx_pervasive_settings_default ON pervasive_settings(is_default);

-- Insert default connection if none exists
INSERT INTO pervasive_settings (
  connection_name, 
  connection_type, 
  database_name, 
  username, 
  password_encrypted,
  is_default
) 
SELECT 
  'Default Connection',
  'odbc',
  'DEMODATA',
  'admin',
  '',
  true
WHERE NOT EXISTS (SELECT 1 FROM pervasive_settings);

COMMENT ON TABLE pervasive_settings IS 'Stores connection settings for Pervasive database integration';
COMMENT ON COLUMN pervasive_settings.connection_type IS 'Connection method: odbc or api';
COMMENT ON COLUMN pervasive_settings.password_encrypted IS 'Encrypted password using AES-256';
COMMENT ON COLUMN pervasive_settings.is_default IS 'Default connection to use when none specified';
