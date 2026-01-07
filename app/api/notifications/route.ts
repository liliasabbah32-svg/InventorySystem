import { type NextRequest, NextResponse } from "next/server"
import { getNotifications, getUnreadNotificationCount } from "@/lib/notifications"

export async function GET(request: NextRequest) {
  try {
    const { searchParams } = new URL(request.url)
    const userId = searchParams.get("user_id") ? Number.parseInt(searchParams.get("user_id")!) : undefined
    const department = searchParams.get("department") || undefined
    const limit = Number.parseInt(searchParams.get("limit") || "50")
    const offset = Number.parseInt(searchParams.get("offset") || "0")
    const unreadOnly = searchParams.get("unread_only") === "true"
    const countOnly = searchParams.get("count_only") === "true"

    if (countOnly) {
      const count = await getUnreadNotificationCount(userId, department)
      return NextResponse.json({ count })
    }

    const notifications = await getNotifications(userId, department, limit, offset, unreadOnly)
    const totalUnread = await getUnreadNotificationCount(userId, department)

    return NextResponse.json({
      notifications,
      totalUnread,
      hasMore: notifications.length === limit,
    })
  } catch (error) {
    console.error("Error fetching notifications:", error)
    return NextResponse.json({ error: "فشل في جلب التنبيهات" }, { status: 500 })
  }
}
