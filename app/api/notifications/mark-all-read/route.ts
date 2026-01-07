import { type NextRequest, NextResponse } from "next/server"
import { markAllNotificationsAsRead } from "@/lib/notifications"

export async function PATCH(request: NextRequest) {
  try {
    const { userId, department } = await request.json()

    await markAllNotificationsAsRead(userId, department)

    return NextResponse.json({
      success: true,
      message: "تم تحديد جميع التنبيهات كمقروءة",
    })
  } catch (error) {
    console.error("Error marking all notifications as read:", error)
    return NextResponse.json({ error: "فشل في تحديث التنبيهات" }, { status: 500 })
  }
}
