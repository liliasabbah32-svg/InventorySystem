import React from "react"

interface PermissionSectionProps {
  title: string
  modules: {
    name: string
    key: string
    actions: string[]
  }[]
  userAccess: Record<string, Record<string, boolean>> // user access map
}

const actionLabels: Record<string, string> = {
  view: "عرض",
  add: "إضافة",
  edit: "تعديل/حذف",
  orders: "عرض",
  export: "تصدير",
  print: "طباعة",
}

const PermissionSection: React.FC<PermissionSectionProps> = ({
  title,
  modules,
  userAccess,
}) => {
  // Collect all unique actions to render header dynamically
  const allActions = Array.from(
    new Set(modules.flatMap((m) => m.actions))
  )

  return (
    <div className="space-y-4">
      <h4 className="font-semibold">{title}</h4>
      <div className="grid grid-cols-[200px_repeat(auto-fit,minmax(80px,1fr))] gap-4 p-4 bg-gray-50 rounded-lg">
        {/* Header Row */}
        <div className="font-medium text-sm">الوحدة</div>
        {allActions.map((action) => (
          <div className="font-medium text-sm" key={action}>
            {actionLabels[action] || action}
          </div>
        ))}

        {/* Modules */}
        {modules.map(({ name, key, actions }) => (
          <React.Fragment key={key}>
            <div className="text-sm">{name}</div>
            {allActions.map((action) => (
              <div key={action}>
                <input
                  type="checkbox"
                  className="rounded"
                  checked={!!userAccess[key]?.[action]}
                  readOnly
                  disabled
                />
              </div>
            ))}
          </React.Fragment>
        ))}
      </div>
    </div>
  )
}

export default PermissionSection
