import { type NextRequest, NextResponse } from "next/server"
import { toggleCustomerUserStatus } from "@/lib/customer-auth"

export async function PUT(request: NextRequest, { params }: { params: Promise<{ id: string }> }) {
  try {
    const { id } = await params
    const userId = Number.parseInt(id)

    await toggleCustomerUserStatus(userId)

    return NextResponse.json({ success: true })
  } catch (error) {
    console.error("Toggle user status error:", error)
    return NextResponse.json({ error: "حدث خطأ أثناء تغيير حالة المستخدم" }, { status: 500 })
  }
}
