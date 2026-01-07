import { NextResponse } from "next/server";
import { Pool } from "pg";

const pool = new Pool({
  connectionString: process.env.DATABASE_URL,
});

export async function GET(
  request: Request,
  { params }: { params: { navigationType: string } }
) {
  try {
    const { searchParams } = new URL(request.url);
    const nav = params.navigationType;
    const order_type = Number(searchParams.get("order_type")) ?? 1;
    const vch_book = searchParams.get("vch_book") ?? "0";
    const numberPrefix = order_type === 1 ? "O" + vch_book : "T" + vch_book;
    let query = "";
    let values: any[] = [];

    switch (nav) {
      case "first":
        {



          query = `
          SELECT orders.*,orders.order_date::date::text AS order_date,    -- <--- FORCE STRING
          orders.delivery_date::date::text AS delivery_date,
          c.name AS customer_name,c.pricecategory,c.customer_code
          FROM orders
          INNER JOIN customers c ON c.id = orders.customer_id
          WHERE order_type = $1
          AND order_number LIKE $2
          AND deleted = false
          ORDER BY order_number ASC
          LIMIT 1
        `;

          values = [order_type, `${numberPrefix}%`];
        }
        break;
      case "last":
        {
          query = `
          SELECT orders.*,orders.order_date::date::text AS order_date,    -- <--- FORCE STRING
          orders.delivery_date::date::text AS delivery_date,
          c.name AS customer_name,c.pricecategory,c.customer_code
          FROM orders
          INNER JOIN customers c ON c.id = orders.customer_id
          WHERE order_type = $1
          AND order_number LIKE $2
          AND deleted = false
          ORDER BY order_number DESC
          LIMIT 1
        `;

          values = [order_type, `${numberPrefix}%`];
        }
        break;
      case "previous": {
        const currentId = searchParams.get("currentId");
        if (!currentId) return NextResponse.json({ error: "currentId required" }, { status: 400 });

        query = `
          SELECT orders.*,orders.order_date::date::text AS order_date,    -- <--- FORCE STRING
          orders.delivery_date::date::text AS delivery_date,
         c.name AS customer_name,c.pricecategory,c.customer_code
          FROM orders
          INNER JOIN customers c ON c.id = orders.customer_id
          WHERE order_type = $1
          AND order_number LIKE $2
          AND order_number < $3
          AND deleted = false
          ORDER BY order_number DESC
          LIMIT 1
        `;
        values = [order_type, `${numberPrefix}%`, currentId];
        break;
      }
      case "next": {
        const currentId = searchParams.get("currentId");
        if (!currentId) return NextResponse.json({ error: "currentId required" }, { status: 400 });

        query = `
          SELECT orders.*, orders.order_date::date::text AS order_date,    -- <--- FORCE STRING
          orders.delivery_date::date::text AS delivery_date,
          c.name AS customer_name,c.pricecategory,c.customer_code
          FROM orders
          INNER JOIN customers c ON c.id = orders.customer_id
          WHERE order_type = $1
          AND order_number LIKE $2
          AND order_number > $3
          AND deleted = false
          ORDER BY order_number ASC
          LIMIT 1
        `;
        values = [order_type, `${numberPrefix}%`, currentId];
        break;
      }
      case "Byid": {
        const id = Number(searchParams.get("id"));
        if (!id) return NextResponse.json({ error: "id required" }, { status: 400 });
        query = `SELECT orders.*,
        orders.order_date::date::text AS order_date,    -- <--- FORCE STRING
        orders.delivery_date::date::text AS delivery_date,
        c.customer_code,c.pricecategory,c.customer_code
                  FROM orders 
                  INNER JOIN customers c on c.id = orders.customer_id
                  WHERE orders.id = $1 LIMIT 1`;
        values = [id];
        break;
      }
      default:
        return NextResponse.json({ error: "Invalid navigation type" }, { status: 400 });
    }

    const result = await pool.query(query, values);

    if (result.rows.length === 0) {
      return NextResponse.json({});
    }

    const order = result.rows[0];

    // Fetch items for this order
    const itemsResult = await pool.query(
      `SELECT 
          oi.*,
          u.unit_name AS unit_name,
          s.warehouse_name AS store_name,
          p.product_code as code,
          p.has_batch_number
      FROM order_items oi
      INNER JOIN products p ON oi.product_id = p.id
      INNER JOIN units u ON oi.unit_id = u.id
      LEFT JOIN warehouses s ON oi.store_id = s.id
      WHERE oi.order_id = $1
`,
      [order.id]
    );

    order.items = itemsResult.rows;
    let priceCategoryId = order.pricecategory && order.pricecategory >= 1 ? order.pricecategory : 1
    for (const item of order.items) {
      const unitsQuery = `
    SELECT u.id AS unit_id, u.unit_name, pu.to_main_qnty,
           pub.barcode,
           COALESCE(pp.price, 0) AS unit_price
    FROM product_units pu
    LEFT JOIN units u ON pu.unit_id = u.id
    LEFT JOIN product_unit_barcodes pub
      ON pu.product_id = pub.product_id AND pu.id = pub.unit_id
    LEFT JOIN product_prices pp
      ON pu.product_id = pp.product_id
      AND pu.unit_id = pp.unit_id
      AND pp.price_category_id = $2
    WHERE pu.product_id = $1
    ORDER BY pu.id
  `;

      const unitsResult = await pool.query(unitsQuery, [item.product_id, priceCategoryId]);
      item.units = unitsResult.rows; // attach units to each order item
    }
    return NextResponse.json(order);
  } catch (err) {
    console.error("Orders navigation error:", err);
    return NextResponse.json({ error: "Internal server error" }, { status: 500 });
  }
}
