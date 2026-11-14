import sql from "@/lib/database"
import { findUsedIds, type UsageRule } from "@/lib/delete-guard"
import type { StepContext } from "@/lib/shamel-migration/core"

// حذف التعريفات المساعدة الحالية قبل الترحيل (مرة واحدة لكل تشغيل، قبل أول خطوة) — تحل محلها تعريفات الشامل.
// كل سجل يُفحص بنفس قواعد فحص الحذف العادي (lib/delete-guard.ts) — دفعة واحدة لكل جدول: المستخدم في
// حركات/أصناف/إعدادات يبقى ويُسجَّل تنبيه. الترتيب: الأبناء قبل الآباء (مراكز التكلفة قبل أنواعها، فروع البنوك قبل البنوك).

type ResetTarget = {
  table: string
  label: string
  /** خريطة الترحيل المرتبطة (تُنظَّف من المعرّفات المحذوفة) */
  mapKinds: string[]
  where?: string
  name: string
  rule: Omit<UsageRule, "textValues">
  /** حقول السجل التي قد تُحفظ نصاً بدل المعرّف في جداول أخرى */
  textFields?: string[]
  /** جدول هرمي: الأب يُحذف بعد أبنائه، ولا يُحذف إن بقي له ابن */
  parentColumn?: string
}

const TARGETS: ResetTarget[] = [
  {
    table: "cost_centers", label: "مراكز التكلفة", mapKinds: ["costcenter"], name: "name", parentColumn: "parent_id",
    rule: { idColumns: /^(cost_center_id|costcenter_id|default_cost_center_id|.+_cost_center_id)$/, excludeTables: ["cost_centers"] },
  },
  {
    table: "cost_center_types", label: "أنواع مراكز التكلفة", mapKinds: ["costcenter_type"], name: "name",
    rule: { idColumns: /^(cost_type_id|cost_center_type_id)$/, excludeTables: ["cost_center_types"] },
  },
  {
    table: "branches", label: "فروع البنوك", mapKinds: ["bank_branch"], where: "COALESCE(is_bank_branch, false) = true", name: "branch_name",
    rule: { idColumns: /^(branch_id|bank_branch_id)$/, excludeTables: ["branches", "product_branches", "account_branches", "customer_branches"] },
  },
  {
    table: "banks", label: "البنوك", mapKinds: ["bank"], name: "bank_name",
    rule: { idColumns: /^bank_id$/, excludeTables: ["banks"] },
  },
  {
    table: "item_groups", label: "مجموعات الأصناف", mapKinds: ["item_group"], name: "group_name", parentColumn: "parent_group_id",
    rule: { idColumns: /^(main_stock_id|item_group_id)$/, excludeTables: ["item_groups"] },
  },
  {
    table: "warehouses", label: "المستودعات", mapKinds: ["store"], name: "warehouse_name", textFields: ["warehouse_name", "warehouse_code"],
    rule: { idColumns: /^(warehouse_id|.+_warehouse_id|store_id|.+_store_id|default_store)$/, textColumns: /^warehouse$/, excludeTables: ["warehouses", "product_warehouses"] },
  },
  {
    table: "units", label: "الوحدات", mapKinds: ["item_unit"], name: "unit_name", textFields: ["unit_name", "unit_name_en"],
    rule: { idColumns: /^(unit_id|.+_unit_id|measurment_unit)$/, textColumns: /^unit$/, excludeTables: ["units"] },
  },
  {
    table: "pricecategory", label: "فئات الأسعار", mapKinds: ["price_class"], name: "name",
    rule: { idColumns: /^(pricecategory|pricecategory_id|price_category_id|price_category)$/, excludeTables: ["pricecategory"] },
  },
  {
    table: "cities", label: "المدن", mapKinds: ["city"], name: "name", textFields: ["name"],
    rule: { idColumns: /^city_id$/, textColumns: /^city$/, excludeTables: ["cities"] },
  },
  {
    table: "customer_categories", label: "تصنيفات العملاء", mapKinds: ["customer_class"], name: "name", textFields: ["name"],
    rule: { idColumns: /^(customer_category_id|customer_categories_id)$/, textColumns: /^classification$/, excludeTables: ["customer_categories"] },
  },
  {
    table: "salesmen", label: "المندوبون", mapKinds: ["salesman"], name: "name", textFields: ["name"],
    rule: { idColumns: /^(salesman_id|supervisor_id|sales_man_id)$/, textColumns: /^salesman$/, excludeTables: ["salesmen", "salesman_targets", "salesman_commission_rules"] },
  },
]

async function tableExists(table: string) {
  return Boolean(((await sql`SELECT to_regclass(${table}) IS NOT NULL AS ok`)[0] as any)?.ok)
}

export async function resetLookups(ctx: StepContext) {
  const summary: string[] = []
  for (const target of TARGETS) {
    if (!(await tableExists(target.table))) continue
    const rows = (await sql.unsafe(`SELECT * FROM ${target.table}${target.where ? ` WHERE ${target.where}` : ""}`)) as any[]
    if (rows.length) {
      const ids = rows.map((row) => Number(row.id))
      const textsById = new Map<number, string[]>(target.textFields ? rows.map((row) => [Number(row.id), target.textFields!.map((field) => String(row[field] ?? ""))]) : [])
      const used = await findUsedIds(ids, { ...target.rule, textsById })
      for (const [id, tables] of used) {
        const row = rows.find((item) => Number(item.id) === id)
        ctx.warn(row?.[target.name], `${target.label}: لم يُحذف لأنه مستخدم في ${tables.slice(0, 4).join("، ")}`)
      }
      // الهرمي: يُحذف الأبناء أولاً، والأب الذي بقي له ابن (مستخدم) يبقى
      let remaining = rows.filter((row) => !used.has(Number(row.id)))
      const keptParents = new Set<number>()
      let deleted = 0
      for (let pass = 0; pass < 50 && remaining.length; pass++) {
        const alive = new Set(rows.map((row) => Number(row.id)).filter((id) => used.has(id) || keptParents.has(id) || remaining.some((row) => Number(row.id) === id)))
        const leaves = target.parentColumn
          ? remaining.filter((row) => !rows.some((child) => alive.has(Number(child.id)) && Number(child[target.parentColumn!]) === Number(row.id)))
          : remaining
        if (!leaves.length) break
        for (const row of leaves) {
          try {
            await sql.unsafe(`DELETE FROM ${target.table} WHERE id = $1`, [Number(row.id)])
            deleted++
          } catch (error) {
            keptParents.add(Number(row.id))
            ctx.warn(row[target.name], `${target.label}: تعذر الحذف — ${error instanceof Error ? error.message : String(error)}`)
          }
        }
        const done = new Set(leaves.map((row) => Number(row.id)))
        remaining = remaining.filter((row) => !done.has(Number(row.id)))
      }
      const kept = rows.length - deleted
      summary.push(`${target.label}: حُذف ${deleted}${kept ? `، أُبقي ${kept} مستخدَم` : ""}`)
    }
    // روابط الترحيل لسجلات لم تعد موجودة تُزال فتُنشأ من جديد
    await sql.unsafe(
      `DELETE FROM shamel_migration_map m WHERE m.kind = ANY($1::text[]) AND NOT EXISTS (SELECT 1 FROM ${target.table} t WHERE t.id = m.web_id)`,
      [target.mapKinds],
    )
  }
  ctx.info(`حذف التعريفات المساعدة قبل الترحيل — ${summary.join(" | ") || "لا توجد سجلات"}`)
}
