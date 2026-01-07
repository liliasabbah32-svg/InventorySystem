"use client"

import { useState, useCallback, useMemo } from "react"

interface UseRecordNavigationOptions<T> {
  data: T[]
  onSave?: (record: T, isNew: boolean) => Promise<void>
  onDelete?: (record: T) => Promise<void>
  createNewRecord: () => T
  initialIndex?: number
}

interface UseRecordNavigationReturn<T> {
  currentRecord: T | null
  currentIndex: number
  isNew: boolean
  isLoading: boolean
  totalRecords: number
  goToFirst: () => void
  goToPrevious: () => void
  goToNext: () => void
  goToLast: () => void
  createNew: () => void
  saveRecord: () => Promise<void>
  deleteRecord: () => Promise<void>
  updateRecord: (updates: Partial<T>) => void
  setCurrentIndex: (index: number) => void
  canSave: boolean
  canDelete: boolean
  isFirstRecord: boolean
  isLastRecord: boolean
}

export function useRecordNavigation<T extends { id?: number | string }>({
  data,
  onSave,
  onDelete,
  createNewRecord,
  initialIndex = 0,
}: UseRecordNavigationOptions<T>): UseRecordNavigationReturn<T> {
  const [currentIndex, setCurrentIndex] = useState(initialIndex)
  const [isNew, setIsNew] = useState(false)
  const [isLoading, setIsLoading] = useState(false)
  const [newRecord, setNewRecord] = useState<T | null>(null)

  const totalRecords = data.length
  const currentRecord = useMemo(() => {
    if (isNew && newRecord) {
      return newRecord
    }
    return data[currentIndex] || null
  }, [data, currentIndex, isNew, newRecord])

  const goToFirst = useCallback(() => {
    if (data.length > 0) {
      setCurrentIndex(0)
      setIsNew(false)
      setNewRecord(null)
    }
  }, [data.length])

  const goToPrevious = useCallback(() => {
    if (currentIndex > 0) {
      setCurrentIndex((prev) => prev - 1)
      setIsNew(false)
      setNewRecord(null)
    }
  }, [currentIndex])

  const goToNext = useCallback(() => {
    if (currentIndex < data.length - 1) {
      setCurrentIndex((prev) => prev + 1)
      setIsNew(false)
      setNewRecord(null)
    }
  }, [currentIndex, data.length])

  const goToLast = useCallback(() => {
    if (data.length > 0) {
      setCurrentIndex(data.length - 1)
      setIsNew(false)
      setNewRecord(null)
    }
  }, [data.length])

  const createNew = useCallback(() => {
    const record = createNewRecord()
    setNewRecord(record)
    setIsNew(true)
  }, [createNewRecord])

  const saveRecord = useCallback(async () => {
    if (!currentRecord || !onSave) return

    try {
      setIsLoading(true)
      await onSave(currentRecord, isNew)
      setIsNew(false)
      setNewRecord(null)
    } catch (error) {
      console.error("Error saving record:", error)
      throw error
    } finally {
      setIsLoading(false)
    }
  }, [currentRecord, onSave, isNew])

  const deleteRecord = useCallback(async () => {
    if (!currentRecord || !onDelete || isNew) return

    try {
      setIsLoading(true)
      await onDelete(currentRecord)

      // Move to previous record or first record after deletion
      if (currentIndex > 0) {
        setCurrentIndex((prev) => prev - 1)
      } else if (data.length > 1) {
        setCurrentIndex(0)
      }
    } catch (error) {
      console.error("Error deleting record:", error)
      throw error
    } finally {
      setIsLoading(false)
    }
  }, [currentRecord, onDelete, isNew, currentIndex, data.length])

  const updateRecord = useCallback(
    (updates: Partial<T>) => {
      if (isNew && newRecord) {
        setNewRecord({ ...newRecord, ...updates })
      }
    },
    [isNew, newRecord],
  )

  const canSave = useMemo(() => {
    return !!currentRecord && !!onSave
  }, [currentRecord, onSave])

  const canDelete = useMemo(() => {
    return !!currentRecord && !!onDelete && !isNew && data.length > 0
  }, [currentRecord, onDelete, isNew, data.length])

  const isFirstRecord = useMemo(() => {
    return currentIndex === 0 && !isNew
  }, [currentIndex, isNew])

  const isLastRecord = useMemo(() => {
    return currentIndex === data.length - 1 && !isNew
  }, [currentIndex, data.length, isNew])

  return {
    currentRecord,
    currentIndex,
    isNew,
    isLoading,
    totalRecords,
    goToFirst,
    goToPrevious,
    goToNext,
    goToLast,
    createNew,
    saveRecord,
    deleteRecord,
    updateRecord,
    setCurrentIndex,
    canSave,
    canDelete,
    isFirstRecord,
    isLastRecord,
  }
}
