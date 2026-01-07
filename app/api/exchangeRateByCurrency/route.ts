import { NextRequest, NextResponse } from "next/server"
import { getExchangeRate } from "@/lib/database"

export async function GET(request: NextRequest) {
  try {
    const { searchParams } = new URL(request.url)

    const currency_id = Number(searchParams.get("currency_id"))
    const rate_date = searchParams.get("rate_date") // optional

    if (!currency_id) {
      return NextResponse.json(
        { error: "currency_id is required" },
        { status: 400 }
      )
    }

    // ✅ Base currency
    if (currency_id === 1) {
      return NextResponse.json({ rate: 1 })
    }

    const result = await getExchangeRate(currency_id, rate_date)

    if (!result.success) {
      return NextResponse.json(
        { error: result.error },
        { status: 500 }
      )
    }

    return NextResponse.json({
      rate: result.data ?? 1
    })
  } catch (error) {
    console.error("Error fetching exchange rate:", error)
    return NextResponse.json(
      { error: "Failed to fetch exchange rate" },
      { status: 500 }
    )
  }
}
