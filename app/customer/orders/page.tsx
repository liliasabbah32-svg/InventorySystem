"use client"

import { useEffect, useState } from "react"
import { CustomerLayout } from "@/components/customer/customer-layout"
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card"
import { Button } from "@/components/ui/button"
import { Input } from "@/components/ui/input"
import { Alert, AlertDescription } from "@/components/ui/alert"
import { Skeleton } from "@/components/ui/skeleton"
import { Badge } from "@/components/ui/badge"
import { Dialog, DialogContent, DialogDescription, DialogHeader, DialogTitle } from "@/components/ui/dialog"
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from "@/components/ui/table"
import { Plus, Search, Eye, Calendar, DollarSign } from "lucide-react"
import Link from "next/link"

interface Order {
  id: number
  order_date: string
  total_amount: number
  status: string
  notes: string | null
}

export default function CustomerOrdersPage() {
  const [orders, setOrders] = useState<Order[]>([])
  const [filteredOrders, setFilteredOrders] = useState<Order[]>([])
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState("")
  const [searchTerm, setSearchTerm] = useState("")
  const [selectedOrder, setSelectedOrder] = useState<any>(null)
  const [detailsOpen, setDetailsOpen] = useState(false)
  const [canCreateOrders, setCanCreateOrders] = useState(false)

  useEffect(() => {
    loadOrders()
    checkPermissions()
  }, [])

  useEffect(() => {
    filterOrders()
  }, [searchTerm, orders])

  const checkPermissions = async () => {
    try {
      const response = await fetch("/api/customer-auth/session")
      if (response.ok) {
        const data = await response.json()
        setCanCreateOrders(data.session.permissions.can_create_orders)
      }
    } catch (error) {
      console.error("Permission check error:", error)
    }
  }

  const loadOrders = async () => {
    try {
      const response = await fetch("/api/customer/orders")

      if (!response.ok) {
        const errorData = await response.json()
        setError(errorData.error || "حدث خطأ أثناء تحميل الطلبيات")
        return
      }

      const data = await response.json()
      setOrders(data.orders)
      setFilteredOrders(data.orders)
    } catch (error) {
      console.error("Load orders error:", error)
      setError("حدث خطأ أثناء تحميل الطلبيات")
    } finally {
      setLoading(false)
    }
  }

  const filterOrders = () => {
    if (!searchTerm) {
      setFilteredOrders(orders)
      return
    }

    const filtered = orders.filter(
      (order) => order.id.toString().includes(searchTerm) || getStatusLabel(order.status).includes(searchTerm),
    )
    setFilteredOrders(filtered)
  }

  const viewOrderDetails = async (orderId: number) => {
    try {
      const response = await fetch(`/api/customer/orders/${orderId}`)

      if (!response.ok) {
        const errorData = await response.json()
        setError(errorData.error || "حدث خطأ أثناء تحميل تفاصيل الطلبية")
        return
      }

      const data = await response.json()
      setSelectedOrder(data)
      setDetailsOpen(true)
    } catch (error) {
      console.error("View order details error:", error)
      setError("حدث خطأ أثناء تحميل تفاصيل الطلبية")
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
        return "bg-yellow-100 text-yellow-800 border-yellow-300"
      case "confirmed":
        return "bg-blue-100 text-blue-800 border-blue-300"
      case "preparing":
        return "bg-purple-100 text-purple-800 border-purple-300"
      case "ready":
        return "bg-green-100 text-green-800 border-green-300"
      case "delivered":
        return "bg-gray-100 text-gray-800 border-gray-300"
      case "cancelled":
        return "bg-red-100 text-red-800 border-red-300"
      default:
        return "bg-gray-100 text-gray-800 border-gray-300"
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
        {/* Header */}
        <div className="flex items-center justify-between">
          <div>
            <h1 className="text-3xl font-bold">طلبياتي</h1>
            <p className="text-muted-foreground mt-1">عرض وإدارة طلبيات المبيعات الخاصة بك</p>
          </div>
          {canCreateOrders && (
            <Link href="/customer/orders/new">
              <Button className="gap-2">
                <Plus className="h-4 w-4" />
                طلبية جديدة
              </Button>
            </Link>
          )}
        </div>

        {error && (
          <Alert variant="destructive">
            <AlertDescription>{error}</AlertDescription>
          </Alert>
        )}

        {/* Search */}
        <Card>
          <CardContent className="pt-6">
            <div className="relative">
              <Search className="absolute right-3 top-1/2 transform -translate-y-1/2 h-4 w-4 text-muted-foreground" />
              <Input
                placeholder="ابحث برقم الطلبية أو الحالة..."
                value={searchTerm}
                onChange={(e) => setSearchTerm(e.target.value)}
                className="pr-10"
              />
            </div>
          </CardContent>
        </Card>

        {/* Orders Table */}
        <Card>
          <CardHeader>
            <CardTitle>قائمة الطلبيات</CardTitle>
          </CardHeader>
          <CardContent>
            {loading ? (
              <div className="space-y-3">
                {[...Array(5)].map((_, i) => (
                  <Skeleton key={i} className="h-16 w-full" />
                ))}
              </div>
            ) : filteredOrders.length === 0 ? (
              <div className="text-center py-12">
                <p className="text-muted-foreground">لا توجد طلبيات</p>
                {canCreateOrders && (
                  <Link href="/customer/orders/new">
                    <Button className="mt-4 gap-2">
                      <Plus className="h-4 w-4" />
                      إنشاء طلبية جديدة
                    </Button>
                  </Link>
                )}
              </div>
            ) : (
              <div className="rounded-md border">
                <Table>
                  <TableHeader>
                    <TableRow>
                      <TableHead className="text-right">رقم الطلبية</TableHead>
                      <TableHead className="text-right">التاريخ</TableHead>
                      <TableHead className="text-right">المبلغ الإجمالي</TableHead>
                      <TableHead className="text-right">الحالة</TableHead>
                      <TableHead className="text-right">الإجراءات</TableHead>
                    </TableRow>
                  </TableHeader>
                  <TableBody>
                    {filteredOrders.map((order) => (
                      <TableRow key={order.id}>
                        <TableCell className="font-medium">#{order.id}</TableCell>
                        <TableCell>
                          <div className="flex items-center gap-2">
                            <Calendar className="h-4 w-4 text-muted-foreground" />
                            {formatDate(order.order_date)}
                          </div>
                        </TableCell>
                        <TableCell>
                          <div className="flex items-center gap-2">
                            <DollarSign className="h-4 w-4 text-muted-foreground" />
                            {formatCurrency(order.total_amount)} ريال
                          </div>
                        </TableCell>
                        <TableCell>
                          <Badge variant="outline" className={getStatusColor(order.status)}>
                            {getStatusLabel(order.status)}
                          </Badge>
                        </TableCell>
                        <TableCell>
                          <Button
                            variant="ghost"
                            size="sm"
                            onClick={() => viewOrderDetails(order.id)}
                            className="gap-2"
                          >
                            <Eye className="h-4 w-4" />
                            عرض التفاصيل
                          </Button>
                        </TableCell>
                      </TableRow>
                    ))}
                  </TableBody>
                </Table>
              </div>
            )}
          </CardContent>
        </Card>

        {/* Order Details Dialog */}
        <Dialog open={detailsOpen} onOpenChange={setDetailsOpen}>
          <DialogContent className="max-w-3xl max-h-[80vh] overflow-y-auto">
            <DialogHeader>
              <DialogTitle>تفاصيل الطلبية #{selectedOrder?.id}</DialogTitle>
              <DialogDescription>معلومات تفصيلية عن الطلبية</DialogDescription>
            </DialogHeader>

            {selectedOrder && (
              <div className="space-y-6">
                {/* Order Info */}
                <div className="grid grid-cols-2 gap-4">
                  <div>
                    <p className="text-sm text-muted-foreground">التاريخ</p>
                    <p className="font-medium">{formatDate(selectedOrder.order_date)}</p>
                  </div>
                  <div>
                    <p className="text-sm text-muted-foreground">الحالة</p>
                    <Badge variant="outline" className={getStatusColor(selectedOrder.status)}>
                      {getStatusLabel(selectedOrder.status)}
                    </Badge>
                  </div>
                  {selectedOrder.notes && (
                    <div className="col-span-2">
                      <p className="text-sm text-muted-foreground">ملاحظات</p>
                      <p className="font-medium">{selectedOrder.notes}</p>
                    </div>
                  )}
                </div>

                {/* Order Items */}
                <div>
                  <h3 className="font-semibold mb-3">الأصناف</h3>
                  <div className="rounded-md border">
                    <Table>
                      <TableHeader>
                        <TableRow>
                          <TableHead className="text-right">الصنف</TableHead>
                          <TableHead className="text-right">الكمية</TableHead>
                          <TableHead className="text-right">السعر</TableHead>
                          <TableHead className="text-right">الإجمالي</TableHead>
                        </TableRow>
                      </TableHeader>
                      <TableBody>
                        {selectedOrder.items?.map((item: any) => (
                          <TableRow key={item.id}>
                            <TableCell className="font-medium">{item.product_name}</TableCell>
                            <TableCell>{item.quantity}</TableCell>
                            <TableCell>{formatCurrency(item.unit_price)} ريال</TableCell>
                            <TableCell className="font-medium">{formatCurrency(item.total_price)} ريال</TableCell>
                          </TableRow>
                        ))}
                      </TableBody>
                    </Table>
                  </div>
                </div>

                {/* Total */}
                <div className="flex justify-between items-center pt-4 border-t">
                  <span className="text-lg font-semibold">المبلغ الإجمالي</span>
                  <span className="text-2xl font-bold text-primary">
                    {formatCurrency(selectedOrder.total_amount)} ريال
                  </span>
                </div>
              </div>
            )}
          </DialogContent>
        </Dialog>
      </div>
    </CustomerLayout>
  )
}
