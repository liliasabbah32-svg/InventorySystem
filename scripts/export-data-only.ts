import { neon } from "@neondatabase/serverless"

const sql = neon(process.env.DATABASE_URL!)

async function exportDataOnly() {
  console.log("[v0] Starting data-only export...")

  try {
    const tables = [
      "products",
      "customers",
      "suppliers",
      "warehouses",
      "sales_orders",
      "sales_order_items",
      "purchase_orders",
      "purchase_order_items",
      "product_lots",
      "lot_transactions",
      "inventory_transactions",
      "user_settings",
      "system_settings",
      "general_settings",
    ]

    const jsonExport = {
      exportDate: new Date().toISOString(),
      version: "1.0",
      tables: {} as Record<string, any[]>,
    }

    for (const tableName of tables) {
      try {
        console.log(`[v0] Exporting data from: ${tableName}`)
        const data = await sql`SELECT * FROM ${sql(tableName)}`
        jsonExport.tables[tableName] = data
        console.log(`[v0] Exported ${data.length} records from ${tableName}`)
      } catch (error) {
        console.log(`[v0] Warning: Could not export ${tableName}:`, error)
        jsonExport.tables[tableName] = []
      }
    }

    console.log("[v0] Data export completed successfully!")

    return {
      success: true,
      data: jsonExport,
      tableCount: Object.keys(jsonExport.tables).length,
    }
  } catch (error) {
    console.error("[v0] Data export failed:", error)
    return {
      success: false,
      error: error.message,
    }
  }
}

// Execute the export
exportDataOnly()
  .then((result) => {
    if (result.success) {
      console.log(`[v0] Data export completed: ${result.tableCount} tables exported`)

      // In a browser environment, you could download the JSON file
      if (typeof window !== "undefined") {
        const jsonString = JSON.stringify(result.data, null, 2)
        const blob = new Blob([jsonString], { type: "application/json" })
        const url = URL.createObjectURL(blob)
        const a = document.createElement("a")
        a.href = url
        a.download = `arabic-erp-data-${new Date().toISOString().split("T")[0]}.json`
        document.body.appendChild(a)
        a.click()
        document.body.removeChild(a)
        URL.revokeObjectURL(url)
      }
    } else {
      console.error("[v0] Data export failed:", result.error)
    }
  })
  .catch((error) => {
    console.error("[v0] Unexpected error:", error)
  })
