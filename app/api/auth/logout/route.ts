import { type NextRequest, NextResponse } from "next/server"
import { logAuditEvent } from "@/lib/auth"

export async function POST(request: NextRequest) {
  try {
    const { userId } = await request.json()

    if (userId) {
      await logAuditEvent({
        userId,
        userName: "مستخدم",
        action: "logout",
        module: "authentication",
        status: "success",
        details: "User logged out successfully",
      })
    }

    return NextResponse.json({ success: true })
  } catch (error) {
    console.error("Logout API error:", error)
    return NextResponse.json({ success: false, error: "حدث خطأ في الخادم" }, { status: 500 })
  }
}
