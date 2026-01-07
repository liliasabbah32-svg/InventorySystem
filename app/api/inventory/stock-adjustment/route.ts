import { type NextRequest, NextResponse } from "next/server"
import { adjustStock } from "@/lib/inventory"

export async function POST(request: NextRequest) {
  try {
    const { productId, newQuantity, reason, userId } = await request.json()
    const organizationId = 1 // Get from auth context in real app

    if (!productId || newQuantity === undefined || !reason || !userId) {
      return NextResponse.json({ error: "البيانات المطلوبة غير مكتملة" }, { status: 400 })
    }

    const result = await adjustStock(productId, newQuantity, reason, userId, organizationId)

    return NextResponse.json(result)
  } catch (error) {
    console.error("Stock adjustment API error:", error)
    return NextResponse.json({ error: "حدث خطأ في تعديل المخزون" }, { status: 500 })
  }
}
