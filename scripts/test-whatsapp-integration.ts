/**
 * سكريبت اختبار تكامل الواتساب
 * يختبر جميع وظائف النظام للتأكد من عملها بشكل صحيح
 */

import { neon } from "@neondatabase/serverless"

const sql = neon(process.env.DATABASE_URL!)

interface TestResult {
  test: string
  status: "✓ نجح" | "✗ فشل"
  message: string
  duration?: number
}

const results: TestResult[] = []

async function runTest(testName: string, testFn: () => Promise<void>) {
  const startTime = Date.now()
  try {
    await testFn()
    const duration = Date.now() - startTime
    results.push({
      test: testName,
      status: "✓ نجح",
      message: "تم بنجاح",
      duration,
    })
  } catch (error) {
    const duration = Date.now() - startTime
    results.push({
      test: testName,
      status: "✗ فشل",
      message: error instanceof Error ? error.message : "خطأ غير معروف",
      duration,
    })
  }
}

// اختبار 1: التحقق من وجود الجداول
await runTest("التحقق من جدول whatsapp_messages", async () => {
  const result = await sql`
    SELECT EXISTS (
      SELECT FROM information_schema.tables 
      WHERE table_name = 'whatsapp_messages'
    )
  `
  if (!result[0].exists) {
    throw new Error("جدول whatsapp_messages غير موجود")
  }
})

await runTest("التحقق من جدول whatsapp_templates", async () => {
  const result = await sql`
    SELECT EXISTS (
      SELECT FROM information_schema.tables 
      WHERE table_name = 'whatsapp_templates'
    )
  `
  if (!result[0].exists) {
    throw new Error("جدول whatsapp_templates غير موجود")
  }
})

await runTest("التحقق من جدول customer_inquiries", async () => {
  const result = await sql`
    SELECT EXISTS (
      SELECT FROM information_schema.tables 
      WHERE table_name = 'customer_inquiries'
    )
  `
  if (!result[0].exists) {
    throw new Error("جدول customer_inquiries غير موجود")
  }
})

// اختبار 2: إنشاء قالب اختباري
let testTemplateId: number

await runTest("إنشاء قالب اختباري", async () => {
  const result = await sql`
    INSERT INTO whatsapp_templates (
      template_name, template_code, category, language, content, variables, status
    ) VALUES (
      'اختبار', 'test_template', 'marketing', 'ar', 
      'مرحباً {{name}}، هذه رسالة اختبار', 
      ARRAY['name'], 'active'
    )
    RETURNING id
  `
  testTemplateId = result[0].id
  if (!testTemplateId) {
    throw new Error("فشل إنشاء القالب")
  }
})

// اختبار 3: قراءة القالب
await runTest("قراءة القالب الاختباري", async () => {
  const result = await sql`
    SELECT * FROM whatsapp_templates WHERE id = ${testTemplateId}
  `
  if (result.length === 0) {
    throw new Error("لم يتم العثور على القالب")
  }
  if (result[0].template_code !== "test_template") {
    throw new Error("بيانات القالب غير صحيحة")
  }
})

// اختبار 4: إنشاء رسالة اختبارية
let testMessageId: number

await runTest("إنشاء رسالة اختبارية", async () => {
  const result = await sql`
    INSERT INTO whatsapp_messages (
      recipient_phone, recipient_name, message_type, message_content, 
      template_id, status, sent_at
    ) VALUES (
      '966501234567', 'عميل اختباري', 'template', 'مرحباً عميل اختباري، هذه رسالة اختبار',
      ${testTemplateId}, 'sent', NOW()
    )
    RETURNING id
  `
  testMessageId = result[0].id
  if (!testMessageId) {
    throw new Error("فشل إنشاء الرسالة")
  }
})

// اختبار 5: تحديث حالة الرسالة
await runTest("تحديث حالة الرسالة", async () => {
  await sql`
    UPDATE whatsapp_messages 
    SET status = 'delivered', delivered_at = NOW()
    WHERE id = ${testMessageId}
  `

  const result = await sql`
    SELECT status FROM whatsapp_messages WHERE id = ${testMessageId}
  `

  if (result[0].status !== "delivered") {
    throw new Error("فشل تحديث حالة الرسالة")
  }
})

// اختبار 6: إنشاء استفسار اختباري
let testInquiryId: number

await runTest("إنشاء استفسار اختباري", async () => {
  const result = await sql`
    INSERT INTO customer_inquiries (
      customer_phone, customer_name, message, inquiry_type, status, created_at
    ) VALUES (
      '966501234567', 'عميل اختباري', 'استفسار اختباري', 'general', 'pending', NOW()
    )
    RETURNING id
  `
  testInquiryId = result[0].id
  if (!testInquiryId) {
    throw new Error("فشل إنشاء الاستفسار")
  }
})

// اختبار 7: تحديث حالة الاستفسار
await runTest("تحديث حالة الاستفسار", async () => {
  await sql`
    UPDATE customer_inquiries 
    SET status = 'resolved', resolved_at = NOW()
    WHERE id = ${testInquiryId}
  `

  const result = await sql`
    SELECT status FROM customer_inquiries WHERE id = ${testInquiryId}
  `

  if (result[0].status !== "resolved") {
    throw new Error("فشل تحديث حالة الاستفسار")
  }
})

// اختبار 8: البحث في الرسائل
await runTest("البحث في الرسائل", async () => {
  const result = await sql`
    SELECT * FROM whatsapp_messages 
    WHERE recipient_phone = '966501234567'
    ORDER BY sent_at DESC
    LIMIT 10
  `

  if (result.length === 0) {
    throw new Error("لم يتم العثور على رسائل")
  }
})

// اختبار 9: إحصائيات الرسائل
await runTest("حساب إحصائيات الرسائل", async () => {
  const result = await sql`
    SELECT 
      COUNT(*) as total,
      COUNT(*) FILTER (WHERE status = 'sent') as sent,
      COUNT(*) FILTER (WHERE status = 'delivered') as delivered,
      COUNT(*) FILTER (WHERE status = 'read') as read,
      COUNT(*) FILTER (WHERE status = 'failed') as failed
    FROM whatsapp_messages
  `

  if (!result[0].total) {
    throw new Error("فشل حساب الإحصائيات")
  }
})

// اختبار 10: تنظيف البيانات الاختبارية
await runTest("حذف البيانات الاختبارية", async () => {
  await sql`DELETE FROM whatsapp_messages WHERE id = ${testMessageId}`
  await sql`DELETE FROM customer_inquiries WHERE id = ${testInquiryId}`
  await sql`DELETE FROM whatsapp_templates WHERE id = ${testTemplateId}`
})

// طباعة النتائج
console.log("\n" + "=".repeat(80))
console.log("نتائج اختبار تكامل الواتساب")
console.log("=".repeat(80) + "\n")

results.forEach((result, index) => {
  console.log(`${index + 1}. ${result.test}`)
  console.log(`   الحالة: ${result.status}`)
  console.log(`   الرسالة: ${result.message}`)
  if (result.duration) {
    console.log(`   المدة: ${result.duration}ms`)
  }
  console.log()
})

const passedTests = results.filter((r) => r.status === "✓ نجح").length
const failedTests = results.filter((r) => r.status === "✗ فشل").length
const totalTests = results.length

console.log("=".repeat(80))
console.log(`الملخص: ${passedTests}/${totalTests} اختبار نجح، ${failedTests} فشل`)
console.log("=".repeat(80))

if (failedTests > 0) {
  process.exit(1)
}
