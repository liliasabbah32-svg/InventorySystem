import { type NextRequest, NextResponse } from "next/server"
import { autoFixSystemIssues } from "@/lib/system-validator"

export async function POST(request: NextRequest) {
  try {
    const fixes = await autoFixSystemIssues()
    return NextResponse.json({ success: true, fixes })
  } catch (error) {
    console.error("خطأ في الإصلاح التلقائي:", error)
    return NextResponse.json({ error: "فشل في الإصلاح التلقائي" }, { status: 500 })
  }
}
