import { NextResponse } from "next/server"
import { testConnection } from "@/lib/whatsapp-service"

// اختبار الاتصال بـ WhatsApp API
export async function GET() {
  try {
    console.log("[v0] Testing WhatsApp connection...")

    const result = await testConnection()

    return NextResponse.json({
      success: result.success,
      message: result.message,
    })
  } catch (error) {
    console.error("[v0] WhatsApp connection test error:", error)
    return NextResponse.json(
      {
        success: false,
        message: error instanceof Error ? error.message : "Connection test failed",
      },
      { status: 500 },
    )
  }
}
