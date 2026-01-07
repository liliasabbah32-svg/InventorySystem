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

export async function GET(req: NextRequest) {
    try {
        const { searchParams } = new URL(req.url)
        const userId = searchParams.get("userId")

        if (!userId) {
            return NextResponse.json({ error: "userId is required" }, { status: 400 })
        }

        // Fetch access_list joined with user_access
        const rows = await sql`
      SELECT 
        al.id AS access_id,
        al.name AS access_name,
        ac.name AS category_name,
        COALESCE(ua.is_granted, FALSE) AS is_granted
      FROM access_list al
      LEFT JOIN access_category ac ON al.category_id = ac.id
      LEFT JOIN user_access ua 
        ON ua.access_id = al.id AND ua.user_id = ${userId}
      ORDER BY ac.id, al.id
    `

        // Normalize rows to plain JS objects
        const data = Array.isArray(rows) ? rows : rows?.rows || []

        return NextResponse.json(data)
    } catch (err) {
        console.error(err)
        return NextResponse.json({ error: "Failed to fetch access" }, { status: 500 })
    }
}
