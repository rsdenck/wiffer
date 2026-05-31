import { WifiOff, RefreshCw } from "lucide-react"

export default function Clients({ clients, onKick, onRefresh }) {
  return (
    <div className="bg-slate-900 border border-slate-800 rounded-lg p-6 space-y-6">
      <div className="flex flex-col sm:flex-row justify-between items-start sm:items-center gap-4">
        <div>
          <h2 className="text-lg font-bold text-slate-200">Gestão de Clientes Conectados</h2>
          <p className="text-xs text-slate-400">Dispositivos atualmente associados ao FakeAP.</p>
        </div>
        <button onClick={onRefresh} className="bg-slate-950 hover:bg-slate-800 text-slate-300 font-semibold px-3 py-1.5 rounded text-xs border border-slate-800 flex items-center gap-2">
          <RefreshCw className="h-3 w-3" /> Atualizar
        </button>
      </div>
      <div className="overflow-x-auto">
        <table className="w-full text-left text-sm border-collapse">
          <thead>
            <tr className="border-b border-slate-800 text-slate-400">
              <th className="py-3 font-semibold text-xs uppercase tracking-wider">Hostname</th>
              <th className="py-3 font-semibold text-xs uppercase tracking-wider">IP</th>
              <th className="py-3 font-semibold text-xs uppercase tracking-wider">MAC</th>
              <th className="py-3 font-semibold text-xs uppercase tracking-wider">Sinal</th>
              <th className="py-3 font-semibold text-xs uppercase tracking-wider">Estado</th>
              <th className="py-3 font-semibold text-xs uppercase tracking-wider text-right">Ação</th>
            </tr>
          </thead>
          <tbody className="divide-y divide-slate-800/60">
            {clients.map((c, i) => (
              <tr key={i} className="hover:bg-slate-800/10">
                <td className="py-4"><p className="font-bold text-slate-200">{c.hostname}</p></td>
                <td className="py-4 font-mono text-slate-300">{c.ip}</td>
                <td className="py-4 font-mono text-slate-400 text-xs">{c.mac}</td>
                <td className="py-4">
                  <span className={`inline-block px-2 py-0.5 rounded text-xs font-mono ${
                    c.signal !== "N/A"
                      ? parseInt(c.signal) > -50 ? "text-emerald-400 bg-emerald-950/20" : parseInt(c.signal) > -70 ? "text-amber-400 bg-amber-950/20" : "text-rose-400 bg-rose-950/20"
                      : "text-slate-500 bg-slate-800"
                  }`}>
                    {c.signal !== "N/A" ? `${c.signal} dBm` : "—"}
                  </span>
                </td>
                <td className="py-4">
                  <span className={`text-xs px-2.5 py-1 rounded-full border ${
                    c.online ? "bg-emerald-950/20 text-emerald-400 border-emerald-900/30" : "bg-slate-800 text-slate-500 border-slate-700/50"
                  }`}>
                    {c.online ? "Online" : "Offline"}
                  </span>
                </td>
                <td className="py-4 text-right">
                  {c.online && (
                    <button onClick={() => onKick(c.mac, c.hostname)}
                      className="bg-slate-950 hover:bg-rose-950/40 hover:text-rose-400 text-slate-400 hover:border-rose-900/30 px-3 py-1.5 rounded text-xs border border-slate-800 transition-all font-semibold inline-flex items-center gap-1.5">
                      <WifiOff className="h-3 w-3" /> Kick (Deauth)
                    </button>
                  )}
                </td>
              </tr>
            ))}
            {clients.length === 0 && (
              <tr><td colSpan="6" className="text-center py-10 text-slate-500 font-medium">Nenhum dispositivo conectado.</td></tr>
            )}
          </tbody>
        </table>
      </div>
    </div>
  )
}