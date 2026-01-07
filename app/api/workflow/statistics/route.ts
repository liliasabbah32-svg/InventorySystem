import { type NextRequest, NextResponse } from "next/server"
import { getWorkflowStatistics } from "@/lib/workflow"

export async function GET(request: NextRequest) {
  try {
    const { searchParams } = new URL(request.url)
    const department = searchParams.get("department")

    const statistics = await getWorkflowStatistics(department || undefined)

    return NextResponse.json({
      success: true,
      data: statistics,
    })
  } catch (error) {
    console.error("Error fetching workflow statistics:", error)
    return NextResponse.json({ error: "حدث خطأ في جلب الإحصائيات" }, { status: 500 })
  }
}
