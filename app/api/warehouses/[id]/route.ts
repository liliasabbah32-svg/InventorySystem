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
type Warehouse = {
  id: number
  warehouse_code: string
  warehouse_name: string
  warehouse_name_en?: string
  description?: string
  location?: string
  is_active: boolean
  created_at: string
  updated_at: string
}
export async function PUT(request: NextRequest) {
  try {
    const data = await request.json();

    if (!data.id) {
      return NextResponse.json({ error: "معرف المستودع مطلوب" }, { status: 400 });
    }

    if (!data.warehouse_name?.trim() || !data.warehouse_code?.trim()) {
      return NextResponse.json({ error: "اسم المستودع ورمزه مطلوبان" }, { status: 400 });
    }

    // Optional: check if the new warehouse_code is already used by another warehouse
    const existing = await sql`
      SELECT id FROM warehouses
      WHERE warehouse_code = ${data.warehouse_code} AND id != ${data.id}
    `;
    if (existing.length > 0) {
      return NextResponse.json({ error: "رمز المستودع موجود مسبقاً" }, { status: 400 });
    }

    const result: Warehouse[] = await sql`
      UPDATE warehouses
      SET
        warehouse_code = ${data.warehouse_code.trim()},
        warehouse_name = ${data.warehouse_name.trim()},
        warehouse_name_en = ${data.warehouse_name_en?.trim() || ""},
        description = ${data.description?.trim() || ""},
        location = ${data.location?.trim() || ""},
        is_active = ${data.is_active !== false},
        updated_at = CURRENT_TIMESTAMP
      WHERE id = ${data.id}
      RETURNING *
    `;

    if (result.length === 0) {
      return NextResponse.json({ error: "المستودع غير موجود" }, { status: 404 });
    }

    return NextResponse.json({ ...result[0], name: result[0].warehouse_name });
  } catch (error) {
    console.error("Error updating warehouse:", error);
    return NextResponse.json({ error: "حدث خطأ أثناء تحديث المستودع" }, { status: 500 });
  }
}
