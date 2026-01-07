import { NextResponse } from "next/server"
import { neon } from "@neondatabase/serverless"

const sql = neon(process.env.DATABASE_URL!)

export async function DELETE(request: Request, { params }: { params: { id: string } }) {
  try {
    await sql`
      UPDATE scheduled_messages
      SET status = 'cancelled'
      WHERE id = ${params.id}
    `

    return NextResponse.json({ success: true })
  } catch (error) {
    console.error("[v0] Error cancelling scheduled message:", error)
    return NextResponse.json({ error: "فشل في إلغاء الرسالة" }, { status: 500 })
  }
}
