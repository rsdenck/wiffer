#!/bin/bash
#############################################
#    WIFI SECURITY & STABILITY AUDIT        #
#############################################

THRESHOLD_DEAUTH=3
RISK_SCORE=0
trap "echo -e '\nEncerrando auditoria...'; exit 0" INT

############################################
# Detecta automaticamente a interface Wi-Fi conectada
############################################
detect_wifi_interface() {
    nmcli -t -f DEVICE,TYPE,STATE device status \
        | awk -F: '$2=="wifi" && $3=="connected"{print $1; exit}'
}

############################################
# Header
############################################
print_header() {
    clear
    echo "========================================="
    echo "     WIFI SECURITY & STABILITY AUDIT"
    echo "========================================="
    echo "Interface : $INTERFACE"
    echo "Data      : $(date)"
    echo "========================================="
}

############################################
# Informações de Conexão
############################################
get_connection_name() {
    nmcli -t -f DEVICE,CONNECTION device status \
        | awk -F: -v iface="$INTERFACE" '$1==iface{print $2}'
}

get_ssid() {
    nmcli -t -f GENERAL.CONNECTION device show "$INTERFACE" \
        | cut -d: -f2-
}

get_channel() {
    nmcli -f IN-USE,CHAN dev wifi list \
        | awk '/\*/{print $2}'
}

############################################
# Segurança
############################################
security_analysis() {
    echo "[1] Segurança da Conexão"

    CONN=$(get_connection_name)
    SSID=$(get_ssid)

    if [ -z "$CONN" ]; then
        echo "Conexão : Nenhuma conexão ativa"
        ((RISK_SCORE+=3))
        return
    fi

    # Tenta pegar dados do cipher via iw
    IWFULL=$(iw dev "$INTERFACE" link 2>/dev/null)
    CIPHER=$(echo "$IWFULL" | awk '/pairwise ciphers/{print $3}')
    KEYMGMT=$(echo "$IWFULL" | awk '/key management/{print $3}')

    # fallback para nmcli caso iw falhe
    [ -z "$CIPHER" ] && CIPHER=$(nmcli -g 802-11-wireless-security.pairwise connection show "$CONN")
    [ -z "$KEYMGMT" ] && KEYMGMT=$(nmcli -g 802-11-wireless-security.key-mgmt connection show "$CONN")

    echo "Conexão       : $CONN"
    echo "Autenticação  : ${KEYMGMT:-N/A}"
    echo "Cipher        : ${CIPHER:-N/A}"

    if echo "$CIPHER" | grep -qi tkip; then
        echo "Análise       : TKIP detectado (INSEGURO)"
        ((RISK_SCORE+=3))
    elif echo "$CIPHER" | grep -qi ccmp; then
        echo "Análise       : AES/CCMP detectado (Seguro)"
    else
        echo "Análise       : Cipher não identificado"
    fi

    if echo "$KEYMGMT" | grep -qi sae; then
        echo "Modo          : WPA3"
    elif echo "$KEYMGMT" | grep -qi wpa-psk; then
        echo "Modo          : WPA2-PSK"
    else
        echo "Modo          : N/A"
    fi

    echo
}

############################################
# Banda
############################################
band_analysis() {
    echo "[2] Análise de Banda"
    CHANNEL=$(get_channel)

    if [ -z "$CHANNEL" ]; then
        echo "Canal : Não identificado"
        return
    fi

    echo "Canal : $CHANNEL"
    if [ "$CHANNEL" -le 14 ]; then
        echo "Banda : 2.4 GHz"
        echo "Impacto: Maior interferência potencial"
        ((RISK_SCORE+=1))
    else
        echo "Banda : 5 GHz"
        echo "Impacto: Melhor estabilidade e desempenho"
    fi
    echo
}

############################################
# Estabilidade
############################################
stability_test() {
    echo "[3] Teste de Estabilidade"
    GATEWAY=$(ip route | awk '/default/{print $3}')

    if [ -z "$GATEWAY" ]; then
        echo "Gateway não identificado."
        ((RISK_SCORE+=2))
        return
    fi

    PING=$(ping -c 10 "$GATEWAY" 2>/dev/null)
    LOSS=$(echo "$PING" | awk -F',' '/loss/{print $3}' | tr -dc '0-9')
    LATENCY=$(echo "$PING" | awk -F'/' '/rtt/{print $5}')

    echo "Gateway        : $GATEWAY"
    echo "Perda Pacotes  : ${LOSS:-0} %"
    echo "Latência Média : ${LATENCY:-N/A} ms"

    if [ "${LOSS:-0}" -gt 5 ]; then
        echo "Análise        : Instabilidade detectada"
        ((RISK_SCORE+=2))
    else
        echo "Análise        : Conexão estável"
    fi
    echo
}

############################################
# Deauth
############################################
deauth_check() {
    echo "[4] Eventos de Desautenticação"
    EVENTS=$(journalctl -k -n 100 2>/dev/null | grep -i deauth | wc -l)
    echo "Eventos recentes : $EVENTS"

    if [ "$EVENTS" -ge "$THRESHOLD_DEAUTH" ]; then
        echo "Análise          : Possível ataque de deauth"
        ((RISK_SCORE+=3))
    else
        echo "Análise          : Sem padrão suspeito"
    fi
    echo
}

############################################
# Evil Twin
############################################
evil_twin_check() {
    echo "[5] Análise de Múltiplos BSSID"
    SSID=$(get_ssid)
    if [ -z "$SSID" ]; then
        echo "SSID : Não identificado"
        return
    fi
    echo "SSID : $SSID"
    COUNT=$(nmcli -t -f SSID,BSSID dev wifi list \
        | awk -F: -v ssid="$SSID" '$1==ssid{print $2}' \
        | sort -u | wc -l)
    echo "BSSID detectados : $COUNT"

    if [ "$COUNT" -gt 3 ]; then
        echo "Análise          : Estrutura com múltiplos APs (verificar contexto)"
        ((RISK_SCORE+=2))
    else
        echo "Análise          : Estrutura normal"
    fi
    echo
}

############################################
# Saturação de Canal
############################################
channel_congestion() {
    echo "[6] Saturação de Canal"
    CHANNEL=$(get_channel)
    COUNT=$(nmcli -f CHAN dev wifi list \
        | awk -v ch="$CHANNEL" '$1==ch{count++} END{print count}')
    echo "Redes no canal $CHANNEL : $COUNT"

    if [ "$COUNT" -gt 3 ]; then
        echo "Análise              : Canal congestionado"
        ((RISK_SCORE+=1))
    else
        echo "Análise              : Baixa ocupação"
    fi
    echo
}

############################################
# Resumo final
############################################
risk_summary() {
    echo "========================================="
    echo "Resumo Final de Risco"
    echo "========================================="
    echo "Score Total : $RISK_SCORE"
    if [ "$RISK_SCORE" -le 1 ]; then
        echo "Classificação : SEGURO"
    elif [ "$RISK_SCORE" -le 4 ]; then
        echo "Classificação : ATENÇÃO"
    else
        echo "Classificação : RISCO ELEVADO"
    fi
    echo "========================================="
}

############################################
# MAIN
############################################
INTERFACE=$(detect_wifi_interface)
if [ -z "$INTERFACE" ]; then
    echo "Nenhuma interface Wi-Fi conectada encontrada."
    exit 1
fi

print_header
security_analysis
band_analysis
stability_test
deauth_check
evil_twin_check
channel_congestion
risk_summary

