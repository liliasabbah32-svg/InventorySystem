import { type NextRequest, NextResponse } from "next/server"
import { neon } from "@neondatabase/serverless"

const sql = neon(process.env.DATABASE_URL!)

export async function GET(request: NextRequest, { params }: { params: { id: string } }) {
  try {
    const movementId = Number.parseInt(params.id)

    const result = await sql`
      SELECT 
        lt.*,
        pl.lot_number,
        pl.product_id,
        p.product_name,
        p.product_code,
        p.main_unit,
        pl.current_quantity,
        pl.available_quantity,
        pl.status,
        s.supplier_name
      FROM lot_transactions lt
      JOIN product_lots pl ON lt.lot_id = pl.id
      JOIN products p ON pl.product_id = p.id
      LEFT JOIN suppliers s ON pl.supplier_id = s.id
      WHERE lt.id = ${movementId}
    `

    if (result.length === 0) {
      return NextResponse.json({ error: "حركة الدفعة غير موجودة" }, { status: 404 })
    }

    return NextResponse.json(result[0])
  } catch (error) {
    console.error("[v0] Error fetching batch movement:", error)
    return NextResponse.json({ error: "فشل في تحميل حركة الدفعة" }, { status: 500 })
  }
}

export async function DELETE(request: NextRequest, { params }: { params: { id: string } }) {
  try {
    const movementId = Number.parseInt(params.id)

    // Get movement details before deletion
    const movement = await sql`
      SELECT * FROM lot_transactions WHERE id = ${movementId}
    `

    if (movement.length === 0) {
      return NextResponse.json({ error: "حركة الدفعة غير موجودة" }, { status: 404 })
    }

    // Check if this is the latest movement for the lot
    const latestMovement = await sql`
      SELECT id FROM lot_transactions 
      WHERE lot_id = ${movement[0].lot_id}
      ORDER BY created_at DESC 
      LIMIT 1
    `

    if (latestMovement[0]?.id !== movementId) {
      return NextResponse.json({ error: "يمكن حذف آخر حركة فقط للدفعة" }, { status: 400 })
    }

    // Reverse the movement effect on lot quantities
    const movementData = movement[0]
    if (movementData.transaction_type !== "status_change") {
      let quantityAdjustment = 0

      if (["purchase", "return", "adjustment"].includes(movementData.transaction_type)) {
        quantityAdjustment = -movementData.quantity // Reverse increase
      } else if (["sale", "transfer", "damage"].includes(movementData.transaction_type)) {
        quantityAdjustment = movementData.quantity // Reverse decrease
      }

      if (quantityAdjustment !== 0) {
        await sql`
          UPDATE product_lots 
          SET 
            current_quantity = current_quantity + ${quantityAdjustment},
            updated_at = CURRENT_TIMESTAMP
          WHERE id = ${movementData.lot_id}
        `
      }
    }

    // Delete the movement
    await sql`DELETE FROM lot_transactions WHERE id = ${movementId}`

    return NextResponse.json({ message: "تم حذف حركة الدفعة بنجاح" })
  } catch (error) {
    console.error("[v0] Error deleting batch movement:", error)
    return NextResponse.json({ error: "فشل في حذف حركة الدفعة" }, { status: 500 })
  }
}
