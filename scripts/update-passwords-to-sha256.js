import { neon } from "@neondatabase/serverless"

const sql = neon(process.env.DATABASE_URL)

// دالة لتشفير كلمة المرور باستخدام SHA-256
async function hashPassword(password) {
  const encoder = new TextEncoder()
  const data = encoder.encode(password)
  const hashBuffer = await crypto.subtle.digest("SHA-256", data)
  const hashArray = Array.from(new Uint8Array(hashBuffer))
  const hashHex = hashArray.map((b) => b.toString(16).padStart(2, "0")).join("")
  return hashHex
}

async function updatePasswords() {
  console.log("[v0] Starting password migration from bcrypt to SHA-256...")

  try {
    // قائمة المستخدمين مع كلمات المرور الجديدة
    const users = [
      { username: "admin", password: "admin123" },
      { username: "ahmed.mohamed", password: "ahmed123" },
      { username: "fatima.ali", password: "fatima123" },
      { username: "omar.salem", password: "omar123" },
      { username: "sara.ahmed", password: "sara123" },
      { username: "Zaid Salous", password: "zaid123" },
    ]

    for (const user of users) {
      const hashedPassword = await hashPassword(user.password)

      console.log(`[v0] Updating password for user: ${user.username} (hash: ${hashedPassword.substring(0, 20)}...)`)

      await sql`
        UPDATE user_settings 
        SET password_hash = ${hashedPassword},
            updated_at = NOW()
        WHERE username = ${user.username}
      `

      console.log(`[v0] ✓ Password updated for: ${user.username}`)
    }

    console.log("[v0] Password migration completed successfully!")
    console.log("[v0] You can now login with:")
    console.log("  - admin / admin123")
    console.log("  - ahmed.mohamed / ahmed123")
    console.log("  - fatima.ali / fatima123")
    console.log("  - omar.salem / omar123")
    console.log("  - sara.ahmed / sara123")
    console.log("  - Zaid Salous / zaid123")
  } catch (error) {
    console.error("[v0] Error updating passwords:", error)
    throw error
  }
}

// تشغيل التحديث
updatePasswords()
