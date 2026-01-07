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

// ❌ Removed export default sql

// ✅ Named export for GET
export async function GET() {
  try {
    await sql`
      CREATE TABLE IF NOT EXISTS pricecategory (
        id SERIAL PRIMARY KEY,
        name VARCHAR(50) NOT NULL,
        name_en VARCHAR(50),
        description TEXT,
        is_active BOOLEAN DEFAULT true,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      )
    `

    const prices = await sql`
      SELECT 
        id,
        name,
        name_en,
        description,
        is_active,
        created_at,
        updated_at
      FROM pricecategory
      WHERE is_active = true
      ORDER BY id
    `

    return NextResponse.json(prices)
  } catch (error) {
    console.error("Error fetching price categories:", error)
    return NextResponse.json({ error: "Failed to fetch price categories" }, { status: 500 })
  }
}

// ✅ Named export for POST
export async function POST(request: NextRequest) {
  try {
    const data = await request.json()

    if (!data.name) {
      return NextResponse.json({ error: "اسم الفئة مطلوب" }, { status: 400 })
    }

    const existingprice = await sql`
      SELECT id FROM pricecategory WHERE name = ${data.name}
    `

    if (existingprice.length > 0) {
      return NextResponse.json({ error: "اسم الفئة موجود مسبقاً" }, { status: 400 })
    }

    if (!data.name_en || data.name_en.trim() === "") {
      data.name_en = data.name
    }

    const result = await sql`
      INSERT INTO pricecategory (
        name, name_en, description, is_active
      ) VALUES ( 
        ${data.name}, 
        ${data.name_en || ""}, 
        ${data.description || ""}, 
        ${data.is_active !== false}
      ) RETURNING *
    `

    return NextResponse.json(result[0], { status: 201 })
  } catch (error) {
    console.error("Error creating price category:", error)
    return NextResponse.json({ error: "Failed to create price category" }, { status: 500 })
  }
}
