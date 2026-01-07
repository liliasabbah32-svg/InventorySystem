// app/api/customer-categories/route.ts
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

// GET all customer categories
export async function GET() {
  try {
    const categories = await sql`SELECT * FROM customer_categories ORDER BY id`
    return NextResponse.json({ categories })
  } catch (error) {
    console.error("Error fetching customer categories:", error)
    return NextResponse.json({ error: "Failed to fetch customer categories" }, { status: 500 })
  }
}

// POST a new customer category
export async function POST(request: NextRequest) {
  try {
    const body = await request.json()
    const { name, discount } = body

    if (!name) {
      return NextResponse.json({ error: "Category name is required" }, { status: 400 })
    }

    // Get last ID
    const lastIdRow = await sql`SELECT MAX(id) AS max_id FROM customer_categories`
    const lastId = lastIdRow[0]?.max_id ?? 0
    const newId = lastId + 1

    const result = await sql`
      INSERT INTO customer_categories (id, name, discount)
      VALUES (${newId}, ${name}, ${discount || 0})
      RETURNING *
    `

    return NextResponse.json({ category: result[0] }, { status: 201 })
  } catch (error) {
    console.error("Error creating customer category:", error)
    return NextResponse.json({ error: "Failed to create customer category" }, { status: 500 })
  }
}

// PUT to update an existing category
export async function PUT(request: NextRequest) {
  try {
    const { id, name, discount } = await request.json()

    if (!id) {
      return NextResponse.json({ error: "Category ID is required" }, { status: 400 })
    }

    const updated = await sql`
      UPDATE customer_categories
      SET
        name = COALESCE(${name}, name),
        discount = COALESCE(${discount}, discount),
        updated_at = CURRENT_TIMESTAMP
      WHERE id = ${id}
      RETURNING *
    `

    if (!updated || updated.length === 0) {
      return NextResponse.json({ error: "Category not found" }, { status: 404 })
    }

    return NextResponse.json({ category: updated[0] })
  } catch (error) {
    console.error("Error updating customer category:", error)
    return NextResponse.json({ error: "Failed to update customer category" }, { status: 500 })
  }
}
