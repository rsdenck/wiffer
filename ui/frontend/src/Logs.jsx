import { useEffect, useRef } from "react"
import { Trash2 } from "lucide-react"

export default function Logs({ logs }) {
  const endRef = useRef(null)

  useEffect(() => {
    if (endRef.current) endRef.current.scrollIntoView({ behavior: "smooth" })
  }, [logs])

  const colorMap = {
    "SUCCESS": "text-emerald-400",
    "WARNING": "text-amber-400",
    "DANGER": "text-rose-400",
    "ERROR": "text-rose-400",
    "CAPTURADO": "text-rose-400",
    "AUTORIZADO": "text-emerald-400",
    "NOVO": "text-cyan-400",
    "ANALISANDO": "text-indigo-400",
    "INFO": "text-slate-300"
  }

  const getColor = (line) => {
    const upper = line.toUpperCase()
    for (const [key, color] of Object.entries(colorMap)) {
      if (upper.includes(key)) return color
    }
    return "text-slate-400"
  }

  const clearLogs = () => {
    if (confirm("Limpar visualizador de logs?")) window.location.reload()
  }

  return (
    <div className="bg-slate-900 border border-slate-800 rounded-lg p-6 space-y-4">
      <div className="flex justify-between items-center">
        <div>
          <h2 className="text-lg font-bold text-slate-200">Terminal de Logs</h2>
          <p className="text-xs text-slate-400">Últimas {logs.length} linhas dos serviços.</p>
        </div>
        <button onClick={clearLogs} className="bg-slate-950 hover:bg-slate-800 text-slate-300 px-3 py-1.5 rounded text-xs border border-slate-800 flex items-center gap-2">
          Limpar
        </button>
      </div>
      <div className="bg-slate-950 border border-slate-800 rounded-lg p-4 h-96 overflow-y-auto font-mono text-xs space-y-1">
        {logs.map((line, i) => (
          <div key={i} className={`${getColor(line)} leading-relaxed`}>
            <span className="text-slate-600 mr-2">{i + 1}</span>
            {line}
          </div>
        ))}
        <div ref={endRef} />
      </div>
    </div>
  )
}