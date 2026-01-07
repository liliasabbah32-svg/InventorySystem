"use client"

import { useState, useEffect } from "react"

export interface BatchSettings {
  id?: number
  document_type: string
  mandatory_batch_selection: boolean
  auto_select_fifo: boolean
  allow_negative_stock: boolean
  require_expiry_date: boolean
  created_at?: string
  updated_at?: string
}

export function useBatchSettings(documentType: string) {
  const [settings, setSettings] = useState<BatchSettings | null>(null)
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState<string | null>(null)

  useEffect(() => {
    if (!documentType) return

    const fetchSettings = async () => {
      try {
        console.log(`[v0] Loading batch settings for: ${documentType}`)
        setLoading(true)
        setError(null)

        const response = await fetch(`/api/settings/batch?document_type=${documentType}`)
        if (!response.ok) {
          throw new Error(`Failed to fetch batch settings: ${response.statusText}`)
        }

        const data = await response.json()
        console.log(`[v0] Loaded batch settings:`, data)

        setSettings(data)
      } catch (err) {
        console.error(`[v0] Error loading batch settings:`, err)
        setError(err instanceof Error ? err.message : "Unknown error")
        setSettings(null)
      } finally {
        setLoading(false)
      }
    }

    fetchSettings()
  }, [documentType])

  // Helper function to check if batch selection is mandatory
  const isBatchMandatory = () => {
    return settings ? settings.mandatory_batch_selection : false
  }

  // Helper function to check if FIFO auto-selection is enabled
  const isAutoFifoEnabled = () => {
    return settings ? settings.auto_select_fifo : true
  }

  // Helper function to check if negative stock is allowed
  const isNegativeStockAllowed = () => {
    return settings ? settings.allow_negative_stock : false
  }

  // Helper function to check if expiry date is required
  const isExpiryDateRequired = () => {
    return settings ? settings.require_expiry_date : false
  }

  return {
    settings,
    loading,
    error,
    isBatchMandatory,
    isAutoFifoEnabled,
    isNegativeStockAllowed,
    isExpiryDateRequired,
  }
}
