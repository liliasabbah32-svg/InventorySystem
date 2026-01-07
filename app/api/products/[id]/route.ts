import { type NextRequest, NextResponse } from "next/server"
import { neon } from "@neondatabase/serverless"

const sql = neon(process.env.DATABASE_URL!)

export async function GET(request: NextRequest, { params }: { params: { id: string } }) {
  try {
    const result = await sql`
      SELECT * FROM products WHERE id = ${params.id}
    `

    if (result.length === 0) {
      return NextResponse.json({ error: "Product not found" }, { status: 404 })
    }

    return NextResponse.json(result[0])
  } catch (error) {
    console.error("Error fetching product:", error)
    return NextResponse.json({ error: "Failed to fetch product" }, { status: 500 })
  }
}

export async function PUT(request: NextRequest, { params }: { params: { id: string } }) {
  try {
    const data = await request.json()

    const result = await sql`
      UPDATE products SET
        product_name = ${data.product_name || data.name},
        description = ${data.description},
        category = ${data.category},
        main_unit = ${data.main_unit},
        secondary_unit = ${data.secondary_unit},
        conversion_factor = ${data.conversion_factor},
        barcode = ${data.barcode},
        original_number = ${data.original_number},
        manufacturer_number = ${data.manufacturer_number},
        last_purchase_price = ${data.last_purchase_price},
        currency = ${data.currency},
        product_type = ${data.product_type},
        has_expiry = ${data.has_expiry},
        has_batch = ${data.has_batch},
        has_colors = ${data.has_colors},
        max_quantity = ${data.max_quantity},
        order_quantity = ${data.order_quantity},
        status = ${data.status},
        product_image = ${data.product_image},
        general_notes = ${data.general_notes},
        classifications = ${data.classifications}
      WHERE id = ${params.id}
      RETURNING *
    `

    if (result.length === 0) {
      return NextResponse.json({ error: "Product not found" }, { status: 404 })
    }

    return NextResponse.json(result[0])
  } catch (error) {
    console.error("Error updating product:", error)
    return NextResponse.json({ error: "Failed to update product" }, { status: 500 })
  }
}

export async function DELETE(request: NextRequest, { params }: { params: { id: string } }) {
  try {
    const result = await sql`
      DELETE FROM products WHERE id = ${params.id}
      RETURNING *
    `

    if (result.length === 0) {
      return NextResponse.json({ error: "Product not found" }, { status: 404 })
    }

    return NextResponse.json({ message: "Product deleted successfully" })
  } catch (error) {
    console.error("Error deleting product:", error)
    return NextResponse.json({ error: "Failed to delete product" }, { status: 500 })
  }
}
