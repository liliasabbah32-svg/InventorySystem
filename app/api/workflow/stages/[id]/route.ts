import { type NextRequest, NextResponse } from "next/server"
import { neon } from "@neondatabase/serverless"

const sql = neon(process.env.DATABASE_URL!)

export async function PUT(request: NextRequest, { params }: { params: { id: string } }) {
  try {
    const stageId = Number.parseInt(params.id)
    const data = await request.json()

    const result = await sql`
      UPDATE workflow_stages SET
        stage_name = ${data.stage_name},
        stage_name_en = ${data.stage_name_en || null},
        description = ${data.description || null},
        stage_type = ${data.stage_type},
        stage_color = ${data.stage_color},
        icon_name = ${data.icon_name},
        requires_approval = ${data.requires_approval || false},
        max_duration_hours = ${data.max_duration_hours || null},
        auto_advance = ${data.auto_advance || false},
        updated_at = CURRENT_TIMESTAMP
      WHERE id = ${stageId}
      RETURNING *
    `

    if (!result.length) {
      return NextResponse.json({ error: "المرحلة غير موجودة" }, { status: 404 })
    }

    return NextResponse.json({
      success: true,
      stage: result[0],
      message: "تم تحديث المرحلة بنجاح",
    })
  } catch (error) {
    console.error("Error updating workflow stage:", error)
    return NextResponse.json({ error: "فشل في تحديث المرحلة" }, { status: 500 })
  }
}

export async function DELETE(request: NextRequest, { params }: { params: { id: string } }) {
  try {
    const stageId = Number.parseInt(params.id)

    // التحقق من عدم وجود طلبيات في هذه المرحلة
    const ordersInStage = await sql`
      SELECT COUNT(*) as count FROM order_workflow_status 
      WHERE current_stage_id = ${stageId}
    `

    if (Number.parseInt(ordersInStage[0].count) > 0) {
      return NextResponse.json(
        {
          error: "لا يمكن حذف المرحلة لوجود طلبيات فيها",
        },
        { status: 400 },
      )
    }

    await sql`
      UPDATE workflow_stages 
      SET is_active = false, updated_at = CURRENT_TIMESTAMP
      WHERE id = ${stageId}
    `

    return NextResponse.json({
      success: true,
      message: "تم حذف المرحلة بنجاح",
    })
  } catch (error) {
    console.error("Error deleting workflow stage:", error)
    return NextResponse.json({ error: "فشل في حذف المرحلة" }, { status: 500 })
  }
}
