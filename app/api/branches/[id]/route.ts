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
export async function PUT(request: NextRequest) {
  try {
    const data = await request.json();

    if (!data.id) {
      return NextResponse.json({ error: "معرف الفرع مطلوب" }, { status: 400 });
    }

    if (!data.branch_name?.trim()) {
      return NextResponse.json({ error: "اسم الفرع مطلوب" }, { status: 400 });
    }

    const result: any[] = await sql`
      UPDATE branches
      SET 
        branch_code = ${data.branch_code.trim()},
        branch_name = ${data.branch_name.trim()},
        address = ${data.address?.trim() || ""},
        manager = ${data.manager?.trim() || ""},
        phone = ${data.phone?.trim() || ""},
        is_active = ${data.is_active !== false},
        updated_at = CURRENT_TIMESTAMP
      WHERE id = ${data.id}
      RETURNING *
    `;

    if (result.length === 0) {
      return NextResponse.json({ error: "الفرع غير موجود" }, { status: 404 });
    }

    return NextResponse.json(result[0]);
  } catch (error) {
    console.error("Error updating branch:", error);
    return NextResponse.json({ error: "حدث خطأ أثناء تحديث الفرع" }, { status: 500 });
  }
}
