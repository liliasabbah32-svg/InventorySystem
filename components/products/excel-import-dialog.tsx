"use client"

import type React from "react"

import { useState, useRef, useEffect } from "react"
import { Button } from "@/components/ui/button"
import { Input } from "@/components/ui/input"
import { Label } from "@/components/ui/label"
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card"
import { Dialog, DialogContent, DialogHeader, DialogTitle } from "@/components/ui/dialog"
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from "@/components/ui/table"
import { Alert, AlertDescription } from "@/components/ui/alert"
import { Progress } from "@/components/ui/progress"
import { Badge } from "@/components/ui/badge"
import { Upload, Download, FileSpreadsheet, CheckCircle, AlertCircle, X, Package } from "lucide-react"
import * as XLSX from "xlsx"

interface ExcelProduct {
  product_code: string
  product_name: string
  product_name_en?: string
  description?: string
  status?: string
  category_id: number
  main_stock_id: number
  brand?: string
  model?: string
  manufacturer_company?: string
  measurment_unit: number
  unit_1?: string
  unit_1_barcode?: string
  unit_2?: string
  unit_2_barcode?: string
  unit_2_to_main_qnty?: number
  weight?: number
  length?: number
  width?: number
  height?: number
  density?: number
  color?: string
  size?: string
  notes?: string
  expiry_tracking: boolean
  batch_tracking: boolean
  serial_tracking?: boolean
  store_id: number
  price_1?: number
  price_2?: number
  price_3?: number
  price_4?: number
  price_5?: number
  price_6?: number
  rowIndex?: number
  errors?: string[]
  isValid?: boolean
}

interface ExcelImportDialogProps {
  open: boolean
  onOpenChange: (open: boolean) => void
  onImportComplete: () => void
}

export function ExcelImportDialog({ open, onOpenChange, onImportComplete }: ExcelImportDialogProps) {
  const [file, setFile] = useState<File | null>(null)
  const [products, setProducts] = useState<ExcelProduct[]>([])
  const [isProcessing, setIsProcessing] = useState(false)
  const [isImporting, setIsImporting] = useState(false)
  const [importProgress, setImportProgress] = useState(0)
  const [loading, setLoading] = useState(false);
  const [importResults, setImportResults] = useState<{
    success: number
    failed: number
    errors: string[]
  } | null>(null)
  const [showPreview, setShowPreview] = useState(false)

  const [definitions, setDefinitions] = useState({
    categories: [] as Array<{ id: number; group_name: string }>,
    suppliers: [] as Array<{ id: number; name: string; code?: string }>,
    warehouses: [] as Array<{ id: number; warehouse_name: string }>,
    units: [] as Array<{ id: number; unit_name: string }>,
    currencies: [] as Array<{ id: number; currency_name: string }>,
    price_category: [] as Array<{ id: number; name: string }>,
    product_category: [] as Array<{ id: number; name: string }>,
  })
  const definitionsRef = useRef({
    categories: [] as Array<{ id: number; group_name: string }>,
    suppliers: [] as Array<{ id: number; name: string; code?: string }>,
    warehouses: [] as Array<{ id: number; warehouse_name: string }>,
    units: [] as Array<{ id: number; unit_name: string }>,
    currencies: [] as Array<{ id: number; currency_name: string }>,
    price_category: [] as Array<{ id: number; name: string }>,
    product_category: [] as Array<{ id: number; name: string }>,
  });

  const fetchDefinitions = async () => {
    try {
      const definitionsObj: any = {}

      // Categories
      const categoriesResponse = await fetch("/api/item-groups")
      if (categoriesResponse.ok) {
        const categoriesData = await categoriesResponse.json()
        definitionsObj.categoriesData = categoriesData
        definitionsRef.current.categories = categoriesData
        setDefinitions((prev) => ({ ...prev, categories: categoriesData }))
      }

      // Suppliers
      const suppliersResponse = await fetch("/api/suppliers")
      if (suppliersResponse.ok) {
        const suppliersData = await suppliersResponse.json()
        definitionsObj.suppliersData = suppliersData
        setDefinitions((prev) => ({ ...prev, suppliers: suppliersData }))
      }

      // Warehouses
      const warehousesResponse = await fetch("/api/warehouses")
      if (warehousesResponse.ok) {
        const warehousesData = await warehousesResponse.json()
        definitionsObj.warehousesData = warehousesData
        definitionsRef.current.warehouses = warehousesData
        setDefinitions((prev) => ({ ...prev, warehouses: warehousesData }))
      }

      // Units
      const unitsResponse = await fetch("/api/units")
      if (unitsResponse.ok) {
        const unitsData = await unitsResponse.json()
        definitionsObj.unitsData = unitsData
        definitionsRef.current.units = unitsData
        setDefinitions((prev) => ({ ...prev, units: unitsData }))
      }

      // Currencies
      const currenciesResponse = await fetch("/api/exchange-rates")
      if (currenciesResponse.ok) {
        const currenciesData = await currenciesResponse.json()
        definitionsObj.currenciesData = currenciesData.rates
        definitionsRef.current.currencies = currenciesData.rates
        setDefinitions((prev) => ({ ...prev, currencies: currenciesData.rates }))
      }

      // Price categories
      const pricesResponse = await fetch("/api/pricecategory")
      if (pricesResponse.ok) {
        const pricesData = await pricesResponse.json()
        definitionsObj.pricesData = pricesData
        definitionsRef.current.price_category = pricesData
        setDefinitions((prev) => ({ ...prev, price_category: pricesData }))
      }

      const productCategoryResponse = await fetch("/api/product-categories")
      if (productCategoryResponse.ok) {
        const productCategory = await productCategoryResponse.json()
        definitionsObj.product_category = productCategory
        definitionsRef.current.product_category = productCategory.categories
        setDefinitions((prev) => ({ ...prev, product_category: productCategory.categories }))
      }
      return definitionsObj
    } catch (error) {
      console.error("Error fetching definitions:", error)
      return {}
    }
  }
  useEffect(() => {
    fetchDefinitions()
  }, [])

  const downloadTemplate = () => {
    const templateData = [
      {
        product_code: "A0000001",
        product_name: "منتج تجريبي",
        product_name_en: "Sample Product",
        description: "وصف المنتج التفصيلي",
        category_id: 1,
        main_stock_id: 1,
        brand: "سامسونج",
        model: "Galaxy S24",
        manufacturer_company: "Samsung Electronics",
        measurment_unit: 1,
        unit_1: "حبة",
        unit_1_barcode: "123456",
        unit_2: "كرتونة",
        unit_2_barcode: "111222",
        unit_2_to_main_qnty: 12,
        weight: 0.2,
        length: 15,
        width: 7,
        height: 0.8,
        density: 0,
        color: "أسود",
        size: "متوسط",
        notes: "منتج عالي الجودة مع ضمان شامل",
        expiry_tracking: false,
        batch_tracking: true,
        serial_tracking: false,
        store_id: 1,
        price_1: 100,
        price_2: 200,
        price_3: 300,
        price_4: 400,
        price_5: 500,
        price_6: 600
      },
      {
        product_code: "B0000002",
        product_name: "منتج غذائي",
        product_name_en: "Food Product",
        description: "منتج غذائي طبيعي",
        category_id: 2,
        main_stock_id: 2,
        brand: "الطبيعة",
        model: "",
        manufacturer_company: "مصنع الأغذية الطبيعية",
        measurment_unit: 1,
        unit_1: "حبة",
        unit_1_barcode: "123456",
        unit_2: "كرتونة",
        unit_2_barcode: "111222",
        unit_2_to_main_qnty: 12,
        weight: 0.4,
        length: 10,
        width: 10,
        height: 5,
        density: 0,
        color: "",
        size: "400 جرام",
        notes: "يحفظ في مكان بارد وجاف",
        expiry_tracking: true,
        batch_tracking: true,
        serial_tracking: false,
        store_id: 1,
        price_1: 100,
        price_2: 200,
        price_3: 300,
        price_4: 400,
        price_5: 500,
        price_6: 600
      }
    ];

    const ws = XLSX.utils.json_to_sheet(templateData);
    const colWidths = [
      { wch: 12 }, // product_code
      { wch: 25 }, // product_name
      { wch: 25 }, // product_name_en
      { wch: 30 }, // description
      { wch: 12 }, // category_id
      { wch: 12 }, // main_stock_id
      { wch: 15 }, // brand
      { wch: 15 }, // model
      { wch: 20 }, // manufacturer_company
      { wch: 12 }, // measurment_unit
      { wch: 15 }, // unit_1
      { wch: 15 }, // unit_1_barcode
      { wch: 15 }, // unit_2
      { wch: 15 }, // unit_2_barcode
      { wch: 15 }, // unit_2_to_main_qnty
      { wch: 10 }, // weight
      { wch: 10 }, // length
      { wch: 10 }, // width
      { wch: 10 }, // height
      { wch: 10 }, // density
      { wch: 10 }, // color
      { wch: 10 }, // size
      { wch: 30 }, // notes
      { wch: 12 }, // expiry_tracking
      { wch: 12 }, // batch_tracking
      { wch: 12 }, // serial_tracking
      { wch: 12 }, // store_id
      { wch: 10 }, // price_1
      { wch: 10 }, // price_2
      { wch: 10 }, // price_3
      { wch: 10 }, // price_4
      { wch: 10 }, // price_5
      { wch: 10 }  // price_6
    ];
    ws["!cols"] = colWidths;

    const wb = XLSX.utils.book_new();
    XLSX.utils.book_append_sheet(wb, ws, "Products Template");

    try {
      const wbout = XLSX.write(wb, { bookType: "xlsx", type: "array" });
      const blob = new Blob([wbout], { type: "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet" });
      const url = URL.createObjectURL(blob);
      const a = document.createElement("a");
      a.href = url;
      a.download = "products_import_template.xlsx";
      document.body.appendChild(a);
      a.click();
      document.body.removeChild(a);
      URL.revokeObjectURL(url);
    } catch (error) {
      console.error("Error downloading template:", error);
      alert("حدث خطأ في تحميل القالب. يرجى المحاولة مرة أخرى.");
    }
  };



  const handleFileChange = (event: React.ChangeEvent<HTMLInputElement>) => {
    const selectedFile = event.target.files?.[0]
    if (selectedFile) {
      setFile(selectedFile)
      processExcelFile(selectedFile)
    }
  }

  const processExcelFile = async (file: File) => {
    setIsProcessing(true);
    try {
      const data = await file.arrayBuffer();
      const workbook = XLSX.read(data, { type: "array" });
      const sheetName = workbook.SheetNames[0];
      const worksheet = workbook.Sheets[sheetName];
      const jsonData = XLSX.utils.sheet_to_json(worksheet) as any[];

      const processedProducts: ExcelProduct[] = jsonData.map((row, index) => {
        const product: ExcelProduct = {
          product_code: row.product_code || "",
          product_name: row.product_name || "",
          product_name_en: row.product_name_en || "",
          description: row.description || "",
          category_id: Number(row.category_id) || 0,
          main_stock_id: Number(row.main_stock_id) || 0,
          brand: row.brand || "",
          model: row.model || "",
          manufacturer_company: row.manufacturer_company || "",
          measurment_unit: row.measurment_unit || 1,
          unit_1: row.unit_1 || "",
          unit_1_barcode: row.unit_1_barcode || "",
          unit_2: row.unit_2 || "",
          unit_2_barcode: row.unit_2_barcode || "",
          unit_2_to_main_qnty: Number(row.unit_2_to_main_qnty) || 1,
          weight: Number(row.weight) || 0,
          length: Number(row.length) || 0,
          width: Number(row.width) || 0,
          height: Number(row.height) || 0,
          density: Number(row.density) || 0,
          color: row.color || "",
          size: row.size || "",
          notes: row.notes || "",
          expiry_tracking: Boolean(row.expiry_tracking),
          batch_tracking: Boolean(row.batch_tracking),
          serial_tracking: Boolean(row.serial_tracking),
          store_id: Number(row.store_id) || 0,
          price_1: Number(row.price_1) || 0,
          price_2: Number(row.price_2) || 0,
          price_3: Number(row.price_3) || 0,
          price_4: Number(row.price_4) || 0,
          price_5: Number(row.price_5) || 0,
          price_6: Number(row.price_6) || 0,
          rowIndex: index + 2,
          errors: [],
        };

        const errors: string[] = [];
        if (!product.product_code.trim()) errors.push("رقم الصنف مطلوب");
        if (!product.product_name.trim()) errors.push("اسم الصنف مطلوب");
        if (product.store_id > 0) {
          const warehouseExists = definitionsRef.current.warehouses.some(w => w.id === product.store_id)
          if (!warehouseExists) errors.push(`المستودع (store_id: ${product.store_id}) غير موجود في النظام`)
        }
        if (product.category_id > 0) {
          const categoryExists = definitionsRef.current.product_category.some(w => w.id === product.category_id)
          if (!categoryExists) errors.push(`التصنيف (category_id: ${product.category_id}) غير موجود في النظام`)
        }
        if (product.main_stock_id > 0) {
          const mainExists = definitionsRef.current.categories.some(w => w.id === product.main_stock_id)
          if (!mainExists) errors.push(`مجموعة الصنف (main_stock_id: ${product.main_stock_id}) غير موجود في النظام`)
        }
        for (let i = 1; i <= 6; i++) {
          const priceValue = Number(product[`price_${i}` as keyof typeof product]);

          if (priceValue > 0) {
            const priceCategory = definitionsRef.current.price_category.length > i - 1;

            if (!priceCategory) {
              errors.push(`فئة السعر رقم ${i} غير موجودة في النظام`);
            }
          }
        }

        //if (!product.category_id) errors.push("الفئة مطلوبة");
        //if (product.price_1 <= 0) errors.push("السعر الأساسي يجب أن يكون أكبر من صفر");
        //if (product.expiry_tracking && !row.expiry_date) errors.push("تاريخ الانتهاء مطلوب عند تفعيل تتبع الصلاحية");
        //if (product.batch_tracking && product.unit_2_to_main_qnty > 0 && !product.unit_2) errors.push("الوحدة الثانوية مطلوبة عند تفعيل تتبع الدفعات");

        product.errors = errors;
        product.isValid = errors.length === 0;

        return product;
      });

      setProducts(processedProducts);
      setShowPreview(true);
    } catch (error) {
      console.error("Error processing Excel file:", error);
      alert("حدث خطأ في معالجة ملف Excel. تأكد من أن الملف يحتوي على البيانات الصحيحة.");
    } finally {
      setIsProcessing(false);
    }
  };

  const importProducts = async () => {
    const validProducts = products.filter(p => p.isValid);
    if (validProducts.length === 0) {
      alert("لا توجد منتجات صالحة للاستيراد");
      return;
    }

    setIsImporting(true);
    setImportProgress(0);
    const results = { success: 0, failed: 0, errors: [] as string[] };

    for (let i = 0; i < validProducts.length; i++) {
      const product = validProducts[i];

      try {
        // Map units
        const units = [];

        if (product.unit_1) {
          const mainUnitDef = definitionsRef.current.units.find(u => u.unit_name === product.unit_1);
          if (mainUnitDef) {
            units.push({
              unit_id: mainUnitDef.id,
              to_main_qnty: 1,
              barcode_list: product.unit_1_barcode ? [product.unit_1_barcode] : [],
            });
          }
        }

        if (product.unit_2) {
          const secUnitDef = definitionsRef.current.units.find(u => u.unit_name === product.unit_2);
          if (secUnitDef) {
            units.push({
              unit_id: secUnitDef.id,
              to_main_qnty: product.unit_2_to_main_qnty || 1,
              barcode_list: product.unit_2_barcode ? [product.unit_2_barcode] : [],
            });
          }
        }


        // Map stores
        const stores = product.store_id ? [{
          store_id: product.store_id,
          shelf: "",
          reorder_quantity: 0,
          max_quantity: 0,
          min_quantity: 0,
        }] : [];

        // Map prices
        const prices: { price_category_id: number; unit_id: number; price: number; currency_id: number }[] = [];

        for (let i = 1; i <= 6; i++) {
          const rawValue = product[`price_${i}` as keyof typeof product];

          // convert to number safely
          const priceValue = Number(rawValue);

          if (!isNaN(priceValue) && priceValue > 0) {
            const priceCategory = definitionsRef.current.price_category.find(pc => pc.id === i);
            const mainUnit = definitionsRef.current.units.find(u => u.unit_name === product.unit_1);

            if (priceCategory && mainUnit) {
              prices.push({
                price_category_id: priceCategory.id,
                unit_id: mainUnit.id,
                price: priceValue,
                currency_id: 1, // or from definitionsRef if needed
              });
            }
          }
        }



        const bodyData = {
          product_code: product.product_code,
          product_name: product.product_name,
          product_name_en: product.product_name_en,
          description: product.description,
          category_id: product.category_id || null,
          main_stock_id: product.main_stock_id || null,
          brand: product.brand,
          model: product.model,
          factory_number: "",
          original_number: "",
          measurment_unit: 1,
          last_purchase_price: 0,
          currency_id: 1, // set default currency id
          tax_rate: 16,
          discount_rate: 0,
          expiry_tracking: product.expiry_tracking,
          batch_tracking: product.batch_tracking,
          serial_tracking: product.serial_tracking,
          status: 1,
          length: product.length,
          width: product.width,
          height: product.height,
          density: product.weight,
          color: product.color,
          size: product.size,
          notes: product.notes,
          manufacturer_company: product.manufacturer_company,
          units,
          stores,
          prices,
        };

        const response = await fetch("/api/inventory/products", {
          method: "POST",
          headers: { "Content-Type": "application/json" },
          body: JSON.stringify(bodyData),
        });

        if (!response.ok) {
          const error = await response.json();
          results.errors.push(`الصنف ${product.product_code}: ${error.message || "خطأ في حفظ الصنف"}`);
          results.failed++;
          setImportProgress(((i + 1) / validProducts.length) * 100);
          continue;
        }

        const createdProduct = await response.json();

        results.success++;
      } catch (error) {
        results.errors.push(`الصنف ${product.product_code}: خطأ غير متوقع`);
        results.failed++;
      }

      setImportProgress(((i + 1) / validProducts.length) * 100);
    }

    setImportResults(results);
    setIsImporting(false);

    //if (results.success > 0) onImportComplete();
  };


  const resetDialog = () => {
    setFile(null)
    setProducts([])
    setShowPreview(false)
    setImportResults(null)
    setImportProgress(0)
  }

  const validProductsCount = products.filter((p) => p.isValid).length
  const invalidProductsCount = products.length - validProductsCount

  return (
    <Dialog
      open={open}
      onOpenChange={(open) => {
        onOpenChange(open)
        if (!open) resetDialog()
      }}
    modal
    >
      <DialogContent className="max-w-6xl max-h-[90vh] overflow-auto" dir="rtl" onPointerDownOutside={(event) => event.preventDefault()}>
        {/* Hide default close button */}
        <style>
          {`
      [data-radix-dialog-overlay] [aria-label="Close"] {
        display: none;
      }
    `}
        </style>
        <DialogHeader>
          <DialogTitle className="flex items-center gap-2">
            <FileSpreadsheet className="h-5 w-5" />
            استيراد الأصناف من Excel
          </DialogTitle>
        </DialogHeader>

        <div className="space-y-6">
          {!showPreview && !importResults && (
            <>
              <Card>
                <CardHeader>
                  <CardTitle className="text-lg">رفع ملف Excel</CardTitle>
                </CardHeader>
                <CardContent className="space-y-4">
                  <div className="flex items-center gap-4">
                    <Button
                      variant="outline"
                      onClick={downloadTemplate}
                      className="flex items-center gap-2 bg-transparent"
                    >
                      <Download className="h-4 w-4" />
                      تحميل القالب
                    </Button>
                    <span className="text-sm text-muted-foreground">
                      قم بتحميل القالب أولاً لمعرفة تنسيق البيانات المطلوب
                    </span>
                  </div>

                  <div>
                    <Label htmlFor="excel-file">اختر ملف Excel</Label>
                    <Input
                      id="excel-file"
                      type="file"
                      accept=".xlsx,.xls"
                      onChange={handleFileChange}
                      disabled={isProcessing}
                    />
                  </div>

                  {isProcessing && (
                    <div className="flex items-center gap-2">
                      <div className="animate-spin rounded-full h-4 w-4 border-b-2 border-primary"></div>
                      <span className="text-sm">جاري معالجة الملف...</span>
                    </div>
                  )}
                </CardContent>
              </Card>

              <Alert>
                <Package className="h-4 w-4" />
                <AlertDescription>
                  <strong>تعليمات الاستيراد:</strong>
                  <ul className="list-disc list-inside mt-2 space-y-1 text-sm">
                    <li>قم بتحميل القالب الذي يحتوي على جميع حقول الصنف (أكثر من 40 حقل)</li>
                    <li>املأ البيانات الأساسية: كود الصنف الاسم، الفئة، وسعر الشراء (مطلوبة)</li>
                    <li>يمكن ملء الحقول الاختيارية مثل: الأسعار المختلفة، المقاسات، الألوان، والمواصفات</li>

                    <li>جميع الحقول المالية والكميات يجب أن تكون أرقام صحيحة</li>
                  </ul>
                </AlertDescription>
              </Alert>
            </>
          )}

          {showPreview && !importResults && (
            <div className="flex flex-col gap-4 ">
              {/* Header */}
              <div className="flex items-center justify-between">
                <div className="flex items-center gap-4">
                  <h3 className="text-lg font-semibold">معاينة البيانات</h3>
                  <div className="flex gap-2">
                    <Badge variant="secondary" className="bg-green-100 text-green-800">
                      صحيح: {validProductsCount}
                    </Badge>
                    {invalidProductsCount > 0 && (
                      <Badge variant="destructive">غير صحيح: {invalidProductsCount}</Badge>
                    )}
                  </div>

                  <Button variant="outline" disabled={isImporting} onClick={resetDialog}>
                    <X className="h-4 w-4 mr-2" /> إلغاء
                  </Button>
                  <Button
                    onClick={importProducts}
                    disabled={validProductsCount === 0 || isImporting}
                    className="bg-primary hover:bg-primary/90"
                  >
                    <Upload className="h-4 w-4 mr-2" />
                    استيراد ({validProductsCount}) صنف
                  </Button>
                </div>
              </div>

              {/* Scrollable wrapper */}
              <div
                className="border rounded-lg overflow-auto max-h-[520px]"
                dir="rtl"
                style={{ direction: "rtl" }}
              >
                <table className="table-fixed border-collapse w-max min-w-full text-sm whitespace-nowrap overflow-auto">
                  <thead className="bg-gray-100 sticky top-0 z-10 ">
                    <tr>
                      {[
                        { label: "#", w: 60 },
                        { label: "رقم الصنف", w: 140 },
                        { label: "اسم الصنف", w: 200 },
                        { label: "اسم الصنف إنجليزي", w: 200 },
                        { label: "الوصف", w: 250 },
                        { label: "التصنيف", w: 130 },
                        { label: "المخزون الرئيسي", w: 150 },
                        { label: "العلامة التجارية", w: 150 },
                        { label: "الموديل", w: 120 },
                        { label: "الشركة المصنعة", w: 180 },
                        { label: "الوحدة 1", w: 120 },
                        { label: "باركود الوحدة 1", w: 150 },
                        { label: "الوحدة 2", w: 120 },
                        { label: "باركود الوحدة 2", w: 150 },
                        { label: "معامل تحويل 2", w: 120 },
                        { label: "الوزن", w: 100 },
                        { label: "الطول", w: 100 },
                        { label: "العرض", w: 100 },
                        { label: "الارتفاع", w: 100 },
                        { label: "اللون", w: 120 },
                        { label: "المقاس", w: 120 },
                        { label: "له صلاحية", w: 100 },
                        { label: "له تشغيله", w: 100 },
                        { label: "له سيريال", w: 100 },
                        { label: "المستودع", w: 150 },
                        { label: "ملاحظات", w: 200 },
                        { label: "السعر 1", w: 120 },
                        { label: "السعر 2", w: 120 },
                        { label: "السعر 3", w: 120 },
                        { label: "السعر 4", w: 120 },
                        { label: "السعر 5", w: 120 },
                        { label: "السعر 6", w: 120 },
                        { label: "الأخطاء", w: 240 },
                      ].map((col, i) => (
                        <th
                          key={i}
                          className="border px-2 py-1 text-right"
                          style={{ minWidth: col.w, maxWidth: col.w }}
                        >
                          {col.label}
                        </th>
                      ))}
                    </tr>
                  </thead>

                  <tbody>
                    {products.map((product, index) => (
                      <tr key={index} className={product.isValid ? "" : "bg-red-50"}>
                        <td className="border px-2 py-1" style={{ minWidth: 60 }}>{index + 1}</td>
                        <td className="border px-2 py-1">{product.product_code}</td>
                        <td className="border px-2 py-1">{product.product_name}</td>
                        <td className="border px-2 py-1">{product.product_name_en}</td>
                        <td className="border px-2 py-1">{product.description}</td>
                        <td className="border px-2 py-1">{product.category_id}</td>
                        <td className="border px-2 py-1">{product.main_stock_id}</td>
                        <td className="border px-2 py-1">{product.brand}</td>
                        <td className="border px-2 py-1">{product.model}</td>
                        <td className="border px-2 py-1">{product.manufacturer_company}</td>
                        <td className="border px-2 py-1">{product.unit_1}</td>
                        <td className="border px-2 py-1">{product.unit_1_barcode}</td>
                        <td className="border px-2 py-1">{product.unit_2}</td>
                        <td className="border px-2 py-1">{product.unit_2_barcode}</td>
                        <td className="border px-2 py-1">{product.unit_2_to_main_qnty}</td>
                        <td className="border px-2 py-1">{product.weight}</td>
                        <td className="border px-2 py-1">{product.length}</td>
                        <td className="border px-2 py-1">{product.width}</td>
                        <td className="border px-2 py-1">{product.height}</td>
                        <td className="border px-2 py-1">{product.color}</td>
                        <td className="border px-2 py-1">{product.size}</td>
                        <td className="border px-2 py-1">{product.expiry_tracking ? "نعم" : "لا"}</td>
                        <td className="border px-2 py-1">{product.batch_tracking ? "نعم" : "لا"}</td>
                        <td className="border px-2 py-1">{product.serial_tracking ? "نعم" : "لا"}</td>
                        <td className="border px-2 py-1">
                          {product.store_id &&
                            definitionsRef.current.warehouses
                            ? definitionsRef.current.warehouses.find((w) => w.id === product.store_id)
                              ?.warehouse_name || "غير محدد"
                            : "غير محدد"}
                        </td>
                        <td className="border px-2 py-1">{product.notes}</td>

                        <td className="border px-2 py-1">{product.price_1}</td>
                        <td className="border px-2 py-1">{product.price_2}</td>
                        <td className="border px-2 py-1">{product.price_3}</td>
                        <td className="border px-2 py-1">{product.price_4}</td>
                        <td className="border px-2 py-1">{product.price_5}</td>
                        <td className="border px-2 py-1">{product.price_6}</td>

                        <td className="border px-2 py-1">
                          {product.errors?.length ? (
                            <div className="text-xs text-red-600">{product.errors.join(", ")}</div>
                          ) : null}
                        </td>
                      </tr>
                    ))}
                  </tbody>
                </table>
              </div>
            </div>

          )}


          {isImporting && (
            <div className="space-y-2">
              <div className="flex justify-between text-sm flex-row w-full" dir="rtl">
                <span>جاري الاستيراد...
                {Math.round(importProgress)}%</span>
              </div>
              <div className="w-full">
                <Progress value={importProgress} className="w-full" />
              </div>
            </div>
          )}


          {importResults && (
            <>
              <Card>
                <CardHeader>
                  <CardTitle className="text-lg">نتائج الاستيراد</CardTitle>
                </CardHeader>
                <CardContent className="space-y-4">
                  <div className="grid grid-cols-2 gap-4">
                    <div className="text-center p-4 bg-green-50 rounded-lg">
                      <div className="text-2xl font-bold text-green-600">{importResults.success}</div>
                      <div className="text-sm text-green-700">تم استيرادها بنجاح</div>
                    </div>
                    <div className="text-center p-4 bg-red-50 rounded-lg">
                      <div className="text-2xl font-bold text-red-600">{importResults.failed}</div>
                      <div className="text-sm text-red-700">فشل في الاستيراد</div>
                    </div>
                  </div>

                  {importResults.errors.length > 0 && (
                    <div>
                      <h4 className="font-semibold mb-2">الأخطاء:</h4>
                      <div className="max-h-32 overflow-auto space-y-1">
                        {importResults.errors.map((error, index) => (
                          <div key={index} className="text-sm text-red-600 bg-red-50 p-2 rounded">
                            {error}
                          </div>
                        ))}
                      </div>
                    </div>
                  )}

                  <div className="flex justify-end gap-2">
                    <Button variant="outline" onClick={resetDialog}>
                      استيراد ملف آخر
                    </Button>
                    <Button onClick={() => onOpenChange(false)}>إغلاق</Button>
                  </div>
                </CardContent>
              </Card>
            </>
          )}
        </div>
      </DialogContent>
    </Dialog>
  )
}
