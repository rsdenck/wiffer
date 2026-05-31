const API = "/api"

export async function getStatus() {
  const r = await fetch(`${API}/status`)
  return r.json()
}

export async function getClients() {
  const r = await fetch(`${API}/clients`)
  return r.json()
}

export async function getCredentials() {
  const r = await fetch(`${API}/credentials`)
  return r.json()
}

export async function getLogs() {
  const r = await fetch(`${API}/logs`)
  return r.json()
}

export async function getConfig() {
  const r = await fetch(`${API}/config`)
  return r.json()
}

export async function toggleAp(action = "toggle") {
  const r = await fetch(`${API}/ap/toggle`, {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({ action })
  })
  return r.json()
}

export async function kickClient(mac) {
  const r = await fetch(`${API}/client/kick`, {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({ mac })
  })
  return r.json()
}