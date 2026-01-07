"use client"

import { useState, useMemo } from "react"
import { Button } from "@/components/ui/button"
import { Input } from "@/components/ui/input"
import { Label } from "@/components/ui/label"
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card"
import { Badge } from "@/components/ui/badge"
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select"
import { Dialog, DialogContent, DialogHeader, DialogTitle } from "@/components/ui/dialog"
import { UniversalToolbar } from "@/components/ui/universal-toolbar"
import {
  Package,
  Plus,
  Search,
  Filter,
  Edit,
  Eye,
  Trash2,
  Grid3X3,
  List,
  Star,
  TrendingUp,
  AlertTriangle,
  CheckCircle,
  Barcode,
} from "lucide-react"
import { cn } from "@/lib/utils"

interface Product {
  id: number
  product_code: string
  product_name: string
  product_name_en?: string
  barcode?: string
  description?: string
  category: string
  subcategory?: string
  brand?: string
  model?: string
  main_unit: string
  secondary_unit?: string
  conversion_factor?: number
  last_purchase_price: number
  average_cost?: number
  selling_price?: number
  wholesale_price?: number
  retail_price?: number
  currency: string
  tax_rate?: number
  discount_rate?: number
  min_stock_level?: number
  max_stock_level?: number
  reorder_point?: number
  current_stock: number
  reserved_stock?: number
  available_stock?: number
  location?: string
  shelf_life?: number
  expiry_tracking: boolean
  batch_tracking: boolean
  serial_tracking: boolean
  status: string
  supplier_id?: number
  supplier_name?: string
  supplier_code?: string
  manufacturer?: string
  country_of_origin?: string
  weight?: number
  dimensions?: string
  color?: string
  size?: string
  material?: string
  warranty_period?: number
  image_url?: string
  notes?: string
  created_at: string
  updated_at: string
  created_by?: string
  updated_by?: string
  rating?: number
  sales_count?: number
  is_featured?: boolean
}

const mockProducts: Product[] = [
  {
    id: 1,
    product_code: "ELEC001",
    product_name: "لابتوب ديل XPS 13",
    product_name_en: "Dell XPS 13 Laptop",
    barcode: "1234567890123",
    description: "لابتوب عالي الأداء مع معالج Intel Core i7",
    category: "إلكترونيات",
    subcategory: "أجهزة كمبيوتر",
    brand: "ديل",
    model: "XPS 13",
    main_unit: "قطعة",
    last_purchase_price: 4500,
    selling_price: 5200,
    wholesale_price: 4800,
    retail_price: 5200,
    currency: "ريال سعودي",
    tax_rate: 15,
    current_stock: 25,
    min_stock_level: 5,
    max_stock_level: 50,
    status: "نشط",
    supplier_name: "شركة التقنية المتقدمة",
    manufacturer: "Dell",
    country_of_origin: "الصين",
    weight: 1.2,
    warranty_period: 24,
    image_url: "/dell-xps-13-laptop.jpg",
    created_at: "2024-01-15",
    updated_at: "2024-01-20",
    rating: 4.8,
    sales_count: 156,
    is_featured: true,
    expiry_tracking: false,
    batch_tracking: false,
    serial_tracking: true,
  },
  {
    id: 2,
    product_code: "CLOTH001",
    product_name: "قميص قطني أزرق",
    product_name_en: "Blue Cotton Shirt",
    barcode: "2345678901234",
    description: "قميص قطني عالي الجودة مناسب للاستخدام اليومي",
    category: "ملابس",
    subcategory: "قمصان",
    brand: "الأناقة",
    main_unit: "قطعة",
    last_purchase_price: 85,
    selling_price: 120,
    wholesale_price: 100,
    retail_price: 120,
    currency: "ريال سعودي",
    tax_rate: 15,
    current_stock: 150,
    min_stock_level: 20,
    max_stock_level: 200,
    status: "نشط",
    supplier_name: "مصنع النسيج الحديث",
    manufacturer: "الأناقة",
    country_of_origin: "تركيا",
    color: "أزرق",
    size: "متوسط",
    material: "قطن 100%",
    image_url: "/blue-cotton-shirt.png",
    created_at: "2024-01-10",
    updated_at: "2024-01-18",
    rating: 4.5,
    sales_count: 89,
    is_featured: false,
    expiry_tracking: false,
    batch_tracking: true,
    serial_tracking: false,
  },
  {
    id: 3,
    product_code: "FOOD001",
    product_name: "أرز بسمتي فاخر",
    product_name_en: "Premium Basmati Rice",
    barcode: "3456789012345",
    description: "أرز بسمتي عالي الجودة من الهند",
    category: "مواد غذائية",
    subcategory: "حبوب",
    brand: "الخير",
    main_unit: "كيلو",
    secondary_unit: "كيس",
    conversion_factor: 25,
    last_purchase_price: 12,
    selling_price: 18,
    wholesale_price: 15,
    retail_price: 18,
    currency: "ريال سعودي",
    tax_rate: 0,
    current_stock: 500,
    min_stock_level: 100,
    max_stock_level: 1000,
    status: "نشط",
    supplier_name: "مستودع المواد الغذائية",
    manufacturer: "الخير",
    country_of_origin: "الهند",
    weight: 1,
    shelf_life: 24,
    image_url: "/basmati-rice-bag.jpg",
    created_at: "2024-01-05",
    updated_at: "2024-01-22",
    rating: 4.7,
    sales_count: 234,
    is_featured: true,
    expiry_tracking: true,
    batch_tracking: true,
    serial_tracking: false,
  },
  {
    id: 4,
    product_code: "HOME001",
    product_name: "ثلاجة سامسونج 400 لتر",
    product_name_en: "Samsung 400L Refrigerator",
    barcode: "4567890123456",
    description: "ثلاجة عائلية بتقنية التبريد المتقدمة",
    category: "أجهزة منزلية",
    subcategory: "ثلاجات",
    brand: "سامسونج",
    model: "RT400",
    main_unit: "قطعة",
    last_purchase_price: 1800,
    selling_price: 2200,
    wholesale_price: 2000,
    retail_price: 2200,
    currency: "ريال سعودي",
    tax_rate: 15,
    current_stock: 8,
    min_stock_level: 3,
    max_stock_level: 15,
    status: "نشط",
    supplier_name: "وكيل سامسونج الرسمي",
    manufacturer: "Samsung",
    country_of_origin: "كوريا الجنوبية",
    weight: 65,
    dimensions: "180x60x65 سم",
    warranty_period: 60,
    image_url: "/samsung-refrigerator.jpg",
    created_at: "2024-01-08",
    updated_at: "2024-01-19",
    rating: 4.6,
    sales_count: 45,
    is_featured: false,
    expiry_tracking: false,
    batch_tracking: false,
    serial_tracking: true,
  },
  {
    id: 5,
    product_code: "COSM001",
    product_name: "كريم مرطب للوجه",
    product_name_en: "Face Moisturizing Cream",
    barcode: "5678901234567",
    description: "كريم مرطب طبيعي للعناية بالبشرة",
    category: "مستحضرات تجميل",
    subcategory: "العناية بالبشرة",
    brand: "الجمال الطبيعي",
    main_unit: "قطعة",
    last_purchase_price: 45,
    selling_price: 75,
    wholesale_price: 60,
    retail_price: 75,
    currency: "ريال سعودي",
    tax_rate: 15,
    current_stock: 2,
    min_stock_level: 10,
    max_stock_level: 100,
    status: "نشط",
    supplier_name: "شركة مستحضرات التجميل",
    manufacturer: "الجمال الطبيعي",
    country_of_origin: "فرنسا",
    weight: 0.05,
    shelf_life: 36,
    image_url: "/face-moisturizing-cream.jpg",
    created_at: "2024-01-12",
    updated_at: "2024-01-21",
    rating: 4.3,
    sales_count: 67,
    is_featured: false,
    expiry_tracking: true,
    batch_tracking: true,
    serial_tracking: false,
  },
]

export default function ProductsPage() {
  const [products, setProducts] = useState<Product[]>(mockProducts)
  const [loading, setLoading] = useState(false)
  const [viewMode, setViewMode] = useState<"grid" | "list">("grid")
  const [showDialog, setShowDialog] = useState(false)
  const [editingProduct, setEditingProduct] = useState<Product | null>(null)
  const [selectedProductIndex, setSelectedProductIndex] = useState(0)
  const [currentPage, setCurrentPage] = useState(1)
  const [itemsPerPage] = useState(12)

  const [filters, setFilters] = useState({
    search: "",
    category: "all",
    status: "all",
    stockLevel: "all",
    featured: "all",
    priceRange: "all",
  })

  console.log("[v0] Products page initialized with", products.length, "products")

  const categories = [
    "إلكترونيات",
    "ملابس",
    "مواد غذائية",
    "أجهزة منزلية",
    "مستحضرات تجميل",
    "أدوية",
    "أدوات منزلية",
    "كتب",
    "ألعاب",
    "رياضة",
    "سيارات",
    "أخرى",
  ]

  const filteredProducts = useMemo(() => {
    return products.filter((product) => {
      if (
        filters.search &&
        !product.product_name?.toLowerCase().includes(filters.search.toLowerCase()) &&
        !product.product_code?.toLowerCase().includes(filters.search.toLowerCase()) &&
        !product.barcode?.toLowerCase().includes(filters.search.toLowerCase())
      ) {
        return false
      }
      if (filters.category !== "all" && product.category !== filters.category) {
        return false
      }
      if (filters.status !== "all" && product.status !== filters.status) {
        return false
      }
      if (filters.featured !== "all") {
        if (filters.featured === "featured" && !product.is_featured) return false
        if (filters.featured === "regular" && product.is_featured) return false
      }
      if (filters.stockLevel !== "all") {
        if (filters.stockLevel === "low" && product.current_stock > (product.min_stock_level || 0)) {
          return false
        }
        if (filters.stockLevel === "out" && product.current_stock > 0) {
          return false
        }
        if (
          filters.stockLevel === "normal" &&
          (product.current_stock <= (product.min_stock_level || 0) || product.current_stock === 0)
        ) {
          return false
        }
      }
      return true
    })
  }, [products, filters])

  const paginatedProducts = useMemo(() => {
    const startIndex = (currentPage - 1) * itemsPerPage
    return filteredProducts.slice(startIndex, startIndex + itemsPerPage)
  }, [filteredProducts, currentPage, itemsPerPage])

  const totalPages = Math.ceil(filteredProducts.length / itemsPerPage)

  const statistics = useMemo(() => {
    const totalProducts = products.length
    const activeProducts = products.filter((p) => p.status === "نشط").length
    const featuredProducts = products.filter((p) => p.is_featured).length
    const lowStockProducts = products.filter((p) => p.current_stock <= (p.min_stock_level || 0)).length
    const outOfStockProducts = products.filter((p) => p.current_stock === 0).length
    const totalValue = products.reduce((sum, p) => sum + p.current_stock * p.last_purchase_price, 0)
    const avgRating = products.reduce((sum, p) => sum + (p.rating || 0), 0) / products.length

    return {
      totalProducts,
      activeProducts,
      featuredProducts,
      lowStockProducts,
      outOfStockProducts,
      totalValue,
      avgRating,
    }
  }, [products])

  const getStatusBadge = (status: string) => {
    switch (status) {
      case "نشط":
        return <Badge className="bg-green-100 text-green-800 border-green-200">نشط</Badge>
      case "غير نشط":
        return <Badge className="bg-gray-100 text-gray-800 border-gray-200">غير نشط</Badge>
      case "متوقف":
        return <Badge className="bg-red-100 text-red-800 border-red-200">متوقف</Badge>
      default:
        return <Badge variant="secondary">{status}</Badge>
    }
  }

  const getStockBadge = (current: number, min: number) => {
    if (current === 0) {
      return <Badge className="bg-red-100 text-red-800 border-red-200">نفد المخزون</Badge>
    }
    if (current <= min) {
      return <Badge className="bg-orange-100 text-orange-800 border-orange-200">مخزون منخفض</Badge>
    }
    return <Badge className="bg-green-100 text-green-800 border-green-200">متوفر</Badge>
  }

  const handleEditProduct = (product: Product) => {
    console.log("[v0] Editing product:", product.id)
    setEditingProduct(product)
    setShowDialog(true)
  }

  const handleDeleteProduct = (productId: number) => {
    console.log("[v0] Deleting product:", productId)
    setProducts(products.filter((p) => p.id !== productId))
    if (selectedProductIndex >= filteredProducts.length - 1) {
      setSelectedProductIndex(Math.max(0, filteredProducts.length - 2))
    }
  }

  const toggleFeatured = (productId: number) => {
    console.log("[v0] Toggling featured status for product:", productId)
    setProducts(products.map((p) => (p.id === productId ? { ...p, is_featured: !p.is_featured } : p)))
  }

  if (loading) {
    return (
      <div className="flex items-center justify-center min-h-[400px]" dir="rtl">
        <div className="text-center">
          <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-primary mx-auto mb-4"></div>
          <p className="text-muted-foreground">جاري تحميل المنتجات...</p>
        </div>
      </div>
    )
  }

  return (
    <div className="space-y-6 p-4 lg:p-6 bg-background min-h-screen" dir="rtl">
      {/* Universal Toolbar */}
      <UniversalToolbar
        currentRecord={selectedProductIndex + 1}
        totalRecords={filteredProducts.length}
        onFirst={() => setSelectedProductIndex(0)}
        onPrevious={() => setSelectedProductIndex(Math.max(0, selectedProductIndex - 1))}
        onNext={() => setSelectedProductIndex(Math.min(filteredProducts.length - 1, selectedProductIndex + 1))}
        onLast={() => setSelectedProductIndex(filteredProducts.length - 1)}
        onNew={() => {
          setEditingProduct(null)
          setShowDialog(true)
        }}
        onSave={() => console.log("Save product")}
        onDelete={() => {
          if (filteredProducts[selectedProductIndex]) {
            handleDeleteProduct(filteredProducts[selectedProductIndex].id)
          }
        }}
        onReport={() => console.log("Generate products report")}
        onExportExcel={() => console.log("Export to Excel")}
        onPrint={() => console.log("Print products")}
        isLoading={loading}
        isSaving={false}
        canSave={!!editingProduct}
        canDelete={filteredProducts.length > 0}
        isFirstRecord={selectedProductIndex === 0}
        isLastRecord={selectedProductIndex === filteredProducts.length - 1}
      />

      {/* Header */}
      <div className="flex flex-col sm:flex-row items-start sm:items-center justify-between gap-4">
        <div>
          <h1 className="text-3xl font-bold text-foreground flex items-center gap-3">
            <Package className="h-8 w-8 text-primary" />
            إدارة الأصناف
          </h1>
          <p className="text-muted-foreground mt-1">إدارة وتتبع جميع المنتجات والمخزون بطريقة احترافية</p>
        </div>
        <div className="flex items-center gap-2">
          <Button
            variant="outline"
            size="sm"
            onClick={() => setViewMode(viewMode === "grid" ? "list" : "grid")}
            className="hidden sm:flex"
          >
            {viewMode === "grid" ? <List className="h-4 w-4" /> : <Grid3X3 className="h-4 w-4" />}
          </Button>
          <Button
            onClick={() => {
              setEditingProduct(null)
              setShowDialog(true)
            }}
            className="bg-primary hover:bg-primary/90 text-primary-foreground"
          >
            <Plus className="ml-2 h-4 w-4" />
            صنف جديد
          </Button>
        </div>
      </div>

      {/* Statistics Cards */}
      <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 xl:grid-cols-7 gap-4">
        <Card className="bg-gradient-to-br from-blue-50 to-blue-100 border-blue-200">
          <CardContent className="p-4">
            <div className="flex items-center justify-between">
              <div>
                <p className="text-sm font-medium text-blue-700">إجمالي الأصناف</p>
                <p className="text-2xl font-bold text-blue-900">{statistics.totalProducts}</p>
              </div>
              <Package className="h-8 w-8 text-blue-600" />
            </div>
          </CardContent>
        </Card>

        <Card className="bg-gradient-to-br from-green-50 to-green-100 border-green-200">
          <CardContent className="p-4">
            <div className="flex items-center justify-between">
              <div>
                <p className="text-sm font-medium text-green-700">الأصناف النشطة</p>
                <p className="text-2xl font-bold text-green-900">{statistics.activeProducts}</p>
              </div>
              <CheckCircle className="h-8 w-8 text-green-600" />
            </div>
          </CardContent>
        </Card>

        <Card className="bg-gradient-to-br from-yellow-50 to-yellow-100 border-yellow-200">
          <CardContent className="p-4">
            <div className="flex items-center justify-between">
              <div>
                <p className="text-sm font-medium text-yellow-700">أصناف مميزة</p>
                <p className="text-2xl font-bold text-yellow-900">{statistics.featuredProducts}</p>
              </div>
              <Star className="h-8 w-8 text-yellow-600" />
            </div>
          </CardContent>
        </Card>

        <Card className="bg-gradient-to-br from-orange-50 to-orange-100 border-orange-200">
          <CardContent className="p-4">
            <div className="flex items-center justify-between">
              <div>
                <p className="text-sm font-medium text-orange-700">مخزون منخفض</p>
                <p className="text-2xl font-bold text-orange-900">{statistics.lowStockProducts}</p>
              </div>
              <AlertTriangle className="h-8 w-8 text-orange-600" />
            </div>
          </CardContent>
        </Card>

        <Card className="bg-gradient-to-br from-red-50 to-red-100 border-red-200">
          <CardContent className="p-4">
            <div className="flex items-center justify-between">
              <div>
                <p className="text-sm font-medium text-red-700">نفد المخزون</p>
                <p className="text-2xl font-bold text-red-900">{statistics.outOfStockProducts}</p>
              </div>
              <AlertTriangle className="h-8 w-8 text-red-600" />
            </div>
          </CardContent>
        </Card>

        <Card className="bg-gradient-to-br from-purple-50 to-purple-100 border-purple-200">
          <CardContent className="p-4">
            <div className="flex items-center justify-between">
              <div>
                <p className="text-sm font-medium text-purple-700">قيمة المخزون</p>
                <p className="text-xl font-bold text-purple-900">{statistics.totalValue.toLocaleString()}</p>
              </div>
              <TrendingUp className="h-8 w-8 text-purple-600" />
            </div>
          </CardContent>
        </Card>

        <Card className="bg-gradient-to-br from-indigo-50 to-indigo-100 border-indigo-200">
          <CardContent className="p-4">
            <div className="flex items-center justify-between">
              <div>
                <p className="text-sm font-medium text-indigo-700">متوسط التقييم</p>
                <p className="text-2xl font-bold text-indigo-900">{statistics.avgRating.toFixed(1)}</p>
              </div>
              <Star className="h-8 w-8 text-indigo-600" />
            </div>
          </CardContent>
        </Card>
      </div>

      {/* Advanced Filters */}
      <Card>
        <CardHeader>
          <CardTitle className="flex items-center gap-2">
            <Filter className="h-5 w-5" />
            البحث والتصفية المتقدمة
          </CardTitle>
        </CardHeader>
        <CardContent>
          <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 xl:grid-cols-6 gap-4">
            <div>
              <Label>البحث الذكي</Label>
              <div className="relative">
                <Search className="absolute right-3 top-1/2 transform -translate-y-1/2 h-4 w-4 text-muted-foreground" />
                <Input
                  placeholder="اسم المنتج، الكود، أو الباركود"
                  value={filters.search}
                  onChange={(e) => setFilters({ ...filters, search: e.target.value })}
                  className="pr-10"
                />
              </div>
            </div>

            <div>
              <Label>التصنيف</Label>
              <Select value={filters.category} onValueChange={(value) => setFilters({ ...filters, category: value })}>
                <SelectTrigger>
                  <SelectValue />
                </SelectTrigger>
                <SelectContent>
                  <SelectItem value="all">جميع التصنيفات</SelectItem>
                  {categories.map((category) => (
                    <SelectItem key={category} value={category}>
                      {category}
                    </SelectItem>
                  ))}
                </SelectContent>
              </Select>
            </div>

            <div>
              <Label>الحالة</Label>
              <Select value={filters.status} onValueChange={(value) => setFilters({ ...filters, status: value })}>
                <SelectTrigger>
                  <SelectValue />
                </SelectTrigger>
                <SelectContent>
                  <SelectItem value="all">جميع الحالات</SelectItem>
                  <SelectItem value="نشط">نشط</SelectItem>
                  <SelectItem value="غير نشط">غير نشط</SelectItem>
                  <SelectItem value="متوقف">متوقف</SelectItem>
                </SelectContent>
              </Select>
            </div>

            <div>
              <Label>مستوى المخزون</Label>
              <Select
                value={filters.stockLevel}
                onValueChange={(value) => setFilters({ ...filters, stockLevel: value })}
              >
                <SelectTrigger>
                  <SelectValue />
                </SelectTrigger>
                <SelectContent>
                  <SelectItem value="all">جميع المستويات</SelectItem>
                  <SelectItem value="normal">مخزون طبيعي</SelectItem>
                  <SelectItem value="low">مخزون منخفض</SelectItem>
                  <SelectItem value="out">نفد المخزون</SelectItem>
                </SelectContent>
              </Select>
            </div>

            <div>
              <Label>الأصناف المميزة</Label>
              <Select value={filters.featured} onValueChange={(value) => setFilters({ ...filters, featured: value })}>
                <SelectTrigger>
                  <SelectValue />
                </SelectTrigger>
                <SelectContent>
                  <SelectItem value="all">جميع الأصناف</SelectItem>
                  <SelectItem value="featured">مميزة فقط</SelectItem>
                  <SelectItem value="regular">عادية فقط</SelectItem>
                </SelectContent>
              </Select>
            </div>

            <div className="flex items-end">
              <Button
                variant="outline"
                onClick={() =>
                  setFilters({
                    search: "",
                    category: "all",
                    status: "all",
                    stockLevel: "all",
                    featured: "all",
                    priceRange: "all",
                  })
                }
                className="w-full"
              >
                إعادة تعيين
              </Button>
            </div>
          </div>
        </CardContent>
      </Card>

      {/* Products Display */}
      <Card>
        <CardHeader>
          <div className="flex items-center justify-between">
            <div>
              <CardTitle>قائمة الأصناف</CardTitle>
              <CardDescription>
                عرض {paginatedProducts.length} من أصل {filteredProducts.length} صنف
              </CardDescription>
            </div>
            <div className="flex items-center gap-2">
              <Button
                variant={viewMode === "grid" ? "default" : "outline"}
                size="sm"
                onClick={() => setViewMode("grid")}
              >
                <Grid3X3 className="h-4 w-4" />
              </Button>
              <Button
                variant={viewMode === "list" ? "default" : "outline"}
                size="sm"
                onClick={() => setViewMode("list")}
              >
                <List className="h-4 w-4" />
              </Button>
            </div>
          </div>
        </CardHeader>
        <CardContent>
          {paginatedProducts.length === 0 ? (
            <div className="text-center py-12">
              <Package className="mx-auto h-12 w-12 text-muted-foreground mb-4" />
              <h3 className="text-lg font-semibold text-foreground mb-2">لا توجد أصناف</h3>
              <p className="text-muted-foreground mb-4">لم يتم العثور على أي أصناف تطابق معايير البحث</p>
              <Button onClick={() => setShowDialog(true)}>
                <Plus className="ml-2 h-4 w-4" />
                إضافة صنف جديد
              </Button>
            </div>
          ) : (
            <>
              {viewMode === "grid" ? (
                <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 gap-6">
                  {paginatedProducts.map((product, index) => (
                    <Card
                      key={product.id}
                      className={cn(
                        "group hover:shadow-lg transition-all duration-200 cursor-pointer border-2",
                        selectedProductIndex === index
                          ? "border-primary shadow-md"
                          : "border-transparent hover:border-primary/30",
                      )}
                      onClick={() => setSelectedProductIndex(index)}
                    >
                      <CardContent className="p-4">
                        <div className="relative mb-4">
                          <img
                            src={product.image_url || "/placeholder.svg"}
                            alt={product.product_name}
                            className="w-full h-48 object-cover rounded-lg bg-muted"
                          />
                          {product.is_featured && (
                            <Badge className="absolute top-2 right-2 bg-yellow-500 text-white">
                              <Star className="h-3 w-3 mr-1" />
                              مميز
                            </Badge>
                          )}
                          <div className="absolute top-2 left-2">
                            {getStockBadge(product.current_stock, product.min_stock_level || 0)}
                          </div>
                        </div>

                        <div className="space-y-2">
                          <div className="flex items-start justify-between">
                            <h3 className="font-semibold text-foreground line-clamp-2 text-right">
                              {product.product_name}
                            </h3>
                            <Button
                              variant="ghost"
                              size="sm"
                              onClick={(e) => {
                                e.stopPropagation()
                                toggleFeatured(product.id)
                              }}
                            >
                              <Star
                                className={cn(
                                  "h-4 w-4",
                                  product.is_featured ? "fill-yellow-400 text-yellow-400" : "text-muted-foreground",
                                )}
                              />
                            </Button>
                          </div>

                          <div className="flex items-center justify-between text-sm text-muted-foreground">
                            <span>{product.product_code}</span>
                            <Badge variant="outline">{product.category}</Badge>
                          </div>

                          {product.barcode && (
                            <div className="flex items-center gap-1 text-xs text-muted-foreground">
                              <Barcode className="h-3 w-3" />
                              {product.barcode}
                            </div>
                          )}

                          <div className="flex items-center justify-between">
                            <div className="text-right">
                              <p className="text-lg font-bold text-primary">
                                {product.selling_price?.toLocaleString()} {product.currency}
                              </p>
                              <p className="text-sm text-muted-foreground">
                                المخزون: {product.current_stock} {product.main_unit}
                              </p>
                            </div>
                            <div className="flex items-center gap-1">
                              {product.rating && (
                                <div className="flex items-center gap-1">
                                  <Star className="h-3 w-3 fill-yellow-400 text-yellow-400" />
                                  <span className="text-xs">{product.rating}</span>
                                </div>
                              )}
                            </div>
                          </div>

                          <div className="flex items-center justify-between pt-2 border-t">
                            <div className="flex items-center gap-1">
                              <Button
                                variant="outline"
                                size="sm"
                                onClick={(e) => {
                                  e.stopPropagation()
                                  handleEditProduct(product)
                                }}
                              >
                                <Edit className="h-3 w-3" />
                              </Button>
                              <Button
                                variant="outline"
                                size="sm"
                                onClick={(e) => {
                                  e.stopPropagation()
                                  console.log("View product details")
                                }}
                              >
                                <Eye className="h-3 w-3" />
                              </Button>
                              <Button
                                variant="outline"
                                size="sm"
                                onClick={(e) => {
                                  e.stopPropagation()
                                  handleDeleteProduct(product.id)
                                }}
                              >
                                <Trash2 className="h-3 w-3" />
                              </Button>
                            </div>
                            {getStatusBadge(product.status)}
                          </div>
                        </div>
                      </CardContent>
                    </Card>
                  ))}
                </div>
              ) : (
                <div className="space-y-2">
                  {paginatedProducts.map((product, index) => (
                    <Card
                      key={product.id}
                      className={cn(
                        "group hover:shadow-md transition-all duration-200 cursor-pointer border-l-4",
                        selectedProductIndex === index
                          ? "border-l-primary bg-primary/5"
                          : "border-l-transparent hover:border-l-primary/50",
                      )}
                      onClick={() => setSelectedProductIndex(index)}
                    >
                      <CardContent className="p-4">
                        <div className="flex items-center gap-4">
                          <img
                            src={product.image_url || "/placeholder.svg"}
                            alt={product.product_name}
                            className="w-16 h-16 object-cover rounded-lg bg-muted flex-shrink-0"
                          />

                          <div className="flex-1 min-w-0">
                            <div className="flex items-start justify-between mb-2">
                              <div className="text-right">
                                <h3 className="font-semibold text-foreground">{product.product_name}</h3>
                                <p className="text-sm text-muted-foreground">{product.product_code}</p>
                              </div>
                              <div className="flex items-center gap-2">
                                {product.is_featured && (
                                  <Badge className="bg-yellow-500 text-white">
                                    <Star className="h-3 w-3 mr-1" />
                                    مميز
                                  </Badge>
                                )}
                                {getStatusBadge(product.status)}
                              </div>
                            </div>

                            <div className="grid grid-cols-2 md:grid-cols-4 gap-4 text-sm">
                              <div>
                                <span className="text-muted-foreground">التصنيف: </span>
                                <Badge variant="outline">{product.category}</Badge>
                              </div>
                              <div>
                                <span className="text-muted-foreground">المخزون: </span>
                                <span className="font-medium">
                                  {product.current_stock} {product.main_unit}
                                </span>
                              </div>
                              <div>
                                <span className="text-muted-foreground">السعر: </span>
                                <span className="font-bold text-primary">
                                  {product.selling_price?.toLocaleString()} {product.currency}
                                </span>
                              </div>
                              <div className="flex items-center gap-2">
                                {getStockBadge(product.current_stock, product.min_stock_level || 0)}
                                {product.rating && (
                                  <div className="flex items-center gap-1">
                                    <Star className="h-3 w-3 fill-yellow-400 text-yellow-400" />
                                    <span>{product.rating}</span>
                                  </div>
                                )}
                              </div>
                            </div>
                          </div>

                          <div className="flex items-center gap-1 flex-shrink-0">
                            <Button
                              variant="outline"
                              size="sm"
                              onClick={(e) => {
                                e.stopPropagation()
                                handleEditProduct(product)
                              }}
                            >
                              <Edit className="h-4 w-4" />
                            </Button>
                            <Button
                              variant="outline"
                              size="sm"
                              onClick={(e) => {
                                e.stopPropagation()
                                console.log("View product details")
                              }}
                            >
                              <Eye className="h-4 w-4" />
                            </Button>
                            <Button
                              variant="outline"
                              size="sm"
                              onClick={(e) => {
                                e.stopPropagation()
                                toggleFeatured(product.id)
                              }}
                            >
                              <Star
                                className={cn(
                                  "h-4 w-4",
                                  product.is_featured ? "fill-yellow-400 text-yellow-400" : "text-muted-foreground",
                                )}
                              />
                            </Button>
                          </div>
                        </div>
                      </CardContent>
                    </Card>
                  ))}
                </div>
              )}

              {/* Pagination */}
              {totalPages > 1 && (
                <div className="flex items-center justify-between mt-6 pt-4 border-t">
                  <div className="text-sm text-muted-foreground">
                    صفحة {currentPage} من {totalPages} ({filteredProducts.length} صنف)
                  </div>
                  <div className="flex gap-2">
                    <Button
                      variant="outline"
                      size="sm"
                      onClick={() => setCurrentPage(currentPage - 1)}
                      disabled={currentPage === 1}
                    >
                      السابق
                    </Button>
                    <Button
                      variant="outline"
                      size="sm"
                      onClick={() => setCurrentPage(currentPage + 1)}
                      disabled={currentPage === totalPages}
                    >
                      التالي
                    </Button>
                  </div>
                </div>
              )}
            </>
          )}
        </CardContent>
      </Card>

      {/* Product Dialog */}
      <Dialog open={showDialog} onOpenChange={setShowDialog}>
        <DialogContent className="max-w-4xl max-h-[90vh] overflow-y-auto" dir="rtl">
          <DialogHeader>
            <DialogTitle className="text-right">{editingProduct ? "تعديل الصنف" : "صنف جديد"}</DialogTitle>
          </DialogHeader>

          <div className="text-center py-8">
            <Package className="h-12 w-12 text-muted-foreground mx-auto mb-4" />
            <p className="text-muted-foreground">نموذج تفصيلي لإدارة الأصناف سيتم إضافته قريباً</p>
          </div>
        </DialogContent>
      </Dialog>
    </div>
  )
}
