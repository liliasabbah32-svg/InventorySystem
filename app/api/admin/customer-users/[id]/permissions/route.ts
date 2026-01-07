import { type NextRequest, NextResponse } from "next/server"
import { updateCustomerPermissions } from "@/lib/customer-auth"

export async function PUT(request: NextRequest, { params }: { params: Promise<{ id: string }> }) {
  try {
    const { id } = await params
    const userId = Number.parseInt(id)
    const body = await request.json()

    await updateCustomerPermissions(userId, body)

    return NextResponse.json({ success: true })
  } catch (error) {
    console.error("Update permissions error:", error)
    return NextResponse.json({ error: "حدث خطأ أثناء تحديث الصلاحيات" }, { status: 500 })
  }
}
