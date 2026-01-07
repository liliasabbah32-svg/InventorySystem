import { neon } from "@neondatabase/serverless"

const sql = neon(process.env.DATABASE_URL)

async function checkUsers() {
  try {
    console.log("[v0] Checking users in database...")

    // Get all users from user_settings table
    const users = await sql`
      SELECT user_id, username, email, full_name, is_active, created_at 
      FROM user_settings 
      ORDER BY created_at DESC
    `

    console.log("[v0] Total users found:", users.length)

    if (users.length > 0) {
      console.log("[v0] Users in database:")
      users.forEach((user, index) => {
        console.log(
          `[v0] ${index + 1}. User ID: ${user.user_id}, Username: ${user.username}, Email: ${user.email}, Full Name: ${user.full_name}, Active: ${user.is_active}`,
        )
      })
    } else {
      console.log("[v0] No users found in database")
    }

    // Check if "Zaid Salous" exists
    const zaidUser = await sql`
      SELECT user_id, username, email, full_name, is_active, password_hash
      FROM user_settings 
      WHERE username = 'Zaid Salous' OR full_name = 'Zaid Salous' OR email = 'Zaid Salous'
    `

    console.log('[v0] Searching for "Zaid Salous":', zaidUser.length > 0 ? "FOUND" : "NOT FOUND")

    if (zaidUser.length > 0) {
      zaidUser.forEach((user) => {
        console.log("[v0] Zaid User Details:", {
          user_id: user.user_id,
          username: user.username,
          email: user.email,
          full_name: user.full_name,
          is_active: user.is_active,
          has_password: user.password_hash ? "YES" : "NO",
        })
      })
    }
  } catch (error) {
    console.error("[v0] Error checking users:", error)
  }
}

checkUsers()
