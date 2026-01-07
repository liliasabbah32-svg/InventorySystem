import { type NextRequest, NextResponse } from "next/server"
import { updateExchangeRate } from "@/lib/database"

export async function PUT(request: NextRequest, { params }: { params: { id: string } }) {
  try {
    const id = Number.parseInt(params.id)
    
    const rates = await request.json()
    const type = Number.parseInt(rates.type)
    const result = await updateExchangeRate(id, rates)

    if (!result.success) {
      return NextResponse.json({ error: result.error }, { status: 500 })
    }

    return NextResponse.json({ rate: result.data[0] })
  } catch (error) {
    console.error("Error updating exchange rate:", error)
    return NextResponse.json({ error: "Failed to update exchange rate" }, { status: 500 })
  }
}
