"use client"

import { useState, useEffect } from "react"

export interface DocumentFieldSetting {
  id: number
  document_type: string
  field_name: string
  display_name: string
  display_order: number
  show_in_screen: boolean
  show_in_print: boolean
  is_required: boolean
  field_type: string
  validation_rules: string | null
  default_value: string | null
  created_at: string
  updated_at: string
}

export function useDocumentSettings(documentType: string) {
  const [settings, setSettings] = useState<DocumentFieldSetting[]>([])
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState<string | null>(null)

  useEffect(() => {
    if (!documentType) return

    const fetchSettings = async () => {
      try {
        console.log(`[v0] Loading document settings for: ${documentType}`)
        setLoading(true)
        setError(null)

        const response = await fetch(`/api/settings/document?document_type=${documentType}`)
        if (!response.ok) {
          throw new Error(`Failed to fetch document settings: ${response.statusText}`)
        }

        const data = await response.json()
        console.log(`[v0] Loaded settings:`, data)

        // Sort by display_order
        const sortedSettings = Array.isArray(data) ? data.sort((a, b) => a.display_order - b.display_order) : []

        setSettings(sortedSettings)
      } catch (err) {
        console.error(`[v0] Error loading document settings:`, err)
        setError(err instanceof Error ? err.message : "Unknown error")
        setSettings([])
      } finally {
        setLoading(false)
      }
    }

    fetchSettings()
  }, [documentType])

  // Helper function to check if a field should be visible
  const isFieldVisible = (fieldName: string) => {
    const setting = settings.find((s) => s.field_name === fieldName)
    return setting ? setting.show_in_screen : true // Default to visible if not found
  }

  // Helper function to check if a field is required
  const isFieldRequired = (fieldName: string) => {
    const setting = settings.find((s) => s.field_name === fieldName)
    return setting ? setting.is_required : false
  }

  // Helper function to get field display name
  const getFieldDisplayName = (fieldName: string) => {
    const setting = settings.find((s) => s.field_name === fieldName)
    return setting ? setting.display_name : fieldName
  }

  // Helper function to get visible fields in order
  const getVisibleFields = () => {
    return settings.filter((s) => s.show_in_screen).sort((a, b) => a.display_order - b.display_order)
  }

  return {
    settings,
    loading,
    error,
    isFieldVisible,
    isFieldRequired,
    getFieldDisplayName,
    getVisibleFields,
  }
}
