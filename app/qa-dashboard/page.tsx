"use client"
import { ProtectedRoute } from "@/components/auth/protected-route"
import QADashboardSimple from "@/components/qa-dashboard-simple"

export default function QADashboardPage() {
  return (
    <ProtectedRoute>
      <QADashboardSimple />
    </ProtectedRoute>
  )
}
