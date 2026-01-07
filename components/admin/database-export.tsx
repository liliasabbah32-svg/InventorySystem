"use client"

import { useState } from "react"
import { Button } from "@/components/ui/button"
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card"
import { Download, Database, FileText, Loader2 } from "lucide-react"
import { Badge } from "@/components/ui/badge"

export default function DatabaseExport() {
  const [isExporting, setIsExporting] = useState(false)
  const [exportStatus, setExportStatus] = useState<string>("")

  const exportFullDatabase = async () => {
    setIsExporting(true)
    setExportStatus("جاري تصدير قاعدة البيانات الكاملة...")

    try {
      const response = await fetch("/api/admin/export-database", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ type: "full" }),
      })

      if (response.ok) {
        const blob = await response.blob()
        const url = URL.createObjectURL(blob)
        const a = document.createElement("a")
        a.href = url
        a.download = `arabic-erp-full-backup-${new Date().toISOString().split("T")[0]}.sql`
        document.body.appendChild(a)
        a.click()
        document.body.removeChild(a)
        URL.revokeObjectURL(url)
        setExportStatus("تم تصدير قاعدة البيانات بنجاح!")
      } else {
        setExportStatus("فشل في تصدير قاعدة البيانات")
      }
    } catch (error) {
      setExportStatus("حدث خطأ أثناء التصدير")
      console.error("Export error:", error)
    } finally {
      setIsExporting(false)
    }
  }

  const exportDataOnly = async () => {
    setIsExporting(true)
    setExportStatus("جاري تصدير البيانات فقط...")

    try {
      const response = await fetch("/api/admin/export-database", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ type: "data" }),
      })

      if (response.ok) {
        const blob = await response.blob()
        const url = URL.createObjectURL(blob)
        const a = document.createElement("a")
        a.href = url
        a.download = `arabic-erp-data-${new Date().toISOString().split("T")[0]}.json`
        document.body.appendChild(a)
        a.click()
        document.body.removeChild(a)
        URL.revokeObjectURL(url)
        setExportStatus("تم تصدير البيانات بنجاح!")
      } else {
        setExportStatus("فشل في تصدير البيانات")
      }
    } catch (error) {
      setExportStatus("حدث خطأ أثناء التصدير")
      console.error("Export error:", error)
    } finally {
      setIsExporting(false)
    }
  }

  return (
    <div className="space-y-6">
      <div className="flex items-center gap-2">
        <Database className="h-6 w-6" />
        <h1 className="text-2xl font-bold">تصدير قاعدة البيانات</h1>
      </div>

      <div className="grid gap-6 md:grid-cols-2">
        <Card>
          <CardHeader>
            <CardTitle className="flex items-center gap-2">
              <Database className="h-5 w-5" />
              نسخة احتياطية كاملة
            </CardTitle>
            <CardDescription>تصدير قاعدة البيانات الكاملة بما في ذلك البنية والبيانات</CardDescription>
          </CardHeader>
          <CardContent className="space-y-4">
            <div className="space-y-2">
              <Badge variant="secondary">SQL Format</Badge>
              <p className="text-sm text-muted-foreground">يشمل: جميع الجداول، البيانات، الفهارس، والقيود</p>
            </div>
            <Button onClick={exportFullDatabase} disabled={isExporting} className="w-full">
              {isExporting ? <Loader2 className="h-4 w-4 animate-spin ml-2" /> : <Download className="h-4 w-4 ml-2" />}
              تصدير النسخة الكاملة
            </Button>
          </CardContent>
        </Card>

        <Card>
          <CardHeader>
            <CardTitle className="flex items-center gap-2">
              <FileText className="h-5 w-5" />
              البيانات فقط
            </CardTitle>
            <CardDescription>تصدير البيانات فقط بدون بنية قاعدة البيانات</CardDescription>
          </CardHeader>
          <CardContent className="space-y-4">
            <div className="space-y-2">
              <Badge variant="secondary">JSON Format</Badge>
              <p className="text-sm text-muted-foreground">يشمل: البيانات من الجداول الرئيسية فقط</p>
            </div>
            <Button onClick={exportDataOnly} disabled={isExporting} variant="outline" className="w-full bg-transparent">
              {isExporting ? <Loader2 className="h-4 w-4 animate-spin ml-2" /> : <Download className="h-4 w-4 ml-2" />}
              تصدير البيانات فقط
            </Button>
          </CardContent>
        </Card>
      </div>

      {exportStatus && (
        <Card>
          <CardContent className="pt-6">
            <p className="text-center text-sm">{exportStatus}</p>
          </CardContent>
        </Card>
      )}

      <Card>
        <CardHeader>
          <CardTitle>معلومات قاعدة البيانات</CardTitle>
        </CardHeader>
        <CardContent>
          <div className="grid gap-4 md:grid-cols-3">
            <div className="text-center">
              <div className="text-2xl font-bold text-primary">50</div>
              <div className="text-sm text-muted-foreground">جدول</div>
            </div>
            <div className="text-center">
              <div className="text-2xl font-bold text-primary">Neon</div>
              <div className="text-sm text-muted-foreground">منصة الاستضافة</div>
            </div>
            <div className="text-center">
              <div className="text-2xl font-bold text-primary">PostgreSQL</div>
              <div className="text-sm text-muted-foreground">نوع قاعدة البيانات</div>
            </div>
          </div>
        </CardContent>
      </Card>
    </div>
  )
}
