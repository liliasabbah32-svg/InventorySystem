import { type NextRequest, NextResponse } from "next/server"
import { advanceOrderToNextStage } from "@/lib/workflow"
import { neon } from "@neondatabase/serverless"

const sql = neon(process.env.DATABASE_URL!)

export async function POST(request: NextRequest, { params }: { params: { id: string } }) {
  try {
    const orderId = Number.parseInt(params.id)
    const body = await request.json()

    const { orderType, performedByUser, performedByDepartment, notes } = body

    if (!orderType || !performedByUser || !performedByDepartment) {
      return NextResponse.json({ error: "جميع الحقول المطلوبة يجب أن تكون موجودة" }, { status: 400 })
    }

    const updatedStatus = await advanceOrderToNextStage(
      orderId,
      orderType,
      performedByUser,
      performedByDepartment,
      notes,
    )

    try {
      // جلب معلومات الطلبية
      const orderTable = orderType === "sales" ? "sales_orders" : "purchase_orders"
      const orderInfo = await sql`
        SELECT id, customer_id, order_number
        FROM ${sql(orderTable)}
        WHERE id = ${orderId}
        LIMIT 1
      `

      if (orderInfo.length > 0 && orderInfo[0].customer_id && updatedStatus?.stage_name) {
        // تحديد حالة الإشعار بناءً على المرحلة الجديدة
        const notificationStatus = mapStageToNotificationStatus(updatedStatus.stage_name)

        if (notificationStatus) {
          // إرسال الإشعار
          await fetch(`${request.nextUrl.origin}/api/customer-notifications/send`, {
            method: "POST",
            headers: { "Content-Type": "application/json" },
            body: JSON.stringify({
              customer_id: orderInfo[0].customer_id,
              order_id: orderInfo[0].id,
              status: notificationStatus,
            }),
          })
        }
      }
    } catch (notificationError) {
      console.error("Error sending notification:", notificationError)
      // لا نوقف العملية إذا فشل الإشعار
    }

    return NextResponse.json({
      success: true,
      message: "تم تقديم الطلبية للمرحلة التالية بنجاح",
      data: updatedStatus,
    })
  } catch (error) {
    console.error("Error advancing order:", error)
    return NextResponse.json({ error: "حدث خطأ في تقديم الطلبية" }, { status: 500 })
  }
}

function mapStageToNotificationStatus(stageName: string): string | null {
  const stageMap: Record<string, string> = {
    "استلام الطلبية": "received",
    "تحضير الطلبية": "preparing",
    "التدقيق والمراجعة": "quality_check",
    "جاهز للشحن": "ready_to_ship",
    "تم الشحن": "shipped",
    "تم التسليم": "delivered",
  }

  return stageMap[stageName] || null
}
