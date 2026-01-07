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

export async function GET() {
  try {
    const suppliers = await sql`
      SELECT *
      FROM suppliers
      ORDER BY created_at DESC
    `

    return NextResponse.json(suppliers)
  } catch (error) {
    console.error("Error fetching suppliers:", error)
    return NextResponse.json({ error: "Failed to fetch suppliers" }, { status: 500 })
  }
}

export async function POST(request: NextRequest) {
  try {
    const data = await request.json()

    console.log("[v0] Received supplier data:", data)

    // Check if supplier code already exists
    if (data.supplier_code) {
      const existingSupplier = await sql`
        SELECT id FROM suppliers WHERE supplier_code = ${data.supplier_code}
      `
      if (existingSupplier.length > 0) {
        return NextResponse.json({ error: "رقم المورد موجود مسبقاً" }, { status: 400 })
      }
    }

    console.log("[v0] About to insert supplier with columns:", {
      supplier_code: data.supplier_code,
      name: data.supplier_name,
      mobile1: data.mobile1,
      mobile2: data.mobile2,
      whatsapp1: data.whatsapp1,
      whatsapp2: data.whatsapp2,
      city: data.city,
      address: data.address,
      email: data.email,
      status: data.status || "نشط",
      business_nature: data.business_nature,
      salesman: data.salesman,
      movement_notes: data.movement_notes,
      general_notes: data.general_notes,
      classifications: data.classifications,
      account_opening_date: data.account_opening_date || new Date().toISOString().split("T")[0],
      web_username: data.web_username,
      api_number: data.api_number,
    })

    const result = await sql`
  INSERT INTO suppliers (
    supplier_code, 
    name, 
    mobile1, 
    mobile2, 
    whatsapp1, 
    whatsapp2, 
    city, 
    address, 
    email, 
    activity, 
    representative, 
    classification, 
    account_open_date, 
    status, 
    web_username, 
    web_password,
    api_key, 
    transaction_notes, 
    general_notes
  ) VALUES (
    ${data.supplier_code}, 
    ${data.name}, 
    ${data.mobile1}, 
    ${data.mobile2}, 
    ${data.whatsapp1}, 
    ${data.whatsapp2}, 
    ${data.city}, 
    ${data.address}, 
    ${data.email}, 
    ${data.activity}, 
    ${data.representative}, 
    ${data.classification}, 
    ${data.account_open_date || new Date().toISOString().split("T")[0]}, 
    ${data.status || "نشط"}, 
    ${data.web_username}, 
    ${data.web_password}, 
    ${data.api_key}, 
    ${data.transaction_notes}, 
    ${data.general_notes}
  ) 
  RETURNING *;
`


    console.log("[v0] Supplier created successfully:", result[0])
    return NextResponse.json(result[0], { status: 201 })
  }catch (error: unknown) {
  const err = error as Error;
  console.error("[v0] Error creating supplier:", err);
  console.error("[v0] Error details:", {
    message: err.message,
    stack: err.stack,
    name: err.name,
  });
  return NextResponse.json(
    { error: "فشل في إنشاء المورد" },
    { status: 500 }
  );
}
}

export async function PUT(request: NextRequest) {
  try {
    const data = await request.json()
    const { id, ...updateData } = data

    const result = await sql`
      UPDATE suppliers SET
        name = ${updateData.supplier_name},
        mobile1 = ${updateData.mobile1},
        mobile2 = ${updateData.mobile2},
        whatsapp1 = ${updateData.whatsapp1},
        whatsapp2 = ${updateData.whatsapp2},
        city = ${updateData.city},
        address = ${updateData.address},
        email = ${updateData.email},
        status = ${updateData.status},
        business_nature = ${updateData.business_nature},
        salesman = ${updateData.salesman},
        movement_notes = ${updateData.movement_notes},
        general_notes = ${updateData.general_notes},
        classifications = ${updateData.classifications},
        web_username = ${updateData.web_username},
        api_number = ${updateData.api_number}
      WHERE id = ${id}
      RETURNING *
    `

    return NextResponse.json(result[0])
  } catch (error) {
    console.error("Error updating supplier:", error)
    return NextResponse.json({ error: "فشل في تحديث المورد" }, { status: 500 })
  }
}

export async function DELETE(request: NextRequest) {
  try {
    const { searchParams } = new URL(request.url)
    const id = searchParams.get("id")

    if (!id) {
      return NextResponse.json({ error: "Supplier ID is required" }, { status: 400 })
    }

    await sql`DELETE FROM suppliers WHERE id = ${id}`

    return NextResponse.json({ message: "Supplier deleted successfully" })
  } catch (error) {
    console.error("Error deleting supplier:", error)
    return NextResponse.json({ error: "Failed to delete supplier" }, { status: 500 })
  }
}
