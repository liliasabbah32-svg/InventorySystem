import { type NextRequest, NextResponse } from "next/server"
import { neon } from "@neondatabase/serverless"

const sql = neon(process.env.DATABASE_URL!)

export async function PUT(request: NextRequest, { params }: { params: { id: string } }) {
  try {
    const data = await request.json()
    const sequenceId = Number.parseInt(params.id)

    if (isNaN(sequenceId)) {
      return NextResponse.json({ error: "معرف التسلسل غير صحيح" }, { status: 400 })
    }

    if (!data.sequence_name || !data.sequence_type) {
      return NextResponse.json({ error: "اسم التسلسل ونوعه مطلوبان" }, { status: 400 })
    }

    // If setting as default, remove default from other sequences of same type
    if (data.is_default) {
      await sql`
        UPDATE workflow_sequences 
        SET is_default = false 
        WHERE sequence_type = ${data.sequence_type} 
        AND is_default = true 
        AND id != ${sequenceId}
      `
    }

    const result = await sql`
      UPDATE workflow_sequences 
      SET 
        sequence_name = ${data.sequence_name},
        sequence_type = ${data.sequence_type},
        description = ${data.description || null},
        is_default = ${data.is_default || false},
        updated_at = NOW()
      WHERE id = ${sequenceId}
      RETURNING *
    `

    if (result.length === 0) {
      return NextResponse.json({ error: "التسلسل غير موجود" }, { status: 404 })
    }

    return NextResponse.json({
      success: true,
      sequence: result[0],
      message: "تم تحديث التسلسل بنجاح",
    })
  } catch (error) {
    console.error("Error updating workflow sequence:", error)
    return NextResponse.json({ error: "فشل في تحديث التسلسل" }, { status: 500 })
  }
}

export async function DELETE(request: NextRequest, { params }: { params: { id: string } }) {
  try {
    const sequenceId = Number.parseInt(params.id)

    if (isNaN(sequenceId)) {
      return NextResponse.json({ error: "معرف التسلسل غير صحيح" }, { status: 400 })
    }

    const result = await sql`
      UPDATE workflow_sequences 
      SET is_active = false, updated_at = NOW()
      WHERE id = ${sequenceId}
      RETURNING *
    `

    if (result.length === 0) {
      return NextResponse.json({ error: "التسلسل غير موجود" }, { status: 404 })
    }

    return NextResponse.json({
      success: true,
      message: "تم حذف التسلسل بنجاح",
    })
  } catch (error) {
    console.error("Error deleting workflow sequence:", error)
    return NextResponse.json({ error: "فشل في حذف التسلسل" }, { status: 500 })
  }
}
