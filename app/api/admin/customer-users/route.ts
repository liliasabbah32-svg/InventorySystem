import { type NextRequest, NextResponse } from "next/server"
import { createCustomerUser, getCustomerUsers } from "@/lib/customer-auth"

export async function GET(request: NextRequest) {
  try {
    console.log("[v0] ========== START GET /api/admin/customer-users ==========")
    console.log("[v0] Request URL:", request.url)
    console.log("[v0] Request method:", request.method)

    const searchParams = request.nextUrl.searchParams
    const customerId = searchParams.get("customerId")

    console.log("[v0] Search params:", Object.fromEntries(searchParams.entries()))
    console.log("[v0] Customer ID from params:", customerId)
    console.log("[v0] Customer ID type:", typeof customerId)

    if (!customerId) {
      console.log("[v0] Error: Customer ID is missing")
      return NextResponse.json({ error: "معرف العميل مطلوب" }, { status: 400 })
    }

    const customerIdNumber = Number.parseInt(customerId)
    console.log("[v0] Parsed customer ID:", customerIdNumber)
    console.log("[v0] Is valid number:", !isNaN(customerIdNumber))

    if (isNaN(customerIdNumber)) {
      console.log("[v0] Error: Invalid customer ID format")
      return NextResponse.json({ error: "معرف العميل غير صحيح" }, { status: 400 })
    }

    console.log("[v0] Calling getCustomerUsers with ID:", customerIdNumber)
    const users = await getCustomerUsers(customerIdNumber)

    console.log("[v0] Users fetched successfully")
    console.log("[v0] Users count:", users.length)
    console.log("[v0] Users data:", JSON.stringify(users, null, 2))
    console.log("[v0] ========== END GET /api/admin/customer-users (SUCCESS) ==========")

    return NextResponse.json({
      users,
      count: users.length,
      customerId: customerIdNumber,
    })
  } catch (error) {
    console.error("[v0] ========== ERROR in GET /api/admin/customer-users ==========")
    console.error("[v0] Get customer users error:", error)
    console.error("[v0] Error type:", error instanceof Error ? error.constructor.name : typeof error)
    console.error("[v0] Error message:", error instanceof Error ? error.message : String(error))
    console.error("[v0] Error stack:", error instanceof Error ? error.stack : undefined)
    return NextResponse.json({ error: "حدث خطأ أثناء تحميل المستخدمين" }, { status: 500 })
  }
}

export async function POST(request: NextRequest) {
  try {
    console.log("[v0] ========== START POST /api/admin/customer-users ==========")

    let body
    try {
      body = await request.json()
    } catch (parseError) {
      console.error("[v0] JSON parse error:", parseError)
      return NextResponse.json({ error: "بيانات الطلب غير صحيحة" }, { status: 400 })
    }

    const { customerId, username, password, email, permissions } = body

    console.log("[v0] Request body:", {
      customerId,
      username,
      email,
      hasPassword: !!password,
      passwordLength: password?.length,
      permissions,
    })

    if (!customerId || !username || !password) {
      console.log("[v0] Error: Missing required fields")
      return NextResponse.json({ error: "البيانات المطلوبة ناقصة" }, { status: 400 })
    }

    console.log("[v0] Creating customer user...")
    let user
    try {
      user = await createCustomerUser(customerId, username, password, email)
      console.log("[v0] User created successfully:", { userId: user.id, username: user.username })
    } catch (createError: any) {
      console.error("[v0] Error creating user:", createError)

      if (createError.message?.includes("duplicate") || createError.message?.includes("unique")) {
        return NextResponse.json({ error: "اسم المستخدم موجود بالفعل" }, { status: 400 })
      }

      return NextResponse.json(
        {
          error: "حدث خطأ أثناء إنشاء المستخدم",
          details: createError.message,
        },
        { status: 500 },
      )
    }

    // Update permissions if provided
    if (permissions) {
      console.log("[v0] Updating permissions:", permissions)
      try {
        const { updateCustomerPermissions } = await import("@/lib/customer-auth")
        await updateCustomerPermissions(user.id, permissions)
        console.log("[v0] Permissions updated successfully")
      } catch (permError: any) {
        console.error("[v0] Error updating permissions:", permError)
        // Don't fail the whole request if permissions update fails
        console.log("[v0] Continuing despite permissions error")
      }
    }

    console.log("[v0] ========== END POST /api/admin/customer-users (SUCCESS) ==========")
    return NextResponse.json({ success: true, user }, { status: 201 })
  } catch (error: any) {
    console.error("[v0] ========== ERROR in POST /api/admin/customer-users ==========")
    console.error("[v0] Unexpected error:", error)
    console.error("[v0] Error message:", error?.message)
    console.error("[v0] Error stack:", error?.stack)

    return NextResponse.json(
      {
        error: "حدث خطأ غير متوقع أثناء إنشاء المستخدم",
        details: error?.message || "خطأ غير معروف",
      },
      { status: 500 },
    )
  }
}
