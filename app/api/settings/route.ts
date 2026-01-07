import { NextResponse } from "next/server"

export async function GET() {
  try {
    const settings = {
      company: {
        name: "شركة النظام المتقدم",
        address: "الرياض، المملكة العربية السعودية",
        phone: "+966501234567",
        email: "info@company.com",
      },
      system: {
        currency: "SAR",
        language: "ar",
        timezone: "Asia/Riyadh",
      },
    }

    return NextResponse.json(settings)
  } catch (error) {
    console.error("Error fetching settings:", error)
    return NextResponse.json({ error: "Failed to fetch settings" }, { status: 500 })
  }
}

export async function POST(request: Request) {
  try {
    const settings = await request.json()
    console.log("Saving settings:", settings)

    return NextResponse.json({ success: true, message: "تم حفظ الإعدادات بنجاح" })
  } catch (error) {
    console.error("Error saving settings:", error)
    return NextResponse.json({ error: "Failed to save settings" }, { status: 500 })
  }
}
