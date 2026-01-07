import { type NextRequest, NextResponse } from "next/server"
import { handleCustomerMessage } from "@/lib/whatsapp-bot"

// اختبار البوت بدون إرسال رسائل حقيقية
export async function POST(request: NextRequest) {
  try {
    const body = await request.json()
    const { phone, message, customerName } = body

    if (!phone || !message) {
      return NextResponse.json({ error: "Phone and message are required" }, { status: 400 })
    }

    console.log("[v0] Testing WhatsApp bot:", { phone, message, customerName })

    // معالجة الرسالة (سيتم إرسال رد حقيقي)
    await handleCustomerMessage(phone, message, customerName)

    return NextResponse.json({
      success: true,
      message: "Bot response sent successfully",
    })
  } catch (error) {
    console.error("[v0] Bot test error:", error)
    return NextResponse.json(
      {
        success: false,
        error: error instanceof Error ? error.message : "Bot test failed",
      },
      { status: 500 },
    )
  }
}
