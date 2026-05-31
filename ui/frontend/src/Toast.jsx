import { CheckCircle, AlertTriangle, ShieldAlert, Info } from "lucide-react"

export default function Toast({ notification }) {
  if (!notification) return null
  const icons = {
    success: <CheckCircle className="text-emerald-500 h-5 w-5" />,
    warning: <AlertTriangle className="text-amber-500 h-5 w-5" />,
    danger: <ShieldAlert className="text-rose-500 h-5 w-5" />,
    info: <Info className="text-cyan-500 h-5 w-5" />
  }
  return (
    <div className="fixed top-5 right-5 z-50 flex items-center gap-3 px-4 py-3 rounded-lg border shadow-xl bg-slate-900 border-slate-700 transition-all duration-300">
      {icons[notification.type] || icons.info}
      <span className="text-sm font-medium">{notification.message}</span>
    </div>
  )
}