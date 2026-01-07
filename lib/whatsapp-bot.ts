import { neon } from "@neondatabase/serverless"
import { sendTextMessage, formatPhoneNumber } from "./whatsapp-service"

const sql = neon(process.env.DATABASE_URL!)

// أنواع الأوامر التي يمكن للعميل إرسالها
export type BotCommand = "menu" | "orders" | "order_status" | "products" | "new_order" | "help" | "contact" | "unknown"

// تحليل رسالة العميل وتحديد نوع الطلب
export function parseCustomerMessage(message: string): {
  command: BotCommand
  params?: any
} {
  const lowerMessage = message.toLowerCase().trim()

  // القائمة الرئيسية
  if (
    lowerMessage.includes("قائمة") ||
    lowerMessage.includes("menu") ||
    lowerMessage === "1" ||
    lowerMessage.includes("البداية") ||
    lowerMessage.includes("start")
  ) {
    return { command: "menu" }
  }

  // طلبياتي
  if (
    lowerMessage.includes("طلبيات") ||
    lowerMessage.includes("طلباتي") ||
    lowerMessage.includes("orders") ||
    lowerMessage === "2"
  ) {
    return { command: "orders" }
  }

  // حالة طلبية محددة
  const orderNumberMatch = lowerMessage.match(/(?:طلبية|order|رقم)\s*:?\s*([a-z0-9-]+)/i)
  if (orderNumberMatch) {
    return { command: "order_status", params: { orderNumber: orderNumberMatch[1] } }
  }

  // المنتجات
  if (
    lowerMessage.includes("منتج") ||
    lowerMessage.includes("أصناف") ||
    lowerMessage.includes("products") ||
    lowerMessage === "3"
  ) {
    return { command: "products" }
  }

  // طلبية جديدة
  if (
    lowerMessage.includes("طلبية جديدة") ||
    lowerMessage.includes("new order") ||
    lowerMessage.includes("أريد طلب") ||
    lowerMessage === "4"
  ) {
    return { command: "new_order" }
  }

  // مساعدة
  if (lowerMessage.includes("مساعدة") || lowerMessage.includes("help") || lowerMessage === "5") {
    return { command: "help" }
  }

  // تواصل معنا
  if (
    lowerMessage.includes("تواصل") ||
    lowerMessage.includes("اتصال") ||
    lowerMessage.includes("contact") ||
    lowerMessage === "6"
  ) {
    return { command: "contact" }
  }

  return { command: "unknown" }
}

// معالجة رسالة العميل والرد عليها
export async function handleCustomerMessage(phone: string, message: string, customerName?: string): Promise<void> {
  try {
    const formattedPhone = formatPhoneNumber(phone)
    const { command, params } = parseCustomerMessage(message)

    console.log("[WhatsApp Bot] Processing command:", command, "from:", formattedPhone)

    let response = ""

    switch (command) {
      case "menu":
        response = await getMainMenu(customerName)
        break

      case "orders":
        response = await getCustomerOrders(formattedPhone, customerName)
        break

      case "order_status":
        response = await getOrderStatus(formattedPhone, params.orderNumber, customerName)
        break

      case "products":
        response = await getProductsList(customerName)
        break

      case "new_order":
        response = await getNewOrderInstructions(customerName)
        break

      case "help":
        response = await getHelpMessage(customerName)
        break

      case "contact":
        response = await getContactInfo(customerName)
        break

      case "unknown":
      default:
        response = await getUnknownCommandResponse(customerName)
        break
    }

    // إرسال الرد للعميل
    await sendTextMessage(formattedPhone, response, customerName)

    // حفظ الاستفسار في قاعدة البيانات
    await saveCustomerInquiry(formattedPhone, customerName, command, message, response)
  } catch (error) {
    console.error("[WhatsApp Bot] Error handling customer message:", error)
    // إرسال رسالة خطأ للعميل
    await sendTextMessage(
      formatPhoneNumber(phone),
      "عذراً، حدث خطأ أثناء معالجة طلبك. يرجى المحاولة مرة أخرى أو التواصل مع فريق الدعم.",
      customerName,
    )
  }
}

// القائمة الرئيسية
async function getMainMenu(customerName?: string): Promise<string> {
  const greeting = customerName ? `مرحباً ${customerName}` : "مرحباً بك"

  return `${greeting}! 👋

أهلاً بك في نظام إدارة الطلبيات. كيف يمكنني مساعدتك اليوم؟

📋 *القائمة الرئيسية:*

1️⃣ عرض طلبياتي
2️⃣ الاستعلام عن حالة طلبية
3️⃣ عرض المنتجات المتوفرة
4️⃣ تقديم طلبية جديدة
5️⃣ المساعدة
6️⃣ التواصل معنا

*يرجى إرسال رقم الخيار أو كتابة طلبك مباشرة.*`
}

// عرض طلبيات العميل
async function getCustomerOrders(phone: string, customerName?: string): Promise<string> {
  try {
    // البحث عن العميل
    const customers = await sql`
      SELECT id, customer_name 
      FROM customers 
      WHERE whatsapp1 = ${phone} OR mobile1 = ${phone}
      LIMIT 1
    `

    if (!customers.length) {
      return `عذراً، لم نتمكن من العثور على حسابك. يرجى التأكد من رقم الهاتف أو التواصل مع فريق الدعم.`
    }

    const customer = customers[0]
    const actualCustomerName = customerName || customer.customer_name

    // الحصول على طلبيات العميل
    const orders = await sql`
      SELECT 
        so.order_number,
        so.order_date,
        so.total_amount,
        so.status,
        ws.stage_name,
        ws.stage_color
      FROM sales_orders so
      LEFT JOIN order_workflow_status ows ON so.id = ows.order_id AND ows.order_type = 'sales'
      LEFT JOIN workflow_stages ws ON ows.current_stage_id = ws.id
      WHERE so.customer_id = ${customer.id}
      ORDER BY so.order_date DESC
      LIMIT 10
    `

    if (!orders.length) {
      return `مرحباً ${actualCustomerName}،

لا توجد لديك طلبيات حالياً. 

هل ترغب في تقديم طلبية جديدة؟ أرسل "طلبية جديدة" أو الرقم 4.`
    }

    let response = `مرحباً ${actualCustomerName}،

📦 *طلبياتك الأخيرة:*\n\n`

    orders.forEach((order, index) => {
      const orderDate = new Date(order.order_date).toLocaleDateString("ar-SA")
      const amount = Number(order.total_amount).toLocaleString("ar-SA", {
        style: "currency",
        currency: "SAR",
      })

      response += `${index + 1}. *${order.order_number}*
   📅 التاريخ: ${orderDate}
   💰 المبلغ: ${amount}
   📍 الحالة: ${order.stage_name || order.status}
   
`
    })

    response += `\n*للاستعلام عن طلبية محددة، أرسل:*
"طلبية: رقم_الطلبية"

مثال: طلبية: SO-2024-001`

    return response
  } catch (error) {
    console.error("[WhatsApp Bot] Error fetching customer orders:", error)
    return "عذراً، حدث خطأ أثناء جلب طلبياتك. يرجى المحاولة مرة أخرى."
  }
}

// الاستعلام عن حالة طلبية محددة
async function getOrderStatus(phone: string, orderNumber: string, customerName?: string): Promise<string> {
  try {
    // البحث عن العميل
    const customers = await sql`
      SELECT id, customer_name 
      FROM customers 
      WHERE whatsapp1 = ${phone} OR mobile1 = ${phone}
      LIMIT 1
    `

    if (!customers.length) {
      return "عذراً، لم نتمكن من العثور على حسابك."
    }

    const customer = customers[0]

    // البحث عن الطلبية
    const orders = await sql`
      SELECT 
        so.order_number,
        so.order_date,
        so.total_amount,
        so.status,
        so.notes,
        ws.stage_name,
        ws.stage_color,
        ws.description as stage_description,
        ows.stage_start_time,
        ows.estimated_completion_time
      FROM sales_orders so
      LEFT JOIN order_workflow_status ows ON so.id = ows.order_id AND ows.order_type = 'sales'
      LEFT JOIN workflow_stages ws ON ows.current_stage_id = ws.id
      WHERE so.customer_id = ${customer.id} 
        AND (so.order_number = ${orderNumber} OR so.order_number LIKE ${`%${orderNumber}%`})
      LIMIT 1
    `

    if (!orders.length) {
      return `عذراً، لم نتمكن من العثور على الطلبية رقم: ${orderNumber}

يرجى التأكد من رقم الطلبية أو عرض جميع طلبياتك بإرسال "طلبياتي" أو الرقم 2.`
    }

    const order = orders[0]
    const orderDate = new Date(order.order_date).toLocaleDateString("ar-SA")
    const amount = Number(order.total_amount).toLocaleString("ar-SA", {
      style: "currency",
      currency: "SAR",
    })

    let response = `📦 *تفاصيل الطلبية ${order.order_number}*

📅 تاريخ الطلبية: ${orderDate}
💰 إجمالي المبلغ: ${amount}
📍 الحالة الحالية: *${order.stage_name || order.status}*
`

    if (order.stage_description) {
      response += `ℹ️ ${order.stage_description}\n`
    }

    if (order.estimated_completion_time) {
      const estimatedDate = new Date(order.estimated_completion_time).toLocaleDateString("ar-SA")
      response += `⏰ الوقت المتوقع للإنجاز: ${estimatedDate}\n`
    }

    if (order.notes) {
      response += `\n📝 ملاحظات: ${order.notes}\n`
    }

    response += `\n✅ سنقوم بإعلامك عند أي تحديث على طلبيتك.

للعودة للقائمة الرئيسية، أرسل "قائمة" أو الرقم 1.`

    return response
  } catch (error) {
    console.error("[WhatsApp Bot] Error fetching order status:", error)
    return "عذراً، حدث خطأ أثناء الاستعلام عن الطلبية."
  }
}

// عرض المنتجات المتوفرة
async function getProductsList(customerName?: string): Promise<string> {
  try {
    const products = await sql`
      SELECT 
        product_code,
        product_name,
        unit_price,
        available_quantity,
        unit
      FROM products 
      WHERE status = 'active' 
        AND available_quantity > 0
      ORDER BY product_name
      LIMIT 15
    `

    if (!products.length) {
      return "عذراً، لا توجد منتجات متوفرة حالياً. يرجى المحاولة لاحقاً."
    }

    let response = `🛍️ *المنتجات المتوفرة:*\n\n`

    products.forEach((product, index) => {
      const price = Number(product.unit_price).toLocaleString("ar-SA", {
        style: "currency",
        currency: "SAR",
      })

      response += `${index + 1}. *${product.product_name}*
   🏷️ الكود: ${product.product_code}
   💵 السعر: ${price} / ${product.unit}
   📦 الكمية المتوفرة: ${product.available_quantity}
   
`
    })

    response += `\n*لطلب منتج معين، أرسل:*
"طلبية جديدة" أو الرقم 4

أو تواصل معنا مباشرة على الرقم المدرج في "التواصل معنا".`

    return response
  } catch (error) {
    console.error("[WhatsApp Bot] Error fetching products:", error)
    return "عذراً، حدث خطأ أثناء جلب المنتجات."
  }
}

// تعليمات تقديم طلبية جديدة
async function getNewOrderInstructions(customerName?: string): Promise<string> {
  const greeting = customerName ? `${customerName}` : "عزيزي العميل"

  return `مرحباً ${greeting}! 🎉

لتقديم طلبية جديدة، يرجى اتباع الخطوات التالية:

1️⃣ *حدد المنتجات:*
   - اطلع على المنتجات المتوفرة بإرسال "منتجات" أو الرقم 3
   
2️⃣ *أرسل طلبك:*
   يرجى إرسال تفاصيل طلبك بالصيغة التالية:
   
   *اسم المنتج - الكمية*
   
   مثال:
   صنف A - 10 قطع
   صنف B - 5 كرتون
   
3️⃣ *التأكيد:*
   سيقوم فريقنا بمراجعة طلبك والتواصل معك لتأكيد التفاصيل والسعر.

📞 *أو تواصل معنا مباشرة:*
يمكنك الاتصال بنا على الأرقام المدرجة في "التواصل معنا" (أرسل الرقم 6).

نحن في خدمتك! 🌟`
}

// رسالة المساعدة
async function getHelpMessage(customerName?: string): Promise<string> {
  return `❓ *كيف يمكنني مساعدتك؟*

يمكنك استخدام الأوامر التالية:

📋 *"قائمة"* أو *1* - القائمة الرئيسية
📦 *"طلبياتي"* أو *2* - عرض طلبياتك
🔍 *"طلبية: رقم"* - الاستعلام عن طلبية محددة
🛍️ *"منتجات"* أو *3* - عرض المنتجات المتوفرة
➕ *"طلبية جديدة"* أو *4* - تقديم طلبية جديدة
📞 *"تواصل"* أو *6* - معلومات التواصل

*يمكنك أيضاً كتابة سؤالك مباشرة وسنحاول مساعدتك!*

للعودة للقائمة الرئيسية، أرسل "قائمة" أو الرقم 1.`
}

// معلومات التواصل
async function getContactInfo(customerName?: string): Promise<string> {
  try {
    // الحصول على معلومات الشركة من الإعدادات
    const settings = await sql`
      SELECT setting_key, setting_value 
      FROM general_settings 
      WHERE setting_key IN ('companyPhone', 'companyEmail', 'companyAddress', 'support_email', 'whatsapp_number')
    `

    const settingsMap = settings.reduce(
      (acc, s) => {
        acc[s.setting_key] = s.setting_value
        return acc
      },
      {} as Record<string, string>,
    )

    return `📞 *معلومات التواصل*

🏢 *العنوان:*
${settingsMap.companyAddress || "الرياض، المملكة العربية السعودية"}

📱 *الهاتف:*
${settingsMap.companyPhone || "+966501234567"}

💬 *واتساب:*
${settingsMap.whatsapp_number || settingsMap.companyPhone || "+966501234567"}

📧 *البريد الإلكتروني:*
${settingsMap.companyEmail || "info@company.com"}

🆘 *الدعم الفني:*
${settingsMap.support_email || settingsMap.companyEmail || "support@company.com"}

⏰ *ساعات العمل:*
السبت - الخميس: 8:00 ص - 5:00 م
الجمعة: مغلق

نحن سعداء بخدمتك! 🌟`
  } catch (error) {
    console.error("[WhatsApp Bot] Error fetching contact info:", error)
    return `📞 *معلومات التواصل*

يرجى التواصل معنا على:
📱 الهاتف: +966501234567
📧 البريد: info@company.com

نحن في خدمتك!`
  }
}

// رد على أمر غير معروف
async function getUnknownCommandResponse(customerName?: string): Promise<string> {
  return `عذراً، لم أفهم طلبك. 🤔

يمكنك:
• إرسال *"قائمة"* أو *1* لعرض القائمة الرئيسية
• إرسال *"مساعدة"* أو *5* لعرض الأوامر المتاحة
• كتابة سؤالك بشكل مختلف

أو تواصل معنا مباشرة بإرسال *"تواصل"* أو *6*.

نحن هنا لمساعدتك! 😊`
}

// حفظ استفسار العميل
async function saveCustomerInquiry(
  phone: string,
  customerName: string | undefined,
  inquiryType: string,
  inquiryMessage: string,
  responseMessage: string,
): Promise<void> {
  try {
    await sql`
      INSERT INTO whatsapp_customer_inquiries (
        customer_phone, customer_name, inquiry_type, inquiry_message,
        status, response_message, responded_at
      ) VALUES (
        ${phone}, ${customerName || null}, ${inquiryType}, ${inquiryMessage},
        'resolved', ${responseMessage}, CURRENT_TIMESTAMP
      )
    `
  } catch (error) {
    console.error("[WhatsApp Bot] Error saving inquiry:", error)
  }
}
