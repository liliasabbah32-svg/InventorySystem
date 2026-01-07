"use client"

import type React from "react"
import { useState, useEffect } from "react"
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card"
import { Button } from "@/components/ui/button"
import { Input } from "@/components/ui/input"
import { Label } from "@/components/ui/label"
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select"
import { Textarea } from "@/components/ui/textarea"
import { Dialog, DialogContent, DialogHeader, DialogTitle } from "@/components/ui/dialog"
import { Badge } from "@/components/ui/badge"
import { Tabs, TabsContent, TabsList, TabsTrigger } from "@/components/ui/tabs"
import { SearchButton } from "@/components/search/search-button"
import MultiSelect from "../common/MultiSelect"
import {
  Plus,
  Package,
  ArrowUpCircle,
  ArrowDownCircle,
  RotateCcw,
  AlertTriangle,
  CheckCircle,
  XCircle,
  Clock,
  Search,
  Filter,
  Download,
  Eye,
  Edit,
  MoreHorizontal,
  Lock,
  RefreshCcw,
} from "lucide-react"
import { useAuth } from "@/components/auth/auth-context"
import { formatDateToBritish } from "@/lib/utils"
import ProductCodeInput from "../products/ProductCodeInput"
import ProductSearchPopup from "../products/ProductSearchPopup"

interface BatchMovement {
  id: number
  lot_id: number
  batch_number: string
  product_id: number
  product_name: string
  product_code: string
  transaction_type: string
  quantity: number
  reference_type?: string
  reference_id?: number
  unit_cost?: number
  reference_number?: string
  created_by?: string
  created_at: string
  order_number?: string
  customer_name?: string
  status?: string
}

interface ProductLot {
  id: number
  product_id: number
  product_name: string
  product_code: string
  lot_number: string
  manufacturing_date?: string
  expiry_date?: string
  supplier_name?: string
  initial_quantity: number
  current_quantity: number
  reserved_quantity: number
  available_quantity: number
  unit_cost: number
  status: "new" | "in_use" | "finished" | "damaged"
  status_display: string
  expiry_status: "منتهي الصلاحية" | "قريب الانتهاء" | "صالح"
}

interface Product {
  id: number
  code: string
  name: string
  main_unit: string
}

const STATUS_FLOW = ['new', 'inUse', 'closed', 'damaged'] as const;
type StatusType = typeof STATUS_FLOW[number];
export function BatchMovements() {
  const { user } = useAuth()
  const [movements, setMovements] = useState<BatchMovement[]>([])
  const [lots, setLots] = useState<ProductLot[]>([])
  const [products, setProducts] = useState<Product[]>([])
  const [loading, setLoading] = useState(true)
  const [showDialog, setShowDialog] = useState(false)
  const [selectedLot, setSelectedLot] = useState<ProductLot | null>(null)
  const [activeTab, setActiveTab] = useState("movements")
  const [showItemSearch, setItemSearch] = useState(false)
  const [status, setStatus] = useState<StatusType>("new");
  // Form states
  const [formData, setFormData] = useState({
    lot_id: "",
    transaction_type: "0",
    quantity: 0,
    unit_cost: 0,
    reference_type: "",
    reference_id: "",
    notes: "",
    new_status: "" as ProductLot["status"] | "",
  })

  // Filter states
  const [filters, setFilters] = useState({
    product_id: "",
    product_Name: "",
    lot_number: "",
    transaction_type: "0",
    date_from: new Date(new Date().getFullYear(), 0, 1).toISOString().split("T")[0], // بداية العام الحالي
    date_to: new Date().toISOString().split("T")[0], // تاريخ اليوم
    status: "",
  })

  useEffect(() => {
    fetchMovements()
  }, [])

  const fetchMovements = async () => {
    try {
      const params = new URLSearchParams()
      Object.entries(filters).forEach(([key, value]) => {
        if (value) params.append(key, value)
      })

      const response = await fetch(`/api/inventory/batch-movements?${params}`)
      if (response.ok) {
        const data = await response.json()
        setMovements(Array.isArray(data) ? data : [])
      } else {
        setMovements([])
      }
    } catch (error) {
      console.error("Error fetching batch movements:", error)
      setMovements([])
    } finally {
      setLoading(false)
    }
  }

  const fetchLots = async () => {
    try {
      const response = await fetch("/api/inventory/batch-lots")
      if (response.ok) {
        const data = await response.json()
        setLots(Array.isArray(data) ? data : [])
      } else {
        setLots([])
      }
    } catch (error) {
      console.error("Error fetching lots:", error)
      setLots([])
    }
  }

  const fetchProducts = async () => {
    try {
      const response = await fetch("/api/inventory/products")
      if (response.ok) {
        const data = await response.json()
        setProducts(Array.isArray(data) ? data : [])
      } else {
        setProducts([])
      }
    } catch (error) {
      console.error("Error fetching products:", error)
      setProducts([])
    }
  }

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault()

    if (!formData.lot_id) {
      alert("يرجى اختيار الدفعة")
      return
    }



    try {
      const movementData = {
        ...formData,
        lot_id: Number.parseInt(formData.lot_id),
        created_by: user?.fullName || "مستخدم",
      }

      const response = await fetch("/api/inventory/batch-movements", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify(movementData),
      })

      if (response.ok) {
        setShowDialog(false)
        resetForm()
        fetchMovements()
        fetchLots()
        alert("تم إضافة حركة الدفعة بنجاح")
      } else {
        const error = await response.json()
        throw new Error(error.error || "فشل في إضافة حركة الدفعة")
      }
    } catch (error) {
      console.error("Error creating batch movement:", error)
      alert(error instanceof Error ? error.message : "حدث خطأ في إضافة حركة الدفعة")
    }
  }

  const resetForm = () => {
    setFormData({
      lot_id: "",
      transaction_type: "0",
      quantity: 0,
      unit_cost: 0,
      reference_type: "",
      reference_id: "",
      notes: "",
      new_status: "",
    })
    setSelectedLot(null)
  }

  const handleLotSelect = (lotId: string) => {
    const lot = lots.find((l) => l.id === Number.parseInt(lotId))
    setSelectedLot(lot || null)
    setFormData((prev) => ({
      ...prev,
      lot_id: lotId,
      unit_cost: lot?.unit_cost || 0,
    }))
  }

  const handleProductSelect = (product: any) => {
    setFilters((prev) => ({
      ...prev,
      product_id: product.id?.toString() || "",
    }))
  }

  const getMovementIcon = (type: string) => {
    const icons = {
      new: <ArrowUpCircle className="h-4 w-4 text-green-600" />,
      inUse: <ArrowDownCircle className="h-4 w-4 text-red-600" />,
      closed: <CheckCircle className="h-4 w-4 text-blue-600" />,
      damaged: <XCircle className="h-4 w-4 text-purple-600" />,

    }
    return icons[type as keyof typeof icons] || <Clock className="h-4 w-4" />
  }

  const getMovementBadge = (type: string) => {
    const config = {
      new: { color: "bg-green-100 text-green-800", text: "جديد" },
      inUse: { color: "bg-red-100 text-red-800", text: "قيد الإستخدام" },
      closed: { color: "bg-blue-100 text-blue-800", text: "مغلق" },
      damaged: { color: "bg-purple-100 text-purple-800", text: "تالف" },
    }
    const { color, text } = config[type as keyof typeof config] || config.inUse
    return <Badge className={color}>{text}</Badge>
  }

  const getStatusBadge = (status: string) => {
    const config = {
      new: { color: "bg-blue-100 text-blue-800", text: "جديد" },
      in_use: { color: "bg-green-100 text-green-800", text: "قيد الاستخدام" },
      finished: { color: "bg-gray-100 text-gray-800", text: "منتهي" },
      damaged: { color: "bg-red-100 text-red-800", text: "تالف" },
    }
    const { color, text } = config[status as keyof typeof config] || config.new
    return <Badge className={color}>{text}</Badge>
  }

  const getExpiryBadge = (status: string) => {
    const config = {
      "منتهي الصلاحية": { color: "bg-red-100 text-red-800", text: "منتهي الصلاحية" },
      "قريب الانتهاء": { color: "bg-yellow-100 text-yellow-800", text: "قريب الانتهاء" },
      صالح: { color: "bg-green-100 text-green-800", text: "صالح" },
    }
    const { color, text } = config[status as keyof typeof config] || config["صالح"]
    return <Badge className={color}>{text}</Badge>
  }

  if (loading) {
    return (
      <div className="flex items-center justify-center h-64">
        <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-primary"></div>
      </div>
    )
  }

  async function updateBatchStatus(batchId: number, statusId: number) {
    await fetch(`/api/inventory/batch-movements/batch-status/${batchId}`, {
      method: "PATCH",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ status_id: statusId })
    });
  }


 const setRowStatus = async (batchId: number, newStatus: string) => {
  try {
    setMovements((prev) =>
      prev.map((row) =>
        row.id === batchId
          ? { ...row, status: newStatus }
          : row
      )
    );

    
  } catch (err) {
    console.error("Failed to update batch status:", err);
  }
};



  const StatusButton = ({
    value,
    active,
    icon,
    onClick,
    tooltip, // new prop
    className = ''
  }: {
    value: StatusType;
    active: boolean;
    icon: React.ReactNode;
    onClick: () => void;
    tooltip?: string; // optional
    className?: string;
  }) => (
    <Button
      variant={active ? 'default' : 'outline'}
      size="sm"
      className={`bg-white ${className}`}
      onClick={onClick}
      title={tooltip} // tooltip added here
    >
      {icon}
    </Button>
  );

  return (
    <div className="space-y-6">
      <div className="flex justify-between items-center">
        <div>
          <h2 className="text-2xl font-bold">إدارة حركات الرقم التشغيلي - الباتش</h2>
        </div>

      </div>
      <ProductSearchPopup
        visible={showItemSearch}
        onClose={() => setItemSearch(false)}
        onSelect={(selectedItems) => {
          if (!selectedItems || selectedItems.length === 0) return;

          const selected = selectedItems[0];

          console.log("Selected product:", selected);

          setFilters((prev) => ({
            ...prev,
            product_id: String(selected.id), // convert number to string
            product_Name: `${selected.product_name}`,

          }));

          setItemSearch(false);
        }}
        priceCategoryId={1}
        ShowSelect={false}
      />

      <Tabs value={activeTab} onValueChange={setActiveTab} className="w-full">


        <TabsContent value="movements" className="space-y-4">
          <Card className="bg-gradient-to-br from-white to-blue-50/30 border-blue-200 shadow-lg">

            <CardContent className="p-6">
              <div className="grid grid-cols-1 md:grid-cols-3 lg:grid-cols-6 gap-4">
                <div className="space-y-4">
                  <Label className="text-sm font-medium">
                    {"رقم الصنف"} <span className="text-red-500 mr-1"></span>
                  </Label>

                  <div className="flex flex-row-reverse gap-2 items-center">
                    <Button type="button" onClick={() => setFilters((prev) => ({
                      ...prev,
                      product_id: "", // convert number to string
                      product_Name: "",

                    }))}>
                      🗑️
                    </Button>
                    <Button type="button" onClick={() => setItemSearch(true)}>
                      🔍
                    </Button>

                    <Input
                      value={filters.product_Name ?? ""}
                      onKeyDown={(e) => {
                        // Allow Enter
                        if (e.key === "F10") {
                          setItemSearch(true)
                          return;
                        }
                      }
                      }
                      onChange={(e) =>
                        setFilters((prev) => ({ ...prev, product_id: e.target.value }))
                      }
                      className="text-right font-medium h-11 flex-1"
                      dir="rtl"
                      placeholder={""}
                      maxLength={8}
                    />
                  </div>
                </div>

                <div>
                  <Label>الرقم التشغيلي</Label>
                  <Input
                    value={filters.lot_number}
                    onChange={(e) => setFilters((prev) => ({ ...prev, lot_number: e.target.value }))}
                    placeholder="ابحث عن رقم تشغيلي..."
                    maxLength={30}
                  />
                </div>

                <div>
                  <Label>الحالة</Label>
                  <Select
                    value={String(filters.transaction_type) ?? "0"}
                    onValueChange={(value) => setFilters((prev) => ({ ...prev, transaction_type: value }))}
                  >
                    <SelectTrigger>
                      <SelectValue placeholder="الكل" />
                    </SelectTrigger>
                    <SelectContent>
                      <SelectItem value="0">الكل</SelectItem>
                      <SelectItem value="1">جديد</SelectItem>
                      <SelectItem value="2">قيد الإستخدام</SelectItem>
                      <SelectItem value="3">مغلق</SelectItem>
                      <SelectItem value="4">تالف</SelectItem>
                    </SelectContent>
                  </Select>
                </div>

                <div>
                  <Label>من تاريخ</Label>
                  <Input
                    type="date"
                    value={filters.date_from}
                    onChange={(e) => setFilters((prev) => ({ ...prev, date_from: e.target.value }))}
                  />
                </div>

                <div>
                  <Label>إلى تاريخ</Label>
                  <Input
                    type="date"
                    value={filters.date_to}
                    onChange={(e) => setFilters((prev) => ({ ...prev, date_to: e.target.value }))}
                  />
                </div>

                <div className="flex items-end">
                  <Button onClick={fetchMovements} className="w-full">
                    <Search className="ml-2 h-4 w-4" />
                    بحث
                  </Button>
                </div>
              </div>
            </CardContent>
          </Card>

          <Card className="bg-gradient-to-br from-white to-gray-50/30 border-gray-200 shadow-lg">
            <CardHeader className="bg-gradient-to-r from-gray-700 to-gray-800 text-white rounded-t-lg">
              <div className="flex justify-between items-center">
                <CardTitle className="flex items-center gap-2">
                  <Package className="h-5 w-5" />
                  سجل حركات الدفعات
                </CardTitle>
                <Button
                  variant="outline"
                  size="sm"
                  className="bg-white/20 border-white/30 text-white hover:bg-white/30"
                >
                  <Download className="ml-2 h-4 w-4" />
                  تصدير
                </Button>
              </div>
            </CardHeader>
            <CardContent className="p-0">
              <div className="overflow-x-auto">
                <table className="w-full">
                  <thead className="bg-gradient-to-r from-gray-50 to-blue-50/50">
                    <tr>
                      <th className="text-right p-4 font-semibold text-gray-700">التاريخ</th>
                      <th className="text-right p-4 font-semibold text-gray-700">الصنف</th>
                      <th className="text-right p-4 font-semibold text-gray-700">الرقم التشغيلي</th>
                      <th className="text-right p-4 font-semibold text-gray-700">الحالة</th>
                      <th className="text-right p-4 font-semibold text-gray-700">رقم الحركة</th>
                      <th className="text-right p-4 font-semibold text-gray-700">المورد</th>
                      <th className="text-right p-4 font-semibold text-gray-700">السند اليدوي</th>
                      <th className="text-right p-4 font-semibold text-gray-700">اجراءات</th>
                    </tr>
                  </thead>
                  <tbody>
                    {Array.isArray(movements) && movements.length > 0 ? (
                      movements.map((movement) => (
                        <tr
                          key={movement.id}
                          className="border-b border-blue-100/50 hover:bg-blue-50/30 transition-colors"
                        >
                          <td className="p-4">{formatDateToBritish(movement.created_at)}</td>
                          <td className="p-4">
                            <div>
                              <div className="font-medium text-gray-900">{movement.product_name}</div>
                              <div className="text-sm text-blue-600">{movement.product_code}</div>
                            </div>
                          </td>
                          <td className="p-4">
                            <Badge variant="outline" className="border-blue-200 text-blue-700 bg-blue-50">
                              {movement.batch_number}
                            </Badge>
                          </td>
                          <td className="p-4">
                            <div className="flex items-center gap-2">
                              {getMovementIcon(String(movement.status))}
                              {getMovementBadge(String(movement.status))}
                            </div>
                          </td>
                          <td className="p-4">
                            <div>
                              <div className="font-medium text-gray-900">{movement.order_number}</div>
                            </div>
                          </td>
                          <td className="p-4">
                            <div>
                              <div className="font-medium text-gray-900">{movement.customer_name}</div>
                            </div>
                          </td>
                          <td className="p-4">
                            <div>
                              <div className="font-medium text-gray-900">{movement.reference_number}</div>
                            </div>
                          </td>
                          <td className="p-4">
                            <div className="flex gap-1">
                              <StatusButton
                                value="new"
                                active={status === 'new'}
                                icon={<RefreshCcw className="h-4 w-4 text-gray-700" />}
                                 onClick={async () => {
                                  //setRowStatus(movement.id, 'inUse'); // update local UI
                                  await updateBatchStatus(movement.id, 1); // update DB
                                  setRowStatus(movement.id, 'new');
                                }}
                                tooltip="تحويل الى جديد"
                              />

                              <StatusButton
                                value="inUse"
                                active={status === 'inUse'}
                                icon={<Edit className="h-4 w-4" />}
                                onClick={async () => {
                                  
                                  await updateBatchStatus(movement.id, 2); // update DB
                                  setRowStatus(movement.id, 'inUse'); // update local UI
                                }}
                                tooltip="تحويل الى قيد الاستخدام"
                              />

                              <StatusButton
                                value="closed"
                                active={status === 'closed'}
                                icon={<Lock className="h-4 w-4" />}
                                 onClick={async () => {
                                  //setRowStatus(movement.id, 'inUse'); // update local UI
                                  await updateBatchStatus(movement.id, 3); // update DB
                                  setRowStatus(movement.id, 'closed');
                                }}
                                tooltip="تحويل الى مغلق"
                              />

                              <StatusButton
                                value="damaged"
                                active={status === 'damaged'}
                                icon={<AlertTriangle className="h-4 w-4 text-red-500" />}
                                 onClick={async () => {
                                  //setRowStatus(movement.id, 'inUse'); // update local UI
                                  await updateBatchStatus(movement.id, 4); // update DB
                                  setRowStatus(movement.id, 'damaged');
                                }}
                                tooltip="تحويل الى تالف"
                              />
                            </div>

                          </td>
                        </tr>
                      ))
                    ) : (
                      <tr>
                        <td colSpan={9} className="p-8 text-center text-gray-500">
                          لا توجد ارقام تشغيلية للعرض
                        </td>
                      </tr>
                    )}
                  </tbody>
                </table>
              </div>
            </CardContent>
          </Card>
        </TabsContent>

        <TabsContent value="lots" className="space-y-4">
          <Card className="bg-gradient-to-br from-white to-purple-50/30 border-purple-200 shadow-lg">
            <CardHeader className="bg-gradient-to-r from-purple-600 to-purple-700 text-white rounded-t-lg">
              <CardTitle className="flex items-center gap-2">
                <Package className="h-5 w-5" />
                إدارة الدفعات النشطة
              </CardTitle>
            </CardHeader>
            <CardContent className="p-0">
              <div className="overflow-x-auto">
                <table className="w-full">
                  <thead className="bg-gray-50">
                    <tr>
                      <th className="text-right p-4 font-semibold">المنتج</th>
                      <th className="text-right p-4 font-semibold">رقم الدفعة</th>
                      <th className="text-right p-4 font-semibold">تاريخ الإنتاج</th>
                      <th className="text-right p-4 font-semibold">تاريخ الانتهاء</th>
                      <th className="text-right p-4 font-semibold">حالة الصلاحية</th>
                      <th className="text-right p-4 font-semibold">الكمية الحالية</th>
                      <th className="text-right p-4 font-semibold">الكمية المتاحة</th>
                      <th className="text-right p-4 font-semibold">الحالة</th>
                      <th className="text-right p-4 font-semibold">المورد</th>
                      <th className="text-right p-4 font-semibold">إجراءات</th>
                    </tr>
                  </thead>
                  <tbody>
                    {Array.isArray(lots) && lots.length > 0 ? (
                      lots.map((lot) => (
                        <tr key={lot.id} className="border-b hover:bg-gray-50">
                          <td className="p-4">
                            <div>
                              <div className="font-medium">{lot.product_name}</div>
                              <div className="text-sm text-gray-500">{lot.product_code}</div>
                            </div>
                          </td>
                          <td className="p-4">
                            <Badge variant="outline">{lot.lot_number}</Badge>
                          </td>
                          <td className="p-4">
                            {lot.manufacturing_date ? formatDateToBritish(lot.manufacturing_date) : "-"}
                          </td>
                          <td className="p-4">{lot.expiry_date ? formatDateToBritish(lot.expiry_date) : "-"}</td>
                          <td className="p-4">{getExpiryBadge(lot.expiry_status)}</td>
                          <td className="p-4 font-medium">{lot.current_quantity.toLocaleString()}</td>
                          <td className="p-4 font-medium text-green-600">{lot.available_quantity.toLocaleString()}</td>
                          <td className="p-4">{getStatusBadge(lot.status)}</td>
                          <td className="p-4">{lot.supplier_name || "-"}</td>
                          <td className="p-4">
                            <Button
                              variant="outline"
                              size="sm"
                              onClick={() => {
                                setSelectedLot(lot)
                                setFormData((prev) => ({
                                  ...prev,
                                  lot_id: lot.id.toString(),
                                  unit_cost: lot.unit_cost,
                                }))
                                setShowDialog(true)
                              }}
                            >
                              <Eye className="h-4 w-4" />
                            </Button>
                          </td>
                        </tr>
                      ))
                    ) : (
                      <tr>
                        <td colSpan={10} className="p-8 text-center text-gray-500">
                          لا توجد دفعات للعرض
                        </td>
                      </tr>
                    )}
                  </tbody>
                </table>
              </div>
            </CardContent>
          </Card>
        </TabsContent>
      </Tabs>

      <Dialog open={showDialog} onOpenChange={setShowDialog}>
        <DialogContent className="max-w-3xl bg-gradient-to-br from-white to-blue-50/20 border-blue-200">
          <DialogHeader className="bg-gradient-to-r from-blue-600 to-blue-700 text-white p-6 -m-6 mb-6 rounded-t-lg">
            <DialogTitle className="flex items-center gap-2 text-white">
              <Plus className="h-5 w-5" />
              إضافة حركة دفعة جديدة
            </DialogTitle>
          </DialogHeader>

          <form onSubmit={handleSubmit} className="space-y-6">
            {/* Lot Selection */}
            <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
              <div>
                <Label htmlFor="lot">الدفعة *</Label>
                <Select value={formData.lot_id} onValueChange={handleLotSelect}>
                  <SelectTrigger>
                    <SelectValue placeholder="اختر الدفعة" />
                  </SelectTrigger>
                  <SelectContent>
                    <SelectItem value="none">اختر الدفعة</SelectItem>
                    {Array.isArray(lots) &&
                      lots.map((lot) => (
                        <SelectItem key={lot.id} value={lot.id.toString()}>
                          {lot.product_name} - {lot.lot_number} (متاح: {lot.available_quantity})
                        </SelectItem>
                      ))}
                  </SelectContent>
                </Select>
              </div>

              <div>
                <Label htmlFor="transaction_type">نوع الحركة *</Label>
                <Select
                  value={formData.transaction_type}
                  onValueChange={(value: BatchMovement["transaction_type"]) =>
                    setFormData((prev) => ({ ...prev, transaction_type: value }))
                  }
                >
                  <SelectTrigger>
                    <SelectValue />
                  </SelectTrigger>
                  <SelectContent>
                    <SelectItem value="purchase">شراء</SelectItem>
                    <SelectItem value="sale">بيع</SelectItem>
                    <SelectItem value="adjustment">تعديل كمية</SelectItem>
                    <SelectItem value="transfer">تحويل</SelectItem>
                    <SelectItem value="return">مرتجع</SelectItem>
                    <SelectItem value="status_change">تغيير حالة</SelectItem>
                    <SelectItem value="damage">تلف</SelectItem>
                    <SelectItem value="close">إغلاق دفعة</SelectItem>
                  </SelectContent>
                </Select>
              </div>
            </div>

            {/* Selected Lot Info */}
            {selectedLot && (
              <Card className="bg-blue-50 border-blue-200">
                <CardContent className="pt-4">
                  <div className="grid grid-cols-2 md:grid-cols-4 gap-4 text-sm">
                    <div>
                      <span className="font-medium">المنتج:</span>
                      <div>{selectedLot.product_name}</div>
                    </div>
                    <div>
                      <span className="font-medium">الكمية الحالية:</span>
                      <div>{selectedLot.current_quantity.toLocaleString()}</div>
                    </div>
                    <div>
                      <span className="font-medium">الكمية المتاحة:</span>
                      <div className="text-green-600 font-medium">
                        {selectedLot.available_quantity.toLocaleString()}
                      </div>
                    </div>
                    <div>
                      <span className="font-medium">الحالة:</span>
                      <div>{getStatusBadge(selectedLot.status)}</div>
                    </div>
                  </div>
                </CardContent>
              </Card>
            )}

            {/* Quantity and Cost */}
            {formData.transaction_type !== "status_change" && (
              <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                <div>
                  <Label htmlFor="quantity">الكمية *</Label>
                  <Input
                    id="quantity"
                    type="number"
                    step="0.01"
                    value={formData.quantity}
                    onChange={(e) =>
                      setFormData((prev) => ({
                        ...prev,
                        quantity: Number.parseFloat(e.target.value) || 0,
                      }))
                    }
                    required
                  />
                </div>

                <div>
                  <Label htmlFor="unit_cost">تكلفة الوحدة</Label>
                  <Input
                    id="unit_cost"
                    type="number"
                    step="0.01"
                    value={formData.unit_cost}
                    onChange={(e) =>
                      setFormData((prev) => ({
                        ...prev,
                        unit_cost: Number.parseFloat(e.target.value) || 0,
                      }))
                    }
                  />
                </div>
              </div>
            )}

            {/* Status Change */}
            {formData.transaction_type === "status_change" && (
              <div>
                <Label htmlFor="new_status">الحالة الجديدة *</Label>
                <Select
                  value={formData.new_status}
                  onValueChange={(value: ProductLot["status"]) =>
                    setFormData((prev) => ({ ...prev, new_status: value }))
                  }
                >
                  <SelectTrigger>
                    <SelectValue placeholder="اختر الحالة الجديدة" />
                  </SelectTrigger>
                  <SelectContent>
                    <SelectItem value="new">جديد</SelectItem>
                    <SelectItem value="in_use">قيد الاستخدام</SelectItem>
                    <SelectItem value="finished">منتهي</SelectItem>
                    <SelectItem value="damaged">تالف</SelectItem>
                  </SelectContent>
                </Select>
              </div>
            )}

            {/* Reference */}
            <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
              <div>
                <Label htmlFor="reference_type">نوع المرجع</Label>
                <Select
                  value={formData.reference_type}
                  onValueChange={(value) => setFormData((prev) => ({ ...prev, reference_type: value }))}
                >
                  <SelectTrigger>
                    <SelectValue placeholder="اختر نوع المرجع" />
                  </SelectTrigger>
                  <SelectContent>
                    <SelectItem value="purchase_order">أمر شراء</SelectItem>
                    <SelectItem value="sales_order">أمر بيع</SelectItem>
                    <SelectItem value="adjustment">تعديل</SelectItem>
                    <SelectItem value="transfer">تحويل</SelectItem>
                    <SelectItem value="manual">يدوي</SelectItem>
                  </SelectContent>
                </Select>
              </div>

              <div>
                <Label htmlFor="reference_id">رقم المرجع</Label>
                <Input
                  id="reference_id"
                  value={formData.reference_id}
                  onChange={(e) => setFormData((prev) => ({ ...prev, reference_id: e.target.value }))}
                  placeholder="رقم الأمر أو المرجع"
                />
              </div>
            </div>

            {/* Notes */}
            <div>
              <Label htmlFor="notes">ملاحظات</Label>
              <Textarea
                id="notes"
                value={formData.notes}
                onChange={(e) => setFormData((prev) => ({ ...prev, notes: e.target.value }))}
                rows={3}
                placeholder="أدخل أي ملاحظات إضافية..."
              />
            </div>

            {/* Actions */}
            <div className="flex justify-end gap-2 pt-4 border-t">
              <Button type="button" variant="outline" onClick={() => setShowDialog(false)}>
                إلغاء
              </Button>
              <Button type="submit">حفظ الحركة</Button>
            </div>
          </form>
        </DialogContent>
      </Dialog>
    </div>
  )
}
