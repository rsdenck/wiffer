#!/bin/bash

INTERFACE="wlp0s20f3"
THRESHOLD_DEAUTH=3
RISK_SCORE=0

trap "echo -e '\nEncerrando...'; exit 0" INT

header() {
    clear
    echo "========================================="
    echo "        WIFI SECURITY AUDIT v3"
    echo "========================================="
    echo "Interface : $INTERFACE"
    echo "Data      : $(date)"
    echo "========================================="
}

get_active_ssid() {
    nmcli -t -f DEVICE,ACTIVE,SSID dev wifi \
        | awk -F: -v iface="$INTERFACE" '$1==iface && $2=="yes"{print $3}'
}

get_active_connection() {
    nmcli -t -f NAME,DEVICE connection show --active \
        | awk -F: -v iface="$INTERFACE" '$2==iface{print $1}'
}

security_analysis() {
    CONN=$(get_active_connection)

    if [ -z "$CONN" ]; then
        echo "Nenhuma conexão ativa."
        return
    fi

    echo "Conexão: $CONN"

    KEYMGMT=$(nmcli -g 802-11-wireless-security.key-mgmt connection show "$CONN")
    PAIRWISE=$(nmcli -g 802-11-wireless-security.pairwise connection show "$CONN")

    echo "Key-Mgmt : $KEYMGMT"
    echo "Cipher   : $PAIRWISE"

    if echo "$PAIRWISE" | grep -qi tkip; then
        echo "⚠ TKIP detectado (inseguro)"
        ((RISK_SCORE+=2))
    fi

    if echo "$KEYMGMT" | grep -qi sae; then
        echo "✔ WPA3 detectado"
    elif echo "$KEYMGMT" | grep -qi wpa-psk; then
        echo "✔ WPA2-PSK detectado"
    else
        echo "⚠ Método desconhecido"
        ((RISK_SCORE+=1))
    fi
}

detect_band() {
    CHANNEL=$(nmcli -f IN-USE,CHAN dev wifi list | awk '/\*/{print $2}')

    if [ "$CHANNEL" -le 14 ]; then
        echo "Banda: 2.4 GHz"
        ((RISK_SCORE+=1))
    else
        echo "Banda: 5 GHz"
    fi
}

check_evil_twin() {
    SSID=$(get_active_ssid)

    if [ -z "$SSID" ]; then
        echo "SSID não identificado."
        return
    fi

    echo "SSID Atual: $SSID"

    COUNT=$(nmcli -t -f SSID,BSSID dev wifi list \
        | awk -F: -v ssid="$SSID" '$1==ssid{print $2}' \
        | sort -u | wc -l)

    if [ "$COUNT" -gt 2 ]; then
        echo "⚠ Múltiplos BSSID detectados ($COUNT)"
        ((RISK_SCORE+=2))
    else
        echo "✔ Nenhum indício de Evil Twin"
    fi
}

check_deauth() {
    EVENTS=$(journalctl -k -n 100 | grep -i deauth | wc -l)

    if [ "$EVENTS" -ge "$THRESHOLD_DEAUTH" ]; then
        echo "⚠ Eventos de desautenticação ($EVENTS)"
        ((RISK_SCORE+=3))
    else
        echo "✔ Sem padrão de ataque deauth"
    fi
}

ping_test() {
    GATEWAY=$(ip route | awk '/default/{print $3}')

    PING=$(ping -c 10 "$GATEWAY")

    LOSS=$(echo "$PING" | awk -F',' '/loss/{print $3}' | tr -dc '0-9')
    LATENCY=$(echo "$PING" | awk -F'/' '/rtt/{print $5}')

    echo "Perda  : $LOSS %"
    echo "Latência: $LATENCY ms"

    if [ "$LOSS" -gt 5 ]; then
        ((RISK_SCORE+=2))
    fi
}

risk_summary() {
    echo
    echo "========== SCORE DE RISCO =========="

    if [ "$RISK_SCORE" -le 1 ]; then
        echo "STATUS: SEGURO"
    elif [ "$RISK_SCORE" -le 4 ]; then
        echo "STATUS: ATENÇÃO"
    else
        echo "STATUS: RISCO ELEVADO"
    fi

    echo "Score Final: $RISK_SCORE"
    echo "===================================="
}

main() {
    header

    echo "[1] Segurança"
    security_analysis
    echo

    echo "[2] Banda"
    detect_band
    echo

    echo "[3] Estabilidade"
    ping_test
    echo

    echo "[4] Evil Twin"
    check_evil_twin
    echo

    echo "[5] Deauth"
    check_deauth
    echo

    risk_summary
}

main

