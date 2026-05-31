# RELATÓRIO DE ATAQUE: PTO03-3G

## 1. INFORMAÇÕES DA REDE

| Campo | Valor |
|---|---|
| SSID | PTO03-3G |
| BSSID | 64:DB:38:2D:8E:8E |
| Canal | Variável (CH 1, 2, 8, 11) — seleção automática |
| Banda | 2.4 GHz |
| Sinal | -54 a -58 dBm |
| Criptografia | WPA2/CCMP/PSK |
| WPS | 2.0, destravado (sem lock) |
| Fabricante | — |

## 2. INTERFACES UTILIZADAS

| Interface | Função | Driver |
|---|---|---|
| zsf1 (wlp0s20f3) | Conexão internet (ERROR 404, 5GHz) | iwlwifi |
| buS1 (wlx00e0283412bc) | Ataque/monitor (2.4GHz) | rtl8xxxu (RTL8188FTV) |

## 3. ATAQUES REALIZADOS

### 3.1 PMKID Attack (hcxdumptool)
- **Resultado:** ❌ Falhou — AP não incluiu PMKID na mensagem M1/4
- **Captura:** `pcap/pto03_pmkid.pcapng` (173 pacotes, 153 EAPOL M1)
- **Análise hcxpcapngtool:** "no hashes written to hash files"

### 3.2 WPS Pixie-Dust (bully + pixiewps)
- **Resultado:** ❌ Falhou — AP não vulnerável ao Pixie-Dust
- **Motivo:** WPSFail em todas as tentativas, ENonce/PKE capturados mas sem sucesso

### 3.3 WPS PIN Brute Force (bully)
- **Resultado:** ❌ Ferramenta bully não avançou nos PINs (bug no driver rtl8xxxu)
- **PIN testado:** Variou entre 00000000 e 87588132 (não avançou além do primeiro)

### 3.4 WPS PIN Brute Force (reaver)
- **Resultado:** ❌ Reaver não conseguiu detectar o beacon do AP
- **Motivo:** Driver rtl8xxxu incompatível com o mecanismo de scan do reaver

### 3.5 Monitoramento Passivo (airodump-ng)
- **Duração:** Em andamento
- **Arquivo:** `pcap/captura_geral-01.*`
- **Clientes detectados:** Nenhum até o momento

## 4. ARQUIVOS GERADOS

| Arquivo | Descrição |
|---|---|
| `pcap/pto03_pmkid.pcapng` | Captura hcxdumptool (PMKID) |
| `pcap/pto03_pmkid.pcap` | Captura convertida |
| `pcap/pto03_pmkid_pcap.pcap` | Captura convertida (tcpdump) |
| `pcap/pto03_capture-01.cap` | Varredura airodump inicial |
| `pcap/pto03_capture-01.csv` | Scan CSV |
| `pcap/pto03_capture-01.kismet.csv` | Scan Kismet CSV |
| `pcap/pto03_capture-01.kismet.netxml` | Scan Kismet XML |
| `pcap/pto03_capture-01.log.csv` | Scan log CSV |
| `pcap/pto03_hash.22000` | Hash extraído (vazio — sem PMKID) |

## 5. PRÓXIMOS PASSOS RECOMENDADOS

1. Monitorar passivamente com airodump-ng até aparecer cliente
2. Quando cliente aparecer: `aireplay-ng -0 0 -a 64:DB:38:2D:8E:8E buS1` para deauth
3. Capturar handshake no airodump
4. Crackear com aircrack-ng + wordlist
5. Alternativa: Evil Twin com hostapd se houver clientes ativos

---

*Gerado em 30/05/2026 para ambiente controlado*
