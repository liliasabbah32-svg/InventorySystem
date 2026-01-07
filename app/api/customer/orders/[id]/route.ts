import { type NextRequest, NextResponse } from "next/server"
import { getCustomerSession } from "@/lib/customer-auth"
import { sql } from "@vercel/postgres"

export async function GET(request: NextRequest, { params }: { params: Promise<{ id: string }> }) {
  try {
    const session = await getCustomerSession()

    if (!session) {
      return NextResponse.json({ error: "غير مصرح" }, { status: 401 })
    }

    if (!session.permissions.can_view_orders) {
      return NextResponse.json({ error: "ليس لديك صلاحية لعرض الطلبيات" }, { status: 403 })
    }

    const { id } = await params
    const orderId = Number.parseInt(id)
    const customerId = session.customer.id

    // Get order
    const orderResult = await sql`
      SELECT id, order_date, total_amount, status, notes
      FROM sales_orders
      WHERE id = ${orderId} AND customer_id = ${customerId}
    `

    if (orderResult.rows.length === 0) {
      return NextResponse.json({ error: "الطلبية غير موجودة" }, { status: 404 })
    }

    const order = orderResult.rows[0]

    // Get order items
    const itemsResult = await sql`
      SELECT soi.id, soi.quantity, soi.unit_price, soi.total_price,
             p.name as product_name
      FROM sales_order_items soi
      JOIN products p ON soi.product_id = p.id
      WHERE soi.sales_order_id = ${orderId}
      ORDER BY soi.id
    `

    return NextResponse.json({
      ...order,
      items: itemsResult.rows,
    })
  } catch (error) {
    console.error("Get order details error:", error)
    return NextResponse.json({ error: "حدث خطأ أثناء تحميل تفاصيل الطلبية" }, { status: 500 })
  }
}
