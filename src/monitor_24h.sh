#!/bin/bash

PCAP_DIR="/root/wifi/captures/dispositivos"
LOG_DIR="/root/wifi/var/logs"
DEVICES_DIR="/root/wifi/devices"
LEASE_FILE="/var/lib/misc/dnsmasq.leases"
KNOWN_DEVS="$LOG_DIR/dispositivos_conhecidos.txt"
PCAP_MAP="$LOG_DIR/pcap_map.txt"

mkdir -p "$PCAP_DIR" "$LOG_DIR" "$DEVICES_DIR"
touch "$KNOWN_DEVS" "$PCAP_MAP"

log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') $*" >> "$LOG_DIR/monitor_24h.log"
    echo "$(date '+%H:%M:%S') $*"
}

log "=== INICIANDO MONITORAMENTO 24H ==="

# --- FULL SNIFFER GLOBAL: captura TODO o tráfego do buS1 ---
FULL_PCAP="$PCAP_DIR/full_sniffer.pcap"
pkill -f "tcpdump -i buS1" 2>/dev/null
nohup tcpdump -i buS1 -s 0 -w "$FULL_PCAP" -G 600 -W 144 > /dev/null 2>&1 &
log "Full sniffer iniciado: $FULL_PCAP (rotacao 10min, 144 arquivos = 24h)"

FULL_ANALYZED_DIR="$PCAP_DIR/analyzed"
mkdir -p "$FULL_ANALYZED_DIR"

ip_lookup() {
    local ip="$1"
    local data
    data=$(curl -s "http://ip-api.com/json/${ip}?fields=query,org,isp,as,country,regionName,city" 2>/dev/null)
    if echo "$data" | grep -q '"org"'; then
        local org=$(echo "$data" | sed 's/.*"org":"//;s/".*//')
        local isp=$(echo "$data" | sed 's/.*"isp":"//;s/".*//')
        local asn=$(echo "$data" | sed 's/.*"as":"//;s/".*//')
        local city=$(echo "$data" | sed 's/.*"city":"//;s/".*//')
        local region=$(echo "$data" | sed 's/.*"regionName":"//;s/".*//')
        local country=$(echo "$data" | sed 's/.*"country":"//;s/".*//')
        echo "$org | $city/$region, $country | $asn"
    fi
}

analisar_dispositivo() {
    local NAME="$1" IP="$2" CAPTURE="$3"
    local MD="$DEVICES_DIR/${NAME}.md"

    [ ! -f "$CAPTURE" ] && return

    log "Analisando $NAME ($IP)..."

    if [ ! -f "$MD" ]; then
        {
            echo "# Dispositivo: $NAME"
            echo ""
            echo "| Campo | Valor |"
            echo "|---|---|"
            echo "| Nome DHCP | $NAME |"
            echo "| Primeira vez visto | $(date '+%Y-%m-%d %H:%M:%S') |"
            echo ""
        } > "$MD"
    fi

    {
        echo "---"
        echo ""
        echo "## Análise $(date '+%Y-%m-%d %H:%M:%S')"
        echo ""
        echo "**Arquivo PCAP:** \`$CAPTURE\`"
        echo "**IP:** $IP"
        echo ""

        echo "### DNS Queries"
        local ts
        ts=$(tshark -r "$CAPTURE" -Y "dns.flags == 0x0100" -T fields -e dns.qry.name 2>/dev/null | sort -u)
        if [ -z "$ts" ]; then
            echo "*Nenhuma*"
        else
            echo "$ts" | while read d; do echo "- $d"; done
        fi
        echo ""

        echo "### Sites Visitados (SNI/TLS)"
        ts=$(tshark -r "$CAPTURE" -Y "tls.handshake.type == 1" -T fields -e tls.handshake.extensions_server_name 2>/dev/null | sort -u)
        if [ -z "$ts" ]; then
            echo "*Nenhum*"
        else
            echo "$ts" | while read d; do echo "- $d"; done
        fi
        echo ""

        echo "### IPs Destino Mais Acessados"
        local ips
        ips=$(tcpdump -r "$CAPTURE" -nn 2>/dev/null | awk '{print $3}' | cut -d. -f1-4 | sort | uniq -c | sort -rn | head -15)
        echo '```'
        echo "$ips"
        echo '```'
        echo ""
        echo "| IP | Organização | Localização |"
        echo "|---|---|---|"
        echo "$ips" | awk '{print $2}' | while read ipaddr; do
            [ -z "$ipaddr" ] && continue
            info=$(ip_lookup "$ipaddr")
            echo "| $ipaddr | ${info:-*não resolvido*} |"
        done
        echo ""

        echo "### Volume de Tráfego"
        local BYTES PKTS
        BYTES=$(tcpdump -r "$CAPTURE" -nn 2>/dev/null | awk '{sum += $NF} END {print sum}' | sed 's/[a-zA-Z)]//g')
        PKTS=$(tcpdump -r "$CAPTURE" -nn 2>/dev/null | wc -l)
        echo "- **Pacotes:** $PKTS"
        echo "- **Bytes:** ${BYTES:-0}"
        echo ""

        echo "### Timeline"
        local FIRST LAST
        FIRST=$(tcpdump -r "$CAPTURE" -tttt 2>/dev/null | awk '{print $1, $2}' | head -1)
        LAST=$(tcpdump -r "$CAPTURE" -tttt 2>/dev/null | awk '{print $1, $2}' | tail -1)
        echo "- **Início:** ${FIRST:-N/A}"
        echo "- **Fim:** ${LAST:-N/A}"
        echo ""

        echo "### Conexões TCP Estabelecidas"
        ts=$(tshark -r "$CAPTURE" -Y "tcp.flags.syn == 1 and tcp.flags.ack == 0" -T fields -e ip.src -e ip.dst -e tcp.dstport 2>/dev/null | sort -u | head -30)
        if [ -z "$ts" ]; then
            echo "*Nenhuma*"
        else
            echo '```'
            echo "$ts"
            echo '```'
        fi
        echo ""

    } >> "$MD" 2>/dev/null

    log "Análise adicionada em $MD"
}

# Restore capture map from existing marker files on startup
for marker in "$LOG_DIR"/.capturing_*; do
    [ -f "$marker" ] || continue
    read name ip cap_path < "$marker"
    if [ -n "$name" ] && [ -n "$ip" ]; then
        echo "$cap_path|$name|$ip" >> "$PCAP_MAP"
    fi
done

while true; do
    # --- Detect new devices via DHCP leases ---
    if [ -f "$LEASE_FILE" ]; then
        while IFS=' ' read -r exp mac ip name rest; do
            [ -z "$ip" ] && continue
            DEVNAME="${name:-desconhecido}"
            DEVNAME_SAFE=$(echo "$DEVNAME" | tr -dc 'a-zA-Z0-9_-')
            [ -z "$DEVNAME_SAFE" ] && DEVNAME_SAFE="device_$(echo $mac | tr -d ':')"
            MARKER="$LOG_DIR/.capturing_${ip}_${DEVNAME_SAFE}"

            if [ ! -f "$MARKER" ]; then
                CAPTURE="$PCAP_DIR/${DEVNAME_SAFE}_$(date '+%Y%m%d_%H%M%S').pcap"
                echo "$DEVNAME_SAFE $ip $CAPTURE" > "$MARKER"
                echo "$CAPTURE|$DEVNAME_SAFE|$ip" >> "$PCAP_MAP"
                log "Novo dispositivo: $DEVNAME_SAFE ($ip) - capturando per-device em $CAPTURE"

                # Per-device full sniffer (filtrado por IP do dispositivo)
                nohup tcpdump -i buS1 -s 0 -w "$CAPTURE" host "$ip" -G 3600 -W 24 > /dev/null 2>&1 &
            fi
        done < "$LEASE_FILE"
    fi

    # --- Analisar .pcap do full sniffer que completaram rotação ---
    for pcap in "$PCAP_DIR"/full_sniffer.pcap[0-9]*; do
        [ -f "$pcap" ] || continue
        BASENAME=$(basename "$pcap")
        ANALYZED="$FULL_ANALYZED_DIR/$BASENAME.analyzed"
        [ -f "$ANALYZED" ] && continue
        touch "$ANALYZED"

        log "Analisando captura global: $BASENAME"

        # Analisar para cada dispositivo conhecido
        while IFS='|' read -r cap name ip; do
            [ -z "$name" ] && continue
            analisar_dispositivo "$name" "$ip" "$pcap"
        done < "$PCAP_MAP"

        # Também analisar dispositivos com lease ativo que não estão no map
        if [ -f "$LEASE_FILE" ]; then
            while IFS=' ' read -r exp mac ip name rest; do
                [ -z "$ip" ] && continue
                DEVNAME="${name:-desconhecido}"
                DEVNAME_SAFE=$(echo "$DEVNAME" | tr -dc 'a-zA-Z0-9_-')
                [ -z "$DEVNAME_SAFE" ] && DEVNAME_SAFE="device_$(echo $mac | tr -d ':')"
                analisar_dispositivo "$DEVNAME_SAFE" "$ip" "$pcap"
            done < "$LEASE_FILE"
        fi
    done

    # --- Analisar .pcap por dispositivo (per-device captures) ---
    for pcap in "$PCAP_DIR"/*.pcap; do
        [ -f "$pcap" ] || continue
        BASENAME=$(basename "$pcap")
        # Pular capturas globais (analisadas separadamente)
        [[ "$BASENAME" == full_sniffer.pcap* ]] && continue
        # Pular se ainda está sendo escrito (modificado nos últimos 30s)
        ANALYZED="$FULL_ANALYZED_DIR/$BASENAME.analyzed"
        [ -f "$ANALYZED" ] && continue

        # Verificar se o arquivo não está mais sendo escrito
        NOW=$(date +%s)
        LAST_MOD=$(stat -c %Y "$pcap" 2>/dev/null)
        [ -z "$LAST_MOD" ] && continue
        DIFF=$((NOW - LAST_MOD))
        [ "$DIFF" -lt 30 ] && continue

        touch "$ANALYZED"
        log "Analisando captura per-device: $BASENAME"

        # Look up device name from pcap_map
        DEVNAME=""
        IP=""
        while IFS='|' read -r cap name ip; do
            if [ "$cap" = "$pcap" ]; then
                DEVNAME="$name"
                IP="$ip"
                break
            fi
        done < "$PCAP_MAP"

        if [ -z "$DEVNAME" ]; then
            BASENAME_CLEAN=$(echo "$BASENAME" | sed 's/_[0-9]\{8\}_[0-9]\{6\}\.pcap$//')
            DEVNAME="$BASENAME_CLEAN"
            IP="desconhecido"
        fi

        [ -z "$DEVNAME" ] && DEVNAME="desconhecido"
        analisar_dispositivo "$DEVNAME" "$IP" "$pcap"
    done

    sleep 10
done
