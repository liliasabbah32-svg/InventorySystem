"use client"

import { useState, useEffect } from "react"
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card"
import { Button } from "@/components/ui/button"
import { Input } from "@/components/ui/input"
import { Label } from "@/components/ui/label"
import { Tabs, TabsContent, TabsList, TabsTrigger } from "@/components/ui/tabs"
import { Package, Loader2, Sparkles, Search, TrendingDown, AlertTriangle } from "lucide-react"
import { ScrollArea } from "@/components/ui/scroll-area"
import { Badge } from "@/components/ui/badge"

interface Product {
  id: number
  product_name: string
  product_code: string
  current_stock: number
  reorder_level: number
  available_stock: number
  reserved_stock?: number
  unit_price: number
}

export function SmartInventoryRecommendations() {
  const [activeTab, setActiveTab] = useState("single")
  const [productId, setProductId] = useState("")
  const [recommendations, setRecommendations] = useState("")
  const [productData, setProductData] = useState<Product | null>(null)
  const [lowStockProducts, setLowStockProducts] = useState<Product[]>([])
  const [isLoading, setIsLoading] = useState(false)
  const [searchResults, setSearchResults] = useState<Product[]>([])
  const [searchQuery, setSearchQuery] = useState("")

  useEffect(() => {
    loadLowStockProducts()
  }, [])

  const loadLowStockProducts = async () => {
    try {
      const response = await fetch("/api/products/low-stock")
      const data = await response.json()
      if (data.success) {
        setLowStockProducts(data.products)
      }
    } catch (error) {
      console.error("[v0] Error loading low stock products:", error)
    }
  }

  const searchProducts = async (query: string) => {
    if (!query || query.length < 2) {
      setSearchResults([])
      return
    }

    try {
      const response = await fetch(`/api/products/search?q=${encodeURIComponent(query)}`)
      const data = await response.json()
      if (data.success) {
        setSearchResults(data.products)
      }
    } catch (error) {
      console.error("[v0] Error searching products:", error)
    }
  }

  const getRecommendations = async (id: string) => {
    if (!id) return

    setIsLoading(true)
    setRecommendations("")
    setProductData(null)

    try {
      const response = await fetch("/api/ai-recommendations/inventory", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ productId: id, analysisType: "reorder" }),
      })

      const result = await response.json()

      if (result.success) {
        setRecommendations(result.recommendations)
        setProductData(result.product)
      } else {
        setRecommendations("فشل في توليد التوصيات. يرجى المحاولة مرة أخرى.")
      }
    } catch (error) {
      console.error("[v0] Error getting recommendations:", error)
      setRecommendations("حدث خطأ أثناء توليد التوصيات.")
    } finally {
      setIsLoading(false)
    }
  }

  const getBulkRecommendations = async () => {
    setIsLoading(true)
    setRecommendations("")

    try {
      const response = await fetch("/api/ai-recommendations/inventory", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ analysisType: "bulk" }),
      })

      const result = await response.json()

      if (result.success) {
        setRecommendations(result.recommendations)
      } else {
        setRecommendations("فشل في توليد التوصيات. يرجى المحاولة مرة أخرى.")
      }
    } catch (error) {
      console.error("[v0] Error getting bulk recommendations:", error)
      setRecommendations("حدث خطأ أثناء توليد التوصيات.")
    } finally {
      setIsLoading(false)
    }
  }

  return (
    <div className="space-y-6" dir="rtl">
      <div>
        <h2 className="text-3xl font-bold">توصيات المخزون الذكية</h2>
        <p className="text-muted-foreground mt-1">توصيات مدعومة بالذكاء الاصطناعي لإدارة المخزون بكفاءة</p>
      </div>

      <Tabs value={activeTab} onValueChange={setActiveTab} className="space-y-6">
        <TabsList className="grid w-full grid-cols-2">
          <TabsTrigger value="single">توصيات منتج واحد</TabsTrigger>
          <TabsTrigger value="bulk">توصيات شاملة</TabsTrigger>
        </TabsList>

        <TabsContent value="single" className="space-y-6">
          <Card>
            <CardHeader>
              <CardTitle>اختر منتج للحصول على توصيات</CardTitle>
              <CardDescription>ابحث عن منتج أو اختر من المنتجات منخفضة المخزون</CardDescription>
            </CardHeader>
            <CardContent className="space-y-4">
              <div className="space-y-2">
                <Label>البحث عن منتج</Label>
                <div className="flex gap-2">
                  <div className="relative flex-1">
                    <Search className="absolute right-3 top-3 h-4 w-4 text-muted-foreground" />
                    <Input
                      placeholder="ابحث بالاسم أو الكود..."
                      value={searchQuery}
                      onChange={(e) => {
                        setSearchQuery(e.target.value)
                        searchProducts(e.target.value)
                      }}
                      className="pr-10"
                    />
                  </div>
                </div>

                {searchResults.length > 0 && (
                  <ScrollArea className="h-[200px] rounded-lg border p-2">
                    <div className="space-y-2">
                      {searchResults.map((product) => (
                        <Button
                          key={product.id}
                          variant="ghost"
                          className="w-full justify-start text-right"
                          onClick={() => {
                            setProductId(product.id.toString())
                            setSearchQuery(product.product_name)
                            setSearchResults([])
                            getRecommendations(product.id.toString())
                          }}
                        >
                          <div className="flex items-center justify-between w-full">
                            <div className="text-right">
                              <div className="font-medium">{product.product_name}</div>
                              <div className="text-sm text-muted-foreground">{product.product_code}</div>
                            </div>
                            <Badge
                              variant={product.current_stock <= product.reorder_level ? "destructive" : "secondary"}
                            >
                              {product.current_stock}
                            </Badge>
                          </div>
                        </Button>
                      ))}
                    </div>
                  </ScrollArea>
                )}
              </div>

              {lowStockProducts.length > 0 && (
                <div className="space-y-2">
                  <Label className="flex items-center gap-2">
                    <AlertTriangle className="h-4 w-4 text-orange-500" />
                    منتجات تحتاج إعادة طلب
                  </Label>
                  <ScrollArea className="h-[200px] rounded-lg border p-2">
                    <div className="space-y-2">
                      {lowStockProducts.map((product) => (
                        <Button
                          key={product.id}
                          variant="ghost"
                          className="w-full justify-start text-right"
                          onClick={() => {
                            setProductId(product.id.toString())
                            setSearchQuery(product.product_name)
                            getRecommendations(product.id.toString())
                          }}
                        >
                          <div className="flex items-center justify-between w-full">
                            <div className="text-right">
                              <div className="font-medium">{product.product_name}</div>
                              <div className="text-sm text-muted-foreground">{product.product_code}</div>
                            </div>
                            <div className="flex items-center gap-2">
                              <Badge variant="destructive">{product.current_stock}</Badge>
                              <TrendingDown className="h-4 w-4 text-red-500" />
                            </div>
                          </div>
                        </Button>
                      ))}
                    </div>
                  </ScrollArea>
                </div>
              )}
            </CardContent>
          </Card>

          {productData && (
            <Card>
              <CardHeader>
                <CardTitle>معلومات المنتج</CardTitle>
              </CardHeader>
              <CardContent>
                <div className="grid gap-4 md:grid-cols-2">
                  <div>
                    <Label className="text-muted-foreground">اسم المنتج</Label>
                    <p className="font-medium">{productData.product_name}</p>
                  </div>
                  <div>
                    <Label className="text-muted-foreground">كود المنتج</Label>
                    <p className="font-medium">{productData.product_code}</p>
                  </div>
                  <div>
                    <Label className="text-muted-foreground">المخزون الحالي</Label>
                    <p className="font-medium">{productData.current_stock}</p>
                  </div>
                  <div>
                    <Label className="text-muted-foreground">مستوى إعادة الطلب</Label>
                    <p className="font-medium">{productData.reorder_level}</p>
                  </div>
                  <div>
                    <Label className="text-muted-foreground">المخزون المتاح</Label>
                    <p className="font-medium">{productData.available_stock}</p>
                  </div>
                  <div>
                    <Label className="text-muted-foreground">سعر الوحدة</Label>
                    <p className="font-medium">{productData.unit_price} ريال</p>
                  </div>
                </div>
              </CardContent>
            </Card>
          )}

          {recommendations && (
            <Card>
              <CardHeader>
                <div className="flex items-center justify-between">
                  <CardTitle>التوصيات الذكية</CardTitle>
                  <Button variant="outline" size="sm" onClick={() => getRecommendations(productId)}>
                    <Sparkles className="h-4 w-4 ml-2" />
                    تحديث
                  </Button>
                </div>
              </CardHeader>
              <CardContent>
                <ScrollArea className="h-[400px] rounded-lg border p-4 bg-muted/30">
                  <div className="prose prose-sm max-w-none whitespace-pre-wrap" dir="rtl">
                    {recommendations}
                  </div>
                </ScrollArea>
              </CardContent>
            </Card>
          )}

          {!recommendations && !isLoading && (
            <Card>
              <CardContent className="py-12">
                <div className="text-center">
                  <Package className="h-12 w-12 mx-auto mb-4 text-muted-foreground" />
                  <p className="text-muted-foreground">اختر منتجاً للحصول على توصيات ذكية</p>
                </div>
              </CardContent>
            </Card>
          )}

          {isLoading && (
            <Card>
              <CardContent className="py-12">
                <div className="text-center">
                  <Loader2 className="h-12 w-12 mx-auto mb-4 animate-spin text-primary" />
                  <p className="text-muted-foreground">جاري توليد التوصيات...</p>
                </div>
              </CardContent>
            </Card>
          )}
        </TabsContent>

        <TabsContent value="bulk" className="space-y-6">
          <Card>
            <CardHeader>
              <div className="flex items-center justify-between">
                <div>
                  <CardTitle>توصيات شاملة للمخزون</CardTitle>
                  <CardDescription>احصل على توصيات لجميع المنتجات التي تحتاج إعادة طلب</CardDescription>
                </div>
                <Button onClick={getBulkRecommendations} disabled={isLoading}>
                  {isLoading ? (
                    <>
                      <Loader2 className="h-4 w-4 ml-2 animate-spin" />
                      جاري التحليل...
                    </>
                  ) : (
                    <>
                      <Sparkles className="h-4 w-4 ml-2" />
                      توليد التوصيات
                    </>
                  )}
                </Button>
              </div>
            </CardHeader>
            <CardContent>
              {lowStockProducts.length > 0 && (
                <div className="mb-4">
                  <Label className="flex items-center gap-2 mb-2">
                    <AlertTriangle className="h-4 w-4 text-orange-500" />
                    المنتجات التي ستتم تغطيتها ({lowStockProducts.length})
                  </Label>
                  <div className="grid gap-2 md:grid-cols-2">
                    {lowStockProducts.slice(0, 6).map((product) => (
                      <div key={product.id} className="flex items-center justify-between p-2 rounded-lg border">
                        <div className="text-right">
                          <div className="font-medium text-sm">{product.product_name}</div>
                          <div className="text-xs text-muted-foreground">{product.product_code}</div>
                        </div>
                        <Badge variant="destructive">{product.current_stock}</Badge>
                      </div>
                    ))}
                  </div>
                  {lowStockProducts.length > 6 && (
                    <p className="text-sm text-muted-foreground mt-2">و {lowStockProducts.length - 6} منتجات أخرى...</p>
                  )}
                </div>
              )}

              {recommendations ? (
                <ScrollArea className="h-[500px] rounded-lg border p-4 bg-muted/30">
                  <div className="prose prose-sm max-w-none whitespace-pre-wrap" dir="rtl">
                    {recommendations}
                  </div>
                </ScrollArea>
              ) : (
                <div className="text-center py-12">
                  <Sparkles className="h-12 w-12 mx-auto mb-4 text-muted-foreground" />
                  <p className="text-muted-foreground">اضغط على "توليد التوصيات" للحصول على تحليل شامل</p>
                </div>
              )}
            </CardContent>
          </Card>
        </TabsContent>
      </Tabs>
    </div>
  )
}
