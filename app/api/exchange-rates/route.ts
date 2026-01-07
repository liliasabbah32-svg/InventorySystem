import { type NextRequest, NextResponse } from "next/server"
import { getCurrenciesWithLatestRate, updateExchangeRate } from "@/lib/database"
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

// ❌ removed export default sql
// ✅ leave sql as an internal helper variable

// ==============================
// GET - Fetch currencies + rates
// ==============================
export async function GET() {
  try {
    const result = await getCurrenciesWithLatestRate()

    if (!result.success) {
      return NextResponse.json({ error: result.error }, { status: 500 })
    }

    return NextResponse.json({ rates: result.data })
  } catch (error) {
    console.error("Error fetching exchange rates:", error)
    return NextResponse.json({ error: "Failed to fetch exchange rates" }, { status: 500 })
  }
}

// ==============================
// POST - Add currency + rate
// ==============================
export async function POST(request: NextRequest) {
  try {
    const body = await request.json()
    const { currency_name, currency_code, buy_rate, sell_rate, exchange_rate, is_active } = body

    if (!currency_name || !currency_code) {
      return NextResponse.json({ error: "Currency name and code are required" }, { status: 400 })
    }

    // Check if currency exists
    let currency = await sql`
      SELECT * FROM currency WHERE currency_code = ${currency_code}
    `

    if (currency.length === 0) {
      const lastIdRow = await sql`SELECT MAX(id) AS max_id FROM currency`
      const lastId = lastIdRow[0]?.max_id ?? 0
      const newId = lastId + 1

      if (newId === 1 && (buy_rate !== 1 || sell_rate !== 1 || exchange_rate !== 1)) {
        return NextResponse.json(
          { error: "عملة الأساس يجب أن يكون سعر الصرف والبيع والشراء يساوي 1" },
          { status: 400 }
        )
      }

      const inserted = await sql`
        INSERT INTO currency (id, currency_code, currency_name, is_active)
        VALUES (${newId}, ${currency_code}, ${currency_name}, true)
        RETURNING *
      `
      currency = inserted
    }

    const currencyId = currency[0].id

    // Insert new exchange rate
    const result = await sql`
      INSERT INTO exchange_rates (
        currency_id,
        buy_rate,
        sell_rate,
        exchange_rate,
        is_active
      ) VALUES (
        ${currencyId},
        ${buy_rate || 0},
        ${sell_rate || 0},
        ${exchange_rate || 0},
        ${is_active !== false}
      ) RETURNING *
    `

    return NextResponse.json({ rate: result[0] }, { status: 201 })
  } catch (error) {
    console.error("Error creating exchange rate:", error)
    return NextResponse.json({ error: "Failed to create exchange rate" }, { status: 500 })
  }
}

// ==============================
// PUT - Update existing rate
// ==============================
export async function PUT(request: NextRequest) {
  try {
    const { id, ...rates } = await request.json()
    const result = await updateExchangeRate(id, rates)

    if (!result.success || !result.data || result.data.length === 0) {
      return NextResponse.json({ error: result.error ?? "No data returned" }, { status: 500 })
    }

    return NextResponse.json({ rate: result.data[0] })
  } catch (error) {
    console.error("Error updating exchange rate:", error)
    return NextResponse.json({ error: "Failed to update exchange rate" }, { status: 500 })
  }
}

// ==============================
// Utility - Manual insert helper
// ==============================
export async function createExchangeRate(data: {
  currency_id: number
  buy_rate: number
  sell_rate: number
  exchange_rate: number
  is_active?: boolean
}) {
  return sql`
    INSERT INTO exchange_rates (
      currency_id,
      buy_rate,
      sell_rate,
      exchange_rate,
      is_active,
      rate_date
    ) VALUES (
      ${data.currency_id},
      ${data.buy_rate},
      ${data.sell_rate},
      ${data.exchange_rate},
      ${data.is_active ?? true},
      CURRENT_DATE
    ) RETURNING *
  `
}
