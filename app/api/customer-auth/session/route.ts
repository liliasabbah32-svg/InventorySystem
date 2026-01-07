import { NextResponse } from "next/server"
import { getCustomerSession } from "@/lib/customer-auth"

export async function GET() {
  try {
    const session = await getCustomerSession()

    if (!session) {
      return NextResponse.json({ error: "غير مصرح" }, { status: 401 })
    }

    return NextResponse.json({ session })
  } catch (error) {
    console.error("Get customer session error:", error)
    return NextResponse.json({ error: "حدث خطأ أثناء جلب الجلسة" }, { status: 500 })
  }
}
