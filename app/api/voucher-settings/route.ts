import { NextRequest, NextResponse } from "next/server"

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
const pool = new Pool({
    connectionString: process.env.DATABASE_URL
});
/* =========================
   GET: Load settings
========================= */
export async function GET(req: Request) {
    try {
        const { searchParams } = new URL(req.url);

        const target = searchParams.get("target");
        let targetCondition = 1;
        if (target === "print") {
            targetCondition = 2;
        }
        if (!target) {
            return NextResponse.json(
                { message: "Missing parameters" },
                { status: 400 }
            );
        }

        const { rows } = await pool.query(
            `
      SELECT column_key, is_visible,voucher_type
      FROM voucher_column_settings
      WHERE target = $1
      group by voucher_type, column_key, is_visible
      ORDER BY voucher_type, column_key
      `,
            [targetCondition]
        );

        const columnsByVoucher: Record<string, Record<string, boolean>> = {};

        rows.forEach(r => {
            if (!columnsByVoucher[r.voucher_type]) {
                columnsByVoucher[r.voucher_type] = {};
            }
            columnsByVoucher[r.voucher_type][r.column_key] = r.is_visible;
        });

        return NextResponse.json({
            target,
            columns: columnsByVoucher
        });
    } catch (error) {
        console.error("GET voucher-settings error:", error);
        return NextResponse.json(
            { message: "Failed to load settings" },
            { status: 500 }
        );
    }
}

/* =========================
   POST: Save settings
========================= */
export async function POST(req: Request) {
    const client = await pool.connect();

    try {
        const body = await req.json();
        const { voucher_type, target, columns } = body;
        let targetCondition = 1;
        if (target === "print") {
            targetCondition = 2;
        }
        if (!voucher_type || !target || !columns) {
            return NextResponse.json(
                { message: "Invalid payload" },
                { status: 400 }
            );
        }

        await client.query("BEGIN");

        for (const columnKey of Object.keys(columns)) {
            await client.query(
                `
        INSERT INTO voucher_column_settings
          (voucher_type, target, column_key, is_visible)
        VALUES
          ($1, $2, $3, $4)
        ON CONFLICT (voucher_type, target, column_key)
        DO UPDATE SET
          is_visible = EXCLUDED.is_visible,
          updated_at = CURRENT_TIMESTAMP
        `,
                [
                    voucher_type,
                    targetCondition,
                    columnKey,
                    Boolean(columns[columnKey])
                ]
            );
        }

        await client.query("COMMIT");

        return NextResponse.json({ success: true });
    } catch (error) {
        await client.query("ROLLBACK");
        console.error("POST voucher-settings error:", error);

        return NextResponse.json(
            { message: "Failed to save settings" },
            { status: 500 }
        );
    } finally {
        client.release();
    }
}
