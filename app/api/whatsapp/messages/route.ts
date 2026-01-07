import { type NextRequest, NextResponse } from "next/server"
import { getMessageHistory } from "@/lib/whatsapp-service"

// الحصول على سجل الرسائل
export async function GET(request: NextRequest) {
  try {
    const { searchParams } = new URL(request.url)
    const phone = searchParams.get("phone")
    const limit = Number.parseInt(searchParams.get("limit") || "50")
    const offset = Number.parseInt(searchParams.get("offset") || "0")

    console.log("[v0] Fetching WhatsApp message history:", { phone, limit, offset })

    const result = await getMessageHistory(phone || undefined, limit, offset)

    return NextResponse.json({
      success: true,
      data: result.messages,
      total: result.total,
      limit,
      offset,
    })
  } catch (error) {
    console.error("[v0] Error fetching WhatsApp messages:", error)
    return NextResponse.json({ error: "Failed to fetch messages" }, { status: 500 })
  }
}
