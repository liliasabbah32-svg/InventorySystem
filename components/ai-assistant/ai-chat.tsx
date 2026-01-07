"use client"

import { useState } from "react"
import { Button } from "@/components/ui/button"
import { Card } from "@/components/ui/card"
import { Input } from "@/components/ui/input"
import { ScrollArea } from "@/components/ui/scroll-area"
import { Loader2, Send, Bot, User } from "lucide-react"

interface Message {
  role: "user" | "assistant"
  content: string
}

export function AIChat() {
  const [messages, setMessages] = useState<Message[]>([])
  const [input, setInput] = useState("")
  const [isLoading, setIsLoading] = useState(false)

  const suggestedQuestions = [
    "كم عدد الطلبيات المعلقة؟",
    "ما هي المنتجات منخفضة المخزون؟",
    "أعطني تقرير عن أفضل 5 منتجات مبيعاً",
    "ما هي حالة طلبية رقم 123؟",
  ]

  const handleSubmit = async (question?: string) => {
    const messageText = question || input
    if (!messageText.trim()) return

    const userMessage: Message = { role: "user", content: messageText }
    setMessages((prev) => [...prev, userMessage])
    setInput("")
    setIsLoading(true)

    try {
      const response = await fetch("/api/ai-assistant/chat", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({
          messages: [...messages, userMessage].map((m) => ({
            role: m.role,
            content: m.content,
          })),
        }),
      })

      if (!response.ok) throw new Error("فشل في الحصول على الرد")

      const reader = response.body?.getReader()
      const decoder = new TextDecoder()
      let assistantContent = ""

      if (reader) {
        while (true) {
          const { done, value } = await reader.read()
          if (done) break

          const chunk = decoder.decode(value)
          assistantContent += chunk

          setMessages((prev) => {
            const newMessages = [...prev]
            const lastMessage = newMessages[newMessages.length - 1]
            if (lastMessage?.role === "assistant") {
              lastMessage.content = assistantContent
            } else {
              newMessages.push({ role: "assistant", content: assistantContent })
            }
            return newMessages
          })
        }
      }
    } catch (error) {
      console.error("[v0] AI Chat error:", error)
      const errorMessage: Message = {
        role: "assistant",
        content: "عذراً، حدث خطأ في الاتصال. الرجاء المحاولة مرة أخرى.",
      }
      setMessages((prev) => [...prev, errorMessage])
    } finally {
      setIsLoading(false)
    }
  }

  return (
    <div className="flex flex-col h-full" dir="rtl">
      <div className="bg-gradient-to-r from-blue-600 to-purple-600 rounded-lg p-6 text-white mb-4">
        <h1 className="text-2xl font-bold mb-2">المساعد الذكي</h1>
        <p className="text-blue-100">اسألني أي سؤال عن نظام ERP الخاص بك</p>
      </div>

      {messages.length === 0 && (
        <Card className="p-6 mb-4">
          <h3 className="font-semibold mb-4">أسئلة مقترحة:</h3>
          <div className="grid gap-2">
            {suggestedQuestions.map((question, index) => (
              <Button
                key={index}
                variant="outline"
                className="justify-start text-right bg-transparent"
                onClick={() => handleSubmit(question)}
              >
                {question}
              </Button>
            ))}
          </div>
        </Card>
      )}

      <ScrollArea className="flex-1 mb-4">
        <div className="space-y-4 p-4">
          {messages.map((message, index) => (
            <div key={index} className={`flex gap-3 ${message.role === "user" ? "justify-end" : "justify-start"}`}>
              {message.role === "assistant" && (
                <div className="w-8 h-8 rounded-full bg-primary flex items-center justify-center flex-shrink-0">
                  <Bot className="w-5 h-5 text-primary-foreground" />
                </div>
              )}
              <Card
                className={`p-4 max-w-[80%] ${message.role === "user" ? "bg-primary text-primary-foreground" : ""}`}
              >
                <p className="whitespace-pre-wrap">{message.content}</p>
              </Card>
              {message.role === "user" && (
                <div className="w-8 h-8 rounded-full bg-secondary flex items-center justify-center flex-shrink-0">
                  <User className="w-5 h-5 text-secondary-foreground" />
                </div>
              )}
            </div>
          ))}
          {isLoading && (
            <div className="flex gap-3 justify-start">
              <div className="w-8 h-8 rounded-full bg-primary flex items-center justify-center flex-shrink-0">
                <Bot className="w-5 h-5 text-primary-foreground" />
              </div>
              <Card className="p-4">
                <Loader2 className="w-5 h-5 animate-spin" />
              </Card>
            </div>
          )}
        </div>
      </ScrollArea>

      <div className="flex gap-2">
        <Input
          value={input}
          onChange={(e) => setInput(e.target.value)}
          onKeyDown={(e) => e.key === "Enter" && !isLoading && handleSubmit()}
          placeholder="اكتب سؤالك هنا..."
          disabled={isLoading}
          className="flex-1"
        />
        <Button onClick={() => handleSubmit()} disabled={isLoading || !input.trim()}>
          {isLoading ? <Loader2 className="w-4 h-4 animate-spin" /> : <Send className="w-4 h-4" />}
        </Button>
      </div>
    </div>
  )
}
