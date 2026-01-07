import { type NextRequest, NextResponse } from "next/server"
import { getOrderWorkflowStatus, getOrderWorkflowHistory } from "@/lib/workflow"

export async function GET(request: NextRequest, { params }: { params: { id: string } }) {
  try {
    const orderId = Number.parseInt(params.id)
    const { searchParams } = new URL(request.url)
    const orderType = searchParams.get("type") as "sales" | "purchase"

    if (!orderType || !["sales", "purchase"].includes(orderType)) {
      return NextResponse.json({ error: "نوع الطلبية مطلوب ويجب أن يكون sales أو purchase" }, { status: 400 })
    }

    const [status, history] = await Promise.all([
      getOrderWorkflowStatus(orderId, orderType),
      getOrderWorkflowHistory(orderId, orderType),
    ])

    return NextResponse.json({
      success: true,
      data: {
        status,
        history,
      },
    })
  } catch (error) {
    console.error("Error fetching order workflow status:", error)
    return NextResponse.json({ error: "حدث خطأ في جلب حالة الطلبية" }, { status: 500 })
  }
}
