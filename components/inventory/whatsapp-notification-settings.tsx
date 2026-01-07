"use client"

import { useState, useEffect } from "react"
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card"
import { Button } from "@/components/ui/button"
import { Input } from "@/components/ui/input"
import { Label } from "@/components/ui/label"
import { Switch } from "@/components/ui/switch"
import { Textarea } from "@/components/ui/textarea"
import { Badge } from "@/components/ui/badge"
import { Alert, AlertDescription } from "@/components/ui/alert"
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from "@/components/ui/table"
import { MessageSquare, Plus, X, Save, Send, CheckCircle, AlertTriangle, Clock, RefreshCw, Phone } from "lucide-react"

interface NotificationSettings {
  id: number | null
  is_enabled: boolean
  phone_numbers: string[]
  notification_threshold: string
  message_template: string
  send_daily_summary: boolean
  daily_summary_time: string
}

interface NotificationLog {
  id: number
  product_code: string
  product_name: string
  phone_number: string
  status: string
  sent_at: string
  error_message?: string
  created_at: string
}

export function WhatsAppNotificationSettings() {
  const [settings, setSettings] = useState<NotificationSettings>({
    id: null,
    is_enabled: false,
    phone_numbers: [],
    notification_threshold: "at_reorder_point",
    message_template: "",
    send_daily_summary: false,
    daily_summary_time: "09:00",
  })

  const [newPhoneNumber, setNewPhoneNumber] = useState("")
  const [notificationLog, setNotificationLog] = useState<NotificationLog[]>([])
  const [loading, setLoading] = useState(true)
  const [saving, setSaving] = useState(false)
  const [sending, setSending] = useState(false)
  const [message, setMessage] = useState<{ type: "success" | "error"; text: string } | null>(null)

  useEffect(() => {
    fetchSettings()
    fetchNotificationLog()
  }, [])

  const fetchSettings = async () => {
    try {
      const response = await fetch("/api/inventory/notification-settings")
      if (response.ok) {
        const data = await response.json()
        setSettings(data)
      }
    } catch (error) {
      console.error("[v0] Error fetching settings:", error)
    } finally {
      setLoading(false)
    }
  }

  const fetchNotificationLog = async () => {
    try {
      const response = await fetch("/api/inventory/send-reorder-notifications?limit=20")
      if (response.ok) {
        const data = await response.json()
        setNotificationLog(data)
      }
    } catch (error) {
      console.error("[v0] Error fetching notification log:", error)
    }
  }

  const handleSaveSettings = async () => {
    try {
      setSaving(true)
      setMessage(null)

      const response = await fetch("/api/inventory/notification-settings", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify(settings),
      })

      if (!response.ok) {
        throw new Error("فشل في حفظ الإعدادات")
      }

      const data = await response.json()
      setSettings(data)
      setMessage({ type: "success", text: "تم حفظ الإعدادات بنجاح" })

      setTimeout(() => setMessage(null), 3000)
    } catch (error) {
      setMessage({
        type: "error",
        text: error instanceof Error ? error.message : "حدث خطأ أثناء الحفظ",
      })
    } finally {
      setSaving(false)
    }
  }

  const handleSendTestNotifications = async () => {
    try {
      setSending(true)
      setMessage(null)

      const response = await fetch("/api/inventory/send-reorder-notifications", {
        method: "POST",
      })

      if (!response.ok) {
        throw new Error("فشل في إرسال الإشعارات")
      }

      const result = await response.json()

      if (result.success) {
        setMessage({
          type: "success",
          text: `${result.message} - تم فحص ${result.productsChecked} منتج`,
        })
        fetchNotificationLog()
      } else {
        setMessage({ type: "error", text: result.message || "فشل في إرسال الإشعارات" })
      }
    } catch (error) {
      setMessage({
        type: "error",
        text: error instanceof Error ? error.message : "حدث خطأ أثناء الإرسال",
      })
    } finally {
      setSending(false)
    }
  }

  const handleAddPhoneNumber = () => {
    if (!newPhoneNumber.trim()) return

    // Basic validation for phone number
    const cleanNumber = newPhoneNumber.trim()
    if (!cleanNumber.match(/^\+?[0-9]{10,15}$/)) {
      setMessage({ type: "error", text: "رقم الهاتف غير صحيح. يجب أن يبدأ بـ + ويحتوي على 10-15 رقم" })
      return
    }

    if (settings.phone_numbers.includes(cleanNumber)) {
      setMessage({ type: "error", text: "رقم الهاتف موجود مسبقاً" })
      return
    }

    setSettings((prev) => ({
      ...prev,
      phone_numbers: [...prev.phone_numbers, cleanNumber],
    }))
    setNewPhoneNumber("")
  }

  const handleRemovePhoneNumber = (number: string) => {
    setSettings((prev) => ({
      ...prev,
      phone_numbers: prev.phone_numbers.filter((n) => n !== number),
    }))
  }

  const getStatusBadge = (status: string) => {
    switch (status) {
      case "sent":
        return (
          <Badge className="bg-green-100 text-green-800">
            <CheckCircle className="h-3 w-3 ml-1" />
            تم الإرسال
          </Badge>
        )
      case "failed":
        return (
          <Badge className="bg-red-100 text-red-800">
            <AlertTriangle className="h-3 w-3 ml-1" />
            فشل
          </Badge>
        )
      case "pending":
        return (
          <Badge className="bg-yellow-100 text-yellow-800">
            <Clock className="h-3 w-3 ml-1" />
            قيد الانتظار
          </Badge>
        )
      default:
        return <Badge>{status}</Badge>
    }
  }

  if (loading) {
    return (
      <div className="flex items-center justify-center min-h-[400px]" dir="rtl">
        <div className="text-center">
          <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-primary mx-auto mb-4"></div>
          <p className="text-muted-foreground">جاري التحميل...</p>
        </div>
      </div>
    )
  }

  return (
    <div className="space-y-6 p-6 bg-background" dir="rtl">
      {/* Header */}
      <div className="flex items-center justify-between">
        <div>
          <h1 className="text-3xl font-bold text-foreground flex items-center gap-3">
            <MessageSquare className="h-8 w-8 text-green-600" />
            إعدادات إشعارات WhatsApp
          </h1>
          <p className="text-muted-foreground mt-1">إدارة إشعارات إعادة الطلب عبر WhatsApp</p>
        </div>
        <Button onClick={handleSendTestNotifications} disabled={sending || !settings.is_enabled} className="gap-2">
          <Send className={`h-4 w-4 ${sending ? "animate-pulse" : ""}`} />
          {sending ? "جاري الإرسال..." : "إرسال الإشعارات الآن"}
        </Button>
      </div>

      {/* Messages */}
      {message && (
        <Alert className={message.type === "success" ? "border-green-200 bg-green-50" : "border-red-200 bg-red-50"}>
          {message.type === "success" ? (
            <CheckCircle className="h-4 w-4 text-green-600" />
          ) : (
            <AlertTriangle className="h-4 w-4 text-red-600" />
          )}
          <AlertDescription className={message.type === "success" ? "text-green-800" : "text-red-800"}>
            {message.text}
          </AlertDescription>
          <Button variant="ghost" size="sm" className="mr-auto" onClick={() => setMessage(null)}>
            <X className="h-4 w-4" />
          </Button>
        </Alert>
      )}

      {/* Settings Card */}
      <Card>
        <CardHeader>
          <CardTitle className="flex items-center justify-between">
            <span>إعدادات الإشعارات</span>
            <Switch
              checked={settings.is_enabled}
              onCheckedChange={(checked) => setSettings((prev) => ({ ...prev, is_enabled: checked }))}
            />
          </CardTitle>
          <CardDescription>
            {settings.is_enabled
              ? "الإشعارات مفعلة - سيتم إرسال تنبيهات عند الوصول لنقطة إعادة الطلب"
              : "الإشعارات معطلة"}
          </CardDescription>
        </CardHeader>
        <CardContent className="space-y-6">
          {/* Phone Numbers */}
          <div>
            <Label className="text-base font-semibold mb-3 block">أرقام الهواتف</Label>
            <div className="flex gap-2 mb-3">
              <Input
                placeholder="+966501234567"
                value={newPhoneNumber}
                onChange={(e) => setNewPhoneNumber(e.target.value)}
                onKeyPress={(e) => e.key === "Enter" && handleAddPhoneNumber()}
                className="flex-1"
              />
              <Button onClick={handleAddPhoneNumber} variant="outline">
                <Plus className="h-4 w-4 ml-2" />
                إضافة
              </Button>
            </div>
            <div className="space-y-2">
              {settings.phone_numbers.length === 0 ? (
                <p className="text-sm text-muted-foreground">لا توجد أرقام مضافة. أضف رقم هاتف لتلقي الإشعارات.</p>
              ) : (
                settings.phone_numbers.map((number) => (
                  <div key={number} className="flex items-center justify-between p-3 bg-muted rounded-lg">
                    <div className="flex items-center gap-2">
                      <Phone className="h-4 w-4 text-muted-foreground" />
                      <span className="font-medium">{number}</span>
                    </div>
                    <Button variant="ghost" size="sm" onClick={() => handleRemovePhoneNumber(number)}>
                      <X className="h-4 w-4" />
                    </Button>
                  </div>
                ))
              )}
            </div>
          </div>

          {/* Message Template */}
          <div>
            <Label htmlFor="message-template" className="text-base font-semibold mb-2 block">
              قالب الرسالة
            </Label>
            <p className="text-sm text-muted-foreground mb-2">
              استخدم المتغيرات: {"{product_name}"}, {"{product_code}"}, {"{current_stock}"}, {"{reorder_point}"},{" "}
              {"{supplier_name}"}
            </p>
            <Textarea
              id="message-template"
              value={settings.message_template}
              onChange={(e) => setSettings((prev) => ({ ...prev, message_template: e.target.value }))}
              rows={6}
              className="font-mono text-sm"
              placeholder="🔔 تنبيه إعادة طلب&#10;&#10;📦 المنتج: {product_name}&#10;🔢 الكود: {product_code}&#10;📊 المخزون الحالي: {current_stock}&#10;⚠️ نقطة إعادة الطلب: {reorder_point}&#10;🏭 المورد: {supplier_name}&#10;&#10;يرجى اتخاذ الإجراء اللازم."
            />
          </div>

          {/* Daily Summary */}
          <div className="flex items-center justify-between p-4 bg-muted rounded-lg">
            <div>
              <Label className="text-base font-semibold">ملخص يومي</Label>
              <p className="text-sm text-muted-foreground">إرسال ملخص يومي بالمنتجات التي تحتاج إعادة طلب</p>
            </div>
            <Switch
              checked={settings.send_daily_summary}
              onCheckedChange={(checked) => setSettings((prev) => ({ ...prev, send_daily_summary: checked }))}
            />
          </div>

          {settings.send_daily_summary && (
            <div>
              <Label htmlFor="summary-time">وقت إرسال الملخص اليومي</Label>
              <Input
                id="summary-time"
                type="time"
                value={settings.daily_summary_time}
                onChange={(e) => setSettings((prev) => ({ ...prev, daily_summary_time: e.target.value }))}
              />
            </div>
          )}

          {/* Save Button */}
          <div className="flex justify-end pt-4 border-t">
            <Button onClick={handleSaveSettings} disabled={saving} className="gap-2">
              <Save className="h-4 w-4" />
              {saving ? "جاري الحفظ..." : "حفظ الإعدادات"}
            </Button>
          </div>
        </CardContent>
      </Card>

      {/* Notification Log */}
      <Card>
        <CardHeader>
          <div className="flex items-center justify-between">
            <div>
              <CardTitle>سجل الإشعارات</CardTitle>
              <CardDescription>آخر 20 إشعار تم إرسالها</CardDescription>
            </div>
            <Button variant="outline" size="sm" onClick={fetchNotificationLog}>
              <RefreshCw className="h-4 w-4 ml-2" />
              تحديث
            </Button>
          </div>
        </CardHeader>
        <CardContent>
          {notificationLog.length === 0 ? (
            <div className="text-center py-12">
              <MessageSquare className="mx-auto h-12 w-12 text-muted-foreground mb-4" />
              <h3 className="text-lg font-semibold text-foreground mb-2">لا توجد إشعارات</h3>
              <p className="text-muted-foreground">لم يتم إرسال أي إشعارات بعد</p>
            </div>
          ) : (
            <div className="overflow-x-auto">
              <Table>
                <TableHeader>
                  <TableRow>
                    <TableHead className="text-right">كود المنتج</TableHead>
                    <TableHead className="text-right">اسم المنتج</TableHead>
                    <TableHead className="text-right">رقم الهاتف</TableHead>
                    <TableHead className="text-right">الحالة</TableHead>
                    <TableHead className="text-right">التاريخ</TableHead>
                  </TableRow>
                </TableHeader>
                <TableBody>
                  {notificationLog.map((log) => (
                    <TableRow key={log.id}>
                      <TableCell className="font-medium">{log.product_code}</TableCell>
                      <TableCell>{log.product_name}</TableCell>
                      <TableCell>{log.phone_number}</TableCell>
                      <TableCell>{getStatusBadge(log.status)}</TableCell>
                      <TableCell>{new Date(log.created_at).toLocaleString("ar-SA")}</TableCell>
                    </TableRow>
                  ))}
                </TableBody>
              </Table>
            </div>
          )}
        </CardContent>
      </Card>
    </div>
  )
}
