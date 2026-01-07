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
    const data = await request.json()
    const { id } = params

    const isActive = data.status === "نشط" || data.status !== "غير نشط"

    const result = await sql`
      UPDATE item_groups SET
        group_name = ${data.group_name},
        description = ${data.description},
        is_active = ${isActive},
        updated_at = CURRENT_TIMESTAMP
      WHERE id = ${id}
      RETURNING *
    `

    const formattedResult = {
      ...result[0],
      status: result[0].is_active ? "نشط" : "غير نشط",
    }

    return NextResponse.json(formattedResult)
  } catch (error) {
    console.error("Error updating item group:", error)
    return NextResponse.json({ error: "Failed to update item group" }, { status: 500 })
  }
}

export async function DELETE(request: NextRequest, { params }: { params: { id: string } }) {
  try {
    const { id } = params

    await sql`UPDATE item_groups set status = 2 WHERE id = ${id}`

    return NextResponse.json({ message: "Item group deleted successfully" })
  } catch (error) {
    console.error("Error deleting item group:", error)
    return NextResponse.json({ error: "Failed to delete item group" }, { status: 500 })
  }
}
