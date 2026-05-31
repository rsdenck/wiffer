#!/bin/bash

############################################
# WIFI SECURITY AUDIT v2.0
# Autor: Ranlens Denck
############################################

INTERFACE="wlp0s20f3"
THRESHOLD_DEAUTH=3
LOGFILE="/tmp/wifi_audit.log"

trap ctrl_c INT

ctrl_c() {
    echo -e "\nEncerrando auditoria..."
    exit 0
}

header() {
    clear
    echo "========================================="
    echo "     WIFI SECURITY & STABILITY AUDIT"
    echo "========================================="
    echo "Interface : $INTERFACE"
    echo "Data      : $(date)"
    echo "========================================="
}

get_active_connection() {
    nmcli -t -f NAME,DEVICE connection show --active \
        | grep "$INTERFACE" \
        | cut -d: -f1
}

get_security_details() {
    CONN=$(get_active_connection)

    if [ -z "$CONN" ]; then
        echo "Nenhuma conexão ativa encontrada."
        return
    fi

    echo "Conexão Ativa: $CONN"

    nmcli connection show "$CONN" \
        | grep -E "802-11-wireless-security.key-mgmt|802-11-wireless-security.pairwise|802-11-wireless-security.group"
}

detect_band() {
    CHANNEL=$(nmcli -f IN-USE,CHAN dev wifi list | awk '/\*/{print $2}')

    if [ "$CHANNEL" -le 14 ]; then
        echo "Banda: 2.4 GHz"
    else
        echo "Banda: 5 GHz"
    fi
}

check_evil_twin() {
    SSID=$(nmcli -t -f ACTIVE,SSID dev wifi | grep "^yes" | cut -d: -f2)

    echo "SSID Atual: $SSID"

    COUNT=$(nmcli -f SSID,BSSID dev wifi list \
        | grep "$SSID" \
        | awk '{print $2}' \
        | sort -u | wc -l)

    if [ "$COUNT" -gt 1 ]; then
        echo "⚠ Possível Evil Twin detectado ($COUNT BSSID encontrados)"
    else
        echo "OK - Nenhum BSSID duplicado"
    fi
}

check_deauth() {
    EVENTS=$(journalctl -k -n 50 | grep -i deauth | wc -l)

    if [ "$EVENTS" -ge "$THRESHOLD_DEAUTH" ]; then
        echo "⚠ Múltiplos eventos de desautenticação detectados ($EVENTS)"
    else
        echo "OK - Sem padrão de ataque de deauth"
    fi
}

check_channel_congestion() {
    CHANNEL=$(nmcli -f IN-USE,CHAN dev wifi list | awk '/\*/{print $2}')

    COUNT=$(nmcli -f CHAN dev wifi list \
        | awk -v ch="$CHANNEL" '$1==ch{count++} END{print count}')

    echo "Redes no mesmo canal: $COUNT"

    if [ "$COUNT" -gt 3 ]; then
        echo "⚠ Canal congestionado"
    fi
}

ping_test() {
    GATEWAY=$(ip route | grep default | awk '{print $3}')

    echo "Testando estabilidade contra gateway $GATEWAY"

    PING=$(ping -c 10 "$GATEWAY")

    LOSS=$(echo "$PING" | grep loss | awk -F',' '{print $3}' | sed 's/% packet loss//')

    LATENCY=$(echo "$PING" | grep rtt | awk -F'/' '{print $5}')

    echo "Perda de pacote: $LOSS%"
    echo "Latência média : $LATENCY ms"
}

main() {
    header

    echo "[1] Segurança detalhada"
    get_security_details
    echo

    echo "[2] Banda"
    detect_band
    echo

    echo "[3] Estabilidade"
    ping_test
    echo

    echo "[4] Detecção de Evil Twin"
    check_evil_twin
    echo

    echo "[5] Eventos de Desautenticação"
    check_deauth
    echo

    echo "[6] Congestionamento de Canal"
    check_channel_congestion
    echo

    echo "========================================="
    echo "Auditoria finalizada."
    echo "========================================="
}

main

