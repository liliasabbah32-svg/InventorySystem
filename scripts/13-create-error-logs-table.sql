-- إنشاء جدول سجلات الأخطاء
CREATE TABLE IF NOT EXISTS error_logs (
    id SERIAL PRIMARY KEY,
    error_id VARCHAR(36) UNIQUE NOT NULL,
    timestamp TIMESTAMP WITH TIME ZONE NOT NULL,
    level VARCHAR(10) NOT NULL CHECK (level IN ('error', 'warning', 'info')),
    message TEXT NOT NULL,
    stack TEXT,
    context JSONB,
    user_id VARCHAR(50),
    user_agent TEXT,
    url TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- إنشاء فهارس للبحث السريع
CREATE INDEX IF NOT EXISTS idx_error_logs_timestamp ON error_logs(timestamp DESC);
CREATE INDEX IF NOT EXISTS idx_error_logs_level ON error_logs(level);
CREATE INDEX IF NOT EXISTS idx_error_logs_user_id ON error_logs(user_id);
CREATE INDEX IF NOT EXISTS idx_error_logs_error_id ON error_logs(error_id);

-- إنشاء فهرس للبحث في السياق
CREATE INDEX IF NOT EXISTS idx_error_logs_context ON error_logs USING GIN(context);

COMMENT ON TABLE error_logs IS 'جدول سجلات الأخطاء والتحذيرات في النظام';
COMMENT ON COLUMN error_logs.error_id IS 'معرف فريد للخطأ';
COMMENT ON COLUMN error_logs.level IS 'مستوى الخطأ: error, warning, info';
COMMENT ON COLUMN error_logs.context IS 'سياق إضافي للخطأ في صيغة JSON';
