import { type NextRequest, NextResponse } from "next/server"
import { neon } from "@neondatabase/serverless"
import { Pool } from "pg"

// ----------------- Types -----------------
interface ItemGroupDB {
  id: number
  group_code: string
  group_name: string
  description: string | null
  parent_group_id: number | null
  is_active: boolean
  product_count: number | null
  created_at: string
  updated_at: string
}

interface ItemGroup extends Omit<ItemGroupDB, "is_active"> {
  status: "نشط" | "غير نشط"
  product_count: number
}

// ----------------- DB Client -----------------
let sql: ((strings: TemplateStringsArray, ...values: any[]) => Promise<any[]>) | null = null

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
          const query = strings.reduce(
            (prev, curr, i) => prev + curr + (i < values.length ? `$${i + 1}` : ""),
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

// ----------------- API Handlers -----------------
export async function GET() {
  if (!sql) return NextResponse.json({ error: "Database not initialized" }, { status: 500 })

  try {
    const itemGroups: ItemGroupDB[] = await sql`
      SELECT 
        id,
        group_code,
        group_name,
        description,
        parent_group_id,
        is_active,
        product_count,
        created_at,
        updated_at
      FROM item_groups_with_count
      ORDER BY id 
    `

    const formattedGroups: ItemGroup[] = itemGroups.map((group) => ({
      ...group,
      status: group.is_active ? "نشط" : "غير نشط",
      product_count: group.product_count ?? 0,
    }))

    return NextResponse.json(formattedGroups)
  } catch (error: unknown) {
    const message = error instanceof Error ? error.message : String(error)
    console.error("Error fetching item groups:", message)
    return NextResponse.json({ error: message }, { status: 500 })
  }
}

export async function POST(request: NextRequest) {
  if (!sql) return NextResponse.json({ error: "Database not initialized" }, { status: 500 })

  try {
    const data = await request.json()

    // Check for duplicate group_number
    if (data.group_code) {
      const existingGroup: { id: number }[] = await sql`
        SELECT id FROM item_groups WHERE group_code = ${data.group_code}
      `
      if (existingGroup.length > 0) {
        return NextResponse.json({ error: "رقم المجموعة موجود مسبقاً" }, { status: 400 })
      }
    } else {
      // توليد رقم جديد إذا لم يتم توفيره
      const lastGroup: { group_code: string }[] = await sql`
        SELECT group_code FROM item_groups 
        ORDER BY created_at DESC 
        LIMIT 1
      `

      let newNumber = 1
      if (lastGroup.length > 0) {
        const lastCode = lastGroup[0].group_code
        const match = lastCode.match(/(\d+)$/)
        if (match) newNumber = parseInt(match[1]) + 1
      }

      data.group_code = `G${newNumber.toString().padStart(7, "0")}`
    }

    const isActive = data.status === "نشط" || data.status !== "غير نشط"

    const result: ItemGroupDB[] = await sql`
      INSERT INTO item_groups (
        group_code, group_name, description, is_active
      ) VALUES (
        ${data.group_code}, ${data.group_name}, ${data.description || ""}, ${isActive}
      ) RETURNING *
    `

    const formattedResult: ItemGroup = {
      ...result[0],
      status: result[0].is_active ? "نشط" : "غير نشط",
      product_count: result[0].product_count ?? 0,
    }

    return NextResponse.json(formattedResult, { status: 201 })
  } catch (error: unknown) {
    const message = error instanceof Error ? error.message : String(error)
    console.error("Error creating item group:", message)
    return NextResponse.json({ error: message }, { status: 500 })
  }
}
