"use client"

import type React from "react"

import { useCallback, useEffect } from "react"

export function useEnterNavigation(formRef: React.RefObject<HTMLFormElement>) {
  const handleKeyDown = useCallback(
    (event: KeyboardEvent) => {
      if (event.key === "Enter" && !event.shiftKey) {
        event.preventDefault()

        const form = formRef.current
        if (!form) return

        const focusableElements = form.querySelectorAll(
          'input:not([disabled]):not([type="hidden"]), select:not([disabled]), textarea:not([disabled]), button:not([disabled])',
        )

        const focusableArray = Array.from(focusableElements) as HTMLElement[]
        const currentIndex = focusableArray.indexOf(document.activeElement as HTMLElement)

        if (currentIndex >= 0 && currentIndex < focusableArray.length - 1) {
          // Move to next field
          focusableArray[currentIndex + 1].focus()
        } else if (currentIndex === focusableArray.length - 1) {
          // Last field - trigger save
          const saveButton = form.querySelector('button[type="submit"]') as HTMLButtonElement
          if (saveButton) {
            saveButton.click()
          }
        }
      }
    },
    [formRef],
  )

  useEffect(() => {
    const form = formRef.current
    if (form) {
      form.addEventListener("keydown", handleKeyDown)
      return () => form.removeEventListener("keydown", handleKeyDown)
    }
  }, [handleKeyDown])
}
