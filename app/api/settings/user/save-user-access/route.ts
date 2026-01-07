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

interface AccessPayload {
  userId: number
  accesses: { access_id: number; is_granted: boolean }[]
}

export async function POST(req: NextRequest) {
  try {
    const body: AccessPayload = await req.json()

    if (!body.userId || !Array.isArray(body.accesses)) {
      return NextResponse.json({ error: "Invalid payload" }, { status: 400 })
    }

    const { userId, accesses } = body

    // For each access, either insert or update
    for (const access of accesses) {
      await sql`
        INSERT INTO user_access (user_id, access_id, is_granted)
        VALUES (${userId}, ${access.access_id}, ${access.is_granted})
        ON CONFLICT (user_id, access_id) DO UPDATE
        SET is_granted = EXCLUDED.is_granted
      `
    }

    return NextResponse.json({ success: true })
  } catch (err) {
    console.error(err)
    return NextResponse.json({ error: "Failed to save user access" }, { status: 500 })
  }
}
