import { type NextRequest, NextResponse } from "next/server"
import { sendTextMessage, sendTemplateMessage, sendMediaMessage } from "@/lib/whatsapp-service"

export async function POST(request: NextRequest) {
  try {
    const body = await request.json()
    const { phone, message, type, templateCode, variables, mediaUrl, mediaType, recipientName } = body

    console.log("[v0] WhatsApp send request:", { phone, type, templateCode })

    if (!phone || !message) {
      return NextResponse.json({ error: "Phone and message are required" }, { status: 400 })
    }

    let result

    switch (type) {
      case "template":
        if (!templateCode || !variables) {
          return NextResponse.json({ error: "Template code and variables are required" }, { status: 400 })
        }
        result = await sendTemplateMessage(phone, templateCode, variables, recipientName)
        break

      case "media":
        if (!mediaUrl || !mediaType) {
          return NextResponse.json({ error: "Media URL and type are required" }, { status: 400 })
        }
        result = await sendMediaMessage(phone, message, mediaUrl, mediaType, recipientName)
        break

      case "text":
      default:
        result = await sendTextMessage(phone, message, recipientName)
        break
    }

    console.log("[v0] WhatsApp message sent successfully:", result.id)

    return NextResponse.json({
      success: true,
      message: "Message sent successfully",
      data: result,
    })
  } catch (error) {
    console.error("[v0] WhatsApp send error:", error)
    return NextResponse.json(
      {
        success: false,
        error: error instanceof Error ? error.message : "Failed to send WhatsApp message",
      },
      { status: 500 },
    )
  }
}
