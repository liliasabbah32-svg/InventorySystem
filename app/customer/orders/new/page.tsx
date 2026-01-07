"use client"

import { useEffect, useState } from "react"
import { useRouter } from "next/navigation"
import { CustomerLayout } from "@/components/customer/customer-layout"
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card"
import { Button } from "@/components/ui/button"
import { Input } from "@/components/ui/input"
import { Textarea } from "@/components/ui/textarea"
import { Alert, AlertDescription } from "@/components/ui/alert"
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from "@/components/ui/table"
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select"
import { Plus, Trash2, Save, Loader2 } from "lucide-react"

interface Product {
  id: number
  name: string
  price: number
  stock_quantity: number
}

interface OrderItem {
  product_id: number
  product_name: string
  quantity: number
  unit_price: number
  total_price: number
}

export default function NewCustomerOrderPage() {
  const router = useRouter()
  const [products, setProducts] = useState<Product[]>([])
  const [items, setItems] = useState<OrderItem[]>([])
  const [notes, setNotes] = useState("")
  const [loading, setLoading] = useState(false)
  const [error, setError] = useState("")
  const [canViewPrices, setCanViewPrices] = useState(false)
  const [canViewStock, setCanViewStock] = useState(false)

  useEffect(() => {
    checkPermissions()
    loadProducts()
  }, [])

  const checkPermissions = async () => {
    try {
      const response = await fetch("/api/customer-auth/session")
      if (response.ok) {
        const data = await response.json()
        setCanViewPrices(data.session.permissions.can_view_prices)
        setCanViewStock(data.session.permissions.can_view_stock)

        if (!data.session.permissions.can_create_orders) {
          router.push("/customer/orders")
        }
      }
    } catch (error) {
      console.error("Permission check error:", error)
    }
  }

  const loadProducts = async () => {
    try {
      const response = await fetch("/api/customer/products")

      if (response.ok) {
        const data = await response.json()
        setProducts(data.products)
      }
    } catch (error) {
      console.error("Load products error:", error)
    }
  }

  const addItem = () => {
    setItems([
      ...items,
      {
        product_id: 0,
        product_name: "",
        quantity: 1,
        unit_price: 0,
        total_price: 0,
      },
    ])
  }

  const removeItem = (index: number) => {
    setItems(items.filter((_, i) => i !== index))
  }

  const updateItem = (index: number, field: keyof OrderItem, value: any) => {
    const newItems = [...items]
    newItems[index] = { ...newItems[index], [field]: value }

    if (field === "product_id") {
      const product = products.find((p) => p.id === Number.parseInt(value))
      if (product) {
        newItems[index].product_name = product.name
        newItems[index].unit_price = product.price
        newItems[index].total_price = product.price * newItems[index].quantity
      }
    } else if (field === "quantity") {
      newItems[index].total_price = newItems[index].unit_price * Number.parseFloat(value)
    }

    setItems(newItems)
  }

  const calculateTotal = () => {
    return items.reduce((sum, item) => sum + item.total_price, 0)
  }

  const handleSubmit = async () => {
    setError("")

    if (items.length === 0) {
      setError("يجب إضافة صنف واحد على الأقل")
      return
    }

    if (items.some((item) => item.product_id === 0 || item.quantity <= 0)) {
      setError("يرجى التأكد من اختيار الأصناف والكميات بشكل صحيح")
      return
    }

    setLoading(true)

    try {
      const response = await fetch("/api/customer/orders", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({
          items: items.map((item) => ({
            product_id: item.product_id,
            quantity: item.quantity,
            unit_price: item.unit_price,
          })),
          notes,
        }),
      })

      const data = await response.json()

      if (!response.ok) {
        setError(data.error || "حدث خطأ أثناء إنشاء الطلبية")
        return
      }

      router.push("/customer/orders")
    } catch (error) {
      console.error("Create order error:", error)
      setError("حدث خطأ أثناء إنشاء الطلبية")
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

  return (
    <CustomerLayout>
      <div className="space-y-6">
        <div>
          <h1 className="text-3xl font-bold">طلبية جديدة</h1>
          <p className="text-muted-foreground mt-1">إنشاء طلبية مبيعات جديدة</p>
        </div>

        {error && (
          <Alert variant="destructive">
            <AlertDescription>{error}</AlertDescription>
          </Alert>
        )}

        <Card>
          <CardHeader>
            <CardTitle>الأصناف</CardTitle>
          </CardHeader>
          <CardContent className="space-y-4">
            {items.length === 0 ? (
              <div className="text-center py-8 text-muted-foreground">
                <p>لم يتم إضافة أي أصناف بعد</p>
              </div>
            ) : (
              <div className="rounded-md border">
                <Table>
                  <TableHeader>
                    <TableRow>
                      <TableHead className="text-right">الصنف</TableHead>
                      <TableHead className="text-right">الكمية</TableHead>
                      {canViewPrices && <TableHead className="text-right">السعر</TableHead>}
                      {canViewPrices && <TableHead className="text-right">الإجمالي</TableHead>}
                      <TableHead className="text-right">إجراءات</TableHead>
                    </TableRow>
                  </TableHeader>
                  <TableBody>
                    {items.map((item, index) => (
                      <TableRow key={index}>
                        <TableCell>
                          <Select
                            value={item.product_id.toString()}
                            onValueChange={(value) => updateItem(index, "product_id", value)}
                          >
                            <SelectTrigger>
                              <SelectValue placeholder="اختر الصنف" />
                            </SelectTrigger>
                            <SelectContent>
                              {products.map((product) => (
                                <SelectItem key={product.id} value={product.id.toString()}>
                                  {product.name}
                                  {canViewStock && ` (متوفر: ${product.stock_quantity})`}
                                </SelectItem>
                              ))}
                            </SelectContent>
                          </Select>
                        </TableCell>
                        <TableCell>
                          <Input
                            type="number"
                            min="1"
                            value={item.quantity}
                            onChange={(e) => updateItem(index, "quantity", e.target.value)}
                            className="w-24"
                          />
                        </TableCell>
                        {canViewPrices && <TableCell>{formatCurrency(item.unit_price)} ريال</TableCell>}
                        {canViewPrices && (
                          <TableCell className="font-medium">{formatCurrency(item.total_price)} ريال</TableCell>
                        )}
                        <TableCell>
                          <Button variant="ghost" size="icon" onClick={() => removeItem(index)}>
                            <Trash2 className="h-4 w-4 text-red-600" />
                          </Button>
                        </TableCell>
                      </TableRow>
                    ))}
                  </TableBody>
                </Table>
              </div>
            )}

            <Button onClick={addItem} variant="outline" className="gap-2 bg-transparent">
              <Plus className="h-4 w-4" />
              إضافة صنف
            </Button>

            {canViewPrices && items.length > 0 && (
              <div className="flex justify-between items-center pt-4 border-t">
                <span className="text-lg font-semibold">المبلغ الإجمالي</span>
                <span className="text-2xl font-bold text-primary">{formatCurrency(calculateTotal())} ريال</span>
              </div>
            )}
          </CardContent>
        </Card>

        <Card>
          <CardHeader>
            <CardTitle>ملاحظات</CardTitle>
          </CardHeader>
          <CardContent>
            <Textarea
              value={notes}
              onChange={(e) => setNotes(e.target.value)}
              placeholder="أضف أي ملاحظات إضافية..."
              rows={4}
            />
          </CardContent>
        </Card>

        <div className="flex gap-3 justify-end">
          <Button variant="outline" onClick={() => router.back()} disabled={loading}>
            إلغاء
          </Button>
          <Button onClick={handleSubmit} disabled={loading} className="gap-2">
            {loading ? (
              <>
                <Loader2 className="h-4 w-4 animate-spin" />
                جاري الحفظ...
              </>
            ) : (
              <>
                <Save className="h-4 w-4" />
                حفظ الطلبية
              </>
            )}
          </Button>
        </div>
      </div>
    </CustomerLayout>
  )
}
