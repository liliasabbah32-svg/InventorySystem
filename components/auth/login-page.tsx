"use client"

import { useState } from "react"
import { PasswordReset } from "./password-reset"
import {
  Card,
  CardContent,
} from "@/components/ui/card"
import { Button } from "@/components/ui/button"
import { Input } from "@/components/ui/input"
import { Label } from "@/components/ui/label"
import { Switch } from "@/components/ui/switch"
import { Alert, AlertDescription } from "@/components/ui/alert"
import {
  Eye,
  EyeOff,
  Lock,
  User,
  AlertCircle,
  LogIn,
} from "lucide-react"

interface LoginPageProps {
  onLogin: (credentials: {
    username: string
    password: string
    rememberMe: boolean
  }) => void
}

export function LoginPage({ onLogin }: LoginPageProps) {
  const [credentials, setCredentials] = useState({
    username: "",
    password: "",
    rememberMe: false,
  })

  const [showPassword, setShowPassword] = useState(false)
  const [isLoading, setIsLoading] = useState(false)
  const [error, setError] = useState("")
  const [showPasswordReset, setShowPasswordReset] = useState(false)

  if (showPasswordReset) {
    return <PasswordReset onBack={() => setShowPasswordReset(false)} />
  }

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault()
    setError("")
    setIsLoading(true)

    try {
      await onLogin(credentials)
    } catch (err: any) {
      setError(err.message || "حدث خطأ في تسجيل الدخول")
    } finally {
      setIsLoading(false)
    }
  }

  return (
    <div className="min-h-screen flex items-center justify-center bg-gradient-to-br from-indigo-50 to-purple-100 px-4">
      <div className="w-full max-w-5xl bg-white rounded-3xl shadow-2xl grid grid-cols-1 md:grid-cols-2 overflow-hidden">

        {/* LEFT – FORM */}
        <div className="p-10 md:p-14 flex flex-col justify-center">
          <h1 className="text-3xl font-bold text-gray-900 mb-2">
            تسجيل الدخول
          </h1>
          <p className="text-gray-500 mb-8">
            أهلاً بك، الرجاء إدخال بياناتك للمتابعة
          </p>

          <Card className="border-0 shadow-none">
            <CardContent className="p-0">
              <form onSubmit={handleSubmit} className="space-y-5">

                {error && (
                  <Alert className="border-red-200 bg-red-50">
                    <AlertCircle className="h-4 w-4 text-red-600" />
                    <AlertDescription className="text-red-700">
                      {error}
                    </AlertDescription>
                  </Alert>
                )}

                {/* Username */}
                <div className="space-y-1">
                  <Label>اسم المستخدم أو البريد الإلكتروني</Label>
                  <div className="relative">
                    <User className="absolute right-4 top-1/2 -translate-y-1/2 text-gray-400" />
                    <Input
                      className="h-12 pr-12 rounded-xl"
                      value={credentials.username}
                      onChange={(e) =>
                        setCredentials({
                          ...credentials,
                          username: e.target.value,
                        })
                      }
                      required
                    />
                  </div>
                </div>

                {/* Password */}
                <div className="space-y-1">
                  <Label>كلمة المرور</Label>
                  <div className="relative">
                    <Lock className="absolute right-4 top-1/2 -translate-y-1/2 text-gray-400" />
                    <Input
                      type={showPassword ? "text" : "password"}
                      className="h-12 pr-12 pl-12 rounded-xl"
                      value={credentials.password}
                      onChange={(e) =>
                        setCredentials({
                          ...credentials,
                          password: e.target.value,
                        })
                      }
                      required
                    />
                    <button
                      type="button"
                      onClick={() => setShowPassword(!showPassword)}
                      className="absolute left-4 top-1/2 -translate-y-1/2 text-gray-400 hover:text-gray-600"
                    >
                      {showPassword ? <EyeOff /> : <Eye />}
                    </button>
                  </div>
                </div>

                {/* Remember */}
                <div className="flex items-center justify-between">
                  <div className="flex items-center gap-2">
                    <Switch
                      checked={credentials.rememberMe}
                      onCheckedChange={(v) =>
                        setCredentials({ ...credentials, rememberMe: v })
                      }
                    />
                    <span className="text-sm">تذكرني</span>
                  </div>

                  <button
                    type="button"
                    className="text-sm text-indigo-600 hover:underline"
                    //onClick={/*() => setShowPasswordReset(true)*/}
                  >
                    نسيت كلمة المرور؟
                  </button>
                </div>

                {/* Submit */}
                <Button
                  type="submit"
                  disabled={isLoading}
                  className="w-full h-12 rounded-xl bg-gradient-to-r from-indigo-600 to-purple-600 hover:from-indigo-700 hover:to-purple-700 shadow-lg"
                >
                  {isLoading ? (
                    <span className="animate-spin w-4 h-4 border-2 border-white border-t-transparent rounded-full" />
                  ) : (
                    <div className="flex items-center gap-2">
                      <LogIn className="w-4 h-4" />
                      تسجيل الدخول
                    </div>
                  )}
                </Button>
              </form>
            </CardContent> 
          </Card>
        </div>

        {/* RIGHT – VISUAL */}
        <div className="hidden md:flex items-center justify-center bg-gradient-to-br from-indigo-600 to-purple-600 relative">
          <div className="absolute inset-0 opacity-20 bg-[radial-gradient(circle_at_top_left,white,transparent_60%)]" />
          <img
            src="/icon-192.jpg"
            alt="Login Illustration"
            className="w-[320px] z-10 drop-shadow-2xl rounded-2xl"
          />
        </div>
      </div>
    </div>
  )
}
