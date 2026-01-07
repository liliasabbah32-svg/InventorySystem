/**
 * Application constants to avoid hardcoded values
 */

// Order statuses
export const ORDER_STATUSES = {
  PENDING: "قيد التنفيذ",
  RECEIVED: "مستلمة",
  CANCELLED: "ملغاة",
  ON_HOLD: "معلقة",
} as const

// Priority levels
export const PRIORITY_LEVELS = {
  URGENT: "urgent",
  HIGH: "high",
  NORMAL: "normal",
  LOW: "low",
} as const

// Priority colors
export const PRIORITY_COLORS = {
  [PRIORITY_LEVELS.URGENT]: "bg-red-100 text-red-800 border-red-200",
  [PRIORITY_LEVELS.HIGH]: "bg-orange-100 text-orange-800 border-orange-200",
  [PRIORITY_LEVELS.NORMAL]: "bg-blue-100 text-blue-800 border-blue-200",
  [PRIORITY_LEVELS.LOW]: "bg-gray-100 text-gray-800 border-gray-200",
} as const

// Currencies
export const CURRENCIES = {
  ILS: { code: "ILS", symbol: "₪", name: "شيكل إسرائيلي" },
  USD: { code: "USD", symbol: "$", name: "دولار أمريكي" },
  EUR: { code: "EUR", symbol: "€", name: "يورو" },
  SAR: { code: "SAR", symbol: "ر.س", name: "ريال سعودي" },
} as const

// Default pagination
export const PAGINATION = {
  DEFAULT_PAGE_SIZE: 50,
  MAX_PAGE_SIZE: 100,
} as const

// Date formats
export const DATE_FORMATS = {
  DISPLAY: "ar-SA",
  INPUT: "YYYY-MM-DD",
} as const

// Departments
export const DEPARTMENTS = ["المبيعات", "المشتريات", "المحاسبة", "المستودعات", "الإدارة"] as const

// Default warehouse
export const DEFAULT_WAREHOUSE = "المستودع الرئيسي"

// Units
export const UNITS = ["قطعة", "كيلو", "متر", "لتر", "صندوق", "كرتون"] as const
