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
      
      sql = neon(dbUrl)
    }

  }
} catch (error) {
  sql = null
}

export default sql

export async function PUT(req: NextRequest, { params }: { params: { id: string } }) {
  const id = parseInt(params.id, 10);
  const data = await req.json();

  if (!data.name) {
    return NextResponse.json({ error: "اسم الفئة مطلوب" }, { status: 400 });
  }

  try {
    const result = await sql`
      UPDATE pricecategory
      SET
        name = ${data.name},
        name_en = ${data.name_en || null},
        description = ${data.description || null},
        is_active = ${data.is_active !== false},
        updated_at = NOW()
      WHERE id = ${id}
      RETURNING *
    `;

    if (result.length === 0) {
      return NextResponse.json({ error: "الفئة غير موجودة" }, { status: 404 });
    }

    return NextResponse.json(result[0]);
  } catch (err) {
    console.error("Error updating price category ", err);
    return NextResponse.json({ error: "فشل في تحديث الفئات" }, { status: 500 });
  }
}
