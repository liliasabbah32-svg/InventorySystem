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
      console.log("[v0] Using local PostgreSQL with pg Pool")
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

export async function GET(request: NextRequest, { params }: { params: { id: string } }) {
  try {
    const { searchParams } = new URL(request.url);
    let priceCategoryId = Number(searchParams.get("price_category_id"));
    if (!priceCategoryId || priceCategoryId < 1) priceCategoryId = 1;

    const productId = params.id;

    const result = await sql`
      SELECT DISTINCT
    ROW_NUMBER() OVER (ORDER BY pu.id) AS ser,
    pu.unit_id,
    pu.to_main_qnty,
    u.unit_name,
    COALESCE(pp.price, 0) AS price,
    pub.barcode
FROM product_units pu
Left JOIN product_unit_barcodes pub
    ON pub.unit_id = pu.id
    AND pub.product_id = pu.product_id
JOIN units u
    ON pu.unit_id = u.id
LEFT JOIN product_prices pp
    ON pp.product_id = pub.product_id
    AND pp.unit_id = pu.unit_id
    AND pp.price_category_id = ${priceCategoryId}
WHERE pu.product_id = ${productId}

    `;

    return NextResponse.json(result);
  } catch (error) {
    console.error("Error fetching product units with price:", error);
    return NextResponse.json({ error: "Failed to fetch data" }, { status: 500 });
  }
}

