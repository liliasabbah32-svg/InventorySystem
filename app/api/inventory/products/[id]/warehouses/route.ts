import { type NextRequest, NextResponse } from "next/server"
import { neon } from "@neondatabase/serverless"

const sql = neon(process.env.DATABASE_URL!)

export async function GET(request: NextRequest, { params }: { params: { id: string } }) {
  try {
    const productId = params.id

    const warehouses = await sql`
      SELECT 
        pw.id,
        pw.warehouse_id,
        w.warehouse_name,
        w.warehouse_code,
        w.location,
        pw.floor,
        pw.area,
        pw.shelf,
        COALESCE(pw.quantity, 0) as quantity,
        COALESCE(pw.reserved_quantity, 0) as reserved_quantity,
        COALESCE(pw.quantity, 0) - COALESCE(pw.reserved_quantity, 0) as available_quantity,
        COALESCE(pw.min_stock_level, 0) as min_stock_level,
        COALESCE(pw.max_stock_level, 0) as max_stock_level,
        CASE 
          WHEN COALESCE(pw.quantity, 0) = 0 THEN 'نفد المخزون'
          WHEN COALESCE(pw.quantity, 0) <= COALESCE(pw.min_stock_level, 0) THEN 'تحت الحد الأدنى'
          ELSE 'متوفر'
        END as status,
        CASE 
          WHEN COALESCE(pw.quantity, 0) = 0 THEN 'danger'
          WHEN COALESCE(pw.quantity, 0) <= COALESCE(pw.min_stock_level, 0) THEN 'warning'
          ELSE 'success'
        END as status_color
      FROM product_warehouses pw
      JOIN warehouses w ON pw.warehouse_id = w.id
      WHERE pw.product_id = ${productId} AND w.is_active = true
      ORDER BY w.warehouse_name
    `

    return NextResponse.json(warehouses)
  } catch (error) {
    console.error("Error fetching product warehouses:", error)
    return NextResponse.json({ error: "Failed to fetch product warehouses" }, { status: 500 })
  }
}

export async function POST(request: NextRequest, { params }: { params: { id: string } }) {
  try {
    const productId = params.id
    const body = await request.json()
    const { warehouse_id, quantity, reserved_quantity, min_stock_level, max_stock_level, floor, area, shelf } = body

    const result = await sql`
      INSERT INTO product_warehouses (
        product_id, warehouse_id, quantity, reserved_quantity, 
        min_stock_level, max_stock_level, floor, area, shelf
      ) VALUES (
        ${productId}, ${warehouse_id}, ${quantity || 0}, ${reserved_quantity || 0},
        ${min_stock_level || 0}, ${max_stock_level || 0}, ${floor || ""}, ${area || ""}, ${shelf || ""}
      )
      ON CONFLICT (product_id, warehouse_id) 
      DO UPDATE SET
        quantity = ${quantity || 0},
        reserved_quantity = ${reserved_quantity || 0},
        min_stock_level = ${min_stock_level || 0},
        max_stock_level = ${max_stock_level || 0},
        floor = ${floor || ""},
        area = ${area || ""},
        shelf = ${shelf || ""},
        updated_at = CURRENT_TIMESTAMP
      RETURNING *
    `

    return NextResponse.json(result[0])
  } catch (error) {
    console.error("Error updating product warehouse:", error)
    return NextResponse.json({ error: "Failed to update product warehouse" }, { status: 500 })
  }
}
