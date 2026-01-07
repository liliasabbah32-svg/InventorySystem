# دليل نظام الباتش نمبر (Batch Number System Guide)

## نظرة عامة

نظام الباتش نمبر في هذا النظام تم تصميمه لتتبع وإدارة دفعات المنتجات (Lots/Batches) بطريقة منظمة وفعالة. يدعم النظام نظام FIFO (First In, First Out) لضمان استخدام الدفعات الأقدم أولاً.

## المصطلحات الموحدة

- **Lot** (الدفعة): المصطلح الرئيسي في قاعدة البيانات
- **Batch Number** (رقم الباتش): الاسم المستخدم في واجهة المستخدم
- **lot_id**: المعرف الفريد للدفعة (Primary Key)
- **lot_number / batch_number**: رقم الدفعة (للعرض)

## هيكل قاعدة البيانات

### الجداول الرئيسية

#### 1. `product_lots`
الجدول الرئيسي لتخزين معلومات الدفعات:
- `id`: المعرف الفريد
- `lot_number`: رقم الباتش
- `product_id`: معرف المنتج (FK)
- `manufacturing_date`: تاريخ الإنتاج
- `expiry_date`: تاريخ الانتهاء
- `current_quantity`: الكمية الحالية
- `reserved_quantity`: الكمية المحجوزة
- `available_quantity`: الكمية المتاحة (محسوبة تلقائياً)
- `unit_cost`: تكلفة الوحدة
- `status`: الحالة (active, depleted, expired)

#### 2. `lot_transactions`
سجل حركات الدفعات:
- `lot_id`: معرف الدفعة (FK)
- `transaction_type`: نوع الحركة (reserve, release, consume, adjust)
- `quantity`: الكمية
- `reference_type`: نوع المرجع (sales_order, purchase_order, etc.)
- `reference_id`: معرف المرجع

#### 3. `batch_settings`
إعدادات الباتش لكل نوع سند:
- `document_type`: نوع السند
- `mandatory_batch_selection`: هل الباتش إجباري؟
- `auto_select_fifo`: اختيار تلقائي بنظام FIFO
- `allow_negative_stock`: السماح بالمخزون السالب
- `require_expiry_date`: تاريخ الصلاحية مطلوب

### Views الموحدة

#### `batch_inventory_view`
عرض شامل لمعلومات الباتش مع حسابات الصلاحية والقيمة.

#### `product_batch_summary`
ملخص الباتشات لكل منتج مع إحصائيات.

## المكتبة الموحدة (`lib/batch-utils.ts`)

### الوظائف الرئيسية

#### 1. `getAvailableBatches(productId)`
الحصول على جميع الباتشات المتاحة لمنتج معين.

#### 2. `calculateFIFOAllocation(productId, quantity)`
حساب توزيع الباتشات حسب نظام FIFO.

#### 3. `reserveBatches(allocations, referenceType, referenceId, createdBy)`
حجز كميات من الباتشات.

#### 4. `releaseBatches(allocations, referenceType, referenceId, createdBy)`
إلغاء حجز كميات من الباتشات.

#### 5. `consumeBatches(allocations, referenceType, referenceId, createdBy)`
استهلاك كميات من الباتشات (تقليل الكمية الفعلية).

#### 6. `searchBatch(searchTerm)`
البحث عن باتش برقم الباتش أو الباركود.

#### 7. `getBatchSettings(documentType)`
الحصول على إعدادات الباتش لنوع سند معين.

## API الموحد

### `/api/inventory/batches`

#### GET
- `?product_id={id}&quantity={qty}`: الحصول على الباتشات المتاحة مع توزيع FIFO
- `?action=search&search={term}`: البحث عن باتش
- `?action=info&lot_id={id}`: معلومات باتش معين
- `?action=summary&product_id={id}`: ملخص الباتشات لمنتج
- `?action=settings&document_type={type}`: إعدادات الباتش

#### POST
\`\`\`json
{
  "action": "reserve|release|consume",
  "allocations": [...],
  "referenceType": "sales_order",
  "referenceId": 123,
  "createdBy": "username"
}
\`\`\`

## نظام FIFO

يتم ترتيب الباتشات حسب:
1. الباتشات بدون تاريخ انتهاء تأتي أخيراً
2. تاريخ الانتهاء الأقرب أولاً
3. تاريخ الإنتاج الأقدم أولاً
4. تاريخ الإنشاء الأقدم أولاً

## حالات الصلاحية

- `no_expiry`: لا يوجد تاريخ انتهاء
- `good`: صالح (أكثر من 30 يوم)
- `near_expiry`: قريب من الانتهاء (30 يوم أو أقل)
- `expired`: منتهي الصلاحية

## أمثلة الاستخدام

### مثال 1: الحصول على باتشات متاحة مع FIFO
\`\`\`typescript
import { calculateFIFOAllocation } from '@/lib/batch-utils'

const allocation = await calculateFIFOAllocation(productId, 100)
if (allocation.canFulfill) {
  console.log('يمكن تلبية الطلب')
  console.log('التوزيع:', allocation.allocations)
}
\`\`\`

### مثال 2: حجز باتشات
\`\`\`typescript
import { reserveBatches } from '@/lib/batch-utils'

await reserveBatches(
  allocation.allocations,
  'sales_order',
  orderId,
  'username'
)
\`\`\`

### مثال 3: البحث عن باتش
\`\`\`typescript
import { searchBatch } from '@/lib/batch-utils'

const results = await searchBatch('BATCH-001')
\`\`\`

## الترقيات والتحسينات

تم تنفيذ التحسينات التالية:
1. ✅ توحيد المصطلحات
2. ✅ تحسين الربط بين الجداول (Foreign Keys)
3. ✅ تبسيط الإعدادات (مكتبة موحدة)
4. ✅ إضافة Indexes للأداء
5. ✅ إنشاء Views موحدة
6. ✅ إضافة Triggers تلقائية
7. ✅ دالة FIFO في قاعدة البيانات
8. ✅ API موحد ومبسط

## الصيانة

### تشغيل Migration
\`\`\`bash
# تشغيل السكريبت من لوحة v0
scripts/22-unify-batch-terminology.sql
\`\`\`

### التحقق من سلامة البيانات
\`\`\`sql
-- التحقق من الكميات
SELECT * FROM product_lots 
WHERE available_quantity != (current_quantity - reserved_quantity);

-- التحقق من الباتشات المنتهية
SELECT * FROM batch_inventory_view 
WHERE expiry_status = 'expired' AND status = 'active';
