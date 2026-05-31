# RELATÓRIO DE ATAQUE: Bruna_2.4G

## 1. INFORMAÇÕES DA REDE

| Campo | Valor |
|---|---|
| SSID | Bruna_2.4G |
| BSSID | 8C:DC:02:5D:C5:6D |
| Canal | 4 (estável) |
| Banda | 2.4 GHz |
| Sinal | -62 a -68 dBm |
| Criptografia | WPA2/CCMP/PSK |
| WPS | 2.0, destravado (sem lock) |
| Fabricante | — |

## 2. INTERFACES UTILIZADAS

| Interface | Função | Driver |
|---|---|---|
| zsf1 (wlp0s20f3) | Conexão internet (ERROR 404, 5GHz) | iwlwifi |
| buS1 (wlx00e0283412bc) | Ataque/monitor (2.4GHz) | rtl8xxxu (RTL8188FTV) |

## 3. ATAQUES REALIZADOS

### 3.1 PMKID Attack (hcxdumptool) — Primeira tentativa
- **Resultado:** ❌ Falhou — AP não incluiu PMKID na mensagem M1/4
- **Captura:** `pcap/bruna_pmkid.pcapng` (71 pacotes)
- **Análise hcxpcapngtool:** "no hashes written to hash files"

### 3.2 PMKID Attack (hcxdumptool) — Segunda tentativa (2 minutos)
- **Resultado:** ❌ Falhou — AP não incluiu PMKID na mensagem M1/4
- **Captura:** `pcap/bruna_pmkid_2min.pcapng` (252 pacotes, 225 EAPOL M1)
- **Análise hcxpcapngtool:** "no hashes written to hash files"

### 3.3 WPS Pixie-Dust (bully + pixiewps)
- **Resultado:** ❌ Falhou — AP não vulnerável ao Pixie-Dust
- **Motivo:** WPSFail em todas as tentativas, ENonce/PKE capturados mas sem sucesso

### 3.4 WPS PIN Brute Force (bully)
- **Resultado:** ❌ Ferramenta bully não avançou nos PINs (bug no driver rtl8xxxu)
- **PIN testado:** Não avançou além do primeiro PIN gerado

### 3.5 Monitoramento Passivo (airodump-ng)
- **Duração:** Em andamento
- **Arquivo:** `pcap/captura_geral-01.*`
- **Clientes detectados:** Nenhum até o momento

## 4. ARQUIVOS GERADOS

| Arquivo | Descrição |
|---|---|
| `pcap/bruna_pmkid.pcapng` | Captura hcxdumptool (1ª tentativa) |
| `pcap/bruna_pmkid_2min.pcapng` | Captura hcxdumptool (2 min) |
| `pcap/bruna_pmkid_2min.pcap` | Captura convertida (2 min) |
| `pcap/bruna_pmkid_converted.pcap` | Captura convertida (1ª tentativa) |
| `pcap/bruna_hash.22000` | Hash extraído (vazio — sem PMKID) |

## 5. HANDCAPTURE CAPTURADO
- **Frame EAPOL M1:** 225 mensagens capturadas
- **PMKID:** Não presente em nenhuma mensagem
- **Handshake 4-vias:** Incompleto (apenas M1 do AP, sem M2/M3/M4)

## 6. PRÓXIMOS PASSOS RECOMENDADOS

1. Monitorar passivamente com airodump-ng até aparecer cliente
2. Quando cliente aparecer: `aireplay-ng -0 0 -a 8C:DC:02:5D:C5:6D buS1` para deauth
3. Capturar handshake no airodump
4. Crackear com aircrack-ng + wordlist
5. Alternativa: Evil Twin com hostapd se houver clientes ativos

---

*Gerado em 30/05/2026 para ambiente controlado*
