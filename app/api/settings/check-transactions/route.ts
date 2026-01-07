import { NextResponse } from "next/server"
import { neon } from "@neondatabase/serverless"

const sql = neon(process.env.DATABASE_URL!)

export async function GET() {
  try {
    // Check if there are any transactions in the system
    const [invoices] = await sql`SELECT COUNT(*) as count FROM invoices LIMIT 1`
    const [orders] = await sql`SELECT COUNT(*) as count FROM sales_orders LIMIT 1`
    const [purchases] = await sql`SELECT COUNT(*) as count FROM purchase_orders LIMIT 1`

    const hasTransactions =
      Number.parseInt(invoices.count) > 0 || Number.parseInt(orders.count) > 0 || Number.parseInt(purchases.count) > 0

    return NextResponse.json({ hasTransactions })
  } catch (error) {
    console.error("Error checking transactions:", error)
    return NextResponse.json({ hasTransactions: false }, { status: 500 })
  }
}
