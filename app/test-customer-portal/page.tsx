"use client"

import { useState } from "react"
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card"
import { Button } from "@/components/ui/button"
import { Input } from "@/components/ui/input"
import { Label } from "@/components/ui/label"
import { Tabs, TabsContent, TabsList, TabsTrigger } from "@/components/ui/tabs"
import { Alert, AlertDescription } from "@/components/ui/alert"
import { Badge } from "@/components/ui/badge"
import { Separator } from "@/components/ui/separator"
import {
  CheckCircle2,
  XCircle,
  Loader2,
  User,
  Lock,
  ShoppingCart,
  Package,
  DollarSign,
  Eye,
  EyeOff,
  LogIn,
  LogOut,
  RefreshCw,
} from "lucide-react"

interface TestResult {
  test: string
  status: "success" | "error" | "pending"
  message: string
  data?: any
}

export default function TestCustomerPortalPage() {
  const [testResults, setTestResults] = useState<TestResult[]>([])
  const [loading, setLoading] = useState(false)
  const [username, setUsername] = useState("")
  const [password, setPassword] = useState("")
  const [showPassword, setShowPassword] = useState(false)
  const [sessionData, setSessionData] = useState<any>(null)

  const addResult = (result: TestResult) => {
    setTestResults((prev) => [...prev, result])
  }

  const clearResults = () => {
    setTestResults([])
    setSessionData(null)
  }

  // Test 1: Login with invalid credentials
  const testInvalidLogin = async () => {
    addResult({ test: "تسجيل دخول ببيانات خاطئة", status: "pending", message: "جاري الاختبار..." })

    try {
      const response = await fetch("/api/customer-auth/login", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ username: "invalid_user", password: "wrong_password" }),
      })

      const data = await response.json()

      if (!response.ok) {
        addResult({
          test: "تسجيل دخول ببيانات خاطئة",
          status: "success",
          message: "✓ النظام رفض البيانات الخاطئة بشكل صحيح",
          data: { error: data.error },
        })
      } else {
        addResult({
          test: "تسجيل دخول ببيانات خاطئة",
          status: "error",
          message: "✗ النظام قبل بيانات خاطئة (خطأ أمني!)",
        })
      }
    } catch (error) {
      addResult({
        test: "تسجيل دخول ببيانات خاطئة",
        status: "error",
        message: `✗ خطأ في الاتصال: ${error}`,
      })
    }
  }

  // Test 2: Login with valid credentials
  const testValidLogin = async () => {
    if (!username || !password) {
      addResult({
        test: "تسجيل دخول ببيانات صحيحة",
        status: "error",
        message: "✗ الرجاء إدخال اسم المستخدم وكلمة المرور",
      })
      return
    }

    addResult({ test: "تسجيل دخول ببيانات صحيحة", status: "pending", message: "جاري الاختبار..." })

    try {
      const response = await fetch("/api/customer-auth/login", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ username, password }),
      })

      const data = await response.json()

      if (response.ok) {
        setSessionData(data.session)
        addResult({
          test: "تسجيل دخول ببيانات صحيحة",
          status: "success",
          message: "✓ تم تسجيل الدخول بنجاح",
          data: {
            user: data.session.user.username,
            customer: data.session.customer.name,
            permissions: data.session.permissions,
          },
        })
      } else {
        addResult({
          test: "تسجيل دخول ببيانات صحيحة",
          status: "error",
          message: `✗ فشل تسجيل الدخول: ${data.error}`,
        })
      }
    } catch (error) {
      addResult({
        test: "تسجيل دخول ببيانات صحيحة",
        status: "error",
        message: `✗ خطأ في الاتصال: ${error}`,
      })
    }
  }

  // Test 3: Check session
  const testSession = async () => {
    addResult({ test: "التحقق من الجلسة", status: "pending", message: "جاري الاختبار..." })

    try {
      const response = await fetch("/api/customer-auth/session")
      const data = await response.json()

      if (response.ok) {
        setSessionData(data.session)
        addResult({
          test: "التحقق من الجلسة",
          status: "success",
          message: "✓ الجلسة نشطة وصالحة",
          data: {
            user: data.session.user.username,
            customer: data.session.customer.name,
            lastLogin: data.session.user.last_login,
          },
        })
      } else {
        addResult({
          test: "التحقق من الجلسة",
          status: "error",
          message: "✗ لا توجد جلسة نشطة",
        })
      }
    } catch (error) {
      addResult({
        test: "التحقق من الجلسة",
        status: "error",
        message: `✗ خطأ في الاتصال: ${error}`,
      })
    }
  }

  // Test 4: Get dashboard data
  const testDashboard = async () => {
    addResult({ test: "تحميل لوحة التحكم", status: "pending", message: "جاري الاختبار..." })

    try {
      const response = await fetch("/api/customer/dashboard")
      const data = await response.json()

      if (response.ok) {
        addResult({
          test: "تحميل لوحة التحكم",
          status: "success",
          message: "✓ تم تحميل بيانات لوحة التحكم بنجاح",
          data: {
            totalOrders: data.totalOrders,
            pendingOrders: data.pendingOrders,
            completedOrders: data.completedOrders,
            currentBalance: data.currentBalance,
          },
        })
      } else {
        addResult({
          test: "تحميل لوحة التحكم",
          status: "error",
          message: `✗ فشل تحميل البيانات: ${data.error}`,
        })
      }
    } catch (error) {
      addResult({
        test: "تحميل لوحة التحكم",
        status: "error",
        message: `✗ خطأ في الاتصال: ${error}`,
      })
    }
  }

  // Test 5: Get orders
  const testOrders = async () => {
    addResult({ test: "تحميل الطلبيات", status: "pending", message: "جاري الاختبار..." })

    try {
      const response = await fetch("/api/customer/orders")
      const data = await response.json()

      if (response.ok) {
        addResult({
          test: "تحميل الطلبيات",
          status: "success",
          message: `✓ تم تحميل ${data.orders.length} طلبية`,
          data: { ordersCount: data.orders.length, orders: data.orders.slice(0, 3) },
        })
      } else {
        addResult({
          test: "تحميل الطلبيات",
          status: "error",
          message: `✗ فشل تحميل الطلبيات: ${data.error}`,
        })
      }
    } catch (error) {
      addResult({
        test: "تحميل الطلبيات",
        status: "error",
        message: `✗ خطأ في الاتصال: ${error}`,
      })
    }
  }

  // Test 6: Get products
  const testProducts = async () => {
    addResult({ test: "تحميل الأصناف", status: "pending", message: "جاري الاختبار..." })

    try {
      const response = await fetch("/api/customer/products")
      const data = await response.json()

      if (response.ok) {
        addResult({
          test: "تحميل الأصناف",
          status: "success",
          message: `✓ تم تحميل ${data.products.length} صنف`,
          data: { productsCount: data.products.length, products: data.products.slice(0, 3) },
        })
      } else {
        addResult({
          test: "تحميل الأصناف",
          status: "error",
          message: `✗ فشل تحميل الأصناف: ${data.error}`,
        })
      }
    } catch (error) {
      addResult({
        test: "تحميل الأصناف",
        status: "error",
        message: `✗ خطأ في الاتصال: ${error}`,
      })
    }
  }

  // Test 7: Test permissions
  const testPermissions = async () => {
    addResult({ test: "اختبار الصلاحيات", status: "pending", message: "جاري الاختبار..." })

    try {
      const sessionResponse = await fetch("/api/customer-auth/session")
      const sessionData = await sessionResponse.json()

      if (!sessionResponse.ok) {
        addResult({
          test: "اختبار الصلاحيات",
          status: "error",
          message: "✗ لا توجد جلسة نشطة",
        })
        return
      }

      const permissions = sessionData.session.permissions
      const permissionTests = []

      // Test view orders permission
      if (permissions.can_view_orders) {
        const ordersResponse = await fetch("/api/customer/orders")
        permissionTests.push({
          permission: "عرض الطلبيات",
          allowed: permissions.can_view_orders,
          tested: ordersResponse.ok,
        })
      }

      // Test view products permission
      if (permissions.can_view_products) {
        const productsResponse = await fetch("/api/customer/products")
        permissionTests.push({
          permission: "عرض الأصناف",
          allowed: permissions.can_view_products,
          tested: productsResponse.ok,
        })
      }

      addResult({
        test: "اختبار الصلاحيات",
        status: "success",
        message: `✓ تم اختبار ${permissionTests.length} صلاحية`,
        data: { permissions, tests: permissionTests },
      })
    } catch (error) {
      addResult({
        test: "اختبار الصلاحيات",
        status: "error",
        message: `✗ خطأ في الاتصال: ${error}`,
      })
    }
  }

  // Test 8: Logout
  const testLogout = async () => {
    addResult({ test: "تسجيل الخروج", status: "pending", message: "جاري الاختبار..." })

    try {
      const response = await fetch("/api/customer-auth/logout", { method: "POST" })
      const data = await response.json()

      if (response.ok) {
        setSessionData(null)
        addResult({
          test: "تسجيل الخروج",
          status: "success",
          message: "✓ تم تسجيل الخروج بنجاح",
        })
      } else {
        addResult({
          test: "تسجيل الخروج",
          status: "error",
          message: `✗ فشل تسجيل الخروج: ${data.error}`,
        })
      }
    } catch (error) {
      addResult({
        test: "تسجيل الخروج",
        status: "error",
        message: `✗ خطأ في الاتصال: ${error}`,
      })
    }
  }

  // Run all tests
  const runAllTests = async () => {
    setLoading(true)
    clearResults()

    await testInvalidLogin()
    await new Promise((resolve) => setTimeout(resolve, 500))

    if (username && password) {
      await testValidLogin()
      await new Promise((resolve) => setTimeout(resolve, 500))

      await testSession()
      await new Promise((resolve) => setTimeout(resolve, 500))

      await testDashboard()
      await new Promise((resolve) => setTimeout(resolve, 500))

      await testOrders()
      await new Promise((resolve) => setTimeout(resolve, 500))

      await testProducts()
      await new Promise((resolve) => setTimeout(resolve, 500))

      await testPermissions()
      await new Promise((resolve) => setTimeout(resolve, 500))

      await testLogout()
    }

    setLoading(false)
  }

  const getStatusIcon = (status: string) => {
    switch (status) {
      case "success":
        return <CheckCircle2 className="h-5 w-5 text-green-600" />
      case "error":
        return <XCircle className="h-5 w-5 text-red-600" />
      case "pending":
        return <Loader2 className="h-5 w-5 text-blue-600 animate-spin" />
      default:
        return null
    }
  }

  return (
    <div className="min-h-screen bg-gradient-to-br from-blue-50 via-white to-indigo-50 p-6" dir="rtl">
      <div className="max-w-7xl mx-auto space-y-6">
        {/* Header */}
        <div className="text-center space-y-2">
          <h1 className="text-4xl font-bold">اختبار بوابة العملاء</h1>
          <p className="text-muted-foreground text-lg">اختبار شامل لجميع وظائف بوابة العملاء ونظام المصادقة</p>
        </div>

        <Tabs defaultValue="manual" className="w-full">
          <TabsList className="grid w-full grid-cols-2">
            <TabsTrigger value="manual">اختبار يدوي</TabsTrigger>
            <TabsTrigger value="auto">اختبار تلقائي</TabsTrigger>
          </TabsList>

          {/* Manual Testing */}
          <TabsContent value="manual" className="space-y-6">
            <Card>
              <CardHeader>
                <CardTitle>بيانات تسجيل الدخول</CardTitle>
                <CardDescription>أدخل بيانات مستخدم صحيحة لاختبار النظام</CardDescription>
              </CardHeader>
              <CardContent className="space-y-4">
                <div className="grid gap-4 md:grid-cols-2">
                  <div className="space-y-2">
                    <Label htmlFor="username">اسم المستخدم</Label>
                    <div className="relative">
                      <User className="absolute right-3 top-1/2 transform -translate-y-1/2 h-4 w-4 text-muted-foreground" />
                      <Input
                        id="username"
                        value={username}
                        onChange={(e) => setUsername(e.target.value)}
                        placeholder="أدخل اسم المستخدم"
                        className="pr-10"
                      />
                    </div>
                  </div>

                  <div className="space-y-2">
                    <Label htmlFor="password">كلمة المرور</Label>
                    <div className="relative">
                      <Lock className="absolute right-3 top-1/2 transform -translate-y-1/2 h-4 w-4 text-muted-foreground" />
                      <Input
                        id="password"
                        type={showPassword ? "text" : "password"}
                        value={password}
                        onChange={(e) => setPassword(e.target.value)}
                        placeholder="أدخل كلمة المرور"
                        className="pr-10 pl-10"
                      />
                      <button
                        type="button"
                        onClick={() => setShowPassword(!showPassword)}
                        className="absolute left-3 top-1/2 transform -translate-y-1/2"
                      >
                        {showPassword ? (
                          <EyeOff className="h-4 w-4 text-muted-foreground" />
                        ) : (
                          <Eye className="h-4 w-4 text-muted-foreground" />
                        )}
                      </button>
                    </div>
                  </div>
                </div>

                {sessionData && (
                  <Alert className="bg-green-50 border-green-200">
                    <CheckCircle2 className="h-4 w-4 text-green-600" />
                    <AlertDescription className="text-green-800">
                      <div className="space-y-1">
                        <p className="font-medium">جلسة نشطة</p>
                        <p className="text-sm">المستخدم: {sessionData.user.username}</p>
                        <p className="text-sm">العميل: {sessionData.customer.name}</p>
                      </div>
                    </AlertDescription>
                  </Alert>
                )}
              </CardContent>
            </Card>

            <div className="grid gap-4 md:grid-cols-2 lg:grid-cols-4">
              <Card className="hover:shadow-lg transition-shadow cursor-pointer" onClick={testInvalidLogin}>
                <CardHeader className="pb-3">
                  <CardTitle className="text-sm flex items-center gap-2">
                    <XCircle className="h-4 w-4 text-red-600" />
                    بيانات خاطئة
                  </CardTitle>
                </CardHeader>
                <CardContent>
                  <p className="text-xs text-muted-foreground">اختبار رفض بيانات غير صحيحة</p>
                </CardContent>
              </Card>

              <Card className="hover:shadow-lg transition-shadow cursor-pointer" onClick={testValidLogin}>
                <CardHeader className="pb-3">
                  <CardTitle className="text-sm flex items-center gap-2">
                    <LogIn className="h-4 w-4 text-green-600" />
                    تسجيل دخول
                  </CardTitle>
                </CardHeader>
                <CardContent>
                  <p className="text-xs text-muted-foreground">اختبار تسجيل دخول صحيح</p>
                </CardContent>
              </Card>

              <Card className="hover:shadow-lg transition-shadow cursor-pointer" onClick={testSession}>
                <CardHeader className="pb-3">
                  <CardTitle className="text-sm flex items-center gap-2">
                    <RefreshCw className="h-4 w-4 text-blue-600" />
                    التحقق من الجلسة
                  </CardTitle>
                </CardHeader>
                <CardContent>
                  <p className="text-xs text-muted-foreground">التحقق من صلاحية الجلسة</p>
                </CardContent>
              </Card>

              <Card className="hover:shadow-lg transition-shadow cursor-pointer" onClick={testDashboard}>
                <CardHeader className="pb-3">
                  <CardTitle className="text-sm flex items-center gap-2">
                    <DollarSign className="h-4 w-4 text-purple-600" />
                    لوحة التحكم
                  </CardTitle>
                </CardHeader>
                <CardContent>
                  <p className="text-xs text-muted-foreground">تحميل بيانات لوحة التحكم</p>
                </CardContent>
              </Card>

              <Card className="hover:shadow-lg transition-shadow cursor-pointer" onClick={testOrders}>
                <CardHeader className="pb-3">
                  <CardTitle className="text-sm flex items-center gap-2">
                    <ShoppingCart className="h-4 w-4 text-orange-600" />
                    الطلبيات
                  </CardTitle>
                </CardHeader>
                <CardContent>
                  <p className="text-xs text-muted-foreground">تحميل قائمة الطلبيات</p>
                </CardContent>
              </Card>

              <Card className="hover:shadow-lg transition-shadow cursor-pointer" onClick={testProducts}>
                <CardHeader className="pb-3">
                  <CardTitle className="text-sm flex items-center gap-2">
                    <Package className="h-4 w-4 text-teal-600" />
                    الأصناف
                  </CardTitle>
                </CardHeader>
                <CardContent>
                  <p className="text-xs text-muted-foreground">تحميل قائمة الأصناف</p>
                </CardContent>
              </Card>

              <Card className="hover:shadow-lg transition-shadow cursor-pointer" onClick={testPermissions}>
                <CardHeader className="pb-3">
                  <CardTitle className="text-sm flex items-center gap-2">
                    <Lock className="h-4 w-4 text-indigo-600" />
                    الصلاحيات
                  </CardTitle>
                </CardHeader>
                <CardContent>
                  <p className="text-xs text-muted-foreground">اختبار نظام الصلاحيات</p>
                </CardContent>
              </Card>

              <Card className="hover:shadow-lg transition-shadow cursor-pointer" onClick={testLogout}>
                <CardHeader className="pb-3">
                  <CardTitle className="text-sm flex items-center gap-2">
                    <LogOut className="h-4 w-4 text-gray-600" />
                    تسجيل خروج
                  </CardTitle>
                </CardHeader>
                <CardContent>
                  <p className="text-xs text-muted-foreground">اختبار تسجيل الخروج</p>
                </CardContent>
              </Card>
            </div>
          </TabsContent>

          {/* Automatic Testing */}
          <TabsContent value="auto" className="space-y-6">
            <Card>
              <CardHeader>
                <CardTitle>اختبار تلقائي شامل</CardTitle>
                <CardDescription>تشغيل جميع الاختبارات تلقائياً بالترتيب</CardDescription>
              </CardHeader>
              <CardContent className="space-y-4">
                <Alert>
                  <AlertDescription>
                    سيتم تشغيل جميع الاختبارات تلقائياً. تأكد من إدخال بيانات تسجيل دخول صحيحة أولاً.
                  </AlertDescription>
                </Alert>

                <div className="flex gap-3">
                  <Button onClick={runAllTests} disabled={loading || !username || !password} className="gap-2">
                    {loading ? (
                      <>
                        <Loader2 className="h-4 w-4 animate-spin" />
                        جاري التشغيل...
                      </>
                    ) : (
                      <>
                        <RefreshCw className="h-4 w-4" />
                        تشغيل جميع الاختبارات
                      </>
                    )}
                  </Button>

                  <Button onClick={clearResults} variant="outline" disabled={loading}>
                    مسح النتائج
                  </Button>
                </div>
              </CardContent>
            </Card>
          </TabsContent>
        </Tabs>

        {/* Test Results */}
        {testResults.length > 0 && (
          <Card>
            <CardHeader>
              <div className="flex items-center justify-between">
                <CardTitle>نتائج الاختبارات</CardTitle>
                <div className="flex gap-2">
                  <Badge variant="outline" className="bg-green-50 text-green-700">
                    نجح: {testResults.filter((r) => r.status === "success").length}
                  </Badge>
                  <Badge variant="outline" className="bg-red-50 text-red-700">
                    فشل: {testResults.filter((r) => r.status === "error").length}
                  </Badge>
                </div>
              </div>
            </CardHeader>
            <CardContent>
              <div className="space-y-3">
                {testResults.map((result, index) => (
                  <div key={index} className="border rounded-lg p-4 space-y-2">
                    <div className="flex items-start justify-between">
                      <div className="flex items-center gap-3">
                        {getStatusIcon(result.status)}
                        <div>
                          <p className="font-medium">{result.test}</p>
                          <p className="text-sm text-muted-foreground">{result.message}</p>
                        </div>
                      </div>
                      <Badge
                        variant={
                          result.status === "success"
                            ? "default"
                            : result.status === "error"
                              ? "destructive"
                              : "secondary"
                        }
                      >
                        {result.status === "success" ? "نجح" : result.status === "error" ? "فشل" : "جاري..."}
                      </Badge>
                    </div>

                    {result.data && (
                      <>
                        <Separator />
                        <details className="text-sm">
                          <summary className="cursor-pointer text-muted-foreground hover:text-foreground">
                            عرض التفاصيل
                          </summary>
                          <pre className="mt-2 p-3 bg-muted rounded-md overflow-auto text-xs">
                            {JSON.stringify(result.data, null, 2)}
                          </pre>
                        </details>
                      </>
                    )}
                  </div>
                ))}
              </div>
            </CardContent>
          </Card>
        )}

        {/* Info Card */}
        <Card className="bg-blue-50 border-blue-200">
          <CardHeader>
            <CardTitle className="text-blue-900">معلومات الاختبار</CardTitle>
          </CardHeader>
          <CardContent className="text-blue-800 space-y-2 text-sm">
            <p>• يجب إنشاء حساب مستخدم للعميل أولاً من لوحة إدارة البوابات</p>
            <p>• تأكد من تفعيل الحساب وتعيين الصلاحيات المناسبة</p>
            <p>• الاختبار التلقائي يشمل جميع الوظائف الأساسية للبوابة</p>
            <p>• يمكنك اختبار كل وظيفة على حدة من تبويب "اختبار يدوي"</p>
            <p>• النتائج تظهر بالتفصيل مع إمكانية عرض البيانات المرجعة</p>
          </CardContent>
        </Card>
      </div>
    </div>
  )
}
