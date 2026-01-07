// خدمة إرسال الإشعارات عبر SMS و WhatsApp

interface NotificationPayload {
  phoneNumber: string
  message: string
  method: "sms" | "whatsapp" | "both"
}

interface NotificationResult {
  success: boolean
  method: string
  messageId?: string
  error?: string
}

/**
 * إرسال رسالة SMS
 * ملاحظة: يحتاج إلى تكامل مع خدمة SMS مثل Twilio أو Unifonic
 */
async function sendSMS(phoneNumber: string, message: string): Promise<NotificationResult> {
  try {
    console.log("[v0] Sending SMS to:", phoneNumber)
    console.log("[v0] Message:", message)

    // TODO: تكامل مع خدمة SMS الفعلية
    // مثال باستخدام Twilio:
    /*
    const accountSid = process.env.TWILIO_ACCOUNT_SID
    const authToken = process.env.TWILIO_AUTH_TOKEN
    const twilioNumber = process.env.TWILIO_PHONE_NUMBER

    const response = await fetch(
      `https://api.twilio.com/2010-04-01/Accounts/${accountSid}/Messages.json`,
      {
        method: 'POST',
        headers: {
          'Authorization': 'Basic ' + Buffer.from(`${accountSid}:${authToken}`).toString('base64'),
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: new URLSearchParams({
          To: phoneNumber,
          From: twilioNumber,
          Body: message,
        }),
      }
    )

    const data = await response.json()
    
    if (response.ok) {
      return {
        success: true,
        method: 'sms',
        messageId: data.sid,
      }
    } else {
      throw new Error(data.message || 'Failed to send SMS')
    }
    */

    // محاكاة الإرسال للتطوير
    await new Promise((resolve) => setTimeout(resolve, 1000))

    return {
      success: true,
      method: "sms",
      messageId: `sms_${Date.now()}`,
    }
  } catch (error) {
    console.error("[v0] Error sending SMS:", error)
    return {
      success: false,
      method: "sms",
      error: error instanceof Error ? error.message : "فشل في إرسال SMS",
    }
  }
}

/**
 * إرسال رسالة WhatsApp
 * ملاحظة: يحتاج إلى تكامل مع WhatsApp Business API
 */
async function sendWhatsApp(phoneNumber: string, message: string): Promise<NotificationResult> {
  try {
    console.log("[v0] Sending WhatsApp to:", phoneNumber)
    console.log("[v0] Message:", message)

    // TODO: تكامل مع WhatsApp Business API
    // مثال باستخدام Twilio WhatsApp:
    /*
    const accountSid = process.env.TWILIO_ACCOUNT_SID
    const authToken = process.env.TWILIO_AUTH_TOKEN
    const whatsappNumber = process.env.TWILIO_WHATSAPP_NUMBER

    const response = await fetch(
      `https://api.twilio.com/2010-04-01/Accounts/${accountSid}/Messages.json`,
      {
        method: 'POST',
        headers: {
          'Authorization': 'Basic ' + Buffer.from(`${accountSid}:${authToken}`).toString('base64'),
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: new URLSearchParams({
          To: `whatsapp:${phoneNumber}`,
          From: `whatsapp:${whatsappNumber}`,
          Body: message,
        }),
      }
    )

    const data = await response.json()
    
    if (response.ok) {
      return {
        success: true,
        method: 'whatsapp',
        messageId: data.sid,
      }
    } else {
      throw new Error(data.message || 'Failed to send WhatsApp')
    }
    */

    // محاكاة الإرسال للتطوير
    await new Promise((resolve) => setTimeout(resolve, 1000))

    return {
      success: true,
      method: "whatsapp",
      messageId: `whatsapp_${Date.now()}`,
    }
  } catch (error) {
    console.error("[v0] Error sending WhatsApp:", error)
    return {
      success: false,
      method: "whatsapp",
      error: error instanceof Error ? error.message : "فشل في إرسال WhatsApp",
    }
  }
}

/**
 * إرسال إشعار حسب الطريقة المحددة
 */
export async function sendNotification(payload: NotificationPayload): Promise<NotificationResult[]> {
  const { phoneNumber, message, method } = payload
  const results: NotificationResult[] = []

  // تنسيق رقم الهاتف (إزالة المسافات والرموز)
  const formattedPhone = phoneNumber.replace(/\s+/g, "").replace(/[^\d+]/g, "")

  // التحقق من صحة رقم الهاتف
  if (!formattedPhone || formattedPhone.length < 10) {
    return [
      {
        success: false,
        method: "validation",
        error: "رقم الهاتف غير صحيح",
      },
    ]
  }

  try {
    if (method === "sms" || method === "both") {
      const smsResult = await sendSMS(formattedPhone, message)
      results.push(smsResult)
    }

    if (method === "whatsapp" || method === "both") {
      const whatsappResult = await sendWhatsApp(formattedPhone, message)
      results.push(whatsappResult)
    }

    return results
  } catch (error) {
    console.error("[v0] Error in sendNotification:", error)
    return [
      {
        success: false,
        method: "general",
        error: "فشل في إرسال الإشعار",
      },
    ]
  }
}

/**
 * إرسال إشعار مجدول (للملخص اليومي)
 */
export async function sendScheduledNotification(
  customerId: number,
  phoneNumber: string,
  message: string,
  method: "sms" | "whatsapp" | "both",
): Promise<NotificationResult[]> {
  console.log("[v0] Sending scheduled notification for customer:", customerId)

  return sendNotification({
    phoneNumber,
    message,
    method,
  })
}

/**
 * توليد رسالة الملخص اليومي
 */
export function generateDailySummaryMessage(
  customerName: string,
  orders: Array<{ order_number: string; status: string }>,
): string {
  const ordersList = orders
    .map((order) => `- طلبية ${order.order_number}: ${getStatusInArabic(order.status)}`)
    .join("\n")

  return `
عزيزي ${customerName}،

ملخص طلبياتك اليوم:

${ordersList}

شكراً لثقتك بنا.
  `.trim()
}

/**
 * ترجمة حالة الطلبية للعربية
 */
function getStatusInArabic(status: string): string {
  const statusMap: Record<string, string> = {
    received: "تم الاستلام",
    preparing: "قيد التحضير",
    quality_check: "التدقيق والمراجعة",
    ready_to_ship: "جاهز للشحن",
    shipped: "تم الشحن",
    delivered: "تم التسليم",
    cancelled: "ملغي",
  }

  return statusMap[status] || status
}
