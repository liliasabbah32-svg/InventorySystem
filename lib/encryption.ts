import crypto from "crypto"

const ENCRYPTION_KEY = process.env.ENCRYPTION_KEY || "default-encryption-key-change-in-production"
const ALGORITHM = "aes-256-cbc"
const IV_LENGTH = 16

/**
 * Encrypts a string using AES-256-CBC
 */
export function encrypt(text: string): string {
  if (!text) return ""

  try {
    const iv = crypto.randomBytes(IV_LENGTH)
    const key = crypto.scryptSync(ENCRYPTION_KEY, "salt", 32)
    const cipher = crypto.createCipheriv(ALGORITHM, key, iv)

    let encrypted = cipher.update(text, "utf8", "hex")
    encrypted += cipher.final("hex")

    // Return IV + encrypted data
    return iv.toString("hex") + ":" + encrypted
  } catch (error) {
    console.error("[v0] Encryption error:", error)
    throw new Error("Failed to encrypt data")
  }
}

/**
 * Decrypts a string encrypted with the encrypt function
 */
export function decrypt(encryptedText: string): string {
  if (!encryptedText) return ""

  try {
    const parts = encryptedText.split(":")
    if (parts.length !== 2) {
      throw new Error("Invalid encrypted data format")
    }

    const iv = Buffer.from(parts[0], "hex")
    const encrypted = parts[1]
    const key = crypto.scryptSync(ENCRYPTION_KEY, "salt", 32)
    const decipher = crypto.createDecipheriv(ALGORITHM, key, iv)

    let decrypted = decipher.update(encrypted, "hex", "utf8")
    decrypted += decipher.final("utf8")

    return decrypted
  } catch (error) {
    console.error("[v0] Decryption error:", error)
    throw new Error("Failed to decrypt data")
  }
}

/**
 * Hashes a string using SHA-256
 */
export function hash(text: string): string {
  return crypto.createHash("sha256").update(text).digest("hex")
}
