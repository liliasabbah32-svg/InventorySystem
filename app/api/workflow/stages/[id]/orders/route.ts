import { type NextRequest, NextResponse } from "next/server"
import { getOrdersByStage } from "@/lib/workflow"

export async function GET(request: NextRequest, { params }: { params: { id: string } }) {
  try {
    const stageId = Number.parseInt(params.id)
    const { searchParams } = new URL(request.url)
    const department = searchParams.get("department")

    const orders = await getOrdersByStage(stageId, department || undefined)

    return NextResponse.json({
      success: true,
      data: orders,
    })
  } catch (error) {
    console.error("Error fetching orders by stage:", error)
    return NextResponse.json({ error: "حدث خطأ في جلب الطلبيات" }, { status: 500 })
  }
}
