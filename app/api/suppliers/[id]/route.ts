import { type NextRequest, NextResponse } from "next/server"
import { neon } from "@neondatabase/serverless"


import { Pool } from "pg"

let sql: any = null

try {
  if (!process.env.DATABASE_URL) {
    console.error("[v0] DATABASE_URL environment variable is not set")
  } else {
    const dbUrl = process.env.DATABASE_URL

    if (dbUrl.includes("localhost") || dbUrl.includes("127.0.0.1")) {
      console.log("[v0] Using local PostgreSQL with pg Pool")
      const pool = new Pool({ connectionString: dbUrl })
      sql = async (strings: TemplateStringsArray, ...values: any[]) => {
        const client = await pool.connect()
        try {
          const query =
            strings.reduce(
              (prev, curr, i) =>
                prev + curr + (i < values.length ? `$${i + 1}` : ""),
              ""
            )
          const result = await client.query(query, values)
          return result.rows
        } finally {
          client.release()
        }
      }
    } else {
      console.log("[v0] Using Neon serverless client")
      sql = neon(dbUrl)
    }

    console.log("[v0] Database client initialized successfully")
  }
} catch (error) {
  console.error("[v0] Failed to initialize DB client:", error)
  sql = null
}

export default sql

export async function PUT(request: NextRequest, { params }: { params: { id: string } }) {
  try {
    const { id } = params
    const data = await request.json()

    const result = await sql`
      UPDATE suppliers 
      SET 
        name = ${data.supplier_name || data.name},
        mobile1 = ${data.mobile1 || data.phone1},
        mobile2 = ${data.mobile2 || data.phone2},
        whatsapp1 = ${data.whatsapp1},
        whatsapp2 = ${data.whatsapp2},
        city = ${data.city},
        address = ${data.address},
        email = ${data.email},
        status = ${data.status},
        business_nature = ${data.business_nature},
        representative = ${data.salesman || data.representative},
        classification = ${data.classifications || data.classification},
        account_open_date = ${data.account_opening_date},
        transaction_notes = ${data.movement_notes || data.transaction_notes},
        general_notes = ${data.general_notes},
        web_username = ${data.web_username},
        web_password = ${data.web_password},
        api_key = ${data.api_number || ""}
      WHERE id = ${id}
      RETURNING *
    `

    return NextResponse.json(result[0])
  } catch (error) {
    console.error("Error updating supplier:", error)
    return NextResponse.json({ error: "Failed to update supplier" }, { status: 500 })
  }
}

export async function DELETE(request: NextRequest, { params }: { params: { id: string } }) {
  try {
    const { id } = params

    await sql`DELETE FROM suppliers WHERE id = ${id}`

    return NextResponse.json({ message: "Supplier deleted successfully" })
  } catch (error) {
    console.error("Error deleting supplier:", error)
    return NextResponse.json({ error: "Failed to delete supplier" }, { status: 500 })
  }
}
