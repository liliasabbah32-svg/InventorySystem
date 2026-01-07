export default function ProductsLoading() {
  return (
    <div className="space-y-6 p-4 lg:p-6 bg-background min-h-screen" dir="rtl">
      <div className="flex items-center justify-center min-h-[400px]">
        <div className="text-center">
          <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-primary mx-auto mb-4"></div>
          <p className="text-muted-foreground">جاري تحميل الأصناف...</p>
        </div>
      </div>
    </div>
  )
}
