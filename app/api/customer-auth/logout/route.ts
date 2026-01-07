import { NextResponse } from "next/server"
import { logoutCustomer } from "@/lib/customer-auth"

export async function POST() {
  try {
    await logoutCustomer()
    return NextResponse.json({ success: true })
  } catch (error) {
    console.error("Customer logout error:", error)
    return NextResponse.json({ error: "حدث خطأ أثناء تسجيل الخروج" }, { status: 500 })
  }
}
