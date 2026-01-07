-- جدول أسعار الصرف
CREATE TABLE IF NOT EXISTS exchange_rates (
    id SERIAL PRIMARY KEY,
    organization_id INTEGER,
    currency_code VARCHAR(10) NOT NULL,
    currency_name VARCHAR(50),
    exchange_rate NUMERIC(10,4) NOT NULL,
    buy_rate NUMERIC(10,4),
    sell_rate NUMERIC(10,4),
    last_updated TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX IF NOT EXISTS idx_exchange_rates_code ON exchange_rates(currency_code);
