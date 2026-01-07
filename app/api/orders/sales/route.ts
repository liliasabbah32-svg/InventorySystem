import { type NextRequest, NextResponse } from "next/server"
import { getSalesOrders, getPurchaseOrders, createOrder, createPurchaseOrder } from "@/lib/orders"

export async function GET(request: NextRequest) {
  try {
    const { searchParams } = new URL(request.url)

    const type = searchParams.get("type") || "1" // 1 = sales, 2 = purchase
    const filters = {
      search: searchParams.get("search") || undefined,
      status: searchParams.get("status") || undefined,
      salesman: searchParams.get("salesman") || undefined,
      dateFrom: searchParams.get("dateFrom") || undefined,
      dateTo: searchParams.get("dateTo") || undefined,
      customerId: searchParams.get("customerId") ? Number.parseInt(searchParams.get("customerId")!) : undefined,
      order_type : type
    }

    const orders = await getSalesOrders(filters)

    return NextResponse.json(orders)
  } catch (error) {
    console.error("Orders API error:", error)
    return NextResponse.json({ error: "حدث خطأ في جلب الطلبات" }, { status: 500 })
  }
}

export async function POST(request: NextRequest) {
  try {
    const requestData = await request.json(); // read once

    const { type, orderData: od, items: it, ...rest } = requestData;

    const orderData = od || rest; // fallback if no nested orderData
    const items = it || requestData.items || [];

    if (!orderData) return NextResponse.json({ error: "بيانات الطلبية مطلوبة" }, { status: 400 });
    if (!orderData.customer_name && !orderData.customer_id)
      return NextResponse.json({ error: "اسم العميل أو رقم العميل مطلوب" }, { status: 400 });
    if (!items || items.length === 0)
      return NextResponse.json({ error: "عناصر الطلبية مطلوبة" }, { status: 400 });

    const order = await createOrder(orderData, items);

    return NextResponse.json(order, { status: 201 });
  } catch (error: any) {
    console.error("Create order API error:", error);
    return NextResponse.json(
      {
        error: error.message || "حدث خطأ في إنشاء الطلبية",
        details: process.env.NODE_ENV === "development" ? error.stack : undefined,
      },
      { status: 500 },
    );
  }
}
