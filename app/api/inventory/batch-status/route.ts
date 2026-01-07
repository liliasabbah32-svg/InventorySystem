import { type NextRequest, NextResponse } from "next/server"
import { changeLotStatus, createLotTransaction } from "@/lib/lot-management"

export async function POST(request: NextRequest) {
  try {
    const body = await request.json()

    const requiredFields = ["lot_id", "new_status"]
    for (const field of requiredFields) {
      if (!body[field]) {
        return NextResponse.json({ error: `الحقل ${field} مطلوب` }, { status: 400 })
      }
    }

    const lotId = Number.parseInt(body.lot_id)
    const newStatus = body.new_status
    const notes = body.notes || ""
    const changedBy = body.changed_by || "مستخدم"

    // Validate status
    const validStatuses = ["new", "in_use", "finished", "damaged"]
    if (!validStatuses.includes(newStatus)) {
      return NextResponse.json({ error: "حالة غير صالحة" }, { status: 400 })
    }

    // Change the status
    await changeLotStatus(lotId, newStatus, notes, changedBy)

    // Create a status change transaction
    const transaction = await createLotTransaction({
      lot_id: lotId,
      transaction_type: "status_change",
      quantity: 0,
      notes: `تغيير حالة إلى ${getStatusDisplay(newStatus)}${notes ? ` - ${notes}` : ""}`,
      created_by: changedBy,
    })

    return NextResponse.json({
      message: "تم تغيير حالة الدفعة بنجاح",
      transaction_id: transaction.id,
    })
  } catch (error) {
    console.error("[v0] Error changing lot status:", error)
    return NextResponse.json(
      { error: error instanceof Error ? error.message : "فشل في تغيير حالة الدفعة" },
      { status: 500 },
    )
  }
}

function getStatusDisplay(status: string): string {
  const statusMap = {
    new: "جديد",
    in_use: "قيد الاستخدام",
    finished: "منتهي",
    damaged: "تالف",
  }
  return statusMap[status as keyof typeof statusMap] || status
}
