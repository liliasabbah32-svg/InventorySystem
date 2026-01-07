import { type NextRequest, NextResponse } from "next/server"
import { changeLotStatus } from "@/lib/lot-management"

export async function PUT(request: NextRequest, { params }: { params: { id: string } }) {
  try {
    const lotId = Number.parseInt(params.id)
    if (isNaN(lotId)) {
      return NextResponse.json({ error: "معرف الدفعة غير صحيح" }, { status: 400 })
    }

    const body = await request.json()
    const { status, notes, changed_by } = body

    if (!status || !["new", "in_use", "finished", "damaged"].includes(status)) {
      return NextResponse.json({ error: "حالة الدفعة غير صحيحة" }, { status: 400 })
    }

    await changeLotStatus(lotId, status, notes, changed_by)

    return NextResponse.json({ success: true, message: "تم تغيير حالة الدفعة بنجاح" })
  } catch (error) {
    console.error("Error changing lot status:", error)
    return NextResponse.json({ error: "فشل في تغيير حالة الدفعة" }, { status: 500 })
  }
}
