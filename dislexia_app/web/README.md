# 🌐 Configuração Web - Flutter

## 📋 Estrutura da Pasta Web

Esta pasta contém todos os arquivos necessários para executar o app Flutter na web.

```
web/
├── index.html           # Ponto de entrada HTML
├── manifest.json        # PWA manifest
├── favicon.png          # Ícone da aba do navegador (adicionar)
└── icons/              # Ícones PWA (adicionar arquivos PNG reais)
    ├── Icon-192.png
    ├── Icon-512.png
    ├── Icon-maskable-192.png
    └── Icon-maskable-512.png
```

---

## 🚀 Como Executar no Navegador

### 1. Certificar que o Flutter Web está habilitado:

```bash
flutter config --enable-web
```

### 2. Executar no Chrome:

```bash
flutter run -d chrome
```

### 3. Executar em outro navegador:

```bash
# Edge
flutter run -d edge

# Safari (macOS)
flutter run -d safari

# Servidor web local
flutter run -d web-server --web-port 8080
```

---

## 🏗️ Build para Produção

### Build padrão:

```bash
flutter build web
```

Arquivos gerados em: `build/web/`

### Build otimizado:

```bash
flutter build web --release --web-renderer canvaskit
```

**Opções de renderer:**
- `canvaskit`: Melhor desempenho, maior tamanho
- `html`: Menor tamanho, compatibilidade maior
- `auto`: Flutter decide automaticamente

---

## 🎨 Adicionar Ícones

Os ícones na pasta `web/icons/` são referenciados no `manifest.json` para instalação PWA.

### Opção 1: Gerador Online

Use https://www.favicon-generator.org/ ou https://realfavicongenerator.net/

1. Upload da sua logo (mínimo 512x512 px)
2. Download do pacote de ícones
3. Substitua os arquivos na pasta `web/icons/`

### Opção 2: Usando Ferramenta ImageMagick

```bash
# Instalar ImageMagick
sudo apt install imagemagick

# Converter logo.png para ícones
convert logo.png -resize 192x192 web/icons/Icon-192.png
convert logo.png -resize 512x512 web/icons/Icon-512.png
```

### Tamanhos Necessários:

- **Icon-192.png**: 192x192 px (ícone padrão)
- **Icon-512.png**: 512x512 px (ícone de alta resolução)
- **Icon-maskable-192.png**: 192x192 px (com padding para Android)
- **Icon-maskable-512.png**: 512x512 px (com padding para Android)

### Adicionar Favicon:

Crie ou converta `favicon.png` (32x32 ou 64x64 px) e coloque na pasta `web/`:

```bash
convert logo.png -resize 32x32 web/favicon.png
```

---

## ⚙️ Configuração PWA (Progressive Web App)

### O que é PWA?

Um PWA permite que usuários "instalem" o app web no dispositivo, funcionando como um app nativo.

### Arquivo manifest.json

Já configurado em `web/manifest.json`:

```json
{
  "name": "Letrinhas",
  "short_name": "Letrinhas",
  "start_url": ".",
  "display": "standalone",
  "background_color": "#0175C2",
  "theme_color": "#0175C2",
  "description": "Aplicativo para auxiliar pessoas com dislexia",
  "orientation": "portrait-primary"
}
```

### Testar PWA:

1. Execute: `flutter run -d chrome --release`
2. Abra DevTools do Chrome (F12)
3. Vá em "Application" > "Manifest"
4. Verifique se o manifest está carregado corretamente

---

## 🔥 Firebase no Web

### Adicionar Configuração Firebase Web

No Firebase Console:
1. Vá em "Project Settings"
2. Scroll até "Your apps"
3. Clique em "Add app" > Web
4. Registre o app
5. Copie o código de configuração

### Adicionar ao index.html

Antes do fechamento do `</body>`, adicione:

```html
<script src="https://www.gstatic.com/firebasejs/9.0.0/firebase-app.js"></script>
<script src="https://www.gstatic.com/firebasejs/9.0.0/firebase-auth.js"></script>
<script src="https://www.gstatic.com/firebasejs/9.0.0/firebase-firestore.js"></script>

<script>
  const firebaseConfig = {
    apiKey: "SUA_API_KEY",
    authDomain: "SEU_PROJECT.firebaseapp.com",
    projectId: "SEU_PROJECT_ID",
    storageBucket: "SEU_PROJECT.firebasestorage.app",
    messagingSenderId: "123456789",
    appId: "1:123456789:web:abcd1234"
  };

  firebase.initializeApp(firebaseConfig);
</script>
```

**Importante**: Não exponha sua configuração Firebase em repositórios públicos!

---

## 🌍 Deploy na Web

### Opção 1: Firebase Hosting

```bash
# Instalar Firebase CLI
npm install -g firebase-tools

# Login
firebase login

# Inicializar projeto
firebase init hosting

# Build do app
flutter build web --release

# Deploy
firebase deploy --only hosting
```

### Opção 2: GitHub Pages

```bash
# Build
flutter build web --release --base-href "/nome-do-repo/"

# Copiar build para branch gh-pages
cp -r build/web/* ../gh-pages/

# Commit e push na branch gh-pages
```

### Opção 3: Vercel

1. Conecte seu repositório GitHub ao Vercel
2. Configure Build Command: `flutter build web --release`
3. Configure Output Directory: `build/web`
4. Deploy automático a cada push

---

## 🐛 Problemas Comuns

### Erro: "Failed to load manifest"

**Solução**: Verifique se `manifest.json` está na pasta `web/`

### Erro: "favicon.png not found"

**Solução**: Crie um arquivo `favicon.png` (32x32) na pasta `web/`

### Erro: "Icons not found"

**Solução**: Os ícones em `web/icons/` são opcionais para desenvolvimento. Para produção, adicione arquivos PNG reais.

### App não carrega no navegador

**Solução**:
```bash
flutter clean
flutter pub get
flutter run -d chrome
```

### Firebase não funciona no web

**Solução**: Verifique se adicionou a configuração Firebase no `index.html` conforme documentado acima.

---

## 📊 Testes de Compatibilidade

### Navegadores Suportados:

- ✅ Chrome 84+
- ✅ Firefox 78+
- ✅ Safari 14+
- ✅ Edge 84+

### Testar em Múltiplos Navegadores:

```bash
# Chrome
flutter run -d chrome

# Edge
flutter run -d edge

# Safari (macOS)
flutter run -d safari
```

---

## 📱 Responsividade

O app usa layouts responsivos via Material Design. Para testar:

1. Abra no navegador: `flutter run -d chrome`
2. Abra DevTools (F12)
3. Clique no ícone de dispositivo móvel
4. Teste diferentes resoluções

---

## 🔒 HTTPS em Desenvolvimento

Para testar PWA localmente com HTTPS:

```bash
flutter run -d web-server --web-hostname localhost --web-port 5000 --web-tls-cert-path=cert.pem --web-tls-cert-key-path=key.pem
```

Gerar certificados auto-assinados:

```bash
openssl req -x509 -newkey rsa:4096 -keyout key.pem -out cert.pem -days 365 -nodes
```

---

## 📚 Recursos Adicionais

- [Flutter Web Documentation](https://docs.flutter.dev/get-started/web)
- [PWA Guide](https://web.dev/progressive-web-apps/)
- [Firebase Hosting](https://firebase.google.com/docs/hosting)
- [Flutter Web Renderers](https://docs.flutter.dev/development/platform-integration/web/renderers)

---

**✅ Estrutura web completa e documentada!**
