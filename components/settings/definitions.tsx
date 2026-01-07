"use client"

import type React from "react"

import { useState, useEffect } from "react"
import { Button } from "@/components/ui/button"
import { Input } from "@/components/ui/input"
import { Label } from "@/components/ui/label"
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select"
import { Tabs, TabsContent, TabsList, TabsTrigger } from "@/components/ui/tabs"
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card"
import { Badge } from "@/components/ui/badge"
import { Plus, Edit, Building, MapPin, Package, Users, CreditCard, Settings } from "lucide-react"
import { UniversalToolbar } from "@/components/ui/universal-toolbar"
import { WorkflowStagesManagement } from "@/components/workflow/workflow-stages-management"
import { WorkflowSequencesManagement } from "@/components/workflow/workflow-sequences-management"
import { cn } from "@/lib/utils"
import { useToast } from "@/hooks/use-toast"
import salesmen from "../salesmen/Salesmen"
import Salesmen from "../salesmen/Salesmen"

interface City {
  id: number
  name: string
}

interface Warehouse {
  id: number
  warehouse_code: string
  warehouse_name: string
  warehouse_name_en?: string
  location?: string
  is_active: boolean
}

interface Branch {
  id: number
  branch_code: string
  branch_name: string
  address?: string
  manager?: string
  phone?: string
  is_active: boolean
}

interface Department {
  id: number
  department_code: string
  department_name: string
  branch_id?: number
  branch_name?: string
  manager?: string
  employee_count: number
  is_active: boolean
}

interface Currency {
  id: number
  currency_code: string
  currency_name: string
  sell_rate: number
  buy_rate: number
  exchange_rate: number
}
interface Customer_Categories {
  id: number
  name: string
  discount: number
}
interface Supplier_Categories {
  id: number
  name: string
  paymentterms: string
}
interface Product_Categories {
  id: number
  name: string
}
interface Unit {
  id: number
  unit_name: string,
  unit_name_e: string,
  description: string,
  is_active: boolean
}

interface Price {
  id: number
  name: string,
  name_en: string,
  description: string,
  is_active: boolean
}

const cities_initial = [
  { id: 1, name: "نابلس" },
  { id: 2, name: "رام الله" },
  { id: 3, name: "الخليل" },
  { id: 4, name: "بيت لحم" },
  { id: 5, name: "جنين" },
]

const warehouses_initial = [
  {
    id: 1,
    warehouse_code: "W001",
    warehouse_name: "المستودع الرئيسي",
    warehouse_name_en: "Main Warehouse",
    location: "نابلس",
    is_active: true,
  },
  {
    id: 2,
    warehouse_code: "W002",
    warehouse_name: "مستودع الفرع الثاني",
    warehouse_name_en: "Branch 2 Warehouse",
    location: "رام الله",
    is_active: true,
  },
]

const customerCategories_initial = [
  { id: 1, name: "زبائن VIP", discount: 15 },
  { id: 2, name: "زبائن عاديين", discount: 5 },
  { id: 3, name: "زبائن الجملة", discount: 20 },
]
const colors = ["#10B981", "#6B7280", "#3B82F6", "#F59E0B", "#EF4444"];
const supplierCategories_initial = [
  {
    id: 1,
    name: "موردين محليين",
    paymentterms: "30 يوم",

  },
  {
    id: 2,
    name: "موردين دوليين",
    paymentterms: "60 يوم",

  },
  { id: 3, name: "موردين استراتيجيين", paymentterms: "45 يوم" },
]

const productCategories_initial = [
  { id: 1, name: "إلكترونيات" },
  { id: 2, name: "ملابس" },
  { id: 3, name: "أجهزة منزلية" },
]

const currencies_initial = [
  { id: 1, currency_code: "USD", currency_name: "دولار أمريكي", sell_rate: 3.65, buy_rate: 3.6, exchange_rate: 3.62 },
  { id: 2, currency_code: "EUR", currency_name: "يورو", sell_rate: 4.1, buy_rate: 4.05, exchange_rate: 4.07 },
  { id: 3, currency_code: "JOD", currency_name: "دينار أردني", sell_rate: 5.15, buy_rate: 5.1, exchange_rate: 5.12 },
  { id: 4, currency_code: "ILS", currency_name: "شيكل إسرائيلي", sell_rate: 1.0, buy_rate: 1.0, exchange_rate: 1.0 },
]




function Definitions() {
  const [cities, setCities] = useState<City[]>([])
  const [warehouses, setWarehouses] = useState<Warehouse[]>([])
  const [customercategories, setCustomerCategories] = useState<Customer_Categories[]>([])
  const [suppliercategories, setSupplierCategories] = useState<Supplier_Categories[]>([])
  const [productcategories, setProductCategories] = useState<Product_Categories[]>([])
  const [branches, setBranches] = useState<Branch[]>([])
  const [departments, setDepartments] = useState<Department[]>([])
  const [currencies, setCurrencies] = useState<Currency[]>([])
  const [loading, setLoading] = useState(false)
  const [editingBranchId, setEditingBranchId] = useState<number | null>(null);
  const [showCityForm, setShowCityForm] = useState(false)
  const [showWarehouseForm, setShowWarehouseForm] = useState(false)
  const [showCurrencyForm, setShowCurrencyForm] = useState(false)
  const [showBranchForm, setShowBranchForm] = useState(false)
  const [showDepartmentForm, setShowDepartmentForm] = useState(false)
  const [showCustomerCategoryForm, setShowCustomerCategoryForm] = useState(false)
  const [showSupplierCategoryForm, setShowSupplierCategoryForm] = useState(false)
  const [showProductCategoryForm, setShowProductCategoryForm] = useState(false)
  const [currentBranchIndex, setCurrentBranchIndex] = useState(0)
  const [currentDepartmentIndex, setCurrentDepartmentIndex] = useState(0)
  const [currentCityIndex, setCurrentCityIndex] = useState(0)
  const [currentWarehouseIndex, setCurrentWarehouseIndex] = useState(0)

  const [cityForm, setCityForm] = useState({ id: 0, name: "" })
  const [warehouseForm, setWarehouseForm] = useState({
    id: 0,
    warehouse_code: "",
    warehouse_name: "",
    location: "",
  })
  const [customercategoryForm, setCustomercategoryForm] = useState({
    name: "",
    discount: 0
  })
  const [suppliercategoryForm, setSuppliercategoryForm] = useState({
    name: "",
    paymentterms: ""
  })
  const [productcategoryForm, setProductcategoryForm] = useState({
    name: "",
  })
  const [branchForm, setBranchForm] = useState({
    id: 0,
    branch_code: "",
    branch_name: "",
    address: "",
    manager: "",
    phone: "",
  })
  const [departmentForm, setDepartmentForm] = useState({
    id: 0,
    department_code: "",
    department_name: "",
    branch_id: "",
    manager: "",
  })
  const [currencyForm, setCurrencyForm] = useState({
    currency_code: "",
    currency_name: "",
    currency_symbol: "",
    buy_rate: "1",
    sell_rate: "1",
    exchange_rate: "1",
  })
  const [units, setUnits] = useState<Unit[]>([])
  const [prices, setPrices] = useState<Price[]>([])
  const [priceForm, setPriceForm] = useState({ name: "", name_en: "", description: "" })
  const [unitForm, setUnitForm] = useState({ unit_name: "", unit_name_e: "", description: "" })
  const [showUnitForm, setShowUnitForm] = useState(false)
  const [showPriceForm, setShowPriceForm] = useState(false)
  const [currentUnitIndex, setCurrentUnitIndex] = useState(0)
  const [currentPriceIndex, setCurrentPriceIndex] = useState(0)
  const [editingUnitId, setEditingUnitId] = useState<number | null>(null)
  const [editingPriceId, setEditingPriceId] = useState<number | null>(null)
  const { toast } = useToast()

  useEffect(() => {
    fetchAllData()
  }, [])

  const fetchAllData = async () => {
    setLoading(true)
    try {
      await Promise.all([fetchCities(), fetchWarehouses(), fetchBranches(), fetchDepartments(), fetchCurrencies(), fetchCustomerCategories(),
      fetchsupplierCategories(), fetchUnits(), fetchProductCategories(), fetchPrices()])
    } catch (error) {
      console.error("Error fetching data:", error)
    } finally {
      setLoading(false)
    }
  }

  const fetchCities = async () => {
    try {
      const response = await fetch("/api/cities")
      if (response.ok) {
        const data = await response.json()
        setCities(data)
      } else {
        // Fallback to initial data if API fails
        setCities(cities_initial)
      }
    } catch (error) {
      console.error("Error fetching cities:", error)
      // Fallback to initial data if API fails
      setCities(cities_initial)
    }
  }

  const fetchWarehouses = async () => {
    try {
      const response = await fetch("/api/warehouses")
      if (response.ok) {
        const data = await response.json()
        setWarehouses(data)
      } else {
        setWarehouses(warehouses_initial)
      }
    } catch (error) {
      console.error("Error fetching warehouses:", error)
      setWarehouses(warehouses_initial)
    }
  }
  const fetchUnits = async () => {
    try {
      const response = await fetch("/api/units")
      if (response.ok) {
        const data = await response.json()
        console.log("data ", data)
        setUnits(data)
      } else {
        setUnits([])
      }
    } catch (error) {
      console.error("Error fetching units:", error)
      setUnits([])
    }
  }
  const fetchPrices = async () => {
    try {
      const response = await fetch("/api/pricecategory")
      if (response.ok) {
        const data = await response.json()
        console.log("data ", data)
        setPrices(data)
      } else {
        setPrices([])
      }
    } catch (error) {
      console.error("Error fetching price categories:", error)
      setPrices([])
    }
  }
  const fetchCustomerCategories = async () => {
    try {
      const response = await fetch("/api/customer-categories")
      if (response.ok) {
        const data = await response.json()
        console.log("datadatadatadatadatadata data ", data)
        setCustomerCategories(data.categories)
      } else {
        setCustomerCategories(customerCategories_initial)
      }
    } catch (error) {
      console.error("Error fetching customer categories:", error)
      setCustomerCategories(customerCategories_initial)
    }
  }
  const fetchsupplierCategories = async () => {
    try {
      const response = await fetch("/api/supplier-categories")
      if (response.ok) {
        const data = await response.json()
        console.log("TTTTTTTTT ", data)
        setSupplierCategories(data.categories)
      } else {
        setSupplierCategories(supplierCategories_initial)
      }
    } catch (error) {
      console.error("Error fetching supplier categories:", error)
      setSupplierCategories(supplierCategories_initial)
    }
  }

  const fetchProductCategories = async () => {
    try {
      const response = await fetch("/api/product-categories")
      if (response.ok) {
        const data = await response.json()
        setProductCategories(data.categories)
      } else {
        setProductCategories(productCategories_initial)
      }
    } catch (error) {
      console.error("Error fetching product categories:", error)
      setProductCategories(productCategories_initial)
    }
  }
  const fetchBranches = async () => {
    try {
      const response = await fetch("/api/branches")
      if (response.ok) {
        const data = await response.json()
        setBranches(data)
      } else {
        setBranches([])
      }
    } catch (error) {
      console.error("Error fetching branches:", error)
      setBranches([])
    }
  }

  const fetchDepartments = async () => {
    try {
      const response = await fetch("/api/departments")
      if (response.ok) {
        const data = await response.json()
        setDepartments(data)
      } else {
        setDepartments([])
      }
    } catch (error) {
      console.error("Error fetching departments:", error)
      setDepartments([])
    }
  }

  const fetchCurrencies = async () => {
    try {
      const response = await fetch("/api/exchange-rates")
      if (response.ok) {
        const data = await response.json()
        console.log("data ", data)
        setCurrencies(data?.rates || [])
      } else {
        setCurrencies(currencies_initial)
      }
    } catch (error) {
      console.error("Error fetching currencies:", error)
      setCurrencies(currencies_initial)
    }
  }

  const handleAddCity = async (e: React.FormEvent) => {
    e.preventDefault();

    if (!cityForm.name.trim()) {
      toast({
        title: "خطأ",
        description: "يرجى إدخال اسم المدينة",
        variant: "destructive",
      });
      return;
    }

    try {
      const isEditing = cityForm.id > 0;
      const url = isEditing ? `/api/cities/${cityForm.id}` : "/api/cities";
      const method = isEditing ? "PUT" : "POST";

      const response = await fetch(url, {
        method,
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify(cityForm),
      });

      if (response.ok) {
        toast({
          title: "تم الحفظ بنجاح",
          description: isEditing ? "تم تعديل المدينة بنجاح" : "تم إضافة المدينة بنجاح",
        });
        await fetchCities(); // refresh list
        setCityForm({ id: 0, name: "" });
        setShowCityForm(false);
      } else {
        const error = await response.json();
        toast({
          title: "فشل الحفظ",
          description: error.error || "حدث خطأ أثناء حفظ المدينة",
          variant: "destructive",
        });
      }
    } catch (error) {
      console.error("Error saving city:", error);
      toast({
        title: "خطأ في الاتصال",
        description: "تعذر الاتصال بالخادم، يرجى المحاولة مرة أخرى",
        variant: "destructive",
      });
    }
  };

  const handleAddCurrency = async (e: React.FormEvent) => {
    e.preventDefault()

    if (!currencyForm.currency_code.trim() || !currencyForm.currency_name.trim()) {
      toast({
        title: "خطأ",
        description: "يرجى إدخال رمز واسم العملة",
        variant: "destructive",
      })
      return
    }

    try {
      const response = await fetch("/api/exchange-rates", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify(currencyForm),
      })

      if (response.ok) {
        toast({
          title: "تم الحفظ بنجاح",
          description: "تم إضافة العملة بنجاح",
        })
        await fetchCurrencies()
        setCurrencyForm({ currency_symbol: "", currency_code: "", currency_name: "", buy_rate: "", sell_rate: "", exchange_rate: "" })
        setShowCurrencyForm(false)
      } else {
        const error = await response.json()
        toast({
          title: "فشل الحفظ",
          description: error.error || "حدث خطأ أثناء حفظ العملة",
          variant: "destructive",
        })
      }
    } catch (error) {
      console.error("Error adding warehouse:", error)
      toast({
        title: "خطأ في الاتصال",
        description: "تعذر الاتصال بالخادم، يرجى المحاولة مرة أخرى",
        variant: "destructive",
      })
    }
  }

  const handleAddCustomerCategories = async (e: React.FormEvent) => {
    e.preventDefault()

    if (!customercategoryForm.name.trim()) {
      toast({
        title: "خطأ",
        description: "يرجى إدخال اسم التصنيف",
        variant: "destructive",
      })
      return
    }

    try {
      const response = await fetch("/api/customer-categories", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify(customercategoryForm),
      })

      if (response.ok) {
        toast({
          title: "تم الحفظ بنجاح",
          description: "تم إضافة التصنيف بنجاح",
        })
        await fetchCustomerCategories()
        setCustomercategoryForm({ name: "", discount: 0 })
        setShowCustomerCategoryForm(false)
      } else {
        const error = await response.json()
        toast({
          title: "فشل الحفظ",
          description: error.error || "حدث خطأ أثناء حفظ التصنيف",
          variant: "destructive",
        })
      }
    } catch (error) {
      console.error("Error adding warehouse:", error)
      toast({
        title: "خطأ في الاتصال",
        description: "تعذر الاتصال بالخادم، يرجى المحاولة مرة أخرى",
        variant: "destructive",
      })
    }
  }

  const handleAddSupplierCategories = async (e: React.FormEvent) => {
    e.preventDefault()

    if (!suppliercategoryForm.name.trim()) {
      toast({
        title: "خطأ",
        description: "يرجى إدخال اسم التصنيف",
        variant: "destructive",
      })
      return
    }

    try {
      const response = await fetch("/api/supplier-categories", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify(suppliercategoryForm),
      })

      if (response.ok) {
        toast({
          title: "تم الحفظ بنجاح",
          description: "تم إضافة التصنيف بنجاح",
        })
        await fetchsupplierCategories()
        setSuppliercategoryForm({ name: "", paymentterms: "" })
        setShowSupplierCategoryForm(false)
      } else {
        const error = await response.json()
        toast({
          title: "فشل الحفظ",
          description: error.error || "حدث خطأ أثناء حفظ التصنيف",
          variant: "destructive",
        })
      }
    } catch (error) {
      console.error("Error adding warehouse:", error)
      toast({
        title: "خطأ في الاتصال",
        description: "تعذر الاتصال بالخادم، يرجى المحاولة مرة أخرى",
        variant: "destructive",
      })
    }
  }


  const handleAddProductCategories = async (e: React.FormEvent) => {
    e.preventDefault()

    if (!productcategoryForm.name.trim()) {
      toast({
        title: "خطأ",
        description: "يرجى إدخال اسم التصنيف",
        variant: "destructive",
      })
      return
    }

    try {
      const response = await fetch("/api/product-categories", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify(productcategoryForm),
      })

      if (response.ok) {
        toast({
          title: "تم الحفظ بنجاح",
          description: "تم إضافة التصنيف بنجاح",
        })
        await fetchProductCategories()
        setProductcategoryForm({ name: "" })
        setShowProductCategoryForm(false)
      } else {
        const error = await response.json()
        toast({
          title: "فشل الحفظ",
          description: error.error || "حدث خطأ أثناء حفظ التصنيف",
          variant: "destructive",
        })
      }
    } catch (error) {
      console.error("Error adding warehouse:", error)
      toast({
        title: "خطأ في الاتصال",
        description: "تعذر الاتصال بالخادم، يرجى المحاولة مرة أخرى",
        variant: "destructive",
      })
    }
  }

  const handleAddUnit = async (e: React.FormEvent) => {
    e.preventDefault()

    try {
      const method = editingUnitId ? "PUT" : "POST"
      const url = editingUnitId ? `/api/units/${editingUnitId}` : "/api/units"
      console.log("editingUnitId ", editingUnitId)
      const res = await fetch(url, {
        method,
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify(unitForm),
      })

      const result = await res.json()

      if (!res.ok) {
        alert(result.error || "حدث خطأ")
        return
      }

      if (editingUnitId) {
        // Update local state
        setUnits((prev) =>
          prev.map((u) => (u.id === editingUnitId ? result : u))
        )
      } else {
        setUnits((prev) => [...prev, result])
      }
      toast({
        title: "تم الحفظ بنجاح",
        description: "تم إضافة الوحدة بنجاح",
      })
      // Reset form
      await fetchUnits()
      setUnitForm({ unit_name: "", unit_name_e: "", description: "" })
      setShowUnitForm(false)
      setEditingUnitId(null)
      setCurrentUnitIndex(units.length) // select the new unit
    } catch (err) {
      console.error(err)
      alert("فشل حفظ الوحدة")
    }
  }

  // Prefill form for editing
  const handleEditUnit = (unit: Unit) => {
    setUnitForm({
      unit_name: unit.unit_name,
      unit_name_e: unit.unit_name_e,
      description: unit.description || "",
    })
    setEditingUnitId(unit.id)
    setShowUnitForm(true)
  }

  const handleEditBranch = (branch: any) => {
    setBranchForm({
      id: branch.id,
      branch_code: branch.branch_code || "",
      branch_name: branch.branch_name || "",
      phone: branch.phone || "",
      address: branch.address || "",
      manager: branch.manager || "",
    });

    setEditingBranchId(branch.id);   // تخزين الـ ID لمعرفة أنه تعديل وليس إضافة
    setShowBranchForm(true);         // إظهار نموذج التعديل
  };

  const handleEditDepartment = (dept: Department) => {
    setDepartmentForm({
      id: dept.id,
      department_code: dept.department_code,
      department_name: dept.department_name,
      branch_id: dept.branch_id?.toString() || "",
      manager: dept.manager || "",
    });
    setShowDepartmentForm(true); // show the form for editing
  };

  const handleEditCity = (city: { id: number; name: string }) => {
    setCityForm({ id: city.id, name: city.name }); // populate form
    setShowCityForm(true);            // show the form
  };
  const handleEditWarehouse = (warehouse: {
    id: number;
    warehouse_code: string;
    warehouse_name: string;
    location?: string;
  }) => {
    setWarehouseForm({
      id: warehouse.id,
      warehouse_code: warehouse.warehouse_code,
      warehouse_name: warehouse.warehouse_name,
      location: warehouse.location || "",
    });
    setShowWarehouseForm(true);
  };
  const handleAddPrice = async (e: React.FormEvent) => {
    e.preventDefault()

    try {
      const method = editingPriceId ? "PUT" : "POST"
      const url = editingPriceId ? `/api/pricecategory/${editingPriceId}` : "/api/pricecategory"
      console.log("editingPriceId ", editingPriceId)
      const res = await fetch(url, {
        method,
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify(priceForm),
      })

      const result = await res.json()

      if (!res.ok) {
        alert(result.error || "حدث خطأ")
        return
      }

      if (editingPriceId) {
        // Update local state
        setPrices((prev) =>
          prev.map((u) => (u.id === editingPriceId ? result : u))
        )
      } else {
        setPrices((prev) => [...prev, result])
      }
      toast({
        title: "تم الحفظ بنجاح",
        description: "تم إضافة الفئة بنجاح",
      })
      // Reset form
      await fetchPrices()
      setPriceForm({ name: "", name_en: "", description: "" })
      setShowPriceForm(false)
      setEditingPriceId(null)
      setCurrentPriceIndex(prices.length) // select the new price
    } catch (err) {
      console.error(err)
      alert("فشل حفظ فئة السعر")
    }
  }

  // Prefill form for editing
  const handleEditPrice = (price: Price) => {
    setPriceForm({
      name: price.name,
      name_en: price.name_en,
      description: price.description || "",
    })
    setEditingPriceId(price.id)
    setShowPriceForm(true)
  }




  const handleAddWarehouse = async (e: React.FormEvent) => {
    e.preventDefault();

    if (!warehouseForm.warehouse_code.trim() || !warehouseForm.warehouse_name.trim()) {
      toast({
        title: "خطأ",
        description: "يرجى إدخال رمز واسم المستودع",
        variant: "destructive",
      });
      return;
    }

    try {
      const isEditing = warehouseForm.id >  0;
      const url = isEditing ? `/api/warehouses/${warehouseForm.id}` : "/api/warehouses";
      const method = isEditing ? "PUT" : "POST";

      const response = await fetch(url, {
        method,
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify(warehouseForm),
      });

      if (response.ok) {
        toast({
          title: "تم الحفظ بنجاح",
          description: isEditing ? "تم تعديل المستودع بنجاح" : "تم إضافة المستودع بنجاح",
        });
        await fetchWarehouses();
        setWarehouseForm({ id: 0, warehouse_code: "", warehouse_name: "", location: "" });
        setShowWarehouseForm(false);
      } else {
        const error = await response.json();
        toast({
          title: "فشل الحفظ",
          description: error.error || "حدث خطأ أثناء حفظ المستودع",
          variant: "destructive",
        });
      }
    } catch (error) {
      console.error("Error saving warehouse:", error);
      toast({
        title: "خطأ في الاتصال",
        description: "تعذر الاتصال بالخادم، يرجى المحاولة مرة أخرى",
        variant: "destructive",
      });
    }
  };
  const handleAddBranch = async (e: React.FormEvent) => {
    e.preventDefault();

    if (!branchForm.branch_code.trim() || !branchForm.branch_name.trim()) {
      toast({
        title: "خطأ",
        description: "يرجى إدخال رمز واسم الفرع",
        variant: "destructive",
      });
      return;
    }

    try {
      const method = editingBranchId ? "PUT" : "POST";
      const url = editingBranchId
        ? `/api/branches/${editingBranchId}`
        : `/api/branches`;

      const response = await fetch(url, {
        method,
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify(branchForm),
      });

      if (response.ok) {
        toast({
          title: editingBranchId ? "تم التعديل بنجاح" : "تم الحفظ بنجاح",
          description: editingBranchId
            ? "تم تحديث بيانات الفرع بنجاح"
            : "تم إضافة الفرع بنجاح",
        });

        await fetchBranches();

        // reset form
        setBranchForm({
          id: 0,
          branch_code: "",
          branch_name: "",
          address: "",
          manager: "",
          phone: "",
        });

        setEditingBranchId(null);
        setShowBranchForm(false);
      } else {
        const error = await response.json();
        toast({
          title: "فشل العملية",
          description: error.error || "حدث خطأ أثناء حفظ الفرع",
          variant: "destructive",
        });
      }
    } catch (error) {
      console.error("Error saving branch:", error);
      toast({
        title: "خطأ في الاتصال",
        description: "تعذر الاتصال بالخادم، يرجى المحاولة مرة أخرى",
        variant: "destructive",
      });
    }
  };


  const handleAddDepartment = async (e: React.FormEvent) => {
    e.preventDefault();

    if (!departmentForm.department_code.trim() || !departmentForm.department_name.trim()) {
      toast({
        title: "خطأ",
        description: "يرجى إدخال رمز واسم القسم",
        variant: "destructive",
      });
      return;
    }

    try {
      const isEditing = departmentForm.id && departmentForm.id > 0;
      const url = isEditing
        ? `/api/departments/${departmentForm.id}`
        : "/api/departments";

      const method = isEditing ? "PUT" : "POST";

      const response = await fetch(url, {
        method,
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({
          ...departmentForm,
          branch_id: departmentForm.branch_id ? Number.parseInt(departmentForm.branch_id) : null,
        }),
      });

      if (response.ok) {
        toast({
          title: "تم الحفظ بنجاح",
          description: isEditing ? "تم تعديل القسم بنجاح" : "تم إضافة القسم بنجاح",
        });
        await fetchDepartments();
        setDepartmentForm({ id: 0, department_code: "", department_name: "", branch_id: "", manager: "" });
        setShowDepartmentForm(false);
      } else {
        const error = await response.json();
        toast({
          title: "فشل الحفظ",
          description: error.error || "حدث خطأ أثناء حفظ القسم",
          variant: "destructive",
        });
      }
    } catch (error) {
      console.error("Error saving department:", error);
      toast({
        title: "خطأ في الاتصال",
        description: "تعذر الاتصال بالخادم، يرجى المحاولة مرة أخرى",
        variant: "destructive",
      });
    }
  };

  return (
    <div className="p-6" dir="rtl">
      <div className="flex items-center justify-between mb-6">
        <div className="flex items-center gap-3">
          <Settings className="h-8 w-8 text-primary" />
          <h1 className="text-2xl font-heading font-bold text-primary">الملفات والتعريفات</h1>
        </div>
        <Badge variant="outline" className="text-sm">
          إدارة شاملة للنظام
        </Badge>
      </div>

      <Tabs defaultValue="departments" className="w-full" dir="rtl">
        <TabsList className="grid w-full grid-cols-4 mb-6">
          <TabsTrigger value="departments" className="flex items-center gap-2">
            <Building className="h-4 w-4" />
            الأقسام والفروع
          </TabsTrigger>
          <TabsTrigger value="definitions" className="flex items-center gap-2">
            <Package className="h-4 w-4" />
            التعريفات الأساسية
          </TabsTrigger>
          <TabsTrigger value="workflow-stages" className="flex items-center gap-2">
            <Settings className="h-4 w-4" />
            مراحل العمل
          </TabsTrigger>
          <TabsTrigger value="workflow-sequences" className="flex items-center gap-2">
            <Settings className="h-4 w-4" />
            تسلسلات العمل
          </TabsTrigger>
        </TabsList>

        <TabsContent value="departments" className="space-y-6">
          <div className="grid grid-cols-1 xl:grid-cols-2 gap-6">
            <Card dir="rtl">
              <CardHeader>
                <div className="flex items-center justify-between">
                  <CardTitle className="flex items-center gap-2">
                    <Building className="h-5 w-5 text-primary" />
                    الفروع ({branches.length})
                  </CardTitle>
                  <Button className="erp-btn-primary" size="sm" onClick={() => setShowBranchForm(!showBranchForm)}>
                    <Plus className="h-4 w-4 mr-2" />
                    {editingBranchId ? "تعديل الفرع" : "إضافة فرع جديد"}
                  </Button>
                </div>
              </CardHeader>
              <CardContent className="space-y-4">


                {showBranchForm && (
                  <div className="bg-muted/30 rounded-lg p-4 border" dir="rtl">
                    <h3 className="font-heading font-semibold mb-4 text-right">إضافة فرع جديد</h3>
                    <form className="space-y-4" onSubmit={handleAddBranch}>
                      <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                        <div className="text-right">
                          <Label className="erp-label text-right block">رمز الفرع *</Label>
                          <Input
                            required
                            className="erp-input text-right"
                            placeholder="B001"
                            dir="rtl"
                            maxLength={5}

                            value={branchForm.branch_code}
                            onChange={(e) => {
                              const value = e.target.value
                                .toUpperCase()        // تحويل إلى Capital
                                .replace(/[^A-Z0-9]/g, ""); // السماح فقط بالحروف الإنجليزية والأرقام

                              setBranchForm({ ...branchForm, branch_code: value });
                            }}
                          />
                        </div>
                        <div className="text-right">
                          <Label className="erp-label text-right block">اسم الفرع *</Label>
                          <Input
                            required
                            className="erp-input text-right"
                            placeholder="مثال: فرع رام الله"
                            dir="rtl"
                            maxLength={30}
                            value={branchForm.branch_name}
                            onChange={(e) => setBranchForm({ ...branchForm, branch_name: e.target.value })}
                          />
                        </div>
                      </div>
                      <div className="text-right">
                        <Label className="erp-label text-right block">رقم الهاتف</Label>
                        <Input
                          className="erp-input text-right"
                          placeholder="09-1234567"
                          dir="rtl"
                          value={branchForm.phone}
                          maxLength={12}
                          onChange={(e) => setBranchForm({ ...branchForm, phone: e.target.value })}
                        />
                      </div>
                      <div className="text-right">
                        <Label className="erp-label text-right block">العنوان</Label>
                        <Input
                          className="erp-input text-right"
                          placeholder="العنوان الكامل للفرع"
                          dir="rtl"
                          maxLength={30}
                          value={branchForm.address}
                          onChange={(e) => setBranchForm({ ...branchForm, address: e.target.value })}
                        />
                      </div>
                      <div className="text-right">
                        <Label className="erp-label text-right block">مسؤول الفرع</Label>
                        <Input
                          className="erp-input text-right"
                          placeholder="اسم المسؤول"
                          dir="rtl"
                          maxLength={30}
                          value={branchForm.manager}
                          onChange={(e) => setBranchForm({ ...branchForm, manager: e.target.value })}
                        />
                      </div>
                      <div className="flex justify-start gap-2 pt-2">
                        <Button type="submit" className="erp-btn-primary" size="sm">
                          <Button type="submit" className="erp-btn-primary" size="sm">
                            {editingBranchId ? "تحديث" : "حفظ"}
                          </Button>
                        </Button>
                        <Button type="button" variant="outline" size="sm" onClick={() => setShowBranchForm(false)}>
                          إلغاء
                        </Button>
                      </div>
                    </form>
                  </div>
                )}

                <div className="space-y-3">
                  {branches.map((branch, index) => (
                    <div
                      key={branch.id}
                      className={cn(
                        "p-4 rounded-lg border transition-all cursor-pointer",
                        index === currentBranchIndex
                          ? "bg-primary/10 border-primary shadow-sm"
                          : "bg-background hover:bg-muted/50",
                      )}
                      onClick={() => setCurrentBranchIndex(index)}
                      dir="rtl"
                    >
                      <div className="flex items-center justify-between">
                        <div className="space-y-1 text-right">
                          <h4 className="font-heading font-semibold">{branch.branch_name}</h4>
                          <p className="text-sm text-muted-foreground flex items-center gap-1">
                            <MapPin className="h-3 w-3" />
                            {branch.address || "لا يوجد عنوان"}
                          </p>
                          <div className="flex items-center gap-4 text-xs text-muted-foreground">
                            <span>المسؤول: {branch.manager || "غير محدد"}</span>
                            <span>الهاتف: {branch.phone || "غير محدد"}</span>
                          </div>
                        </div>
                        <div className="flex items-center gap-2">
                          <Button variant="outline" size="sm" onClick={() => handleEditBranch(branch)}>
                            <Edit className="h-3 w-3" />
                          </Button>
                          <Badge variant={branch.is_active ? "default" : "secondary"}>
                            {branch.is_active ? "نشط" : "غير نشط"}
                          </Badge>
                        </div>
                      </div>
                    </div>
                  ))}
                </div>
              </CardContent>
            </Card>

            <Card dir="rtl">
              <CardHeader>
                <div className="flex items-center justify-between">
                  <CardTitle className="flex items-center gap-2">
                    <Users className="h-5 w-5 text-primary" />
                    الأقسام ({departments.length})
                  </CardTitle>
                  <Button
                    className="erp-btn-primary"
                    size="sm"
                    onClick={() => setShowDepartmentForm(!showDepartmentForm)}
                  >
                    <Plus className="h-4 w-4 mr-2" />
                    إضافة قسم
                  </Button>
                </div>
              </CardHeader>
              <CardContent className="space-y-4">


                {showDepartmentForm && (
                  <div className="bg-muted/30 rounded-lg p-4 border" dir="rtl">
                    <h3 className="font-heading font-semibold mb-4 text-right">إضافة قسم جديد</h3>
                    <form className="space-y-4" onSubmit={handleAddDepartment}>
                      <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                        <div className="text-right">
                          <Label className="erp-label text-right block">رمز القسم *</Label>
                          <Input
                            required
                            className="erp-input text-right"
                            placeholder="D0001"
                            dir="rtl"
                            onChange={(e) => {
                              const value = e.target.value
                                .toUpperCase()        // تحويل إلى Capital
                                .replace(/[^A-Z0-9]/g, ""); // السماح فقط بالحروف الإنجليزية والأرقام

                              setDepartmentForm({ ...departmentForm, department_code: value })
                            }}
                            value={departmentForm.department_code}
                            maxLength={5}
                          />
                        </div>
                        <div className="text-right">
                          <Label className="erp-label text-right block">اسم القسم *</Label>
                          <Input
                            required
                            className="erp-input text-right"
                            placeholder="مثال: المحاسبة"
                            dir="rtl"
                            maxLength={30}
                            value={departmentForm.department_name}
                            onChange={(e) => setDepartmentForm({ ...departmentForm, department_name: e.target.value })}
                          />
                        </div>
                      </div>
                      <div className="text-right">
                        <Label className="erp-label text-right block">تابع لفرع</Label>
                        <Select
                          dir="rtl"
                          value={departmentForm.branch_id}
                          onValueChange={(value) => setDepartmentForm({ ...departmentForm, branch_id: value })}
                        >
                          <SelectTrigger className="erp-input text-right">
                            <SelectValue placeholder="اختر الفرع" />
                          </SelectTrigger>
                          <SelectContent>
                            {branches.map((branch) => (
                              <SelectItem key={branch.id} value={branch.id.toString()}>
                                {branch.branch_name}
                              </SelectItem>
                            ))}
                          </SelectContent>
                        </Select>
                      </div>
                      <div className="text-right">
                        <Label className="erp-label text-right block">مسؤول القسم</Label>
                        <Input
                          className="erp-input text-right"
                          placeholder="اسم المسؤول"
                          dir="rtl"
                          maxLength={30}
                          value={departmentForm.manager}
                          onChange={(e) => setDepartmentForm({ ...departmentForm, manager: e.target.value })}
                        />
                      </div>
                      <div className="flex justify-start gap-2 pt-2">
                        <Button type="submit" className="erp-btn-primary" size="sm">
                          حفظ القسم
                        </Button>
                        <Button type="button" variant="outline" size="sm" onClick={() => setShowDepartmentForm(false)}>
                          إلغاء
                        </Button>
                      </div>
                    </form>
                  </div>
                )}

                <div className="space-y-3">
                  {departments.map((dept, index) => (
                    <div
                      key={dept.id}
                      className={cn(
                        "p-4 rounded-lg border transition-all cursor-pointer",
                        index === currentDepartmentIndex
                          ? "bg-primary/10 border-primary shadow-sm"
                          : "bg-background hover:bg-muted/50",
                      )}
                      onClick={() => setCurrentDepartmentIndex(index)}
                      dir="rtl"
                    >
                      <div className="flex items-center justify-between">
                        <div className="space-y-1 text-right">
                          <h4 className="font-heading font-semibold">{dept.department_name}</h4>
                          <p className="text-sm text-muted-foreground">الفرع: {dept.branch_name || "غير محدد"}</p>
                          <div className="flex items-center gap-4 text-xs text-muted-foreground">
                            <span>المسؤول: {dept.manager || "غير محدد"}</span>
                            <span>الموظفين: {dept.employee_count}</span>
                          </div>
                        </div>
                        <div className="flex items-center gap-2">
                          <Button variant="outline" size="sm" onClick={() => handleEditDepartment(dept)}>
                            <Edit className="h-3 w-3" />
                          </Button>
                          <Badge variant={dept.is_active ? "default" : "secondary"}>
                            {dept.is_active ? "نشط" : "غير نشط"}
                          </Badge>
                        </div>
                      </div>
                    </div>
                  ))}
                </div>
              </CardContent>
            </Card>
          </div>
        </TabsContent>

        <TabsContent value="definitions" className="space-y-6">
          <div className="grid grid-cols-1 xl:grid-cols-2 gap-6">
            <Card dir="rtl">
              <CardHeader>
                <div className="flex items-center justify-between">
                  <CardTitle className="flex items-center gap-2">
                    <MapPin className="h-5 w-5 text-primary" />
                    المدن ({cities.length})
                  </CardTitle>
                  <Button className="erp-btn-primary" size="sm" onClick={() => setShowCityForm(!showCityForm)}>
                    <Plus className="h-4 w-4 mr-2" />
                    إضافة مدينة
                  </Button>
                </div>
              </CardHeader>
              <CardContent className="space-y-4">


                {showCityForm && (
                  <div className="bg-muted/30 rounded-lg p-4 border" dir="rtl">
                    <h3 className="font-heading font-semibold mb-4 text-right">إضافة مدينة جديدة</h3>
                    <form className="space-y-4" onSubmit={handleAddCity}>
                      <div className="text-right">
                        <Label className="erp-label text-right block">اسم المدينة *</Label>
                        <Input
                          required
                          className="erp-input text-right"
                          placeholder="مثال: طولكرم"
                          dir="rtl"
                          value={cityForm.name}
                          maxLength={30}
                          onChange={(e) => setCityForm({ ...cityForm, name: e.target.value })}
                        />
                      </div>
                      <div className="flex justify-start gap-2 pt-2">
                        <Button type="submit" className="erp-btn-primary" size="sm">
                          حفظ المدينة
                        </Button>
                        <Button type="button" variant="outline" size="sm" onClick={() => setShowCityForm(false)}>
                          إلغاء
                        </Button>
                      </div>
                    </form>
                  </div>
                )}

                <div className="space-y-2 max-h-80 overflow-y-auto">
                  {cities.map((city, index) => (
                    <div
                      key={city.id}
                      className={cn(
                        "p-3 rounded-lg border transition-all cursor-pointer",
                        index === currentCityIndex ? "bg-primary/10 border-primary" : "bg-background hover:bg-muted/50",
                      )}
                      onClick={() => setCurrentCityIndex(index)}
                      dir="rtl"
                    >
                      <div className="flex items-center justify-between">
                        <div className="text-right">
                          <h4 className="font-medium">{city.name}</h4>
                        </div>
                        <Button variant="outline" size="sm" onClick={() => handleEditCity(city)}>
                          <Edit className="h-3 w-3" />
                        </Button>
                      </div>
                    </div>
                  ))}
                </div>
              </CardContent>
            </Card>

            <Card dir="rtl">
              <CardHeader>
                <div className="flex items-center justify-between">
                  <CardTitle className="flex items-center gap-2">
                    <Package className="h-5 w-5 text-primary" />
                    المستودعات ({warehouses.length})
                  </CardTitle>
                  <Button
                    className="erp-btn-primary"
                    size="sm"
                    onClick={() => setShowWarehouseForm(!showWarehouseForm)}
                  >
                    <Plus className="h-4 w-4 mr-2" />
                    إضافة مستودع
                  </Button>
                </div>
              </CardHeader>
              <CardContent className="space-y-4">

                {showWarehouseForm && (
                  <div className="bg-muted/30 rounded-lg p-4 border" dir="rtl">
                    <h3 className="font-heading font-semibold mb-4 text-right">إضافة مستودع جديد</h3>
                    <form className="space-y-4" onSubmit={handleAddWarehouse}>
                      <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                        <div className="text-right">
                          <Label className="erp-label text-right block">رمز المستودع *</Label>
                          <Input
                            required
                            className="erp-input text-right"
                            placeholder="MAIN"
                            dir="rtl"
                            value={warehouseForm.warehouse_code}
                            maxLength={8}
                            onChange={(e) => {
                              const value = e.target.value
                                .toUpperCase()        // تحويل إلى Capital
                                .replace(/[^A-Z0-9]/g, ""); // السماح فقط بالحروف الإنجليزية والأرقام

                              setWarehouseForm({ ...warehouseForm, warehouse_code: value })
                            }}
                           />
                        </div>
                        <div className="text-right">
                          <Label className="erp-label text-right block">اسم المستودع *</Label>
                          <Input
                            required
                            className="erp-input text-right"
                            placeholder="مثال: مستودع الخليل"
                            dir="rtl"
                            maxLength={30}
                            value={warehouseForm.warehouse_name}
                            onChange={(e) => setWarehouseForm({ ...warehouseForm, warehouse_name: e.target.value })}
                          />
                        </div>
                      </div>
                      <div className="text-right">
                        <Label className="erp-label text-right block">الموقع</Label>
                        <Input
                          className="erp-input text-right"
                          placeholder="الموقع"
                          dir="rtl"
                          maxLength={30}
                          value={warehouseForm.location}
                          onChange={(e) => setWarehouseForm({ ...warehouseForm, location: e.target.value })}
                        />
                      </div>
                      <div className="flex justify-start gap-2 pt-2">
                        <Button type="submit" className="erp-btn-primary" size="sm">
                          حفظ المستودع
                        </Button>
                        <Button type="button" variant="outline" size="sm" onClick={() => setShowWarehouseForm(false)}>
                          إلغاء
                        </Button>
                      </div>
                    </form>
                  </div>
                )}

                <div className="space-y-3">
                  {warehouses.map((warehouse, index) => (
                    <div
                      key={warehouse.id}
                      className={cn(
                        "p-4 rounded-lg border transition-all cursor-pointer",
                        index === currentWarehouseIndex
                          ? "bg-primary/10 border-primary shadow-sm"
                          : "bg-background hover:bg-muted/50",
                      )}
                      onClick={() => setCurrentWarehouseIndex(index)}
                      dir="rtl"
                    >
                      <div className="flex items-center justify-between">
                        <div className="space-y-1 text-right">
                          <h4 className="font-heading font-semibold">{warehouse.warehouse_name}</h4>
                          <p className="text-sm text-muted-foreground flex items-center gap-1">
                            <MapPin className="h-3 w-3" />
                            {warehouse.location || "لا يوجد موقع"}
                          </p>
                        </div>
                        <div className="flex items-center gap-2">
                          <Button variant="outline" size="sm" onClick={() => handleEditWarehouse(warehouse)}>
                            <Edit className="h-3 w-3" />
                          </Button>
                          <Badge variant={warehouse.is_active ? "default" : "secondary"}>
                            {warehouse.is_active ? "نشط" : "غير نشط"}
                          </Badge>
                        </div>
                      </div>
                    </div>
                  ))}
                </div>
              </CardContent>
            </Card>

          </div>
          <div className="grid grid-cols-1 xl:grid-cols-2 gap-6" >
            <Card dir="rtl" >
              <CardHeader>
                <div className="flex items-center justify-between">
                  <CardTitle className="flex items-center gap-2">
                    <Package className="h-5 w-5 text-primary" />
                    الوحدات ({units.length})
                  </CardTitle>
                  <Button
                    className="erp-btn-primary"
                    size="sm"
                    onClick={() => setShowUnitForm(!showUnitForm)}
                  >
                    <Plus className="h-4 w-4 mr-2" />
                    إضافة وحدة
                  </Button>
                </div>
              </CardHeader>

              <CardContent className="space-y-4">


                {showUnitForm && (
                  <div className="bg-muted/30 rounded-lg p-4 border" dir="rtl">
                    <h3 className="font-heading font-semibold mb-4 text-right">إضافة وحدة جديدة</h3>
                    <form className="space-y-4" onSubmit={handleAddUnit}>
                      <div className="grid grid-cols-1 md:grid-cols-1 gap-4">

                        <div className="text-right">
                          <Label className="erp-label text-right block">اسم الوحدة *</Label>
                          <Input
                            required
                            className="erp-input text-right"
                            placeholder="قطعة"
                            dir="rtl"
                            value={unitForm.unit_name}
                            onChange={(e) => setUnitForm({ ...unitForm, unit_name: e.target.value })}
                          />
                        </div>
                        <div className="text-right">
                          <Label className="erp-label text-right block">اسم الوحدة en</Label>
                          <Input
                            className="erp-input text-right"
                            placeholder="PCS"
                            dir="rtl"
                            value={unitForm.unit_name_e}
                            onChange={(e) => setUnitForm({ ...unitForm, unit_name_e: e.target.value })}
                          />
                        </div>
                      </div>

                      <div className="text-right">
                        <Label className="erp-label text-right block">الوصف</Label>
                        <Input
                          className="erp-input text-right"
                          placeholder="وصف الوحدة"
                          dir="rtl"
                          value={unitForm.description}
                          onChange={(e) => setUnitForm({ ...unitForm, description: e.target.value })}
                        />
                      </div>

                      <div className="flex justify-start gap-2 pt-2">
                        <Button type="submit" className="erp-btn-primary" size="sm">
                          حفظ الوحدة
                        </Button>
                        <Button type="button" variant="outline" size="sm" onClick={() => setShowUnitForm(false)}>
                          إلغاء
                        </Button>
                      </div>
                    </form>
                  </div>
                )}

                <div className="space-y-3">
                  {units.map((unit, index) => (
                    <div
                      key={unit.id}
                      className={cn(
                        "p-4 rounded-lg border transition-all cursor-pointer",
                        index === currentUnitIndex
                          ? "bg-primary/10 border-primary shadow-sm"
                          : "bg-background hover:bg-muted/50",
                      )}
                      onClick={() => setCurrentUnitIndex(index)}
                      dir="rtl"
                    >
                      <div className="flex items-center justify-between">
                        <div className="space-y-1 text-right">
                          <h4 className="font-heading font-semibold">{unit.unit_name}</h4>
                          <p className="text-sm text-muted-foreground flex items-center gap-1">

                          </p>
                        </div>
                        <div className="flex items-center gap-2">
                          <Button variant="outline" size="sm" onClick={() => handleEditUnit(unit)}>
                            <Edit className="h-3 w-3" />
                          </Button>
                          <Badge variant={unit.is_active ? "default" : "secondary"}>
                            {unit.is_active ? "نشط" : "غير نشط"}
                          </Badge>
                        </div>
                      </div>
                    </div>
                  ))}
                </div>
              </CardContent>
            </Card>


            <Card dir="rtl" >
              <CardHeader>
                <div className="flex items-center justify-between">
                  <CardTitle className="flex items-center gap-2">
                    <Package className="h-5 w-5 text-primary" />
                    فئات الأسعار ({units.length})
                  </CardTitle>
                  <Button
                    className="erp-btn-primary"
                    size="sm"
                    onClick={() => setShowPriceForm(!showPriceForm)}
                  >
                    <Plus className="h-4 w-4 mr-2" />
                    إضافة فئة
                  </Button>
                </div>
              </CardHeader>

              <CardContent className="space-y-4">


                {showPriceForm && (
                  <div className="bg-muted/30 rounded-lg p-4 border" dir="rtl">
                    <h3 className="font-heading font-semibold mb-4 text-right">إضافة فئة جديدة</h3>
                    <form className="space-y-4" onSubmit={handleAddPrice}>
                      <div className="grid grid-cols-1 md:grid-cols-1 gap-4">

                        <div className="text-right">
                          <Label className="erp-label text-right block">اسم الفئة *</Label>
                          <Input
                            required
                            className="erp-input text-right"
                            placeholder="مفرق"
                            dir="rtl"
                            value={priceForm.name}
                            onChange={(e) => setPriceForm({ ...priceForm, name: e.target.value })}
                          />
                        </div>
                        <div className="text-right">
                          <Label className="erp-label text-right block">اسم الفئة en</Label>
                          <Input
                            className="erp-input text-right"
                            placeholder=""
                            dir="rtl"
                            value={priceForm.name_en}
                            onChange={(e) => setPriceForm({ ...priceForm, name_en: e.target.value })}
                          />
                        </div>
                      </div>

                      <div className="text-right">
                        <Label className="erp-label text-right block">الوصف</Label>
                        <Input
                          className="erp-input text-right"
                          placeholder="وصف الفئة"
                          dir="rtl"
                          value={priceForm.description}
                          onChange={(e) => setPriceForm({ ...priceForm, description: e.target.value })}
                        />
                      </div>

                      <div className="flex justify-start gap-2 pt-2">
                        <Button type="submit" className="erp-btn-primary" size="sm">
                          حفظ الفئة
                        </Button>
                        <Button type="button" variant="outline" size="sm" onClick={() => {
                          setShowPriceForm(false);
                          setPriceForm({ name: "", name_en: "", description: "" })
                          setShowPriceForm(false)
                          setEditingPriceId(null)
                        }}>
                          إلغاء
                        </Button>
                      </div>
                    </form>
                  </div>
                )}

                <div className="space-y-3">
                  {prices.map((price, index) => (
                    <div
                      key={price.id}
                      className={cn(
                        "p-4 rounded-lg border transition-all cursor-pointer",
                        index === currentPriceIndex
                          ? "bg-primary/10 border-primary shadow-sm"
                          : "bg-background hover:bg-muted/50",
                      )}
                      onClick={() => setCurrentPriceIndex(index)}
                      dir="rtl"
                    >
                      <div className="flex items-center justify-between">
                        <div className="space-y-1 text-right">
                          <h4 className="font-heading font-semibold">{price.name}</h4>
                          <p className="text-sm text-muted-foreground flex items-center gap-1">

                          </p>
                        </div>
                        <div className="flex items-center gap-2">
                          <Button variant="outline" size="sm" onClick={() => handleEditPrice(price)}>
                            <Edit className="h-3 w-3" />
                          </Button>
                          <Badge variant={price.is_active ? "default" : "secondary"}>
                            {price.is_active ? "نشط" : "غير نشط"}
                          </Badge>
                        </div>
                      </div>
                    </div>
                  ))}
                </div>
              </CardContent>
            </Card>


            <Salesmen
            />

          </div>

          <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
            {/* Customer Categories */}
            <Card dir="rtl">
              <CardHeader>
                <div className="flex items-center justify-between">
                  <CardTitle className="flex items-center gap-2 text-base">
                    <Users className="h-4 w-4 text-primary" />
                    تصنيفات الزبائن
                  </CardTitle>
                  <Button
                    size="sm"
                    variant="outline"
                    onClick={() => setShowCustomerCategoryForm(!showCustomerCategoryForm)}
                  >
                    <Plus className="h-3 w-3" />
                  </Button>
                </div>
              </CardHeader>
              <CardContent className="space-y-3">
                {showCustomerCategoryForm && (
                  <div className="bg-muted/30 rounded-lg p-3 border" dir="rtl">
                    <form className="space-y-3" onSubmit={handleAddCustomerCategories}>
                      <div className="text-right">
                        <Label className="erp-label text-sm text-right block">اسم التصنيف</Label>
                        <Input className="erp-input text-right" placeholder="مثال: زبائن الجملة" dir="rtl"
                          value={customercategoryForm.name}
                          onChange={(e) => setCustomercategoryForm({ ...customercategoryForm, name: e.target.value })}
                        />
                      </div>
                      <div className="text-right">
                        <Label className="erp-label text-sm text-right block">نسبة الخصم (%)</Label>
                        <Input
                          type="number"
                          className="erp-input text-right"
                          placeholder="10"
                          dir="rtl"
                          value={customercategoryForm.discount}
                          onChange={(e) => {
                            let value = Number(e.target.value)
                            if (value > 100) value = 100   // Limit to 100
                            if (value < 0) value = 0       // Optional: prevent negative
                            setCustomercategoryForm({
                              ...customercategoryForm,
                              discount: value
                            })
                          }}
                        />
                      </div>
                      <div className="flex justify-start gap-2">
                        <Button type="submit" size="sm" className="erp-btn-primary">
                          حفظ
                        </Button>
                        <Button
                          type="button"
                          variant="outline"
                          size="sm"
                          onClick={() => setShowCustomerCategoryForm(false)}
                        >
                          إلغاء
                        </Button>
                      </div>
                    </form>
                  </div>
                )}

                <div className="space-y-2 max-h-64 overflow-y-auto">
                  {customercategories.map((category, index) => (
                    <div
                      key={category.id}
                      className="p-3 rounded-lg border bg-background hover:bg-muted/50 transition-colors"
                      dir="rtl"
                    >
                      <div className="flex items-center justify-between">
                        <div className="flex items-center gap-2">
                          <div className="w-3 h-3 rounded-full" style={{ backgroundColor: colors[index % colors.length] }} />
                          <div className="text-right">
                            <h4 className="font-medium text-sm">{category.name}</h4>
                            <p className="text-xs text-muted-foreground">خصم {category.discount}%</p>
                          </div>
                        </div>

                      </div>
                      <div className="mt-2">

                      </div>
                    </div>
                  ))}
                </div>
              </CardContent>
            </Card>

            {/* Supplier Categories */}
            <Card dir="rtl">
              <CardHeader>
                <div className="flex items-center justify-between">
                  <CardTitle className="flex items-center gap-2 text-base">
                    <Package className="h-4 w-4 text-primary" />
                    تصنيفات الموردين
                  </CardTitle>
                  <Button
                    size="sm"
                    variant="outline"
                    onClick={() => setShowSupplierCategoryForm(!showSupplierCategoryForm)}
                  >
                    <Plus className="h-3 w-3" />
                  </Button>
                </div>
              </CardHeader>
              <CardContent className="space-y-3">
                {showSupplierCategoryForm && (
                  <div className="bg-muted/30 rounded-lg p-3 border" dir="rtl">
                    <form className="space-y-3" onSubmit={handleAddSupplierCategories}>
                      <div className="text-right">
                        <Label className="erp-label text-sm text-right block">اسم التصنيف</Label>
                        <Input className="erp-input text-right" placeholder="مثال: موردين أوروبيين" dir="rtl"
                          value={suppliercategoryForm.name}
                          onChange={(e) => setSuppliercategoryForm({ ...suppliercategoryForm, name: e.target.value })}
                        />
                      </div>
                      <div className="text-right">
                        <Label className="erp-label text-sm text-right block">شروط الدفع</Label>
                        <Input className="erp-input text-right" placeholder="مثال: 30 يوم" dir="rtl"
                          value={suppliercategoryForm.paymentterms}
                          onChange={(e) => setSuppliercategoryForm({ ...suppliercategoryForm, paymentterms: e.target.value })}
                        />
                      </div>
                      <div className="flex justify-start gap-2">
                        <Button type="submit" size="sm" className="erp-btn-primary">
                          حفظ
                        </Button>
                        <Button
                          type="button"
                          variant="outline"
                          size="sm"
                          onClick={() => setShowSupplierCategoryForm(false)}
                        >
                          إلغاء
                        </Button>
                      </div>
                    </form>
                  </div>
                )}

                <div className="space-y-2 max-h-64 overflow-y-auto">
                  {suppliercategories.map((category, index) => (
                    <div
                      key={category.id}
                      className="p-3 rounded-lg border bg-background hover:bg-muted/50 transition-colors"
                      dir="rtl"
                    >
                      <div className="flex items-center justify-between">
                        <div className="flex items-center gap-2">
                          <div className="w-3 h-3 rounded-full" style={{ backgroundColor: colors[index % colors.length] }} />
                          <div className="text-right">
                            <h4 className="font-medium text-sm">{category.name}</h4>
                            <p className="text-xs text-muted-foreground">{category.paymentterms}</p>
                          </div>
                        </div>

                      </div>

                    </div>
                  ))}
                </div>
              </CardContent>
            </Card>

            {/* Product Categories */}
            <Card dir="rtl">
              <CardHeader>
                <div className="flex items-center justify-between">
                  <CardTitle className="flex items-center gap-2 text-base">
                    <Package className="h-4 w-4 text-primary" />
                    تصنيفات الأصناف
                  </CardTitle>
                  <Button
                    size="sm"
                    variant="outline"
                    onClick={() => setShowProductCategoryForm(!showProductCategoryForm)}
                  >
                    <Plus className="h-3 w-3" />
                  </Button>
                </div>
              </CardHeader>
              <CardContent className="space-y-3">
                {showProductCategoryForm && (
                  <div className="bg-muted/30 rounded-lg p-3 border" dir="rtl">
                    <form className="space-y-3" onSubmit={handleAddProductCategories}>
                      <div className="text-right">
                        <Label className="erp-label text-sm text-right block">اسم التصنيف</Label>
                        <Input className="erp-input text-right" placeholder="مثال: مواد غذائية" dir="rtl"
                          value={productcategoryForm.name}
                          onChange={(e) => setProductcategoryForm({ ...productcategoryForm, name: e.target.value })}
                        />
                      </div>

                      <div className="flex justify-start gap-2">
                        <Button type="submit" size="sm" className="erp-btn-primary">
                          حفظ
                        </Button>
                        <Button
                          type="button"
                          variant="outline"
                          size="sm"
                          onClick={() => setShowProductCategoryForm(false)}
                        >
                          إلغاء
                        </Button>
                      </div>
                    </form>
                  </div>
                )}

                <div className="space-y-2 max-h-64 overflow-y-auto">
                  {productcategories.map((category, index) => (
                    <div
                      key={category.id}
                      className="p-3 rounded-lg border bg-background hover:bg-muted/50 transition-colors"
                      dir="rtl"
                    >
                      <div className="flex items-center justify-between">
                        <div className="flex items-center gap-2">
                          <div className="w-3 h-3 rounded-full" style={{ backgroundColor: colors[index % colors.length] }} />
                          <div className="text-right">
                            <h4 className="font-medium text-sm">{category.name}</h4>
                          </div>
                        </div>

                      </div>
                      <div className="mt-2">

                      </div>
                    </div>
                  ))}
                </div>
              </CardContent>
            </Card>
          </div>

          <Card dir="rtl">
            <CardHeader>
              <div className="flex items-center justify-between">
                <CardTitle className="flex items-center gap-2">
                  <CreditCard className="h-5 w-5 text-primary" />
                  العملات ({currencies.length})
                </CardTitle>
                <Button className="erp-btn-primary" size="sm" onClick={() => setShowCurrencyForm(!showCurrencyForm)}>
                  <Plus className="h-4 w-4 mr-2" />
                  إضافة عملة
                </Button>
              </div>
            </CardHeader>
            <CardContent className="space-y-4">
              {showCurrencyForm && (
                <div className="bg-muted/30 rounded-lg p-4 border" dir="rtl">
                  <h3 className="font-heading font-semibold mb-4 text-right">إضافة عملة جديدة</h3>
                  <form className="space-y-4" onSubmit={handleAddCurrency}>
                    <div className="grid grid-cols-2 md:grid-cols-5 gap-4">
                      <div className="text-right">
                        <Label className="erp-label text-right block">رمز العملة *</Label>
                        <Input
                          className="erp-input text-right"
                          placeholder="USD"
                          dir="rtl"
                          value={currencyForm.currency_code}
                          maxLength={10} // HTML limit
                          onChange={(e) => {
                            let value = e.target.value
                              .replace(/[^A-Za-z]/g, "")
                              .toUpperCase();

                            if (value.length > 10) value = value.slice(0, 10);

                            setCurrencyForm({ ...currencyForm, currency_code: value });
                          }}
                        />
                      </div>
                      <div className="text-right">
                        <Label className="erp-label text-right block">اسم العملة *</Label>
                        <Input
                          className="erp-input text-right"
                          placeholder="دولار أمريكي"
                          dir="rtl"
                          value={currencyForm.currency_name}
                          onChange={(e) => setCurrencyForm({ ...currencyForm, currency_name: e.target.value })}
                        />
                      </div>
                      <div className="text-right">
                        <Label className="erp-label text-right block">سعر البيع</Label>
                        <Input
                          type="number"
                          step="0.01"
                          className="erp-input text-right"
                          placeholder="3.65"
                          dir="rtl"
                          value={currencyForm.sell_rate}
                          onChange={(e) => setCurrencyForm({ ...currencyForm, sell_rate: e.target.value })}
                        />
                      </div>
                      <div className="text-right">
                        <Label className="erp-label text-right block">سعر الشراء</Label>
                        <Input
                          type="number"
                          step="0.01"
                          className="erp-input text-right"
                          placeholder="3.60"
                          dir="rtl"
                          value={currencyForm.buy_rate}
                          onChange={(e) => setCurrencyForm({ ...currencyForm, buy_rate: e.target.value })}
                        />
                      </div>
                      <div className="text-right">
                        <Label className="erp-label text-right block">سعر الصرف</Label>
                        <Input
                          type="number"
                          step="0.01"
                          className="erp-input text-right"
                          placeholder="3.62"
                          dir="rtl"
                          value={currencyForm.exchange_rate}
                          onChange={(e) => setCurrencyForm({ ...currencyForm, exchange_rate: e.target.value })}
                        />
                      </div>
                    </div>
                    <div className="flex justify-start gap-2 pt-2">
                      <Button type="submit" className="erp-btn-primary" size="sm">
                        حفظ العملة
                      </Button>
                      <Button type="button" variant="outline" size="sm" onClick={() => setShowCurrencyForm(false)}>
                        إلغاء
                      </Button>
                    </div>
                  </form>
                </div>
              )}

              <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-4">
                {currencies.map((currency) => (
                  <div
                    key={currency.id}
                    className="p-4 rounded-lg border bg-background hover:bg-muted/50 transition-colors"
                    dir="rtl"
                  >
                    <div className="flex items-center justify-between mb-2">
                      <div className="flex items-center gap-2">
                        <CreditCard className="h-4 w-4 text-primary" />
                        <span className="font-mono font-bold">{currency.currency_code}</span>
                      </div>
                      {/* Assuming a property like isDefault exists or can be inferred */}
                      {/* {currency.isDefault && (
                        <Badge variant="default" className="text-xs">
                          افتراضي
                        </Badge>
                      )} */}
                    </div>
                    <h4 className="font-medium mb-3 text-right">{currency.currency_name}</h4>
                    <div className="space-y-1 text-sm">
                      <div className="flex justify-between">

                        <span className="text-muted-foreground">البيع</span>
                        <span className="font-mono">{Number(currency.sell_rate).toFixed(4)}</span>
                      </div>
                      <div className="flex justify-between">

                        <span className="text-muted-foreground">الشراء</span>
                        <span className="font-mono">{Number(currency.buy_rate).toFixed(4)}</span>
                      </div>
                      <div className="flex justify-between">

                        <span className="text-muted-foreground">الصرف</span>
                        <span className="font-mono">{Number(currency.exchange_rate).toFixed(4)}</span>
                      </div>
                    </div>
                    <div className="flex justify-start mt-3">
                      <Button variant="outline" size="sm">
                        <Edit className="h-3 w-3" />
                      </Button>
                    </div>
                  </div>
                ))}
              </div>
            </CardContent>
          </Card>
        </TabsContent>

        {/* Workflow Stages Management Tab */}
        <TabsContent value="workflow-stages">
          <WorkflowStagesManagement />
        </TabsContent>

        {/* Workflow Sequences Management Tab */}
        <TabsContent value="workflow-sequences">
          <WorkflowSequencesManagement />
        </TabsContent>
      </Tabs>
    </div>
  )
}

export { Definitions }
export default Definitions
