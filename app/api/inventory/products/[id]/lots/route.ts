import { type NextRequest, NextResponse } from "next/server"
import { neon } from "@neondatabase/serverless"

const sql = neon(process.env.DATABASE_URL!)

export async function GET(request: NextRequest, { params }: { params: { id: string } }) {
  try {
    const productId = params.id

    const lots = await sql`
      SELECT 
        pl.id,
        pl.lot_number,
        pl.manufacturing_date,
        pl.expiry_date,
        pl.supplier_id,
        s.supplier_name,
        pl.initial_quantity,
        pl.current_quantity,
        pl.reserved_quantity,
        (pl.current_quantity - pl.reserved_quantity) as available_quantity,
        pl.unit_cost,
        pw.warehouse_id,
        w.warehouse_name,
        pw.floor,
        pw.area,
        pw.shelf,
        pl.status,
        pl.notes
      FROM product_lots pl
      LEFT JOIN suppliers s ON pl.supplier_id = s.id
      LEFT JOIN product_warehouses pw ON pl.product_id = pw.product_id
      LEFT JOIN warehouses w ON pw.warehouse_id = w.id
      WHERE pl.product_id = ${productId}
      ORDER BY pl.expiry_date, pl.lot_number
    `

    return NextResponse.json(lots)
  } catch (error) {
    console.error("Error fetching product lots:", error)
    return NextResponse.json({ error: "فشل في جلب بيانات الدفعات" }, { status: 500 })
  }
}
