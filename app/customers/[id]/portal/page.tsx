"use client"

import { useEffect, useState } from "react"
import { useParams, useRouter } from "next/navigation"
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card"
import { Button } from "@/components/ui/button"
import { Input } from "@/components/ui/input"
import { Label } from "@/components/ui/label"
import { Switch } from "@/components/ui/switch"
import { Alert, AlertDescription } from "@/components/ui/alert"
import { Skeleton } from "@/components/ui/skeleton"
import { Badge } from "@/components/ui/badge"
import { Dialog, DialogContent, DialogDescription, DialogHeader, DialogTitle } from "@/components/ui/dialog"
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from "@/components/ui/table"
import { Tabs, TabsContent, TabsList, TabsTrigger } from "@/components/ui/tabs"
import { Plus, Trash2, Key, Shield, UserPlus, Bell, MessageSquare, Phone, ArrowRight, Home } from "lucide-react"

interface CustomerUser {
  id: number
  username: string
  email: string | null
  is_active: boolean
  last_login: string | null
  can_view_orders: boolean
  can_create_orders: boolean
  can_view_balance: boolean
  can_view_products: boolean
  can_view_prices: boolean
  can_view_stock: boolean
}

interface Customer {
  id: number
  name: string
}

interface NotificationSettings {
  id?: number
  customer_id: number
  notification_method: "sms" | "whatsapp" | "both"
  preferred_phone: string
  notify_on_received: boolean
  notify_on_preparing: boolean
  notify_on_quality_check: boolean
  notify_on_shipped: boolean
  is_active: boolean
}

export default function CustomerPortalManagementPage() {
  const params = useParams()
  const router = useRouter()
  const customerId = Number.parseInt(params.id as string)

  const [customer, setCustomer] = useState<Customer | null>(null)
  const [users, setUsers] = useState<CustomerUser[]>([])
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState("")
  const [success, setSuccess] = useState("")

  const [createDialogOpen, setCreateDialogOpen] = useState(false)
  const [editDialogOpen, setEditDialogOpen] = useState(false)
  const [selectedUser, setSelectedUser] = useState<CustomerUser | null>(null)

  const [formData, setFormData] = useState({
    username: "",
    password: "",
    email: "",
  })

  const [permissions, setPermissions] = useState({
    can_view_orders: true,
    can_create_orders: true,
    can_view_balance: true,
    can_view_products: true,
    can_view_prices: true,
    can_view_stock: true,
  })

  const [notificationSettings, setNotificationSettings] = useState<NotificationSettings>({
    customer_id: customerId,
    notification_method: "sms",
    preferred_phone: "",
    notify_on_received: true,
    notify_on_preparing: true,
    notify_on_quality_check: true,
    notify_on_shipped: true,
    is_active: true,
  })
  const [notificationLoading, setNotificationLoading] = useState(false)

  useEffect(() => {
    loadData()
    loadNotificationSettings()
  }, [customerId])

  const loadData = async () => {
    try {
      const [customerRes, usersRes] = await Promise.all([
        fetch(`/api/customers/${customerId}`),
        fetch(`/api/admin/customer-users?customerId=${customerId}`),
      ])

      if (customerRes.ok) {
        const customerData = await customerRes.json()
        setCustomer(customerData)
      }

      if (usersRes.ok) {
        const usersData = await usersRes.json()
        setUsers(usersData.users)
      }
    } catch (error) {
      console.error("Load data error:", error)
      setError("حدث خطأ أثناء تحميل البيانات")
    } finally {
      setLoading(false)
    }
  }

  const loadNotificationSettings = async () => {
    try {
      const response = await fetch(`/api/customer-notifications/settings?customerId=${customerId}`)
      if (response.ok) {
        const data = await response.json()
        if (data.settings) {
          setNotificationSettings(data.settings)
        }
      }
    } catch (error) {
      console.error("Load notification settings error:", error)
    }
  }

  const handleCreateUser = async () => {
    console.log("[v0] handleCreateUser called")
    setError("")
    setSuccess("")

    if (!formData.username || !formData.password) {
      console.log("[v0] Validation failed: missing username or password")
      setError("اسم المستخدم وكلمة المرور مطلوبان")
      return
    }

    console.log("[v0] Form data:", {
      username: formData.username,
      email: formData.email,
      hasPassword: !!formData.password,
    })
    console.log("[v0] Permissions:", permissions)

    try {
      console.log("[v0] Sending POST request to /api/admin/customer-users")
      const requestBody = {
        customerId,
        username: formData.username,
        password: formData.password,
        email: formData.email || null,
        permissions,
      }
      console.log("[v0] Request body:", JSON.stringify(requestBody, null, 2))

      const response = await fetch("/api/admin/customer-users", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify(requestBody),
      })

      console.log("[v0] Response status:", response.status)
      console.log("[v0] Response ok:", response.ok)
      console.log("[v0] Response headers:", Object.fromEntries(response.headers.entries()))

      const contentType = response.headers.get("content-type")
      console.log("[v0] Response content-type:", contentType)

      if (!contentType || !contentType.includes("application/json")) {
        const text = await response.text()
        console.error("[v0] Non-JSON response received:", text.substring(0, 500))
        setError("حدث خطأ في الاتصال بالخادم. الرجاء المحاولة مرة أخرى")
        return
      }

      const data = await response.json()
      console.log("[v0] Response data:", data)

      if (!response.ok) {
        console.log("[v0] Error response:", data.error)
        setError(data.error || "حدث خطأ أثناء إنشاء المستخدم")
        return
      }

      console.log("[v0] User created successfully")
      setSuccess("تم إنشاء المستخدم بنجاح")
      setCreateDialogOpen(false)
      resetForm()
      loadData()
    } catch (error) {
      console.error("[v0] Create user error:", error)
      console.error("[v0] Error type:", error instanceof Error ? error.constructor.name : typeof error)
      console.error("[v0] Error message:", error instanceof Error ? error.message : String(error))
      console.error("[v0] Error stack:", error instanceof Error ? error.stack : undefined)
      setError(`حدث خطأ أثناء إنشاء المستخدم: ${error instanceof Error ? error.message : "خطأ غير معروف"}`)
    }
  }

  const handleUpdatePermissions = async (userId: number, newPermissions: any) => {
    setError("")
    setSuccess("")

    try {
      const response = await fetch(`/api/admin/customer-users/${userId}/permissions`, {
        method: "PUT",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify(newPermissions),
      })

      const data = await response.json()

      if (!response.ok) {
        setError(data.error || "حدث خطأ أثناء تحديث الصلاحيات")
        return
      }

      setSuccess("تم تحديث الصلاحيات بنجاح")
      setEditDialogOpen(false)
      loadData()
    } catch (error) {
      console.error("Update permissions error:", error)
      setError("حدث خطأ أثناء تحديث الصلاحيات")
    }
  }

  const handleToggleStatus = async (userId: number) => {
    setError("")
    setSuccess("")

    try {
      const response = await fetch(`/api/admin/customer-users/${userId}/toggle`, {
        method: "PUT",
      })

      const data = await response.json()

      if (!response.ok) {
        setError(data.error || "حدث خطأ أثناء تغيير حالة المستخدم")
        return
      }

      setSuccess("تم تغيير حالة المستخدم بنجاح")
      loadData()
    } catch (error) {
      console.error("Toggle status error:", error)
      setError("حدث خطأ أثناء تغيير حالة المستخدم")
    }
  }

  const handleResetPassword = async (userId: number) => {
    const newPassword = prompt("أدخل كلمة المرور الجديدة:")

    if (!newPassword) return

    setError("")
    setSuccess("")

    try {
      const response = await fetch(`/api/admin/customer-users/${userId}/password`, {
        method: "PUT",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ password: newPassword }),
      })

      const data = await response.json()

      if (!response.ok) {
        setError(data.error || "حدث خطأ أثناء تغيير كلمة المرور")
        return
      }

      setSuccess("تم تغيير كلمة المرور بنجاح")
    } catch (error) {
      console.error("Reset password error:", error)
      setError("حدث خطأ أثناء تغيير كلمة المرور")
    }
  }

  const openEditDialog = (user: CustomerUser) => {
    setSelectedUser(user)
    setPermissions({
      can_view_orders: user.can_view_orders,
      can_create_orders: user.can_create_orders,
      can_view_balance: user.can_view_balance,
      can_view_products: user.can_view_products,
      can_view_prices: user.can_view_prices,
      can_view_stock: user.can_view_stock,
    })
    setEditDialogOpen(true)
  }

  const resetForm = () => {
    setFormData({ username: "", password: "", email: "" })
    setPermissions({
      can_view_orders: true,
      can_create_orders: true,
      can_view_balance: true,
      can_view_products: true,
      can_view_prices: true,
      can_view_stock: true,
    })
  }

  const formatDate = (date: string | null) => {
    if (!date) return "لم يسجل دخول بعد"
    return new Date(date).toLocaleDateString("ar-SA", {
      year: "numeric",
      month: "long",
      day: "numeric",
      hour: "2-digit",
      minute: "2-digit",
    })
  }

  const handleSaveNotificationSettings = async () => {
    setError("")
    setSuccess("")
    setNotificationLoading(true)

    try {
      const response = await fetch("/api/customer-notifications/settings", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify(notificationSettings),
      })

      const data = await response.json()

      if (!response.ok) {
        setError(data.error || "حدث خطأ أثناء حفظ الإعدادات")
        return
      }

      setSuccess("تم حفظ إعدادات الإشعارات بنجاح")
      loadNotificationSettings()
    } catch (error) {
      console.error("Save notification settings error:", error)
      setError("حدث خطأ أثناء حفظ الإعدادات")
    } finally {
      setNotificationLoading(false)
    }
  }

  return (
    <div className="container mx-auto py-6 space-y-6" dir="rtl">
      {/* Header */}
      <div className="flex items-center justify-between">
        <div className="flex items-center gap-4">
          <Button variant="outline" size="icon" onClick={() => router.push("/")} title="العودة للرئيسية">
            <Home className="h-4 w-4" />
          </Button>
          <Button variant="outline" onClick={() => router.back()} className="gap-2">
            <ArrowRight className="h-4 w-4" />
            رجوع
          </Button>
          <div>
            <h1 className="text-3xl font-bold">إدارة بوابة العملاء</h1>
            <p className="text-muted-foreground mt-1">
              {customer ? `إدارة حسابات وصلاحيات: ${customer.name}` : "جاري التحميل..."}
            </p>
          </div>
        </div>
        <Button onClick={() => setCreateDialogOpen(true)} className="gap-2">
          <UserPlus className="h-4 w-4" />
          إضافة مستخدم
        </Button>
      </div>

      {error && (
        <Alert variant="destructive">
          <AlertDescription>{error}</AlertDescription>
        </Alert>
      )}

      {success && (
        <Alert>
          <AlertDescription>{success}</AlertDescription>
        </Alert>
      )}

      {/* Tabs for organizing content */}
      <Tabs defaultValue="users" className="w-full">
        <TabsList className="grid w-full grid-cols-2">
          <TabsTrigger value="users">المستخدمون</TabsTrigger>
          <TabsTrigger value="notifications">إعدادات الإشعارات</TabsTrigger>
        </TabsList>

        {/* Users Table */}
        <TabsContent value="users" className="space-y-4">
          <Card>
            <CardHeader>
              <CardTitle>المستخدمون</CardTitle>
              <CardDescription>قائمة المستخدمين وصلاحياتهم</CardDescription>
            </CardHeader>
            <CardContent>
              {loading ? (
                <div className="space-y-3">
                  {[...Array(3)].map((_, i) => (
                    <Skeleton key={i} className="h-16 w-full" />
                  ))}
                </div>
              ) : users.length === 0 ? (
                <div className="text-center py-12">
                  <p className="text-muted-foreground">لا يوجد مستخدمون</p>
                  <Button onClick={() => setCreateDialogOpen(true)} className="mt-4 gap-2">
                    <UserPlus className="h-4 w-4" />
                    إضافة أول مستخدم
                  </Button>
                </div>
              ) : (
                <div className="rounded-md border">
                  <Table>
                    <TableHeader>
                      <TableRow>
                        <TableHead className="text-right">اسم المستخدم</TableHead>
                        <TableHead className="text-right">البريد الإلكتروني</TableHead>
                        <TableHead className="text-right">آخر تسجيل دخول</TableHead>
                        <TableHead className="text-right">الحالة</TableHead>
                        <TableHead className="text-right">الصلاحيات</TableHead>
                        <TableHead className="text-right">الإجراءات</TableHead>
                      </TableRow>
                    </TableHeader>
                    <TableBody>
                      {users.map((user) => (
                        <TableRow key={user.id}>
                          <TableCell className="font-medium">{user.username}</TableCell>
                          <TableCell>{user.email || "-"}</TableCell>
                          <TableCell className="text-sm">{formatDate(user.last_login)}</TableCell>
                          <TableCell>
                            <Badge variant={user.is_active ? "default" : "secondary"}>
                              {user.is_active ? "مفعل" : "معطل"}
                            </Badge>
                          </TableCell>
                          <TableCell>
                            <div className="flex flex-wrap gap-1">
                              {user.can_view_orders && <Badge variant="outline">عرض الطلبيات</Badge>}
                              {user.can_create_orders && <Badge variant="outline">إنشاء طلبيات</Badge>}
                              {user.can_view_balance && <Badge variant="outline">عرض الرصيد</Badge>}
                              {user.can_view_products && <Badge variant="outline">عرض الأصناف</Badge>}
                              {user.can_view_prices && <Badge variant="outline">عرض الأسعار</Badge>}
                              {user.can_view_stock && <Badge variant="outline">عرض المخزون</Badge>}
                            </div>
                          </TableCell>
                          <TableCell>
                            <div className="flex gap-2">
                              <Button
                                variant="ghost"
                                size="icon"
                                onClick={() => openEditDialog(user)}
                                title="تعديل الصلاحيات"
                              >
                                <Shield className="h-4 w-4" />
                              </Button>
                              <Button
                                variant="ghost"
                                size="icon"
                                onClick={() => handleResetPassword(user.id)}
                                title="تغيير كلمة المرور"
                              >
                                <Key className="h-4 w-4" />
                              </Button>
                              <Button
                                variant="ghost"
                                size="icon"
                                onClick={() => handleToggleStatus(user.id)}
                                title={user.is_active ? "تعطيل" : "تفعيل"}
                              >
                                {user.is_active ? (
                                  <Trash2 className="h-4 w-4 text-red-600" />
                                ) : (
                                  <Plus className="h-4 w-4 text-green-600" />
                                )}
                              </Button>
                            </div>
                          </TableCell>
                        </TableRow>
                      ))}
                    </TableBody>
                  </Table>
                </div>
              )}
            </CardContent>
          </Card>
        </TabsContent>

        {/* Notification Settings Tab */}
        <TabsContent value="notifications" className="space-y-4">
          <Card>
            <CardHeader>
              <CardTitle className="flex items-center gap-2">
                <Bell className="h-5 w-5" />
                إعدادات الإشعارات التلقائية
              </CardTitle>
              <CardDescription>تحديد كيفية إرسال الإشعارات للعميل عند تحديث حالة الطلبيات</CardDescription>
            </CardHeader>
            <CardContent className="space-y-6">
              {/* Notification Method */}
              <div className="space-y-4">
                <h3 className="font-semibold text-lg">طريقة الإرسال</h3>
                <div className="grid gap-4 md:grid-cols-3">
                  <Card
                    className={`cursor-pointer transition-all ${
                      notificationSettings.notification_method === "sms"
                        ? "border-primary bg-primary/5"
                        : "hover:border-primary/50"
                    }`}
                    onClick={() => setNotificationSettings({ ...notificationSettings, notification_method: "sms" })}
                  >
                    <CardContent className="flex flex-col items-center justify-center p-6">
                      <Phone className="h-8 w-8 mb-2 text-primary" />
                      <h4 className="font-semibold">SMS</h4>
                      <p className="text-sm text-muted-foreground text-center mt-1">رسائل نصية قصيرة</p>
                    </CardContent>
                  </Card>

                  <Card
                    className={`cursor-pointer transition-all ${
                      notificationSettings.notification_method === "whatsapp"
                        ? "border-primary bg-primary/5"
                        : "hover:border-primary/50"
                    }`}
                    onClick={() =>
                      setNotificationSettings({ ...notificationSettings, notification_method: "whatsapp" })
                    }
                  >
                    <CardContent className="flex flex-col items-center justify-center p-6">
                      <MessageSquare className="h-8 w-8 mb-2 text-green-600" />
                      <h4 className="font-semibold">واتساب</h4>
                      <p className="text-sm text-muted-foreground text-center mt-1">رسائل واتساب</p>
                    </CardContent>
                  </Card>

                  <Card
                    className={`cursor-pointer transition-all ${
                      notificationSettings.notification_method === "both"
                        ? "border-primary bg-primary/5"
                        : "hover:border-primary/50"
                    }`}
                    onClick={() => setNotificationSettings({ ...notificationSettings, notification_method: "both" })}
                  >
                    <CardContent className="flex flex-col items-center justify-center p-6">
                      <Bell className="h-8 w-8 mb-2 text-blue-600" />
                      <h4 className="font-semibold">كلاهما</h4>
                      <p className="text-sm text-muted-foreground text-center mt-1">SMS + واتساب</p>
                    </CardContent>
                  </Card>
                </div>
              </div>

              {/* Preferred Phone Number */}
              <div className="space-y-2">
                <Label htmlFor="preferred_phone">رقم الهاتف المفضل للإشعارات</Label>
                <Input
                  id="preferred_phone"
                  type="tel"
                  placeholder="مثال: +963999999999"
                  value={notificationSettings.preferred_phone}
                  onChange={(e) =>
                    setNotificationSettings({ ...notificationSettings, preferred_phone: e.target.value })
                  }
                />
                <p className="text-sm text-muted-foreground">
                  إذا لم يتم تحديد رقم، سيتم استخدام رقم الهاتف الأساسي للعميل
                </p>
              </div>

              {/* Active Notifications */}
              <div className="space-y-4">
                <h3 className="font-semibold text-lg">الإشعارات المفعلة</h3>
                <div className="space-y-3 bg-muted/30 p-4 rounded-lg">
                  <div className="flex items-center justify-between">
                    <div>
                      <Label htmlFor="notify_received" className="font-medium">
                        إشعار عند استلام الطلبية
                      </Label>
                      <p className="text-sm text-muted-foreground">يتم الإرسال عند تسجيل الطلبية في النظام</p>
                    </div>
                    <Switch
                      id="notify_received"
                      checked={notificationSettings.notify_on_received}
                      onCheckedChange={(checked) =>
                        setNotificationSettings({ ...notificationSettings, notify_on_received: checked })
                      }
                    />
                  </div>

                  <div className="flex items-center justify-between">
                    <div>
                      <Label htmlFor="notify_preparing" className="font-medium">
                        إشعار عند بدء التحضير
                      </Label>
                      <p className="text-sm text-muted-foreground">يتم الإرسال عند بدء تحضير الطلبية</p>
                    </div>
                    <Switch
                      id="notify_preparing"
                      checked={notificationSettings.notify_on_preparing}
                      onCheckedChange={(checked) =>
                        setNotificationSettings({ ...notificationSettings, notify_on_preparing: checked })
                      }
                    />
                  </div>

                  <div className="flex items-center justify-between">
                    <div>
                      <Label htmlFor="notify_quality" className="font-medium">
                        إشعار عند التدقيق
                      </Label>
                      <p className="text-sm text-muted-foreground">يتم الإرسال عند إتمام مرحلة التدقيق</p>
                    </div>
                    <Switch
                      id="notify_quality"
                      checked={notificationSettings.notify_on_quality_check}
                      onCheckedChange={(checked) =>
                        setNotificationSettings({ ...notificationSettings, notify_on_quality_check: checked })
                      }
                    />
                  </div>

                  <div className="flex items-center justify-between">
                    <div>
                      <Label htmlFor="notify_shipped" className="font-medium">
                        إشعار عند الشحن
                      </Label>
                      <p className="text-sm text-muted-foreground">يتم الإرسال عند إرسال الطلبية للشحن</p>
                    </div>
                    <Switch
                      id="notify_shipped"
                      checked={notificationSettings.notify_on_shipped}
                      onCheckedChange={(checked) =>
                        setNotificationSettings({ ...notificationSettings, notify_on_shipped: checked })
                      }
                    />
                  </div>
                </div>
              </div>

              {/* Enable/Disable System */}
              <div className="flex items-center justify-between p-4 bg-blue-50 rounded-lg border border-blue-200">
                <div>
                  <Label htmlFor="is_active" className="font-semibold text-blue-900">
                    تفعيل نظام الإشعارات
                  </Label>
                  <p className="text-sm text-blue-700">تفعيل أو تعطيل جميع الإشعارات لهذا العميل</p>
                </div>
                <Switch
                  id="is_active"
                  checked={notificationSettings.is_active}
                  onCheckedChange={(checked) =>
                    setNotificationSettings({ ...notificationSettings, is_active: checked })
                  }
                />
              </div>

              {/* Save Button */}
              <div className="flex justify-end gap-3 pt-4">
                <Button variant="outline" onClick={loadNotificationSettings} disabled={notificationLoading}>
                  إلغاء التغييرات
                </Button>
                <Button onClick={handleSaveNotificationSettings} disabled={notificationLoading}>
                  {notificationLoading ? "جاري الحفظ..." : "حفظ الإعدادات"}
                </Button>
              </div>
            </CardContent>
          </Card>

          {/* Additional Information */}
          <Card className="bg-amber-50 border-amber-200">
            <CardHeader>
              <CardTitle className="text-amber-900">ملاحظات مهمة</CardTitle>
            </CardHeader>
            <CardContent className="text-amber-800 space-y-2">
              <p>• يتم إرسال الإشعارات تلقائياً عند تحديث حالة الطلبية في النظام</p>
              <p>• يمكن تعطيل إشعارات معينة حسب رغبة العميل</p>
              <p>• يتم تسجيل جميع الإشعارات المرسلة في سجل النظام</p>
              <p>• تأكد من صحة رقم الهاتف قبل تفعيل النظام</p>
            </CardContent>
          </Card>
        </TabsContent>
      </Tabs>

      {/* Create User Dialog */}
      <Dialog open={createDialogOpen} onOpenChange={setCreateDialogOpen}>
        <DialogContent className="max-w-2xl">
          <DialogHeader>
            <DialogTitle>إضافة مستخدم جديد</DialogTitle>
            <DialogDescription>إنشاء حساب جديد للعميل مع تحديد الصلاحيات</DialogDescription>
          </DialogHeader>

          <div className="space-y-6">
            {/* User Info */}
            <div className="space-y-4">
              <div className="space-y-2">
                <Label htmlFor="username">اسم المستخدم *</Label>
                <Input
                  id="username"
                  value={formData.username}
                  onChange={(e) => setFormData({ ...formData, username: e.target.value })}
                  placeholder="أدخل اسم المستخدم"
                />
              </div>

              <div className="space-y-2">
                <Label htmlFor="password">كلمة المرور *</Label>
                <Input
                  id="password"
                  type="password"
                  value={formData.password}
                  onChange={(e) => setFormData({ ...formData, password: e.target.value })}
                  placeholder="أدخل كلمة المرور"
                />
              </div>

              <div className="space-y-2">
                <Label htmlFor="email">البريد الإلكتروني</Label>
                <Input
                  id="email"
                  type="email"
                  value={formData.email}
                  onChange={(e) => setFormData({ ...formData, email: e.target.value })}
                  placeholder="أدخل البريد الإلكتروني (اختياري)"
                />
              </div>
            </div>

            {/* Permissions */}
            <div className="space-y-4">
              <h3 className="font-semibold">الصلاحيات</h3>

              <div className="space-y-3">
                <div className="flex items-center justify-between">
                  <Label htmlFor="can_view_orders">عرض الطلبيات</Label>
                  <Switch
                    id="can_view_orders"
                    checked={permissions.can_view_orders}
                    onCheckedChange={(checked) => setPermissions({ ...permissions, can_view_orders: checked })}
                  />
                </div>

                <div className="flex items-center justify-between">
                  <Label htmlFor="can_create_orders">إنشاء طلبيات</Label>
                  <Switch
                    id="can_create_orders"
                    checked={permissions.can_create_orders}
                    onCheckedChange={(checked) => setPermissions({ ...permissions, can_create_orders: checked })}
                  />
                </div>

                <div className="flex items-center justify-between">
                  <Label htmlFor="can_view_balance">عرض الرصيد</Label>
                  <Switch
                    id="can_view_balance"
                    checked={permissions.can_view_balance}
                    onCheckedChange={(checked) => setPermissions({ ...permissions, can_view_balance: checked })}
                  />
                </div>

                <div className="flex items-center justify-between">
                  <Label htmlFor="can_view_products">عرض الأصناف</Label>
                  <Switch
                    id="can_view_products"
                    checked={permissions.can_view_products}
                    onCheckedChange={(checked) => setPermissions({ ...permissions, can_view_products: checked })}
                  />
                </div>

                <div className="flex items-center justify-between">
                  <Label htmlFor="can_view_prices">عرض الأسعار</Label>
                  <Switch
                    id="can_view_prices"
                    checked={permissions.can_view_prices}
                    onCheckedChange={(checked) => setPermissions({ ...permissions, can_view_prices: checked })}
                  />
                </div>

                <div className="flex items-center justify-between">
                  <Label htmlFor="can_view_stock">عرض المخزون</Label>
                  <Switch
                    id="can_view_stock"
                    checked={permissions.can_view_stock}
                    onCheckedChange={(checked) => setPermissions({ ...permissions, can_view_stock: checked })}
                  />
                </div>
              </div>
            </div>

            <div className="flex gap-3 justify-end">
              <Button variant="outline" onClick={() => setCreateDialogOpen(false)}>
                إلغاء
              </Button>
              <Button onClick={handleCreateUser}>إنشاء المستخدم</Button>
            </div>
          </div>
        </DialogContent>
      </Dialog>

      {/* Edit Permissions Dialog */}
      <Dialog open={editDialogOpen} onOpenChange={setEditDialogOpen}>
        <DialogContent>
          <DialogHeader>
            <DialogTitle>تعديل الصلاحيات</DialogTitle>
            <DialogDescription>تعديل صلاحيات المستخدم: {selectedUser?.username}</DialogDescription>
          </DialogHeader>

          <div className="space-y-4">
            <div className="flex items-center justify-between">
              <Label htmlFor="edit_can_view_orders">عرض الطلبيات</Label>
              <Switch
                id="edit_can_view_orders"
                checked={permissions.can_view_orders}
                onCheckedChange={(checked) => setPermissions({ ...permissions, can_view_orders: checked })}
              />
            </div>

            <div className="flex items-center justify-between">
              <Label htmlFor="edit_can_create_orders">إنشاء طلبيات</Label>
              <Switch
                id="edit_can_create_orders"
                checked={permissions.can_create_orders}
                onCheckedChange={(checked) => setPermissions({ ...permissions, can_create_orders: checked })}
              />
            </div>

            <div className="flex items-center justify-between">
              <Label htmlFor="edit_can_view_balance">عرض الرصيد</Label>
              <Switch
                id="edit_can_view_balance"
                checked={permissions.can_view_balance}
                onCheckedChange={(checked) => setPermissions({ ...permissions, can_view_balance: checked })}
              />
            </div>

            <div className="flex items-center justify-between">
              <Label htmlFor="edit_can_view_products">عرض الأصناف</Label>
              <Switch
                id="edit_can_view_products"
                checked={permissions.can_view_products}
                onCheckedChange={(checked) => setPermissions({ ...permissions, can_view_products: checked })}
              />
            </div>

            <div className="flex items-center justify-between">
              <Label htmlFor="edit_can_view_prices">عرض الأسعار</Label>
              <Switch
                id="edit_can_view_prices"
                checked={permissions.can_view_prices}
                onCheckedChange={(checked) => setPermissions({ ...permissions, can_view_prices: checked })}
              />
            </div>

            <div className="flex items-center justify-between">
              <Label htmlFor="edit_can_view_stock">عرض المخزون</Label>
              <Switch
                id="edit_can_view_stock"
                checked={permissions.can_view_stock}
                onCheckedChange={(checked) => setPermissions({ ...permissions, can_view_stock: checked })}
              />
            </div>

            <div className="flex gap-3 justify-end pt-4">
              <Button variant="outline" onClick={() => setEditDialogOpen(false)}>
                إلغاء
              </Button>
              <Button onClick={() => selectedUser && handleUpdatePermissions(selectedUser.id, permissions)}>
                حفظ التغييرات
              </Button>
            </div>
          </div>
        </DialogContent>
      </Dialog>
    </div>
  )
}
