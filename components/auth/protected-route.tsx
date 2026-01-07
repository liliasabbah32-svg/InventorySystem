"use client"

import type React from "react"

import { useAuth } from "./auth-context"
import { LoginPage } from "./login-page"

interface ProtectedRouteProps {
  children: React.ReactNode
  requiredPermission?: string
}

export function ProtectedRoute({ children, requiredPermission }: ProtectedRouteProps) {
  const { isAuthenticated, hasPermission, login, isLoading } = useAuth()


  if (isLoading) {
    return (
      <div className="min-h-screen bg-gradient-to-br from-emerald-50 via-blue-50 to-emerald-100 flex items-center justify-center">
        <div className="text-center space-y-4">
          <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-emerald-600 mx-auto"></div>
          <p className="text-gray-600 text-lg">جاري تحميل النظام...</p>
          <p className="text-gray-500 text-sm">يرجى الانتظار</p>
        </div>
      </div>
    )
  }

  if (!isAuthenticated) {
    return (
      <div className="min-h-screen">
        <LoginPage onLogin={login} />
      </div>
    )
  }

  if (requiredPermission && !hasPermission(requiredPermission)) {
    console.log(" User lacks required permission:", requiredPermission)
    return (
      <div className="flex items-center justify-center h-64">
        <div className="text-center">
          <h2 className="text-2xl font-semibold mb-2 text-red-600">غير مصرح</h2>
          <p className="text-muted-foreground">ليس لديك صلاحية للوصول إلى هذا القسم</p>
        </div>
      </div>
    )
  }

  return <>{children}</>
}
