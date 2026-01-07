/**
 * Centralized validation service for form fields
 */
export class ValidationService {
  /**
   * Validates required fields
   */
  static validateRequired(value: string | number | null | undefined, fieldName: string): string | null {
    if (value === null || value === undefined || String(value).trim() === "") {
      return `${fieldName} مطلوب`
    }
    return null
  }

  /**
   * Validates email format
   */
  static validateEmail(email: string): string | null {
    if (!email) return null

    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/
    return emailRegex.test(email) ? null : "صيغة البريد الإلكتروني غير صحيحة"
  }

  /**
   * Validates phone number format
   */
  static validatePhone(phone: string): string | null {
    if (!phone) return null

    const phoneRegex = /^[+]?[\d\s\-()]{10,}$/
    return phoneRegex.test(phone) ? null : "صيغة رقم الهاتف غير صحيحة"
  }

  /**
   * Validates numeric values
   */
  static validateNumeric(value: string | number, fieldName: string, min?: number, max?: number): string | null {
    const numValue = typeof value === "string" ? Number.parseFloat(value) : value

    if (isNaN(numValue)) {
      return `${fieldName} يجب أن يكون رقماً صحيحاً`
    }

    if (min !== undefined && numValue < min) {
      return `${fieldName} يجب أن يكون أكبر من أو يساوي ${min}`
    }

    if (max !== undefined && numValue > max) {
      return `${fieldName} يجب أن يكون أقل من أو يساوي ${max}`
    }

    return null
  }

  /**
   * Validates date format and range
   */
  static validateDate(date: string, fieldName: string, minDate?: string, maxDate?: string): string | null {
    if (!date) return null

    const dateObj = new Date(date)
    if (isNaN(dateObj.getTime())) {
      return `${fieldName} تاريخ غير صحيح`
    }

    if (minDate && dateObj < new Date(minDate)) {
      return `${fieldName} يجب أن يكون بعد ${minDate}`
    }

    if (maxDate && dateObj > new Date(maxDate)) {
      return `${fieldName} يجب أن يكون قبل ${maxDate}`
    }

    return null
  }

  /**
   * Validates form data against schema
   */
  static validateForm<T extends Record<string, any>>(
    data: T,
    schema: Record<keyof T, (value: any) => string | null>,
  ): Record<keyof T, string | null> {
    const errors = {} as Record<keyof T, string | null>

    Object.keys(schema).forEach((key) => {
      const validator = schema[key as keyof T]
      errors[key as keyof T] = validator(data[key])
    })

    return errors
  }
}
