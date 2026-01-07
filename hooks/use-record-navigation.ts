"use client"

import { useState, useCallback, useEffect, useRef } from "react"

interface UseRecordNavigationProps<T> {
  data: T[]
  onSave?: (record: T, isNew: boolean) => Promise<void>
  onDelete?: (record: T) => Promise<void>
  createNewRecord: () => T
}

export function useRecordNavigation<T extends { id?: string | number }>({
  data,
  onSave,
  onDelete,
  createNewRecord,
}: UseRecordNavigationProps<T>) {
  const [currentIndex, setCurrentIndex] = useState(0)
  const [currentRecord, setCurrentRecord] = useState<T>(createNewRecord())
  const [isNew, setIsNew] = useState(true)
  const [isLoading, setIsLoading] = useState(false)
  const initializedRef = useRef(false)
  const previousDataLengthRef = useRef(0)

  useEffect(() => {
    const dataLengthChanged = data.length !== previousDataLengthRef.current

    if (!initializedRef.current || dataLengthChanged) {
      if (data.length > 0) {
        // If we have data, show the first record on initial load
        // or stay on current index if data length changed
        const targetIndex = !initializedRef.current ? 0 : Math.min(currentIndex, data.length - 1)
        setCurrentIndex(targetIndex)
        setCurrentRecord(data[targetIndex])
        setIsNew(false)
        initializedRef.current = true
      } else {
        // No data, show new record
        setCurrentRecord(createNewRecord())
        setIsNew(true)
        setCurrentIndex(0)
        initializedRef.current = true
      }

      previousDataLengthRef.current = data.length
    }
  }, [data, data.length, createNewRecord])

  const goToFirst = useCallback(() => {

    if (data.length > 0) {
      setCurrentIndex(0)
      setCurrentRecord(data[0])
      setIsNew(false)
    }
  }, [data])

  const goToPrevious = useCallback(() => {
    if (currentIndex > 0) {
      const newIndex = currentIndex - 1
      setCurrentIndex(newIndex)
      setCurrentRecord(data[newIndex])
      setIsNew(false)
    }
  }, [currentIndex, data])

  const goToNext = useCallback(() => {
    if (currentIndex < data.length - 1) {
      const newIndex = currentIndex + 1
      setCurrentIndex(newIndex)
      setCurrentRecord(data[newIndex])
      setIsNew(false)
    }
  }, [currentIndex, data])

  const goToLast = useCallback(() => {
    if (data.length > 0) {
      const newIndex = data.length - 1
      setCurrentIndex(newIndex)
      console.log("data[newIndex] ",data[newIndex])
      setCurrentRecord(data[newIndex])
      setIsNew(false)
    }
  }, [data])

  const createNew = useCallback(() => {
    setCurrentRecord(createNewRecord())
    setIsNew(true)
    setCurrentIndex(data.length)
  }, [createNewRecord, data.length])

  const saveRecord = useCallback(async () => {
    if (!onSave) return

    setIsLoading(true)
    try {
      await onSave(currentRecord, isNew)
      setIsNew(false)
    } catch (error) {
      console.error("Error saving record:", error)
      throw error
    } finally {
      setIsLoading(false)
    }
  }, [currentRecord, isNew, onSave])

  const deleteRecord = useCallback(async () => {
    if (!onDelete || isNew) return

    setIsLoading(true)
    try {
      await onDelete(currentRecord)
      initializedRef.current = false
    } catch (error) {
      console.error("Error deleting record:", error)
      throw error
    } finally {
      setIsLoading(false)
    }
  }, [currentRecord, isNew, onDelete])

  const updateRecord = useCallback((updates: Partial<T>) => {
    setCurrentRecord((prev) => ({ ...prev, ...updates }))
  }, [])

  return {
    currentRecord,
    currentIndex: currentIndex + 1, // Display as 1-based
    isNew,
    isLoading,
    totalRecords: data.length,
    goToFirst,
    goToPrevious,
    goToNext,
    goToLast,
    createNew,
    saveRecord,
    deleteRecord,
    updateRecord,
    canSave: true,
    canDelete: !isNew && data.length > 0,
    isFirstRecord: currentIndex === 0,
    isLastRecord: currentIndex === data.length - 1 || data.length === 0,
  }
}
