# WiFer - Rogue Access Point Suite

WiFer is a complete penetration testing toolkit for wireless network auditing, featuring a Rogue Access Point (FakeAP), captive portal credential harvesting, full packet capture (pcap) with tshark analysis, and a real-time administration web UI.

## Architecture

```
                    +------------------+       +------------------+
                    |   Internet via   |       |   Target Client  |
                    |   ERROR 404      |       |   (victim)       |
                    |   (zsf1 - AX201) |       |                  |
                    +--------+---------+       +--------+---------+
                             |                          |
                             | NAT MASQUERADE           | Wi-Fi
                             |                          |
                    +--------v---------+       +--------v---------+
                    |   Linux Host     |<------+   FakeAP         |
                    |   (Ubuntu/Deb)   |       |   Lucas_2GHz     |
                    |                  |       |   (buS1 - CH 6)  |
                    |  +------------+  |       |   RTL8188FTV     |
                    |  | Captive    |  |       +------------------+
                    |  | Portal     |  |
                    |  | :8080      |  |
                    |  +------------+  |
                    |                  |
                    |  +------------+  |
                    |  | UI Server  |  |
                    |  | Flask :9000|  |
                    |  +------------+  |
                    |                  |
                    |  +------------+  |
                    |  | Monitor    |  |
                    |  | tcpdump    |  |
                    |  | + tshark   |  |
                    |  +------------+  |
                    +------------------+
```

## Components

### FakeAP (Rogue Access Point)
- **SSID**: Lucas_2GHz (open, no password)
- **Channel**: 6 (2.4 GHz)
- **Interface**: buS1 (RTL8188FTV USB dongle)
- **NAT**: iptables MASQUERADE via zsf1 (Intel AX201, internet via ERROR 404)
- **Processes**: hostapd + dnsmasq running in screen sessions

### Captive Portal
- **Port**: 8080 (redirected from port 80 via iptables)
- **Login pages**: Google and Facebook themed (mobile-first, responsive)
- **Detection**: 302 redirect for non-"/" paths (Android/iOS captive portal detection)
- **Authorization**: After credential capture, iptables ACCEPT + DNS release for the client IP
- **DNS**: Blocked by default (address=/#/192.168.50.1), released per-authorized-client

### Packet Capture & Analysis
- **Global sniffer**: tcpdump on buS1, rotating every 10 minutes, 24-hour retention
- **Per-device capture**: tcpdump filtered by client IP, rotating every hour
- **Analysis**: tshark-based .md reports with DNS queries, HTTP hosts, protocols, and traffic volume
- **Output**: /root/wifi/captures/dispositivos/ (pcap) + /root/wifi/devices/ (analysis)

### Web UI (Administration)
- **Address**: http://192.168.130.5:9000
- **Stack**: Flask (backend API) + React + Vite + Tailwind CSS + lucide-react (frontend)
- **Features**:
  - Real-time dashboard with AP status, uptime, client count, credentials count
  - Client management (view connected devices, signal strength, kick/deauth)
  - Credential viewer with export (.txt) functionality
  - Live log terminal (monitor_24h.log + captive.log)
  - AP start/stop toggle
- **API endpoints**: /api/status, /api/clients, /api/credentials, /api/logs, /api/config, /api/ap/toggle, /api/client/kick

## Directory Structure

```
/root/wifi/
  captures/           - pcap files and captured credentials
    credenciais/      - Captured credentials (todas.txt + JSON per submission)
    dispositivos/     - Per-device pcap files + full_sniffer.pcap
    handshakes/       - WPA handshake captures (PMKID, beacon, EAPOL)
    monitor/          - General monitoring captures
    pmkid/            - PMKID capture files
  conf/
    dnsmasq/          - dnsmasq configuration for FakeAP
    hostapd/          - hostapd configuration for FakeAP
  devices/            - tshark analysis reports (.md)
  docs/
    ataques/          - Attack documentation
    credenciais/      - Network credentials (ERROR 404 password)
    referencias/      - Reference docs (fase3.md, usage.md, adapter specs, etc.)
  src/
    captive_portal.py - HTTP captive portal server (port 8080)
    monitor_24h.sh    - 24-hour monitoring script (tcpdump + tshark)
    scripts/          - Utility scripts (sniffing, Wi-Fi audit, WPS brute)
  ui/
    api_server.py     - Flask API + static file server (port 9000)
    frontend/         - React + Vite frontend source
    fe.html           - UI design reference
    fe.md             - Frontend guidelines
  var/logs/           - Runtime logs and state files
```

## Requirements

### Hardware
- **buS1**: RTL8188FTV USB dongle (2.4 GHz, AP mode) for FakeAP
- **zsf1**: Intel AX201 (5 GHz, station mode) for internet via ERROR 404
- **Recommended upgrade**: RTL8812AU USB adapter (5 GHz + 2.4 GHz, supports all 25 attack types)

### Software
- Linux kernel >= 5.0
- hostapd, dnsmasq, iptables
- tcpdump, tshark, aircrack-ng suite
- Python 3 + Flask + flask-cors
- Node.js 20+ for frontend development

## Usage

### Starting Services
```bash
# Start FakeAP (hostapd + dnsmasq)
sudo hostapd -B /root/wifi/conf/hostapd/lucas_2ghz.conf
sudo dnsmasq -C /root/wifi/conf/dnsmasq/lucas_2ghz.conf -i buS1 --bind-interfaces

# Start captive portal
screen -dmS captive python3 /root/wifi/src/captive_portal.py

# Start 24-hour monitoring
bash /root/wifi/src/monitor_24h.sh

# Start web UI
screen -dmS api python3 /root/wifi/ui/api_server.py
```

### Accessing the UI
Open http://192.168.130.5:9000 in any browser on the same network.

### Reading Captures
1. Install Wireshark: `sudo apt install wireshark`
2. Open .pcap files from /root/wifi/captures/dispositivos/
3. Or read analysis reports (.md) in /root/wifi/devices/

## Key Configurations

- ERROR 404 password: /root/wifi/docs/credenciais/pass.md
- hostapd config: /root/wifi/conf/hostapd/lucas_2ghz.conf
- dnsmasq config: /root/wifi/conf/dnsmasq/lucas_2ghz.conf
- iptables: FORWARD REJECT (buS1 -> zsf1) by default, ACCEPT per authorized IP

## Security Notes

- This tool is designed for authorized security testing only
- All captured data is stored locally in /root/wifi/captures/
- The interface zsf1 (Intel AX201) must never be modified or taken down
- RTL8812AU driver is available via apt (rtl8812au-dkms) on kernel >= 6.14

## Status

- FakeAP, captive portal, monitoring, and web UI are operational
- 3 devices have been observed (Redmi 9C, device_16839148b5f1, rsdenck-dektop)
- Multiple credentials captured and analyzed
- RTL8812AU adapter purchase pending (Amazon BR ~R$89-110)

## License

Internal audit tool. Not for public distribution.
