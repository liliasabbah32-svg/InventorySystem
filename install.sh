#!/bin/bash

# سكريبت تثبيت نظام إدارة المخزون والطلبات
# Arabic ERP System Installation Script

echo "🚀 بدء تثبيت نظام إدارة المخزون والطلبات..."
echo "Starting Arabic ERP System installation..."

# التحقق من Node.js
if ! command -v node &> /dev/null; then
    echo "❌ Node.js غير مثبت. يرجى تثبيت Node.js 18+ أولاً"
    echo "❌ Node.js is not installed. Please install Node.js 18+ first"
    exit 1
fi

# التحقق من PostgreSQL
if ! command -v psql &> /dev/null; then
    echo "⚠️  PostgreSQL غير مثبت. سيتم تثبيته..."
    echo "⚠️  PostgreSQL is not installed. Installing..."
    
    # تثبيت PostgreSQL حسب نظام التشغيل
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        sudo apt update
        sudo apt install -y postgresql postgresql-contrib
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        brew install postgresql
    else
        echo "❌ يرجى تثبيت PostgreSQL يدوياً"
        echo "❌ Please install PostgreSQL manually"
        exit 1
    fi
fi

# تثبيت التبعيات
echo "📦 تثبيت التبعيات..."
echo "📦 Installing dependencies..."
npm install

# إنشاء قاعدة البيانات
echo "🗄️  إعداد قاعدة البيانات..."
echo "🗄️  Setting up database..."

# التحقق من وجود قاعدة البيانات
DB_EXISTS=$(psql -lqt | cut -d \| -f 1 | grep -qw inventory_system; echo $?)

if [ $DB_EXISTS -ne 0 ]; then
    echo "إنشاء قاعدة البيانات inventory_system..."
    echo "Creating inventory_system database..."
    createdb inventory_system
fi

# تشغيل سكريبت إنشاء الجداول
if [ -f "scripts/create-tables.sql" ]; then
    echo "إنشاء الجداول..."
    echo "Creating tables..."
    psql -d inventory_system -f scripts/create-tables.sql
else
    echo "⚠️  ملف إنشاء الجداول غير موجود"
    echo "⚠️  Create tables script not found"
fi

# إنشاء ملف البيئة إذا لم يكن موجوداً
if [ ! -f ".env.local" ]; then
    echo "📝 إنشاء ملف متغيرات البيئة..."
    echo "📝 Creating environment variables file..."
    
    cat > .env.local << EOL
# Database Configuration
DATABASE_URL="postgresql://postgres:password@localhost:5432/inventory_system"
POSTGRES_URL="postgresql://postgres:password@localhost:5432/inventory_system"
POSTGRES_PRISMA_URL="postgresql://postgres:password@localhost:5432/inventory_system"

# Encryption Key (يرجى تغيير هذا المفتاح)
ENCRYPTION_KEY="change-this-to-32-character-key"

# Stack Auth (اختياري)
# NEXT_PUBLIC_STACK_PROJECT_ID=""
# NEXT_PUBLIC_STACK_PUBLISHABLE_CLIENT_KEY=""
# STACK_SECRET_SERVER_KEY=""
EOL

    echo "⚠️  يرجى تحديث ملف .env.local بالقيم الصحيحة"
    echo "⚠️  Please update .env.local with correct values"
fi

echo ""
echo "✅ تم التثبيت بنجاح!"
echo "✅ Installation completed successfully!"
echo ""
echo "🚀 لتشغيل التطبيق:"
echo "🚀 To start the application:"
echo "   npm run dev"
echo ""
echo "🌐 ثم افتح المتصفح على:"
echo "🌐 Then open your browser at:"
echo "   http://localhost:3000"
echo ""
echo "📚 للمزيد من المعلومات، راجع ملف README.md"
echo "📚 For more information, check README.md"
