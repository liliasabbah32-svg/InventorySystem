import { type NextRequest, NextResponse } from "next/server"
import { getCustomers } from "@/lib/orders"

export async function GET(request: NextRequest) {
  try {
    console.log("[v0] Customers API GET called")
    const customers = await getCustomers()
    console.log("[v0] Returning customers:", customers.length, "records")
    return NextResponse.json(customers)
  } catch (error) {
    console.error("[v0] Customers API error:", error)
    return NextResponse.json({ error: "حدث خطأ في جلب بيانات العملاء" }, { status: 500 })
  }
}
