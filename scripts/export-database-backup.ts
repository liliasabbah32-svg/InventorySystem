import { neon } from "@neondatabase/serverless"

const sql = neon(process.env.DATABASE_URL!)

interface TableInfo {
  table_name: string
  table_schema: string
}

interface ColumnInfo {
  column_name: string
  data_type: string
  is_nullable: string
  column_default: string | null
  character_maximum_length: number | null
}

async function exportDatabaseBackup() {
  console.log("[v0] Starting database export...")

  try {
    // Get all tables
    const tables = (await sql`
      SELECT table_name, table_schema 
      FROM information_schema.tables 
      WHERE table_schema = 'public' 
      ORDER BY table_name
    `) as TableInfo[]

    console.log(`[v0] Found ${tables.length} tables to export`)

    let sqlDump = `-- Database Export Generated on ${new Date().toISOString()}\n`
    sqlDump += `-- Arabic ERP System Database Backup\n\n`
    sqlDump += `SET client_encoding = 'UTF8';\n`
    sqlDump += `SET standard_conforming_strings = on;\n\n`

    // Export table structures and data
    for (const table of tables) {
      console.log(`[v0] Exporting table: ${table.table_name}`)

      // Get table structure
      const columns = (await sql`
        SELECT column_name, data_type, is_nullable, column_default, character_maximum_length
        FROM information_schema.columns 
        WHERE table_schema = ${table.table_schema} 
        AND table_name = ${table.table_name}
        ORDER BY ordinal_position
      `) as ColumnInfo[]

      // Create table structure
      sqlDump += `-- Table: ${table.table_name}\n`
      sqlDump += `DROP TABLE IF EXISTS "${table.table_name}" CASCADE;\n`
      sqlDump += `CREATE TABLE "${table.table_name}" (\n`

      const columnDefs = columns.map((col) => {
        let def = `  "${col.column_name}" ${col.data_type}`

        if (col.character_maximum_length) {
          def += `(${col.character_maximum_length})`
        }

        if (col.is_nullable === "NO") {
          def += " NOT NULL"
        }

        if (col.column_default) {
          def += ` DEFAULT ${col.column_default}`
        }

        return def
      })

      sqlDump += columnDefs.join(",\n")
      sqlDump += `\n);\n\n`

      // Export data
      try {
        const data = await sql`SELECT * FROM ${sql(table.table_name)}`

        if (data.length > 0) {
          sqlDump += `-- Data for table: ${table.table_name}\n`

          const columnNames = columns.map((col) => `"${col.column_name}"`).join(", ")

          for (const row of data) {
            const values = columns
              .map((col) => {
                const value = row[col.column_name]
                if (value === null) return "NULL"
                if (typeof value === "string") return `'${value.replace(/'/g, "''")}'`
                if (typeof value === "boolean") return value ? "true" : "false"
                if (value instanceof Date) return `'${value.toISOString()}'`
                if (typeof value === "object") return `'${JSON.stringify(value).replace(/'/g, "''")}'`
                return String(value)
              })
              .join(", ")

            sqlDump += `INSERT INTO "${table.table_name}" (${columnNames}) VALUES (${values});\n`
          }
          sqlDump += `\n`
        }
      } catch (error) {
        console.log(`[v0] Warning: Could not export data for table ${table.table_name}:`, error)
        sqlDump += `-- Warning: Could not export data for table ${table.table_name}\n\n`
      }
    }

    // Export views and custom types
    try {
      const views = await sql`
        SELECT table_name, view_definition 
        FROM information_schema.views 
        WHERE table_schema = 'public'
      `

      if (views.length > 0) {
        sqlDump += `-- Views\n`
        for (const view of views) {
          sqlDump += `CREATE OR REPLACE VIEW "${view.table_name}" AS ${view.view_definition};\n`
        }
        sqlDump += `\n`
      }
    } catch (error) {
      console.log("[v0] Warning: Could not export views:", error)
    }

    // Export custom types
    try {
      const types = await sql`
        SELECT typname, typtype 
        FROM pg_type 
        WHERE typnamespace = (SELECT oid FROM pg_namespace WHERE nspname = 'public')
        AND typtype = 'e'
      `

      if (types.length > 0) {
        sqlDump += `-- Custom Types\n`
        for (const type of types) {
          const enumValues = await sql`
            SELECT enumlabel 
            FROM pg_enum 
            WHERE enumtypid = (
              SELECT oid FROM pg_type WHERE typname = ${type.typname}
            )
            ORDER BY enumsortorder
          `

          const values = enumValues.map((e) => `'${e.enumlabel}'`).join(", ")
          sqlDump += `CREATE TYPE "${type.typname}" AS ENUM (${values});\n`
        }
        sqlDump += `\n`
      }
    } catch (error) {
      console.log("[v0] Warning: Could not export custom types:", error)
    }

    sqlDump += `-- End of database export\n`

    console.log("[v0] Database export completed successfully!")
    console.log(`[v0] Total export size: ${(sqlDump.length / 1024 / 1024).toFixed(2)} MB`)

    // Save to file (in a real environment, you might want to save this to a file or return it)
    return {
      success: true,
      sqlDump,
      tableCount: tables.length,
      exportSize: sqlDump.length,
    }
  } catch (error) {
    console.error("[v0] Database export failed:", error)
    return {
      success: false,
      error: error.message,
    }
  }
}

// Execute the export
exportDatabaseBackup()
  .then((result) => {
    if (result.success) {
      console.log(`[v0] Export completed: ${result.tableCount} tables exported`)
      console.log(`[v0] SQL dump size: ${(result.exportSize / 1024).toFixed(2)} KB`)

      // In a browser environment, you could download the file
      if (typeof window !== "undefined") {
        const blob = new Blob([result.sqlDump], { type: "text/sql" })
        const url = URL.createObjectURL(blob)
        const a = document.createElement("a")
        a.href = url
        a.download = `arabic-erp-backup-${new Date().toISOString().split("T")[0]}.sql`
        document.body.appendChild(a)
        a.click()
        document.body.removeChild(a)
        URL.revokeObjectURL(url)
      }
    } else {
      console.error("[v0] Export failed:", result.error)
    }
  })
  .catch((error) => {
    console.error("[v0] Unexpected error:", error)
  })
