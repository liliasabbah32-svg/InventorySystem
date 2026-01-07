import type React from "react"
import type { Metadata } from "next"

export const metadata: Metadata = {
  title: "إدخال الطلبيات - تطبيق الموبايل",
  description: "تطبيق موبايل لإدخال طلبيات البيع",
  viewport: "width=device-width, initial-scale=1, maximum-scale=1, user-scalable=no",
}

export default function MobileLayout({
  children,
}: {
  children: React.ReactNode
}) {
  return <div className="mobile-app bg-gray-50 min-h-screen">{children}</div>
}
