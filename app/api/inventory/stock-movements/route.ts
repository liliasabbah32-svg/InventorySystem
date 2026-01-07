import { type NextRequest, NextResponse } from "next/server"
import { createStockMovement, getInventoryTransactions } from "@/lib/inventory"

export async function GET(request: NextRequest) {
  try {
    const { searchParams } = new URL(request.url)
    const productId = searchParams.get("productId")
    const limit = Number.parseInt(searchParams.get("limit") || "50")
    const organizationId = Number.parseInt(searchParams.get("organizationId") || "1")

    const transactions = await getInventoryTransactions(
      productId ? Number.parseInt(productId) : undefined,
      limit,
      organizationId,
    )

    return NextResponse.json(transactions)
  } catch (error) {
    console.error("Stock movements API error:", error)
    return NextResponse.json({ error: "حدث خطأ في جلب حركات المخزون" }, { status: 500 })
  }
}

export async function POST(request: NextRequest) {
  try {
    const movementData = await request.json()
    const organizationId = 1 // Get from auth context in real app

    const movement = await createStockMovement(movementData, organizationId)

    return NextResponse.json(movement)
  } catch (error) {
    console.error("Create stock movement API error:", error)
    return NextResponse.json({ error: "حدث خطأ في إنشاء حركة المخزون" }, { status: 500 })
  }
}
