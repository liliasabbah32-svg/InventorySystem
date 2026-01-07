import { clsx, type ClassValue } from "clsx"
import { twMerge } from "tailwind-merge"

export function cn(...inputs: ClassValue[]) {
  return twMerge(clsx(inputs))
}

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
