import { toast } from "@/hooks/use-toast"

export interface ErrorLog {
  id: string
  timestamp: Date
  level: "error" | "warning" | "info"
  message: string
  stack?: string
  context?: Record<string, any>
  userId?: string
  userAgent?: string
  url?: string
}

export class ErrorHandler {
  private static logs: ErrorLog[] = []
  private static maxLogs = 1000

  // تسجيل الخطأ مع السياق
  static logError(error: Error | string, context?: Record<string, any>, level: "error" | "warning" | "info" = "error") {
    const errorLog: ErrorLog = {
      id: crypto.randomUUID(),
      timestamp: new Date(),
      level,
      message: typeof error === "string" ? error : error.message,
      stack: typeof error === "object" ? error.stack : undefined,
      context,
      userId: this.getCurrentUserId(),
      userAgent: typeof window !== "undefined" ? window.navigator.userAgent : undefined,
      url: typeof window !== "undefined" ? window.location.href : undefined,
    }

    // إضافة إلى السجل المحلي
    this.logs.unshift(errorLog)
    if (this.logs.length > this.maxLogs) {
      this.logs = this.logs.slice(0, this.maxLogs)
    }

    // تسجيل في console مع تفاصيل إضافية
    console.error(`[${level.toUpperCase()}] ${errorLog.message}`, {
      id: errorLog.id,
      timestamp: errorLog.timestamp,
      context: errorLog.context,
      stack: errorLog.stack,
    })

    // حفظ في localStorage للاسترجاع لاحقاً
    this.saveToLocalStorage()

    // إرسال إلى الخادم إذا كان خطأ حرج
    if (level === "error") {
      this.sendToServer(errorLog)
    }
  }

  // عرض رسالة خطأ للمستخدم
  static showUserError(userMessage: string, technicalError?: Error | string, context?: Record<string, any>) {
    // تسجيل الخطأ التقني
    if (technicalError) {
      this.logError(technicalError, context, "error")
    }

    // عرض رسالة مفهومة للمستخدم
    toast({
      variant: "destructive",
      title: "حدث خطأ",
      description: userMessage,
    })
  }

  // معالجة أخطاء API
  static handleApiError(error: any, operation: string) {
    let userMessage = "حدث خطأ أثناء العملية. يرجى المحاولة مرة أخرى."

    if (error.message?.includes("fetch")) {
      userMessage = "مشكلة في الاتصال بالخادم. تحقق من اتصال الإنترنت."
    } else if (error.message?.includes("timeout")) {
      userMessage = "انتهت مهلة الاتصال. يرجى المحاولة مرة أخرى."
    } else if (error.message?.includes("404")) {
      userMessage = "الصفحة أو البيانات المطلوبة غير موجودة."
    } else if (error.message?.includes("403")) {
      userMessage = "ليس لديك صلاحية للوصول إلى هذه البيانات."
    } else if (error.message?.includes("500")) {
      userMessage = "خطأ في الخادم. تم إبلاغ فريق الدعم الفني."
    }

    this.showUserError(userMessage, error, { operation })
  }

  // معالجة أخطاء قاعدة البيانات
  static handleDatabaseError(error: any, query: string) {
    let userMessage = "حدث خطأ في قاعدة البيانات."

    if (error.message?.includes("duplicate")) {
      userMessage = "البيانات موجودة مسبقاً. يرجى التحقق من المدخلات."
    } else if (error.message?.includes("foreign key")) {
      userMessage = "لا يمكن حذف هذا السجل لأنه مرتبط ببيانات أخرى."
    } else if (error.message?.includes("not null")) {
      userMessage = "يرجى ملء جميع الحقول المطلوبة."
    } else if (error.message?.includes("connection")) {
      userMessage = "مشكلة في الاتصال بقاعدة البيانات."
    }

    this.showUserError(userMessage, error, { query })
  }

  // الحصول على السجلات المحلية
  static getLogs(level?: "error" | "warning" | "info", limit = 100): ErrorLog[] {
    let filteredLogs = this.logs

    if (level) {
      filteredLogs = this.logs.filter((log) => log.level === level)
    }

    return filteredLogs.slice(0, limit)
  }

  // تصدير السجلات
  static exportLogs(): string {
    const logsData = {
      exportDate: new Date().toISOString(),
      totalLogs: this.logs.length,
      logs: this.logs,
    }

    return JSON.stringify(logsData, null, 2)
  }

  // مسح السجلات
  static clearLogs() {
    this.logs = []
    if (typeof window !== "undefined") {
      localStorage.removeItem("error-logs")
    }
  }

  // حفظ في localStorage
  private static saveToLocalStorage() {
    if (typeof window !== "undefined") {
      try {
        const recentLogs = this.logs.slice(0, 100) // حفظ آخر 100 سجل فقط
        localStorage.setItem("error-logs", JSON.stringify(recentLogs))
      } catch (e) {
        console.warn("Failed to save error logs to localStorage:", e)
      }
    }
  }

  // استرجاع من localStorage
  static loadFromLocalStorage() {
    if (typeof window !== "undefined") {
      try {
        const saved = localStorage.getItem("error-logs")
        if (saved) {
          const logs = JSON.parse(saved) as ErrorLog[]
          this.logs = [...logs, ...this.logs]
        }
      } catch (e) {
        console.warn("Failed to load error logs from localStorage:", e)
      }
    }
  }

  // إرسال إلى الخادم
  private static async sendToServer(errorLog: ErrorLog) {
    try {
      await fetch("/api/errors", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify(errorLog),
      })
    } catch (e) {
      console.warn("Failed to send error to server:", e)
    }
  }

  // الحصول على معرف المستخدم الحالي
  private static getCurrentUserId(): string | undefined {
    if (typeof window !== "undefined") {
      try {
        const userData = localStorage.getItem("user-data")
        if (userData) {
          const user = JSON.parse(userData)
          return user.id || user.username
        }
      } catch (e) {
        // تجاهل الخطأ
      }
    }
    return undefined
  }
}

// تحميل السجلات عند بدء التطبيق
if (typeof window !== "undefined") {
  ErrorHandler.loadFromLocalStorage()
}
