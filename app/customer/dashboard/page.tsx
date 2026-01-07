"use client"

import { useEffect, useState } from "react"
import { CustomerLayout } from "@/components/customer/customer-layout"
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card"
import { Alert, AlertDescription } from "@/components/ui/alert"
import { Skeleton } from "@/components/ui/skeleton"
import { ShoppingCart, Package, DollarSign, Clock, TrendingUp, TrendingDown } from "lucide-react"
import type { CustomerSession } from "@/lib/customer-auth"

interface DashboardStats {
  totalOrders: number
  pendingOrders: number
  completedOrders: number
  currentBalance: number
  recentOrders: any[]
}

export default function CustomerDashboardPage() {
  const [session, setSession] = useState<CustomerSession | null>(null)
  const [stats, setStats] = useState<DashboardStats | null>(null)
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState("")

  useEffect(() => {
    loadDashboard()
  }, [])

  const loadDashboard = async () => {
    try {
      const [sessionRes, statsRes] = await Promise.all([
        fetch("/api/customer-auth/session"),
        fetch("/api/customer/dashboard"),
      ])

      if (sessionRes.ok) {
        const sessionData = await sessionRes.json()
        setSession(sessionData.session)
      }

      if (statsRes.ok) {
        const statsData = await statsRes.json()
        setStats(statsData)
      } else {
        const errorData = await statsRes.json()
        setError(errorData.error || "حدث خطأ أثناء تحميل البيانات")
      }
    } catch (error) {
      console.error("Dashboard load error:", error)
      setError("حدث خطأ أثناء تحميل البيانات")
    } finally {
      setLoading(false)
    }
  }

  const formatCurrency = (amount: number) => {
    return new Intl.NumberFormat("ar-SA", {
      minimumFractionDigits: 2,
      maximumFractionDigits: 2,
    }).format(amount)
  }

  const formatDate = (date: string) => {
    return new Date(date).toLocaleDateString("ar-SA", {
      year: "numeric",
      month: "long",
      day: "numeric",
    })
  }

  const getStatusColor = (status: string) => {
    switch (status) {
      case "pending":
        return "text-yellow-600 bg-yellow-50"
      case "confirmed":
        return "text-blue-600 bg-blue-50"
      case "preparing":
        return "text-purple-600 bg-purple-50"
      case "ready":
        return "text-green-600 bg-green-50"
      case "delivered":
        return "text-gray-600 bg-gray-50"
      case "cancelled":
        return "text-red-600 bg-red-50"
      default:
        return "text-gray-600 bg-gray-50"
    }
  }

  const getStatusLabel = (status: string) => {
    const labels: Record<string, string> = {
      pending: "قيد الانتظار",
      confirmed: "مؤكد",
      preparing: "قيد التحضير",
      ready: "جاهز",
      delivered: "تم التسليم",
      cancelled: "ملغي",
    }
    return labels[status] || status
  }

  return (
    <CustomerLayout>
      <div className="space-y-6">
        {/* Welcome Section */}
        <div>
          <h1 className="text-3xl font-bold">مرحباً، {session?.customer.name}</h1>
          <p className="text-muted-foreground mt-1">إليك ملخص حسابك وطلبياتك</p>
        </div>

        {error && (
          <Alert variant="destructive">
            <AlertDescription>{error}</AlertDescription>
          </Alert>
        )}

        {/* Stats Cards */}
        <div className="grid gap-4 md:grid-cols-2 lg:grid-cols-4">
          {loading ? (
            <>
              {[...Array(4)].map((_, i) => (
                <Card key={i}>
                  <CardHeader className="flex flex-row items-center justify-between pb-2">
                    <Skeleton className="h-4 w-24" />
                    <Skeleton className="h-4 w-4 rounded" />
                  </CardHeader>
                  <CardContent>
                    <Skeleton className="h-8 w-20" />
                  </CardContent>
                </Card>
              ))}
            </>
          ) : (
            <>
              <Card>
                <CardHeader className="flex flex-row items-center justify-between pb-2">
                  <CardTitle className="text-sm font-medium">إجمالي الطلبيات</CardTitle>
                  <ShoppingCart className="h-4 w-4 text-muted-foreground" />
                </CardHeader>
                <CardContent>
                  <div className="text-2xl font-bold">{stats?.totalOrders ?? 0}</div>
                </CardContent>
              </Card>

              <Card>
                <CardHeader className="flex flex-row items-center justify-between pb-2">
                  <CardTitle className="text-sm font-medium">طلبيات قيد التنفيذ</CardTitle>
                  <Clock className="h-4 w-4 text-muted-foreground" />
                </CardHeader>
                <CardContent>
                  <div className="text-2xl font-bold text-blue-600">{stats?.pendingOrders ?? 0}</div>
                </CardContent>
              </Card>

              <Card>
                <CardHeader className="flex flex-row items-center justify-between pb-2">
                  <CardTitle className="text-sm font-medium">طلبيات مكتملة</CardTitle>
                  <Package className="h-4 w-4 text-muted-foreground" />
                </CardHeader>
                <CardContent>
                  <div className="text-2xl font-bold text-green-600">{stats?.completedOrders ?? 0}</div>
                </CardContent>
              </Card>

              {session?.permissions.can_view_balance && (
                <Card>
                  <CardHeader className="flex flex-row items-center justify-between pb-2">
                    <CardTitle className="text-sm font-medium">الرصيد الحالي</CardTitle>
                    <DollarSign className="h-4 w-4 text-muted-foreground" />
                  </CardHeader>
                  <CardContent>
                    <div className="flex items-center gap-2">
                      <div
                        className={`text-2xl font-bold ${
                          (stats?.currentBalance ?? 0) >= 0 ? "text-green-600" : "text-red-600"
                        }`}
                      >
                        {formatCurrency(stats?.currentBalance ?? 0)}
                      </div>
                      {(stats?.currentBalance ?? 0) >= 0 ? (
                        <TrendingUp className="h-4 w-4 text-green-600" />
                      ) : (
                        <TrendingDown className="h-4 w-4 text-red-600" />
                      )}
                    </div>
                  </CardContent>
                </Card>
              )}
            </>
          )}
        </div>

        {/* Recent Orders */}
        {session?.permissions.can_view_orders && (
          <Card>
            <CardHeader>
              <CardTitle>آخر الطلبيات</CardTitle>
            </CardHeader>
            <CardContent>
              {loading ? (
                <div className="space-y-3">
                  {[...Array(3)].map((_, i) => (
                    <div key={i} className="flex items-center justify-between p-4 border rounded-lg">
                      <div className="space-y-2">
                        <Skeleton className="h-4 w-32" />
                        <Skeleton className="h-3 w-24" />
                      </div>
                      <Skeleton className="h-6 w-20 rounded-full" />
                    </div>
                  ))}
                </div>
              ) : stats?.recentOrders && stats.recentOrders.length > 0 ? (
                <div className="space-y-3">
                  {stats.recentOrders.map((order: any) => (
                    <div
                      key={order.id}
                      className="flex items-center justify-between p-4 border rounded-lg hover:bg-accent transition-colors"
                    >
                      <div className="space-y-1">
                        <div className="font-medium">طلبية #{order.id}</div>
                        <div className="text-sm text-muted-foreground">{formatDate(order.order_date)}</div>
                        <div className="text-sm font-medium">{formatCurrency(order.total_amount)} ريال</div>
                      </div>
                      <div className={`px-3 py-1 rounded-full text-xs font-medium ${getStatusColor(order.status)}`}>
                        {getStatusLabel(order.status)}
                      </div>
                    </div>
                  ))}
                </div>
              ) : (
                <div className="text-center py-8 text-muted-foreground">لا توجد طلبيات حتى الآن</div>
              )}
            </CardContent>
          </Card>
        )}
      </div>
    </CustomerLayout>
  )
}
