import { type NextRequest, NextResponse } from "next/server"
import {
  getAvailableBatches,
  calculateFIFOAllocation,
  reserveBatches,
  releaseBatches,
  consumeBatches,
  searchBatch,
  getBatchInfo,
  getProductBatchSummary,
  getBatchSettings,
} from "@/lib/batch-utils"

// GET: الحصول على معلومات الباتشات
export async function GET(request: NextRequest) {
  try {
    const { searchParams } = new URL(request.url)
    const action = searchParams.get("action")
    const productId = searchParams.get("product_id")
    const lotId = searchParams.get("lot_id")
    const searchTerm = searchParams.get("search")
    const documentType = searchParams.get("document_type")

    // البحث عن باتش
    if (action === "search" && searchTerm) {
      const results = await searchBatch(searchTerm)
      return NextResponse.json({ success: true, batches: results })
    }

    // الحصول على معلومات باتش معين
    if (action === "info" && lotId) {
      const batch = await getBatchInfo(Number(lotId))
      if (!batch) {
        return NextResponse.json({ error: "الباتش غير موجود" }, { status: 404 })
      }
      return NextResponse.json({ success: true, batch })
    }

    // الحصول على ملخص الباتشات لمنتج
    if (action === "summary" && productId) {
      const summary = await getProductBatchSummary(Number(productId))
      return NextResponse.json({ success: true, summary })
    }

    // الحصول على إعدادات الباتش
    if (action === "settings" && documentType) {
      const settings = await getBatchSettings(documentType)
      return NextResponse.json({ success: true, settings })
    }

    // الحصول على الباتشات المتاحة لمنتج
    if (productId) {
      const requestedQuantity = Number(searchParams.get("quantity")) || 0
      const batches = await getAvailableBatches(Number(productId))

      if (requestedQuantity > 0) {
        const allocation = await calculateFIFOAllocation(Number(productId), requestedQuantity)
        return NextResponse.json({
          success: true,
          batches,
          allocation,
          totalAvailable: batches.reduce((sum, b) => sum + b.availableQuantity, 0),
        })
      }

      return NextResponse.json({
        success: true,
        batches,
        totalAvailable: batches.reduce((sum, b) => sum + b.availableQuantity, 0),
      })
    }

    return NextResponse.json({ error: "معاملات غير صحيحة" }, { status: 400 })
  } catch (error) {
    console.error("[v0] Error in batches API:", error)
    return NextResponse.json(
      { error: error instanceof Error ? error.message : "حدث خطأ في معالجة الطلب" },
      { status: 500 },
    )
  }
}

// POST: حجز أو استهلاك الباتشات
export async function POST(request: NextRequest) {
  try {
    const body = await request.json()
    const { action, allocations, referenceType, referenceId, createdBy } = body

    if (!action || !allocations || !referenceType || !referenceId || !createdBy) {
      return NextResponse.json({ error: "بيانات غير مكتملة" }, { status: 400 })
    }

    switch (action) {
      case "reserve":
        await reserveBatches(allocations, referenceType, referenceId, createdBy)
        return NextResponse.json({
          success: true,
          message: "تم حجز الباتشات بنجاح",
        })

      case "release":
        await releaseBatches(allocations, referenceType, referenceId, createdBy)
        return NextResponse.json({
          success: true,
          message: "تم إلغاء حجز الباتشات بنجاح",
        })

      case "consume":
        await consumeBatches(allocations, referenceType, referenceId, createdBy)
        return NextResponse.json({
          success: true,
          message: "تم استهلاك الباتشات بنجاح",
        })

      default:
        return NextResponse.json({ error: "عملية غير معروفة" }, { status: 400 })
    }
  } catch (error) {
    console.error("[v0] Error in batches POST:", error)
    return NextResponse.json(
      { error: error instanceof Error ? error.message : "حدث خطأ في معالجة الطلب" },
      { status: 500 },
    )
  }
}
