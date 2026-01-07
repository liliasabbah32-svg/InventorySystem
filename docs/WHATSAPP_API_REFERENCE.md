# مرجع واجهات برمجة الواتساب (API Reference)

## نظرة عامة

هذا المستند يوفر مرجعاً شاملاً لجميع واجهات برمجة الواتساب المتاحة في النظام.

---

## 1. إرسال رسالة

### `POST /api/whatsapp/send`

إرسال رسالة واتساب إلى رقم محدد.

#### المعاملات (Request Body)

\`\`\`typescript
{
  to: string              // رقم الهاتف بصيغة دولية (مثال: 966501234567)
  message: string         // نص الرسالة
  template_code?: string  // كود القالب (اختياري)
  variables?: Record<string, string>  // متغيرات القالب (اختياري)
}
\`\`\`

#### مثال الطلب

\`\`\`typescript
const response = await fetch('/api/whatsapp/send', {
  method: 'POST',
  headers: { 'Content-Type': 'application/json' },
  body: JSON.stringify({
    to: '966501234567',
    message: 'مرحباً بك في نظامنا',
    template_code: 'welcome_customer',
    variables: {
      customer_name: 'أحمد محمد'
    }
  })
})
\`\`\`

#### الاستجابة الناجحة (200)

\`\`\`json
{
  "success": true,
  "message_id": 123,
  "status": "sent"
}
\`\`\`

#### الأخطاء المحتملة

- `400`: بيانات غير صحيحة
- `404`: القالب غير موجود
- `500`: خطأ في الخادم

---

## 2. الحصول على الرسائل

### `GET /api/whatsapp/messages`

الحصول على قائمة الرسائل المرسلة.

#### المعاملات (Query Parameters)

\`\`\`typescript
{
  status?: string   // فلترة حسب الحالة (sent, delivered, read, failed)
  limit?: number    // عدد النتائج (افتراضي: 50)
  offset?: number   // تخطي عدد من النتائج (افتراضي: 0)
  phone?: string    // فلترة حسب رقم الهاتف
}
\`\`\`

#### مثال الطلب

\`\`\`typescript
const response = await fetch('/api/whatsapp/messages?status=delivered&limit=20')
const messages = await response.json()
\`\`\`

#### الاستجابة الناجحة (200)

\`\`\`json
[
  {
    "id": 123,
    "recipient_phone": "966501234567",
    "recipient_name": "أحمد محمد",
    "message_type": "text",
    "message_content": "مرحباً بك",
    "status": "delivered",
    "sent_at": "2025-01-03T10:30:00Z",
    "delivered_at": "2025-01-03T10:30:05Z"
  }
]
\`\`\`

---

## 3. إنشاء قالب

### `POST /api/whatsapp/templates`

إنشاء قالب رسالة جديد.

#### المعاملات (Request Body)

\`\`\`typescript
{
  template_name: string    // اسم القالب
  template_code: string    // كود فريد للقالب
  category: string         // الفئة (marketing, transactional, notification, support)
  language: string         // اللغة (ar, en)
  content: string          // محتوى القالب
}
\`\`\`

#### مثال الطلب

\`\`\`typescript
const response = await fetch('/api/whatsapp/templates', {
  method: 'POST',
  headers: { 'Content-Type': 'application/json' },
  body: JSON.stringify({
    template_name: 'ترحيب بالعملاء',
    template_code: 'welcome_customer',
    category: 'marketing',
    language: 'ar',
    content: 'مرحباً {{customer_name}}، نشكرك على انضمامك!'
  })
})
\`\`\`

#### الاستجابة الناجحة (201)

\`\`\`json
{
  "success": true,
  "template_id": 456,
  "template_code": "welcome_customer"
}
\`\`\`

---

## 4. الحصول على القوالب

### `GET /api/whatsapp/templates`

الحصول على قائمة القوالب المتاحة.

#### المعاملات (Query Parameters)

\`\`\`typescript
{
  status?: string     // فلترة حسب الحالة (active, inactive)
  category?: string   // فلترة حسب الفئة
  language?: string   // فلترة حسب اللغة
}
\`\`\`

#### مثال الطلب

\`\`\`typescript
const response = await fetch('/api/whatsapp/templates?status=active&language=ar')
const templates = await response.json()
\`\`\`

#### الاستجابة الناجحة (200)

\`\`\`json
[
  {
    "id": 456,
    "template_name": "ترحيب بالعملاء",
    "template_code": "welcome_customer",
    "category": "marketing",
    "language": "ar",
    "content": "مرحباً {{customer_name}}، نشكرك على انضمامك!",
    "variables": ["customer_name"],
    "status": "active",
    "created_at": "2025-01-01T00:00:00Z"
  }
]
\`\`\`

---

## 5. إنشاء استفسار

### `POST /api/whatsapp/inquiries`

إنشاء استفسار جديد من العميل.

#### المعاملات (Request Body)

\`\`\`typescript
{
  customer_phone: string   // رقم هاتف العميل
  customer_name: string    // اسم العميل
  message: string          // نص الاستفسار
  inquiry_type: string     // نوع الاستفسار
}
\`\`\`

#### مثال الطلب

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
})
\`\`\`

#### الاستجابة الناجحة (201)

\`\`\`json
{
  "success": true,
  "inquiry_id": 789,
  "status": "pending"
}
\`\`\`

---

## 6. تحديث حالة استفسار

### `PUT /api/whatsapp/inquiries`

تحديث حالة استفسار موجود.

#### المعاملات (Request Body)

\`\`\`typescript
{
  inquiry_id: number   // معرف الاستفسار
  status: string       // الحالة الجديدة (pending, resolved)
}
\`\`\`

#### مثال الطلب

\`\`\`typescript
const response = await fetch('/api/whatsapp/inquiries', {
  method: 'PUT',
  headers: { 'Content-Type': 'application/json' },
  body: JSON.stringify({
    inquiry_id: 789,
    status: 'resolved'
  })
})
\`\`\`

#### الاستجابة الناجحة (200)

\`\`\`json
{
  "success": true,
  "inquiry_id": 789,
  "status": "resolved"
}
\`\`\`

---

## 7. إرسال إشعار

### `POST /api/whatsapp/notify`

إرسال إشعار تلقائي بناءً على حدث معين.

#### المعاملات (Request Body)

\`\`\`typescript
{
  type: string   // نوع الإشعار
  data: object   // بيانات الإشعار
}
\`\`\`

#### أنواع الإشعارات المدعومة

##### 1. طلب جديد (`order_created`)

\`\`\`typescript
{
  type: 'order_created',
  data: {
    order_id: number
    customer_phone: string
    customer_name: string
    total_amount: number
  }
}
\`\`\`

##### 2. تحديث حالة الطلب (`order_status_updated`)

\`\`\`typescript
{
  type: 'order_status_updated',
  data: {
    order_id: number
    customer_phone: string
    status: string
  }
}
\`\`\`

##### 3. مخزون منخفض (`low_stock_alert`)

\`\`\`typescript
{
  type: 'low_stock_alert',
  data: {
    product_name: string
    current_quantity: number
    admin_phone: string
  }
}
\`\`\`

#### مثال الطلب

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
})
\`\`\`

#### الاستجابة الناجحة (200)

\`\`\`json
{
  "success": true,
  "notification_sent": true,
  "message_id": 999
}
\`\`\`

---

## رموز الأخطاء

| الكود | الوصف | الحل |
|------|-------|------|
| 400 | بيانات غير صحيحة | تحقق من صحة البيانات المرسلة |
| 401 | غير مصرح | تحقق من صلاحيات الوصول |
| 404 | غير موجود | تأكد من وجود المورد المطلوب |
| 429 | طلبات كثيرة | انتظر قبل إرسال طلبات جديدة |
| 500 | خطأ في الخادم | تواصل مع الدعم الفني |

---

## معدلات الاستخدام (Rate Limits)

- **إرسال الرسائل**: 100 رسالة/دقيقة
- **القراءة**: 1000 طلب/دقيقة
- **الكتابة**: 200 طلب/دقيقة

---

## أمثلة متقدمة

### إرسال رسائل جماعية

\`\`\`typescript
const phones = ['966501234567', '966507654321', '966509876543']

const results = await Promise.all(
  phones.map(phone =>
    fetch('/api/whatsapp/send', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        to: phone,
        template_code: 'promotion',
        variables: { discount: '20%' }
      })
    })
  )
)
\`\`\`

### معالجة الأخطاء

\`\`\`typescript
try {
  const response = await fetch('/api/whatsapp/send', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ to: '966501234567', message: 'مرحباً' })
  })

  if (!response.ok) {
    const error = await response.json()
    console.error('فشل الإرسال:', error.error)
    return
  }

  const data = await response.json()
  console.log('تم الإرسال بنجاح:', data.message_id)
} catch (error) {
  console.error('خطأ في الاتصال:', error)
}
\`\`\`

---

**آخر تحديث:** 2025-01-03
**الإصدار:** 1.0.0
