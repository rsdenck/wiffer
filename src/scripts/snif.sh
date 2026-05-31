#!/usr/bin/env bash

set -euo pipefail

MON_IFACE="mon0"
BSSID="ec:e7:a2:7d:8b:94"
SSID="BJNET - Quisela 5GHz"
TEMPO=180

DATA=$(date +%Y%m%d_%H%M%S)
BASE="/root/tcc_quisela_${DATA}"

mkdir -p "$BASE"

PCAP="${BASE}/quisela_wifi.pcap"

echo "=================================================="
echo "LABORATÓRIO WIFI - TCC"
echo "=================================================="
echo "SSID : $SSID"
echo "BSSID: $BSSID"
echo "DIR  : $BASE"
echo

echo "[+] Iniciando captura (${TEMPO}s)..."

timeout "$TEMPO" tcpdump \
    -i "$MON_IFACE" \
    -s 0 \
    -w "$PCAP" \
    >/dev/null 2>&1 || true

echo
echo "[+] Captura finalizada"
echo

echo "=================================================="
echo "ARQUIVO"
echo "=================================================="

ls -lh "$PCAP"

echo
echo "=================================================="
echo "BEACONS DETECTADOS"
echo "=================================================="

tshark -r "$PCAP" \
-Y "wlan.fc.type_subtype == 8" \
-T fields \
-e wlan.bssid \
-e wlan.ssid 2>/dev/null | sort -u

echo
echo "=================================================="
echo "TOP ENDPOINTS WIFI"
echo "=================================================="

tshark -r "$PCAP" \
-q \
-z endpoints,wlan 2>/dev/null

echo
echo "=================================================="
echo "ESTATÍSTICAS GERAIS"
echo "=================================================="

tshark -r "$PCAP" \
-q \
-z io,stat,30 2>/dev/null

echo
echo "=================================================="
echo "PRIMEIROS PACOTES"
echo "=================================================="

tshark -r "$PCAP" \
-c 30 2>/dev/null

echo
echo "=================================================="
echo "RESUMO DO AP QUASELA"
echo "=================================================="

tshark -r "$PCAP" \
-Y "wlan.bssid == $BSSID" \
-T fields \
-e frame.number \
-e frame.time \
-e wlan.fc.type_subtype 2>/dev/null | head -20

echo
echo "[+] Finalizado"
echo "[+] PCAP: $PCAP"
