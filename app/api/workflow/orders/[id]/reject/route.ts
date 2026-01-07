import { type NextRequest, NextResponse } from "next/server"
import { rejectOrderToAlternativeStage } from "@/lib/workflow"

export async function POST(request: NextRequest, { params }: { params: { id: string } }) {
  try {
    const orderId = Number.parseInt(params.id)
    const body = await request.json()

    const { orderType, performedByUser, performedByDepartment, reason, notes } = body

    if (!orderType || !performedByUser || !performedByDepartment || !reason) {
      return NextResponse.json({ error: "جميع الحقول المطلوبة يجب أن تكون موجودة" }, { status: 400 })
    }

    const updatedStatus = await rejectOrderToAlternativeStage(
      orderId,
      orderType,
      performedByUser,
      performedByDepartment,
      reason,
      notes,
    )

    return NextResponse.json({
      success: true,
      message: "تم رفض الطلبية وإرجاعها للمرحلة المناسبة",
      data: updatedStatus,
    })
  } catch (error) {
    console.error("Error rejecting order:", error)
    return NextResponse.json({ error: "حدث خطأ في رفض الطلبية" }, { status: 500 })
  }
}
