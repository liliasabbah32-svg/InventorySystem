import { type NextRequest, NextResponse } from "next/server"
import { authenticateUser } from "@/lib/auth"

export async function POST(request: NextRequest) {
  try {
    const credentials = await request.json()

    // Get client IP and user agent for logging
    const ip = request.headers.get("x-forwarded-for") || request.headers.get("x-real-ip") || "unknown"
    const userAgent = request.headers.get("user-agent") || "unknown"

    const result = await authenticateUser({
      ...credentials,
      ip,
      userAgent,
    })

    

    return NextResponse.json(result)
  } catch (error) {
    console.error("Login API error:", error)
    return NextResponse.json({ success: false, error: "حدث خطأ في الخادم" }, { status: 500 })
  }
}
