import { type NextRequest, NextResponse } from "next/server"
import { neon } from "@neondatabase/serverless"

const sql = neon(process.env.DATABASE_URL!)

export async function GET(request: NextRequest, { params }: { params: { id: string } }) {
  try {
    const lotId = params.id

    if (!lotId) {
      return NextResponse.json({ error: "معرف الباتش مطلوب" }, { status: 400 })
    }

    const result = await sql`
      SELECT 
        pl.id as lot_id,
        pl.lot_number,
        p.product_code,
        p.product_name,
        p.color_code,
        p.color_name,
        p.model_name,
        pl.manufacturing_date,
        pl.expiry_date,
        po.order_date as purchase_date,
        pl.initial_quantity,
        pl.current_quantity,
        pl.unit_cost,
        pl.status,
        CASE 
          WHEN pl.status = 'new' THEN 'جديد'
          WHEN pl.status = 'in_use' THEN 'قيد الاستخدام'
          WHEN pl.status = 'finished' THEN 'منتهي'
          WHEN pl.status = 'damaged' THEN 'تالف/مغلق'
          ELSE pl.status
        END as status_display,
        w.warehouse_name,
        pws.floor,
        pws.shelf,
        pws.location,
        s.supplier_name,
        p.barcode
      FROM product_lots pl
      JOIN products p ON pl.product_id = p.id
      LEFT JOIN purchase_orders po ON pl.purchase_order_id = po.id
      LEFT JOIN product_warehouse_stock pws ON p.id = pws.product_id AND pl.lot_number = pws.batch_number
      LEFT JOIN warehouses w ON pws.warehouse_name = w.warehouse_name
      LEFT JOIN suppliers s ON pl.supplier_id = s.id
      WHERE pl.id = ${lotId}
      LIMIT 1
    `

    if (result.length === 0) {
      return NextResponse.json({ error: "لم يتم العثور على الباتش" }, { status: 404 })
    }

    return NextResponse.json(result[0])
  } catch (error) {
    console.error("Error fetching batch details:", error)
    return NextResponse.json({ error: "فشل في تحميل تفاصيل الباتش" }, { status: 500 })
  }
}
