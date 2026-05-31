# LINKS DE ADAPTADORES USB WiFi PARA PENTEST

> Links verificados em 30/05/2026. Preços podem variar.
> Chipset necessário: **RTL8812AU** (driver nativo no kernel ≥6.14, apt install, suporta TODOS os 25 ataques da fase2).

---

## 🥇 MERCADO LIVRE (melhor custo-benefício Brasil)

### 1. Realtek Dual Band 1300Mbps — RTL8812AU ✅
- **Chipset confirmado:** RTL8812AU
- **Preço:** ~R$ 80-120 (frete grátis em muitas regiões)
- **Driver:** `apt install rtl8812au-dkms` ou nativo kernel ≥6.14
- **Link:** https://www.mercadolivre.com.br/adaptador-wireless-realtek-dual-band-1300mbps-usb-30-2-antenas/p/MLB51038424

### 2. Busca geral "rtl8812au" no ML
- Filtre por "Realtek RTL8812AU" (evite RTL8812BU)
- Faixa de preço: R$ 60-150
- **Link:** https://lista.mercadolivre.com.br/realtek-rtl8812au

### 3. Busca "adaptador wifi pentest" no ML
- Vários vendedores com produtos genéricos RTL8812AU
- **Link:** https://lista.mercadolivre.com.br/adaptador-wifi-pentest

---

## 🥈 AMAZON BRASIL

### 4. RTL8812AU Placa de Rede Sem Fio — Genérico ✅
- **Chipset confirmado:** RTL8812AU
- **Preço:** ~R$ 89-110
- **Link:** https://www.amazon.com.br/RTL8812AU-Adaptador-Computadores-Desktop-Compat%C3%ADveis/dp/B0D85P6W1H

### 5. Busca geral "rtl8812au" na Amazon BR
- Vários modelos genéricos com RTL8812AU
- Faixa de preço: R$ 40-150 (muitos com frete grátis)
- **Link:** https://www.amazon.com.br/s?k=rtl8812au

### 6. Adaptador WiFi USB AC1200/AC1300 Dual Band (genérico)
- Buscar por "AC1200 USB wifi Linux" na Amazon
- Verificar se o chipset é RTL8812AU nos comentários
- Preço: ~R$ 35-70
- **Link:** https://www.amazon.com.br/s?k=adaptador+wifi+ac1200+linux

---

## 🥉 ALIEXPRESS (mais barato, porém demora ~20-40 dias)

### 7. RTL8812AU Dual Band 1200Mbps — Genérico
- **Preço:** ~US$ 8-10 (~R$ 45-55 + frete)
- **Chipset:** RTL8812AU ou RTL8812BU (confirmar no anúncio)
- **Link de busca:** https://www.aliexpress.com/wholesale?SearchText=rtl8812au

---

## ⭐ RECOMENDAÇÃO TOP 3 (melhor custo-benefício)

| # | Produto | Local | Preço | Chipset | Driver |
|---|---|---|---|---|---|
| 1 | **Realtek Dual Band 1300Mbps** | ML (MLB51038424) | ~R$ 80-120 | RTL8812AU ✅ | Nativo + apt |
| 2 | **RTL8812AU genérico AC1200** | Amazon BR | ~R$ 40-90 | RTL8812AU ✅ (verificar) | apt install |
| 3 | **RTL8812AU AliExpress** | AliExpress | ~R$ 45-55 | RTL8812AU ⚠️ (verificar) | apt install |

---

## ⚠️ EVITAR

- **RTL8812BU** (Pix-Link UAC20, etc.) — driver manual, sem AP mode, injeção instável
- **RTL8821AU** — Bluetooth atrapalha, driver irregular
- **RTL8188FTV** (seu atual buS1) — apenas 2.4GHz, sem WPS/injeção confiável
- **RT5572** — 5GHz instável para monitor mode
- **TP-Link Archer T2U** — chipset RTL8821AU (não recomendado)

---

## Links Úteis

- **Pesquisa ML:** https://lista.mercadolivre.com.br/adaptador-wireless-realtek-dual-band-1300mbps
- **Pesquisa Amazon BR:** https://www.amazon.com.br/s?k=rtl8812au
- **Pesquisa AliExpress:** https://www.aliexpress.com/wholesale?SearchText=rtl8812au
- **Driver rtl8812au-dkms:** https://packages.debian.org/search?keywords=rtl8812au-dkms
- **Guia Kali + RTL8812AU:** https://zsecurity.org/installing-drivers-for-realtek-rtl8812au-on-kali-linux-testing-monitor-mode-packet-injection

## Instalação do Driver

```bash
# Para RTL8812AU (método 1 — apt)
apt update && apt install -y rtl8812au-dkms

# Para RTL8812AU (método 2 — kernel ≥6.14 já tem nativo)
# Não precisa fazer nada, só conectar o adaptador

# Verificar se carregou
lsusb | grep -i realtek
iw dev
```
