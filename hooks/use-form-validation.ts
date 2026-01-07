"use client"

import { useState, useCallback } from "react"
import { ValidationService } from "@/lib/validation-service"

/**
 * Generic form validation hook
 */
export function useFormValidation<T extends Record<string, any>>(
  initialData: T,
  validationSchema: Record<keyof T, (value: any) => string | null>,
) {
  const [formData, setFormData] = useState<T>(initialData)
  const [errors, setErrors] = useState<Record<keyof T, string | null>>({} as Record<keyof T, string | null>)
  const [touched, setTouched] = useState<Record<keyof T, boolean>>({} as Record<keyof T, boolean>)

  /**
   * Update form field value
   */
  const updateField = useCallback(
    (field: keyof T, value: any) => {
      setFormData((prev) => ({ ...prev, [field]: value }))

      // Clear error when user starts typing
      if (errors[field]) {
        setErrors((prev) => ({ ...prev, [field]: null }))
      }
    },
    [errors],
  )

  /**
   * Mark field as touched
   */
  const touchField = useCallback((field: keyof T) => {
    setTouched((prev) => ({ ...prev, [field]: true }))
  }, [])

  /**
   * Validate single field
   */
  const validateField = useCallback(
    (field: keyof T) => {
      const validator = validationSchema[field]
      if (validator) {
        const error = validator(formData[field])
        setErrors((prev) => ({ ...prev, [field]: error }))
        return error === null
      }
      return true
    },
    [formData, validationSchema],
  )

  /**
   * Validate entire form
   */
  const validateForm = useCallback(() => {
    const newErrors = ValidationService.validateForm(formData, validationSchema)
    setErrors(newErrors)

    // Mark all fields as touched
    const allTouched = {} as Record<keyof T, boolean>
    Object.keys(formData).forEach((key) => {
      allTouched[key as keyof T] = true
    })
    setTouched(allTouched)

    // Return true if no errors
    return Object.values(newErrors).every((error) => error === null)
  }, [formData, validationSchema])

  /**
   * Reset form to initial state
   */
  const resetForm = useCallback(() => {
    setFormData(initialData)
    setErrors({} as Record<keyof T, string | null>)
    setTouched({} as Record<keyof T, boolean>)
  }, [initialData])

  /**
   * Check if form has errors
   */
  const hasErrors = Object.values(errors).some((error) => error !== null)

  /**
   * Check if form is valid (no errors and at least one field touched)
   */
  const isValid = !hasErrors && Object.values(touched).some(Boolean)

  return {
    formData,
    errors,
    touched,
    hasErrors,
    isValid,
    updateField,
    touchField,
    validateField,
    validateForm,
    resetForm,
    setFormData,
  }
}
