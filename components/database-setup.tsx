"use client"

import { useState } from "react"
import { Button } from "@/components/ui/button"
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card"
import { CheckCircle, AlertCircle, Loader2 } from "lucide-react"

export function DatabaseSetup() {
  const [status, setStatus] = useState<"idle" | "loading" | "success" | "error">("idle")
  const [message, setMessage] = useState("")

  const setupDatabase = async () => {
    setStatus("loading")
    setMessage("جاري إعداد قاعدة البيانات...")

    try {
      const response = await fetch("/api/setup-database", {
        method: "POST",
      })

      const result = await response.json()

      if (response.ok) {
        setStatus("success")
        setMessage("تم إعداد قاعدة البيانات بنجاح!")
      } else {
        setStatus("error")
        setMessage(`خطأ: ${result.error}`)
      }
    } catch (error) {
      setStatus("error")
      setMessage("فشل في الاتصال بقاعدة البيانات")
    }
  }

  return (
    <Card className="w-full max-w-md mx-auto">
      <CardHeader className="text-center">
        <CardTitle>إعداد قاعدة البيانات</CardTitle>
        <CardDescription>اضغط على الزر أدناه لإنشاء الجداول والبيانات التجريبية</CardDescription>
      </CardHeader>
      <CardContent className="space-y-4">
        <Button onClick={setupDatabase} disabled={status === "loading"} className="w-full">
          {status === "loading" && <Loader2 className="mr-2 h-4 w-4 animate-spin" />}
          إعداد قاعدة البيانات
        </Button>

        {message && (
          <div
            className={`flex items-center gap-2 p-3 rounded-md ${
              status === "success"
                ? "bg-green-50 text-green-700"
                : status === "error"
                  ? "bg-red-50 text-red-700"
                  : "bg-blue-50 text-blue-700"
            }`}
          >
            {status === "success" && <CheckCircle className="h-4 w-4" />}
            {status === "error" && <AlertCircle className="h-4 w-4" />}
            {status === "loading" && <Loader2 className="h-4 w-4 animate-spin" />}
            <span className="text-sm">{message}</span>
          </div>
        )}

        {status === "success" && (
          <Button onClick={() => window.location.reload()} variant="outline" className="w-full">
            إعادة تحميل الصفحة
          </Button>
        )}
      </CardContent>
    </Card>
  )
}
