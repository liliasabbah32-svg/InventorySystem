import { type NextRequest, NextResponse } from "next/server"
import { sendSMS } from "@/lib/twilio"

export async function POST(request: NextRequest) {
  try {
    const { phone, message } = await request.json()

    if (!phone || !message) {
      return NextResponse.json({ message: "رقم الهاتف والرسالة مطلوبان" }, { status: 400 })
    }

    const result = await sendSMS(phone, message)

    if (result.success) {
      return NextResponse.json({
        message: "تم إرسال الرسالة بنجاح",
        sid: result.sid,
      })
    } else {
      return NextResponse.json({ message: result.error || "فشل إرسال الرسالة" }, { status: 500 })
    }
  } catch (error) {
    console.error("[v0] Error sending SMS:", error)
    return NextResponse.json({ message: "حدث خطأ في إرسال الرسالة" }, { status: 500 })
  }
}
