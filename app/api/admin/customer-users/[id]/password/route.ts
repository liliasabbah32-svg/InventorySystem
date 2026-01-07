import { NextRequest, NextResponse } from "next/server"
import { updateCustomerPassword } from "@/lib/customer-auth"

export async function PUT(
  request: NextRequest,
  { params }: { params: { id: string } }
) {
  try {
    const userId = Number(params.id)

    if (Number.isNaN(userId)) {
      return NextResponse.json(
        { error: "معرّف المستخدم غير صالح" },
        { status: 400 }
      )
    }

    const body = await request.json()
    const { password } = body

    if (!password || typeof password !== "string") {
      return NextResponse.json(
        { error: "كلمة المرور مطلوبة" },
        { status: 400 }
      )
    }

    await updateCustomerPassword(userId, password)

    return NextResponse.json({ success: true })
  } catch (error) {
    console.error("Update password error:", error)

    return NextResponse.json(
      { error: "حدث خطأ أثناء تغيير كلمة المرور" },
      { status: 500 }
    )
  }
}
