import { NextRequest, NextResponse } from "next/server";
import { Pool } from 'pg';
const pool = new Pool({
  connectionString: process.env.DATABASE_URL,
});

export async function GET(
  req: NextRequest,
  { params }: { params: { navigationType: string, id: string } }
) {
  const { navigationType, id } = params;
  let productQuery = "";
  let values: any[] = [];

  try {
    switch (navigationType) {
      case "first":
        productQuery = `
          SELECT * FROM products
          WHERE deleted IS NULL OR deleted = false
          ORDER BY id ASC
          LIMIT 1
        `;
        break;

      case "last":
        productQuery = `
          SELECT * FROM products
          WHERE deleted IS NULL OR deleted = false
          ORDER BY id DESC
          LIMIT 1
        `;
        break;

      case "previous": {
        const currentId = Number(req.nextUrl.searchParams.get("currentId") || 0);
        productQuery = `
          SELECT * FROM products
          WHERE id < $1
          AND (deleted IS NULL OR deleted = false)
          ORDER BY id DESC
          LIMIT 1
        `;
        values = [currentId];
        break;
      }

      case "next": {
        const currentId = Number(req.nextUrl.searchParams.get("currentId") || 0);
        productQuery = `
          SELECT * FROM products
          WHERE id > $1
          AND (deleted IS NULL OR deleted = false)
          ORDER BY id ASC
          LIMIT 1
        `;
        values = [currentId];
        break;
      }
      case "Byid": {
        const idStr = req.nextUrl.searchParams.get("id"); 
        const id = idStr ? parseInt(idStr, 10) : undefined;
        if (!id) {
          return NextResponse.json({ error: "ID is required" }, { status: 400 });
        }
        productQuery = `
          SELECT * FROM products
          WHERE id = $1
          AND (deleted IS NULL OR deleted = false)
        `;
        values = [Number(id)];
        break;
      }


      default:
        return NextResponse.json({ error: "Invalid navigation type" }, { status: 400 });
    }

    const client = await pool.connect();
    const result = await client.query(productQuery, values);
    client.release();

    if (!result.rows.length) {
      return NextResponse.json({ error: "No product found" }, { status: 404 });
    }

    const product = result.rows[0];

    // fetch units
    const unitsResult = await pool.query(
      "SELECT * FROM product_units WHERE product_id=$1",
      [product.id]
    );
    product.units = unitsResult.rows;

    let units = unitsResult.rows;

    for (let i = 0; i < units.length; i++) {
      units[i].ser = i + 1;

      const barcodeRes = await pool.query(
        `SELECT barcode FROM product_unit_barcodes WHERE unit_id = $1 and product_id = $2`,
        [units[i].id, product.id]
      );

      units[i].barcode_list = barcodeRes.rows.map(b => b.barcode);
    }

    product.units = units;
    // fetch prices
    const pricesResult = await pool.query(
      "SELECT * FROM product_prices WHERE product_id=$1",
      [product.id]
    );
    product.prices = pricesResult.rows;

    // fetch stores
    const storesResult = await pool.query(
      "SELECT * FROM product_warehouses WHERE product_id=$1",
      [product.id]
    );
    product.stores = storesResult.rows;

    return NextResponse.json(product);
  } catch (error) {
    console.error(error);
    return NextResponse.json({ error: "Server error" }, { status: 500 });
  }
}
