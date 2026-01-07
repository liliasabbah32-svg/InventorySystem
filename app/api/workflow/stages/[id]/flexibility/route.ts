import { type NextRequest, NextResponse } from "next/server"
import { neon } from "@neondatabase/serverless"

const sql = neon(process.env.DATABASE_URL!)

export async function PUT(request: NextRequest, { params }: { params: { id: string } }) {
  try {
    const stageId = Number.parseInt(params.id)
    const body = await request.json()

    await sql`
      INSERT INTO stage_flexibility_settings (
        stage_id, is_optional, requires_approval, requires_previous_approval,
        can_skip, skip_conditions, max_duration_hours, warning_hours,
        escalation_hours, escalation_to_department, updated_at
      ) VALUES (
        ${stageId}, ${body.isOptional}, ${body.requiresApproval}, ${body.requiresPreviousApproval},
        ${body.canSkip}, ${body.skipConditions}, ${body.maxDurationHours}, ${body.warningHours},
        ${body.escalationHours}, ${body.escalationToDepartment}, NOW()
      )
      ON CONFLICT (stage_id) DO UPDATE SET
        is_optional = EXCLUDED.is_optional,
        requires_approval = EXCLUDED.requires_approval,
        requires_previous_approval = EXCLUDED.requires_previous_approval,
        can_skip = EXCLUDED.can_skip,
        skip_conditions = EXCLUDED.skip_conditions,
        max_duration_hours = EXCLUDED.max_duration_hours,
        warning_hours = EXCLUDED.warning_hours,
        escalation_hours = EXCLUDED.escalation_hours,
        escalation_to_department = EXCLUDED.escalation_to_department,
        updated_at = NOW()
    `

    return NextResponse.json({ success: true })
  } catch (error) {
    console.error("Error updating stage flexibility settings:", error)
    return NextResponse.json({ error: "Failed to update stage flexibility settings" }, { status: 500 })
  }
}
