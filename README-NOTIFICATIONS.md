# نظام الإشعارات التلقائية للعملاء

## نظرة عامة
نظام متكامل لإرسال إشعارات تلقائية للعملاء عن حالة طلبياتهم عبر SMS أو WhatsApp.

## المكونات الرئيسية

### 1. قاعدة البيانات
- **customer_notification_settings**: إعدادات الإشعارات لكل عميل
- **customer_notifications**: سجل جميع الإشعارات المرسلة

### 2. واجهة المستخدم
- إعدادات الإشعارات في شاشة إدارة بوابة العميل
- خيارات تفعيل/تعطيل الإشعارات لكل مرحلة
- اختيار طريقة الإرسال (SMS، WhatsApp، أو كليهما)

### 3. APIs
- `GET/POST /api/customer-notifications/settings` - إدارة إعدادات الإشعارات
- `POST /api/customer-notifications/send` - إرسال إشعار فوري
- `POST /api/customer-notifications/daily-summary` - إرسال الملخص اليومي
- `GET /api/customer-notifications/history` - سجل الإشعارات
- `POST /api/customer-notifications/test` - اختبار الإرسال

### 4. خدمة الإرسال
- `lib/notification-service.ts` - خدمة إرسال SMS و WhatsApp
- دعم الإرسال المزدوج
- تسجيل جميع الإشعارات
- معالجة الأخطاء

## التكامل مع الطلبيات

### تحديثات تلقائية
يتم إرسال إشعارات تلقائية عند:
1. تقديم الطلبية للمرحلة التالية في workflow
2. تحديث حالة الطلبية من لوحة التحكم
3. رفض أو إلغاء الطلبية

### المراحل المدعومة
- استلام الطلبية (received)
- تحضير الطلبية (preparing)
- التدقيق والمراجعة (quality_check)
- جاهز للشحن (ready_to_ship)
- تم الشحن (shipped)
- تم التسليم (delivered)
- إلغاء الطلبية (cancelled)

## التكامل مع خدمات خارجية

### Twilio (موصى به)
\`\`\`typescript
// في ملف .env
TWILIO_ACCOUNT_SID=your_account_sid
TWILIO_AUTH_TOKEN=your_auth_token
TWILIO_PHONE_NUMBER=your_twilio_number
TWILIO_WHATSAPP_NUMBER=your_whatsapp_number
\`\`\`

### Unifonic (بديل)
\`\`\`typescript
// في ملف .env
UNIFONIC_APP_SID=your_app_sid
\`\`\`

## الملخص اليومي
يمكن جدولة إرسال ملخص يومي للعملاء يحتوي على:
- جميع طلبيات اليوم
- حالة كل طلبية
- يتم الإرسال في الوقت المحدد من قبل العميل

## الاختبار
استخدم endpoint الاختبار لتجربة الإرسال:
\`\`\`bash
POST /api/customer-notifications/test
{
  "phoneNumber": "0501234567",
  "message": "رسالة تجريبية",
  "method": "sms"
}
\`\`\`

## ملاحظات مهمة
1. النظام يعمل حالياً في وضع المحاكاة (simulation mode)
2. للتفعيل الكامل، يجب إضافة بيانات خدمة SMS/WhatsApp في ملف .env
3. جميع الإشعارات يتم تسجيلها في قاعدة البيانات
4. يمكن تعطيل الإشعارات لكل عميل أو لمراحل معينة
5. الإشعارات لا توقف عملية تحديث الطلبية في حال فشل الإرسال
