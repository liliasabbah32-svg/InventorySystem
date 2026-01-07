import { type NextRequest, NextResponse } from "next/server"
import { validateSystemStability } from "@/lib/system-validator"

export async function GET(request: NextRequest) {
  try {
    const result = await validateSystemStability()
    return NextResponse.json(result)
  } catch (error) {
    console.error("خطأ في فحص النظام:", error)
    return NextResponse.json({ error: "فشل في فحص النظام" }, { status: 500 })
  }
}
