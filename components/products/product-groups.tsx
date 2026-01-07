"use client"

import { useState, useEffect, useMemo, useCallback, ChangeEvent, FormEvent, useRef } from "react"
import { Button } from "@/components/ui/button"
import { Input } from "@/components/ui/input"
import { Label } from "@/components/ui/label"
import { Dialog, DialogContent, DialogHeader, DialogTitle } from "@/components/ui/dialog"
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card"
import { Badge } from "@/components/ui/badge"
import { Plus, Search, Download, Package, Layers, BarChart3, TrendingUp } from "lucide-react"
import { UniversalToolbar } from "@/components/ui/universal-toolbar"

// ----------------- Types -----------------
interface ItemGroup {
  id: number
  group_code: string
  group_name: string
  description?: string | null
  product_count?: number | null
  status: "نشط" | "غير نشط" | "متوقف"
}

interface FormData {
  group_code: string
  group_name: string
  description: string
  status: "نشط" | "غير نشط"
}

interface State {
  itemGroups: ItemGroup[]
  loading: boolean
  error: string | null
  isFormOpen: boolean
  isSubmitting: boolean
  editingGroup: ItemGroup | null
  currentIndex: number
  searchTerm: string
  formData: FormData
}

export default function ProductGroups() {
  const [state, setState] = useState<State>({
    itemGroups: [],
    loading: true,
    error: null,
    isFormOpen: false,
    isSubmitting: false,
    editingGroup: null,
    currentIndex: 0,
    searchTerm: "",
    formData: {
      group_code: "",
      group_name: "",
      description: "",
      status: "نشط",
    },
  })
  const groupNameRef = useRef<HTMLInputElement>(null);
  // ----------------- Computed Values -----------------
  const filteredGroups = useMemo(
    () =>
      state.itemGroups.filter(
        (g) =>
          g.group_name?.includes(state.searchTerm) || g.group_code?.includes(state.searchTerm),
      ),
    [state.itemGroups, state.searchTerm],
  )

  const statistics = useMemo(() => {
    const totalGroups = state.itemGroups.length
    const totalProducts = state.itemGroups.reduce(
      (sum, g) => sum + (Number(g.product_count) || 0),
      0
    );
    console.log("totalProducts ", totalProducts)
    const largestGroup = state.itemGroups.reduce(
      (max, g) => (g.product_count && g.product_count > (max.product_count || 0) ? g : max),
      { group_name: "لا يوجد", product_count: 0 } as ItemGroup,
    )
    const averageProducts = totalGroups ? Math.round(totalProducts / totalGroups) : 0
    return { totalGroups, totalProducts, largestGroup, averageProducts }
  }, [state.itemGroups])

  const currentGroup = useMemo(() => filteredGroups[state.currentIndex] || null, [
    filteredGroups,
    state.currentIndex,
  ])

  // ----------------- Fetch Data -----------------
  const fetchItemGroups = useCallback(async () => {
    setState((prev) => ({ ...prev, loading: true, error: null }))
    try {
      const res = await fetch("/api/item-groups")
      if (!res.ok) throw new Error("فشل في تحميل المجموعات")
      const data: ItemGroup[] = await res.json()
      setState((prev) => ({ ...prev, itemGroups: data }))
    } catch (err: any) {
      setState((prev) => ({ ...prev, error: err.message || "حدث خطأ" }))
    } finally {
      setState((prev) => ({ ...prev, loading: false }))
    }
  }, [])

  useEffect(() => {
    fetchItemGroups()
  }, [fetchItemGroups])

  useEffect(() => {
    console.log("currentGroup ",currentGroup)
    if (currentGroup && state.isFormOpen) updateFormData(currentGroup)
  }, [currentGroup, state.isFormOpen])

  useEffect(() => {
  if (state.isFormOpen) {
    groupNameRef.current?.focus();
  }
}, [state.isFormOpen]);
  // ----------------- Form Handling -----------------
  const updateFormData = (group: ItemGroup) => {
    setState((prev) => ({
      ...prev,
      formData: {
        group_code: group.group_code || "",
        group_name: group.group_name || "",
        description: group.description || "",
        status: group.status === "متوقف" ? "نشط" : group.status || "نشط",
      },
    }))
  }

  const handleInputChange = useCallback((field: keyof FormData, value: string) => {
    setState((prev) => ({ ...prev, formData: { ...prev.formData, [field]: value } }))
  }, [])

  const generateNewGroupNumber = useCallback(async () => {
    try {
      const res = await fetch("/api/item-groups/generate-number")
      if (!res.ok) return
      const data = await res.json()
      setState((prev) => ({ ...prev, formData: { group_code: data.number, group_name: "", description: "", status: "نشط" } }))
    } catch (err) {
      console.error(err)
    }
  }, [])

  const handleSubmit = async (e: FormEvent) => {
    e.preventDefault()
    if (!state.formData.group_name.trim()) return alert("اسم المجموعة مطلوب")
    if (!state.editingGroup && !state.formData.group_code.trim()) return alert("رقم المجموعة مطلوب")

    setState((prev) => ({ ...prev, isSubmitting: true }))
    try {
      const method = state.editingGroup ? "PUT" : "POST"
      const url = state.editingGroup
        ? `/api/item-groups/${state.editingGroup.id}`
        : "/api/item-groups"

      const res = await fetch(url, {
        method,
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify(state.formData),
      })
      if (!res.ok) {
        const errData = await res.json()
        throw new Error(errData.error || "فشل في حفظ البيانات")
      }

      await fetchItemGroups()
      setState((prev) => ({
        ...prev,
        isFormOpen: false,
        editingGroup: null,
        formData: { group_code: "", group_name: "", description: "", status: "نشط" },
      }))
      alert(state.editingGroup ? "تم تحديث المجموعة بنجاح" : "تم حفظ المجموعة بنجاح")
    } catch (err: any) {
      console.error(err)
      alert("حدث خطأ أثناء الحفظ: " + err.message)
    } finally {
      setState((prev) => ({ ...prev, isSubmitting: false }))
    }
  }

  // ----------------- Navigation -----------------
  const handleFirst = useCallback(() => {
    setState((prev) => ({
      ...prev,
      currentIndex: 0,
      editingGroup: filteredGroups[0] || null,
      isFormOpen: true,
    }))
  }, [filteredGroups])
  const handlePrevious = useCallback(() => {
    setState((prev) => {
      const newIndex = Math.max(0, prev.currentIndex - 1)
      return {
        ...prev,
        currentIndex: newIndex,
        editingGroup: filteredGroups[newIndex] || null,
        isFormOpen: true,
      }
    })
  }, [filteredGroups])

  const handleNext = useCallback(() => {
    setState((prev) => {
      const newIndex = Math.min(filteredGroups.length - 1, prev.currentIndex + 1)
      return {
        ...prev,
        currentIndex: newIndex,
        editingGroup: filteredGroups[newIndex] || null,
        isFormOpen: true,
      }
    })
  }, [filteredGroups])

  const handleLast = useCallback(() => {
    const lastIndex = filteredGroups.length - 1
    setState((prev) => ({
      ...prev,
      currentIndex: lastIndex,
      editingGroup: filteredGroups[lastIndex] || null,
      isFormOpen: true,
    }))
  }, [filteredGroups])

  const handleEditGroup = useCallback(
    (group: ItemGroup) => {
      const index = filteredGroups.findIndex((g) => g.group_code === group.group_code)
      setState((prev) => ({ ...prev, currentIndex: index >= 0 ? index : 0, editingGroup: group, isFormOpen: true }))
    },
    [filteredGroups],
  )

  const handleDeleteGroup = useCallback(
    async (groupId: number) => {
      if (!confirm("هل أنت متأكد من حذف هذه المجموعة؟")) return
      try {
        const res = await fetch(`/api/item-groups/${groupId}`, { method: "DELETE" })
        if (res.ok) await fetchItemGroups()
        else setState((prev) => ({ ...prev, error: "فشل في حذف المجموعة" }))
      } catch (err) {
        console.error(err)
        setState((prev) => ({ ...prev, error: "حدث خطأ أثناء الحذف" }))
      }
    },
    [fetchItemGroups],
  )

  // ----------------- UI Helpers -----------------
  const getStatusBadge = useCallback((status: ItemGroup["status"]) => {
    const config = {
      نشط: { color: "bg-green-100 text-green-800", text: "نشط" },
      "غير نشط": { color: "bg-red-100 text-red-800", text: "غير نشط" },
      متوقف: { color: "bg-yellow-100 text-yellow-800", text: "متوقف" },
    }[status || "نشط"]
    return <Badge className={config.color}>{config.text}</Badge>
  }, [])

  // ----------------- Render -----------------
  if (state.loading)
    return (
      <div className="flex items-center justify-center h-64">
        <div className="text-center">
          <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-primary mx-auto mb-4"></div>
          <p className="text-muted-foreground">جاري تحميل المجموعات...</p>
        </div>
      </div>
    )

  if (state.error)
    return (
      <div className="flex items-center justify-center h-64">
        <div className="text-center">
          <p className="text-destructive mb-4">خطأ: {state.error}</p>
          <Button onClick={fetchItemGroups} variant="outline">
            إعادة المحاولة
          </Button>
        </div>
      </div>
    )

  return (
    <div className="space-y-6 p-6" dir="rtl">
      {/* Statistics Cards */}
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
        <Card className="bg-gradient-to-br from-blue-50 to-blue-100 border-blue-200">
          <CardContent className="p-6 flex justify-between items-center">
            <div>
              <p className="text-sm font-medium text-blue-700">إجمالي المجموعات</p>
              <p className="text-3xl font-bold text-blue-900">{statistics.totalGroups}</p>
            </div>
            <Layers className="h-10 w-10 text-blue-600" />
          </CardContent>
        </Card>
        <Card className="bg-gradient-to-br from-green-50 to-green-100 border-green-200">
          <CardContent className="p-6 flex justify-between items-center">
            <div>
              <p className="text-sm font-medium text-green-700">إجمالي الأصناف</p>
              <p className="text-3xl font-bold text-green-900">{statistics.totalProducts}</p>
            </div>
            <Package className="h-10 w-10 text-green-600" />
          </CardContent>
        </Card>
        <Card className="bg-gradient-to-br from-orange-50 to-orange-100 border-orange-200">
          <CardContent className="p-6 flex justify-between items-center">
            <div>
              <p className="text-sm font-medium text-orange-700">أكبر مجموعة</p>
              <p className="text-lg font-bold text-orange-900 truncate">{statistics.largestGroup.group_name}</p>
              <p className="text-sm text-orange-600">{statistics.largestGroup.product_count} صنف</p>
            </div>
            <BarChart3 className="h-10 w-10 text-orange-600" />
          </CardContent>
        </Card>
        <Card className="bg-gradient-to-br from-purple-50 to-purple-100 border-purple-200">
          <CardContent className="p-6 flex justify-between items-center">
            <div>
              <p className="text-sm font-medium text-purple-700">متوسط الأصناف</p>
              <p className="text-3xl font-bold text-purple-900">{statistics.averageProducts}</p>
            </div>
            <TrendingUp className="h-10 w-10 text-purple-600" />
          </CardContent>
        </Card>
      </div>

      {/* Toolbar */}
      <Card>
        <CardContent className="flex flex-col lg:flex-row gap-4 items-center justify-between">
          <div className="relative flex-1">
            <Search className="absolute right-3 top-1/2 -translate-y-1/2 text-gray-400 h-4 w-4" />
            <Input
              placeholder="البحث في المجموعات..."
              value={state.searchTerm}
              onChange={(e: ChangeEvent<HTMLInputElement>) =>
                setState((prev) => ({ ...prev, searchTerm: e.target.value }))
              }
              className="pr-10"
            />
          </div>
          <div className="flex gap-2">
            <Button onClick={() => {generateNewGroupNumber();setState((prev) => ({ ...prev, isFormOpen: true, editingGroup: null }) ); }}>
              <Plus className="ml-2 h-4 w-4" /> إضافة مجموعة جديدة
            </Button>
            <Button variant="outline">
              <Download className="ml-2 h-4 w-4" /> تصدير
            </Button>
          </div>
        </CardContent>
      </Card>

      {/* Groups Table */}
      <Card>
        <CardHeader>
          <CardTitle className="font-heading">مجموعات الأصناف ({filteredGroups.length})</CardTitle>
        </CardHeader>
        <CardContent className="p-0 overflow-x-auto">
          <table className="w-full">
            <thead className="bg-gray-50">
              <tr>
                <th className="text-right p-4 font-semibold">رقم المجموعة</th>
                <th className="text-right p-4 font-semibold">اسم المجموعة</th>
                <th className="text-right p-4 font-semibold">الوصف</th>
                <th className="text-right p-4 font-semibold">عدد الأصناف</th>
                <th className="text-right p-4 font-semibold">الحالة</th>
                <th className="text-right p-4 font-semibold">الإجراءات</th>
              </tr>
            </thead>
            <tbody>
              {filteredGroups.map((g) => (
                <tr key={g.group_code} className="border-b hover:bg-gray-50">
                  <td className="p-4 font-mono">{g.group_code}</td>
                  <td className="p-4 font-semibold">{g.group_name}</td>
                  <td className="p-4">{g.description || "-"}</td>
                  <td className="p-4 font-medium">{g.product_count || 0}</td>
                  <td className="p-4">{getStatusBadge(g.status)}</td>
                  <td className="p-4 flex gap-2">
                    <Button variant="outline" size="sm" onClick={() => handleEditGroup(g)}>
                      عرض
                    </Button>
                    <Button variant="outline" size="sm" onClick={() => handleEditGroup(g)}>
                      تعديل
                    </Button>
                    <Button variant="outline" size="sm" onClick={() => handleDeleteGroup(g.id)}>
                      حذف
                    </Button>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </CardContent>
      </Card>

      {/* Group Form Dialog */}
      <Dialog open={state.isFormOpen} onOpenChange={(open) => setState((prev) => ({ ...prev, isFormOpen: open }))}>
        <DialogContent className="max-w-2xl">
          <DialogHeader>
            <DialogTitle className="text-xl font-bold">
              {state.editingGroup ? "تعديل بيانات المجموعة" : currentGroup ? "عرض المجموعة" : "إضافة مجموعة جديدة"}
            </DialogTitle>
          </DialogHeader>

          {filteredGroups.length > 0 && (
            <UniversalToolbar
              totalRecords={filteredGroups.length}
              onFirst={handleFirst}
              onPrevious={handlePrevious}
              onNext={handleNext}
              onLast={handleLast}
              onNew={generateNewGroupNumber}
              isFirstRecord={state.currentIndex === 0}
              isLastRecord={state.currentIndex === filteredGroups.length - 1}
              isSaving={state.isSubmitting}
            />
          )}

          <form onSubmit={handleSubmit} className="space-y-4">
            <div className="grid grid-cols-1 md:grid-cols-4 gap-4">
              {/* رقم المجموعة (1 column) */}
              <div className="space-y-1 col-span-1">
                <Label>رقم المجموعة</Label>
                <div className="flex gap-2">
                  <Input
                    value={state.formData.group_code}
                    maxLength={8}
                    onChange={(e) => {
                      const value = e.target.value.toUpperCase().replace(/[^A-Z0-9]/g, "");
                      handleInputChange("group_code", value);
                    }}
                    disabled={!!state.editingGroup}
                  />
                </div>
              </div>

              {/* اسم المجموعة (3 columns) */}
              <div className="space-y-3 col-span-3">
                <Label>اسم المجموعة *</Label>
                <Input
                  ref={groupNameRef}
                  required
                  value={state.formData.group_name}
                  onChange={(e) => handleInputChange("group_name", e.target.value)}
                />
              </div>
            </div>


            <div className="space-y-2">
              <Label>الوصف</Label>
              <Input
                value={state.formData.description}
                onChange={(e) => handleInputChange("description", e.target.value)}
              />
            </div>

            <div className="flex justify-end gap-3 pt-6 border-t">
              <Button type="button" variant="outline" onClick={() => setState((prev) => ({ ...prev, isFormOpen: false }))} disabled={state.isSubmitting}>
                إلغاء
              </Button>
              <Button type="submit" disabled={state.isSubmitting}>
                {state.isSubmitting ? "جاري الحفظ..." : "حفظ البيانات"}
              </Button>
            </div>
          </form>
        </DialogContent>
      </Dialog>
    </div>
  )
}
