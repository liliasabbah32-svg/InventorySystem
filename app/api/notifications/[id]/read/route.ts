import { type NextRequest, NextResponse } from "next/server"
import { markNotificationAsRead } from "@/lib/notifications"

export async function PATCH(request: NextRequest, { params }: { params: { id: string } }) {
  try {
    const notificationId = Number.parseInt(params.id)

    if (isNaN(notificationId)) {
      return NextResponse.json({ error: "معرف التنبيه غير صحيح" }, { status: 400 })
    }

    const notification = await markNotificationAsRead(notificationId)

    return NextResponse.json({
      success: true,
      notification,
    })
  } catch (error) {
    console.error("Error marking notification as read:", error)
    return NextResponse.json({ error: "فشل في تحديث التنبيه" }, { status: 500 })
  }
}
