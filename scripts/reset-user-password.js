import { neon } from "@neondatabase/serverless"
import bcrypt from "bcryptjs"

const sql = neon(process.env.DATABASE_URL)

async function resetPassword() {
  try {
    const username = "Zaid Salous"
    const newPassword = "123456" // كلمة المرور الجديدة

    console.log(`[v0] Resetting password for user: ${username}`)

    // Hash the new password
    const passwordHash = bcrypt.hashSync(newPassword, 10)
    console.log(`[v0] New password hash generated`)

    // Update the user's password
    const result = await sql`
      UPDATE user_settings 
      SET 
        password_hash = ${passwordHash},
        updated_at = NOW()
      WHERE username = ${username}
      RETURNING user_id, username, full_name, email
    `

    if (result.length === 0) {
      console.log(`[v0] User not found: ${username}`)
      return
    }

    console.log(`[v0] Password reset successful for:`, result[0])
    console.log(`[v0] New password: ${newPassword}`)
    console.log(`[v0] You can now login with username: ${username} and password: ${newPassword}`)
  } catch (error) {
    console.error("[v0] Error resetting password:", error)
  }
}

resetPassword()
