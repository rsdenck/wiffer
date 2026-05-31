import { Download, Trash2 } from "lucide-react"

export default function Credentials({ credentials }) {
  const clearList = () => {
    if (confirm("Limpar histórico de credenciais?")) {
      window.location.reload()
    }
  }

  const exportTxt = () => {
    let txt = "=== CREDENCIAIS CAPTURADAS ===\n\n"
    credentials.forEach((c, i) => {
      txt += `${i + 1}. [${c.timestamp || "—"}] IP:${c.ip || "—"} | Provider:${c.provider || "—"} | Email:${c.email || "—"} | Senha:${c.senha || "—"}\n`
    })
    const blob = new Blob([txt], { type: "text/plain" })
    const a = document.createElement("a")
    a.href = URL.createObjectURL(blob)
    a.download = `credenciais_${new Date().toISOString().slice(0, 10)}.txt`
    a.click()
  }

  return (
    <div className="bg-slate-900 border border-slate-800 rounded-lg p-6 space-y-6">
      <div className="flex flex-col sm:flex-row justify-between items-start sm:items-center gap-4">
        <div>
          <h2 className="text-lg font-bold text-slate-200">Credenciais Capturadas</h2>
          <p className="text-xs text-slate-400">{credentials.length} credenciais recolhidas.</p>
        </div>
        <div className="flex gap-2">
          <button onClick={clearList} className="bg-slate-950 hover:bg-rose-950/30 hover:text-rose-400 text-slate-300 font-semibold px-3 py-1.5 rounded text-xs border border-slate-800 flex items-center gap-2">
            <Trash2 className="h-3 w-3" /> Limpar
          </button>
          <button onClick={exportTxt} className="bg-indigo-600 hover:bg-indigo-500 text-white font-semibold px-3 py-1.5 rounded text-xs transition-all shadow flex items-center gap-2">
            <Download className="h-3 w-3" /> Exportar (.txt)
          </button>
        </div>
      </div>

      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
        {credentials.map((cred, i) => (
          <div key={i} className="bg-slate-950 border border-slate-800 rounded-lg p-4 relative overflow-hidden group">
            <div className="absolute top-0 right-0 h-1.5 w-full bg-indigo-600 group-hover:bg-emerald-500 transition-colors" />
            <div className="flex justify-between items-center mb-3">
              <span className="text-[10px] bg-indigo-950 text-indigo-400 px-2 py-0.5 rounded border border-indigo-900/40 uppercase font-bold font-mono">
                {cred.provider || "Portal"}
              </span>
              <span className="text-[10px] text-slate-500 font-mono">{cred.timestamp || "—"}</span>
            </div>
            <div className="space-y-2">
              <div className="bg-slate-900/50 p-2.5 rounded border border-slate-800/40 font-mono text-xs">
                <p className="text-[10px] text-slate-500">Email / Utilizador</p>
                <p className="text-slate-200 font-bold break-all mt-0.5">{cred.email || "—"}</p>
              </div>
              <div className="bg-slate-900/50 p-2.5 rounded border border-slate-800/40 font-mono text-xs">
                <p className="text-[10px] text-slate-500">Senha (Password)</p>
                <p className="text-emerald-400 font-bold break-all mt-0.5">{cred.senha || "—"}</p>
              </div>
            </div>
            <div className="mt-3 pt-3 border-t border-slate-900 text-[10px] text-slate-500">
              <span>IP: <strong className="text-slate-400">{cred.ip || "—"}</strong></span>
            </div>
          </div>
        ))}
        {credentials.length === 0 && (
          <div className="col-span-full text-center py-12 bg-slate-950 rounded-lg border border-slate-800 text-slate-500">
            Nenhuma credencial capturada ainda.
          </div>
        )}
      </div>
    </div>
  )
}