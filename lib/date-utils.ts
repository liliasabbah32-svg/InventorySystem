/**
 * Date formatting utilities for consistent British date format (DD/MM/YYYY) across the system
 */

export const formatDateToBritish = (date: Date | string): string => {
  const dateObj = typeof date === "string" ? new Date(date) : date

  if (isNaN(dateObj.getTime())) {
    return ""
  }

  return dateObj.toLocaleDateString("en-GB", {
    day: "2-digit",
    month: "2-digit",
    year: "numeric",
  })
}

export const formatDateTimeToBritish = (date: Date | string): string => {
  const dateObj = typeof date === "string" ? new Date(date) : date

  if (isNaN(dateObj.getTime())) {
    return ""
  }

  return dateObj.toLocaleString("en-GB", {
    day: "2-digit",
    month: "2-digit",
    year: "numeric",
    hour: "2-digit",
    minute: "2-digit",
    hour12: false,
  })
}

export const formatDateForInput = (date: Date | string): string => {
  const dateObj = typeof date === "string" ? new Date(date) : date

  if (isNaN(dateObj.getTime())) {
    return ""
  }

  // For HTML date inputs (YYYY-MM-DD format)
  return dateObj.toISOString().split("T")[0]
}

export const getCurrentDateForInput = (): string => {
  return formatDateForInput(new Date())
}

export const parseBritishDate = (dateString: string): Date | null => {
  // Parse DD/MM/YYYY format
  const parts = dateString.split("/")
  if (parts.length !== 3) return null

  const day = Number.parseInt(parts[0], 10)
  const month = Number.parseInt(parts[1], 10) - 1 // Month is 0-indexed
  const year = Number.parseInt(parts[2], 10)

  const date = new Date(year, month, day)

  // Validate the date
  if (date.getDate() !== day || date.getMonth() !== month || date.getFullYear() !== year) {
    return null
  }

  return date
}
