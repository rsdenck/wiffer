#!/usr/bin/env bash

set -euo pipefail

MON_IFACE="mon0"
WIFI_IFACE="wlp0s20f3"

SSID="BJNET - Quisela 5GHz"
BSSID="ec:e7:a2:7d:8b:94"

DURACAO=180

DATA=$(date +%Y%m%d_%H%M%S)
BASE="$HOME/tcc_quisela_${DATA}"

mkdir -p "$BASE"

echo "[+] Coleta iniciada"

{
    echo "DATA: $(date)"
    echo "SSID: $SSID"
    echo "BSSID: $BSSID"
    echo
    iw dev
} > "$BASE/ambiente.txt"

echo "[+] Localizando o AP"

iw dev "$WIFI_IFACE" scan 2>/dev/null > "$BASE/scan.txt"

grep -i -A15 "$BSSID" "$BASE/scan.txt" \
    > "$BASE/ap_quisela.txt" || true

echo "[+] Captura de quadros 802.11 (${DURACAO}s)"

timeout "$DURACAO" \
tcpdump \
    -i "$MON_IFACE" \
    -s 0 \
    -w "$BASE/quisela_wifi.pcap" \
    >/dev/null 2>&1 || true

echo "[+] Estatísticas"

{
    echo "ARQUIVO:"
    ls -lh "$BASE/quisela_wifi.pcap"

    echo
    echo "PRIMEIROS PACOTES:"
    tcpdump -nn -e -r "$BASE/quisela_wifi.pcap" 2>/dev/null | head -50
} > "$BASE/resumo.txt"

echo
echo "Arquivos:"
find "$BASE" -type f | sort
