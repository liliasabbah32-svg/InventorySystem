# دليل تكامل الواتساب - نظام إدارة المخزون والطلبات

## نظرة عامة

نظام تكامل شامل مع واتساب يتيح للشركات التواصل مع عملائها، إرسال إشعارات تلقائية، واستقبال الطلبات والاستفسارات عبر الواتساب.

## المميزات الرئيسية

### 1. إرسال الرسائل
- إرسال رسائل نصية مباشرة
- استخدام القوالب الجاهزة
- دعم المتغيرات الديناميكية
- تتبع حالة التسليم والقراءة

### 2. إدارة القوالب
- إنشاء قوالب قابلة لإعادة الاستخدام
- تصنيف القوالب (تسويق، معاملات، إشعارات، دعم)
- دعم متعدد اللغات (عربي/إنجليزي)
- متغيرات ديناميكية

### 3. بوابة العملاء
- واجهة ويب للعملاء للتفاعل عبر الواتساب
- عرض المنتجات والأسعار
- إرسال طلبات الشراء
- تقديم الاستفسارات

### 4. الإشعارات التلقائية
- إشعارات الطلبات الجديدة
- تحديثات حالة الطلب
- تنبيهات المخزون المنخفض
- رسائل ترحيبية للعملاء الجدد

### 5. لوحة الإدارة
- عرض سجل جميع الرسائل
- إدارة القوالب
- متابعة استفسارات العملاء
- إحصائيات وتقارير

## البنية التقنية

### قاعدة البيانات

#### جدول `whatsapp_messages`
\`\`\`sql
- id: معرف فريد
- recipient_phone: رقم هاتف المستلم
- recipient_name: اسم المستلم (اختياري)
- message_type: نوع الرسالة (text, template, media)
- message_content: محتوى الرسالة
- template_id: معرف القالب (إن وجد)
- status: حالة الرسالة (sent, delivered, read, failed)
- sent_at: وقت الإرسال
- delivered_at: وقت التسليم
- read_at: وقت القراءة
- error_message: رسالة الخطأ (إن وجدت)
\`\`\`

#### جدول `whatsapp_templates`
\`\`\`sql
- id: معرف فريد
- template_name: اسم القالب
- template_code: كود القالب الفريد
- category: فئة القالب
- language: لغة القالب
- content: محتوى القالب
- variables: المتغيرات المستخدمة
- status: حالة القالب (active, inactive)
- created_at: تاريخ الإنشاء
\`\`\`

#### جدول `customer_inquiries`
\`\`\`sql
- id: معرف فريد
- customer_phone: رقم هاتف العميل
- customer_name: اسم العميل
- message: نص الاستفسار
- inquiry_type: نوع الاستفسار
- status: حالة الاستفسار (pending, resolved)
- assigned_to: المسؤول عن الاستفسار
- created_at: تاريخ الإنشاء
- resolved_at: تاريخ الحل
\`\`\`

### الواجهات البرمجية (API)

#### 1. إرسال رسالة
\`\`\`
POST /api/whatsapp/send
Body: {
  to: "966xxxxxxxxx",
  message: "نص الرسالة",
  template_code?: "welcome_customer",
  variables?: { customer_name: "أحمد" }
}
\`\`\`

#### 2. الحصول على الرسائل
\`\`\`
GET /api/whatsapp/messages
Query: ?status=sent&limit=50
\`\`\`

#### 3. إنشاء قالب
\`\`\`
POST /api/whatsapp/templates
Body: {
  template_name: "ترحيب بالعملاء",
  template_code: "welcome_customer",
  category: "marketing",
  language: "ar",
  content: "مرحباً {{customer_name}}..."
}
\`\`\`

#### 4. الحصول على القوالب
\`\`\`
GET /api/whatsapp/templates
Query: ?status=active
\`\`\`

#### 5. إنشاء استفسار
\`\`\`
POST /api/whatsapp/inquiries
Body: {
  customer_phone: "966xxxxxxxxx",
  customer_name: "أحمد",
  message: "استفسار عن المنتج",
  inquiry_type: "product_inquiry"
}
\`\`\`

#### 6. تحديث حالة استفسار
\`\`\`
PUT /api/whatsapp/inquiries
Body: {
  inquiry_id: 1,
  status: "resolved"
}
\`\`\`

#### 7. إرسال إشعار
\`\`\`
POST /api/whatsapp/notify
Body: {
  type: "order_created",
  data: {
    order_id: 123,
    customer_phone: "966xxxxxxxxx",
    customer_name: "أحمد",
    total_amount: 500
  }
}
\`\`\`

## الإعداد والتكوين

### 1. متغيرات البيئة المطلوبة

\`\`\`env
# معلومات الاتصال بواتساب
WHATSAPP_API_URL=https://api.whatsapp.com
WHATSAPP_API_TOKEN=your_api_token_here
WHATSAPP_PHONE_NUMBER_ID=your_phone_number_id

# قاعدة البيانات (Neon)
DATABASE_URL=your_database_url
\`\`\`

### 2. إنشاء الجداول

قم بتشغيل السكريبت التالي لإنشاء الجداول المطلوبة:

\`\`\`bash
# سيتم تشغيله تلقائياً من مجلد scripts
scripts/create-whatsapp-tables.sql
\`\`\`

### 3. إضافة القوالب الأساسية

\`\`\`sql
INSERT INTO whatsapp_templates (template_name, template_code, category, language, content, variables, status)
VALUES 
  ('ترحيب بالعملاء', 'welcome_customer', 'marketing', 'ar', 
   'مرحباً {{customer_name}}، نشكرك على انضمامك لعائلتنا!', 
   ARRAY['customer_name'], 'active'),
  
  ('تأكيد الطلب', 'order_confirmation', 'transactional', 'ar',
   'تم استلام طلبك رقم {{order_id}} بنجاح. المبلغ الإجمالي: {{total_amount}} ريال',
   ARRAY['order_id', 'total_amount'], 'active'),
  
  ('تحديث حالة الطلب', 'order_status_update', 'notification', 'ar',
   'طلبك رقم {{order_id}} الآن في حالة: {{status}}',
   ARRAY['order_id', 'status'], 'active');
\`\`\`

## أمثلة الاستخدام

### مثال 1: إرسال رسالة ترحيبية

\`\`\`typescript
const response = await fetch('/api/whatsapp/send', {
  method: 'POST',
  headers: { 'Content-Type': 'application/json' },
  body: JSON.stringify({
    to: '966501234567',
    template_code: 'welcome_customer',
    variables: {
      customer_name: 'أحمد محمد'
    }
  })
});
\`\`\`

### مثال 2: إرسال إشعار طلب جديد

\`\`\`typescript
const response = await fetch('/api/whatsapp/notify', {
  method: 'POST',
  headers: { 'Content-Type': 'application/json' },
  body: JSON.stringify({
    type: 'order_created',
    data: {
      order_id: 123,
      customer_phone: '966501234567',
      customer_name: 'أحمد محمد',
      total_amount: 500
    }
  })
});
\`\`\`

### مثال 3: استقبال استفسار من العميل

\`\`\`typescript
const response = await fetch('/api/whatsapp/inquiries', {
  method: 'POST',
  headers: { 'Content-Type': 'application/json' },
  body: JSON.stringify({
    customer_phone: '966501234567',
    customer_name: 'أحمد محمد',
    message: 'هل المنتج متوفر؟',
    inquiry_type: 'product_inquiry'
  })
});
\`\`\`

## الصفحات والمكونات

### 1. لوحة إدارة الواتساب
**المسار:** `/whatsapp`

**المميزات:**
- عرض إحصائيات الرسائل
- سجل جميع الرسائل المرسلة
- إدارة القوالب
- متابعة استفسارات العملاء
- إرسال رسائل جديدة

### 2. بوابة العملاء
**المسار:** `/customer-portal`

**المميزات:**
- عرض المنتجات المتاحة
- إرسال طلبات شراء
- تقديم استفسارات
- التواصل المباشر عبر الواتساب

## أفضل الممارسات

### 1. إدارة الرسائل
- استخدم القوالب للرسائل المتكررة
- تحقق من صحة أرقام الهواتف قبل الإرسال
- راقب حالة التسليم والقراءة
- احتفظ بسجل كامل للرسائل

### 2. القوالب
- استخدم أسماء واضحة للقوالب
- صنف القوالب حسب الغرض
- استخدم المتغيرات للمحتوى الديناميكي
- اختبر القوالب قبل الاستخدام

### 3. الإشعارات
- أرسل إشعارات في الأوقات المناسبة
- تجنب الإزعاج بكثرة الرسائل
- اجعل الرسائل واضحة ومختصرة
- وفر خيار إلغاء الاشتراك

### 4. الأمان
- احمِ مفاتيح API
- تحقق من صلاحيات المستخدمين
- سجل جميع العمليات
- راقب الاستخدام غير الطبيعي

## استكشاف الأخطاء

### مشكلة: فشل إرسال الرسالة

**الحلول:**
1. تحقق من صحة رقم الهاتف
2. تأكد من صحة مفتاح API
3. راجع رسالة الخطأ في `error_message`
4. تحقق من حالة الاتصال بالإنترنت

### مشكلة: القالب لا يعمل

**الحلول:**
1. تأكد من أن القالب في حالة `active`
2. تحقق من صحة المتغيرات المستخدمة
3. راجع صيغة القالب
4. تأكد من تطابق اللغة

### مشكلة: الاستفسارات لا تظهر

**الحلول:**
1. تحقق من الاتصال بقاعدة البيانات
2. راجع صلاحيات الجدول
3. تأكد من صحة البيانات المرسلة
4. راجع سجلات الأخطاء

## الدعم والمساعدة

للحصول على المساعدة:
1. راجع هذا الدليل أولاً
2. تحقق من سجلات الأخطاء
3. راجع وثائق واتساب API الرسمية
4. تواصل مع فريق الدعم الفني

## التحديثات المستقبلية

### قيد التطوير:
- دعم الرسائل الصوتية والمرئية
- روبوت محادثة ذكي (Chatbot)
- تكامل مع أنظمة CRM
- تقارير وتحليلات متقدمة
- دعم المحادثات الجماعية

---

**آخر تحديث:** 2025-01-03
**الإصدار:** 1.0.0
