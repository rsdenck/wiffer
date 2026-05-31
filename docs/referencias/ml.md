# ANÁLISE: PIX-LINK AC1200 UAC20 (RTL8812BU)

## Produto
- **Link ML:** https://www.mercadolivre.com.br/adaptador-usb30-wireless-245ghz-ac1200-pentest-kali-linux/up/MLBU1430199504
- **Link alternativo:** https://www.mercadolivre.com.br/adaptador-usb-30-wifi-pixlink-5dbi-dualband-kali-linux/up/MLBU1440830036
- **Marca:** Pix-Link
- **Modelo:** UAC20
- **Chipset:** Realtek RTL8812BU (NÃO é RTL8812AU!)
- **Banda:** 2.4GHz + 5GHz
- **Interface:** USB 3.0
- **Antenas:** 2x 5dBi externas
- **Preço estimado:** ~R$ 100-150

## ⚠️ ALERTA: RTL8812BU vs RTL8812AU

| Característica | RTL8812AU | RTL8812BU (este produto) |
|---|---|---|
| Driver no kernel (6.14+) | ✅ Nativo (rtw88) | ❌ Não |
| DKMS no apt | ✅ `rtl8812au-dkms` | ❌ Não disponível |
| Instalação | `apt install` | Manual (git clone + make) |
| Modo Monitor | ✅ Excelente | ⚠️ Funciona, mas instável |
| Injeção de pacotes | ✅ | ⚠️ Relatos mistos |
| AP mode (hostapd) | ✅ Excelente | ❌ Driver diz "no AP mode" |
| WPS (reaver/bully) | ✅ | ⚠️ Não testado |

O RTL8812BU precisa de driver manual do GitHub:
```bash
git clone -b v5.13.1 https://github.com/munzoorf95/rtl8812bu-Kali-Linux.git
cd rtl8812bu-Kali-Linux
make && sudo make install
```

## Alternativas na faixa R$ 100-200

### Opção 1: Pix-Link UAC20 (RTL8812BU) — ~R$ 100-150
- ✅ Dual-band, 2 antenas, USB 3.0
- ✅ Funciona com Kali (com driver manual)
- ✅ Modo monitor + injeção (segundo o fabricante)
- ❌ Driver manual (sem apt)
- ❌ AP mode não suportado (sem hostapd como AP!)
- ⚠️ Risco de incompatibilidade em 5GHz

### Opção 2: Realtek Dual Band 1300Mbps (RTL8812AU) — ~R$ 80-120
- ✅ Chipset RTL8812AU (driver `rtl8812au-dkms` no apt)
- ✅ Plug & play no kernel 6.14+
- ✅ Todos os ataques funcionam
- **Link:** https://www.mercadolivre.com.br/adaptador-wireless-realtek-dual-band-1300mbps-usb-30-2-antenas/p/MLB51038424

### Opção 3: TP-Link Archer T2U Plus / T3U (RTL8821AU/RTL8812BU) — ~R$ 70-120
- ⚠️ Chipset varia (RTL8821AU ou RTL8812BU)
- Driver manual necessário
- Menos potência que as opções com antenas externas grandes

### Opção 4: Adaptador USB AC1200 genérico (RTL8812AU) — ~R$ 60-100
- No Mercado Livre, pesquise por "rtl8812au"
- Verifique se o anúncio especifica RTL8812AU (não BU!)
- Mesmo chipset do AWUS036ACH (mais barato)

## Veredito
**O Pix-Link UAC20 (RTL8812BU) deve funcionar para monitor/injeção**, mas:
1. Exige driver manual (sem apt)
2. Pode ter instabilidade em 5GHz
3. **NÃO funciona como AP** (sem hostapd como ponto de acesso)
4. Se for usar AP falso (Evil Twin), precisa de outro adaptador

**Recomendação:** Se couber no orçamento, prefira um adaptador com **RTL8812AU** (mesma faixa de preço ~R$ 80-150). Se não achar, o Pix-Link serve — mas prepare-se para compilar driver manualmente e aceitar que AP mode pode não funcionar.
