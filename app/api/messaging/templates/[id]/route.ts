import { NextResponse } from "next/server"
import { neon } from "@neondatabase/serverless"

const sql = neon(process.env.DATABASE_URL!)

export async function PUT(request: Request, { params }: { params: { id: string } }) {
  try {
    const body = await request.json()
    const { template_name, template_code, template_category, message_content } = body

    // استخراج المتغيرات من محتوى الرسالة
    const extractedVariables = message_content.match(/\{([^}]+)\}/g)?.map((v: string) => v.slice(1, -1)) || []

    const result = await sql`
      UPDATE message_templates
      SET 
        template_name = ${template_name},
        template_code = ${template_code},
        template_category = ${template_category},
        message_content = ${message_content},
        variables = ${JSON.stringify(extractedVariables)},
        updated_at = CURRENT_TIMESTAMP
      WHERE id = ${params.id}
      RETURNING *
    `

    return NextResponse.json(result[0])
  } catch (error) {
    console.error("[v0] Error updating template:", error)
    return NextResponse.json({ error: "فشل في تحديث القالب" }, { status: 500 })
  }
}

export async function DELETE(request: Request, { params }: { params: { id: string } }) {
  try {
    // التحقق من أن القالب ليس نظامياً
    const template = await sql`
      SELECT is_system FROM message_templates WHERE id = ${params.id}
    `

    if (template[0]?.is_system) {
      return NextResponse.json({ error: "لا يمكن حذف القوالب النظامية" }, { status: 400 })
    }

    await sql`
      DELETE FROM message_templates WHERE id = ${params.id}
    `

    return NextResponse.json({ success: true })
  } catch (error) {
    console.error("[v0] Error deleting template:", error)
    return NextResponse.json({ error: "فشل في حذف القالب" }, { status: 500 })
  }
}
