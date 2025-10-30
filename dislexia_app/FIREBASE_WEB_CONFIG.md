# 🔥 Configuração Firebase para Web

## ⚠️ AÇÃO NECESSÁRIA

O arquivo `lib/main.dart` contém placeholders para configuração do Firebase Web que **DEVEM SER SUBSTITUÍDOS** pelas suas credenciais reais.

---

## 📋 Passo a Passo

### 1. Acesse o Firebase Console

Vá para: https://console.firebase.google.com

### 2. Selecione seu projeto

Clique no projeto **dislexia-app** (ou o nome do seu projeto).

### 3. Acesse as configurações do projeto

1. Clique no ícone de **engrenagem** (⚙️) ao lado de "Project Overview"
2. Selecione **"Project settings"** (Configurações do projeto)

### 4. Adicione um app Web (se ainda não fez)

1. Role até a seção **"Your apps"** (Seus apps)
2. Clique no ícone **Web** (`</>`)
3. Dê um apelido ao app (ex: "Letrinhas Web")
4. Marque a opção **"Also set up Firebase Hosting"** (opcional)
5. Clique em **"Register app"** (Registrar app)

### 5. Copie a configuração

Você verá um código JavaScript parecido com este:

```javascript
const firebaseConfig = {
  apiKey: "AIzaSyA...",
  authDomain: "dislexia-app-1494e.firebaseapp.com",
  projectId: "dislexia-app-1494e",
  storageBucket: "dislexia-app-1494e.firebasestorage.app",
  messagingSenderId: "123456789",
  appId: "1:123456789:web:abc123def456",
  measurementId: "G-XXXXXXXXXX"
};
```

### 6. Substitua no arquivo `lib/main.dart`

Abra o arquivo `lib/main.dart` e localize a seção:

```dart
await Firebase.initializeApp(
  options: const FirebaseOptions(
    apiKey: "YOUR_API_KEY_HERE",  // ← SUBSTITUIR
    authDomain: "YOUR_PROJECT_ID.firebaseapp.com",  // ← SUBSTITUIR
    projectId: "YOUR_PROJECT_ID",  // ← SUBSTITUIR
    storageBucket: "YOUR_PROJECT_ID.firebasestorage.app",  // ← SUBSTITUIR
    messagingSenderId: "YOUR_MESSAGING_SENDER_ID",  // ← SUBSTITUIR
    appId: "YOUR_APP_ID",  // ← SUBSTITUIR
    measurementId: "YOUR_MEASUREMENT_ID",  // ← SUBSTITUIR (opcional)
  ),
);
```

**Substitua pelos valores do Firebase Console:**

```dart
await Firebase.initializeApp(
  options: const FirebaseOptions(
    apiKey: "AIzaSyA...",  // Cole aqui
    authDomain: "dislexia-app-1494e.firebaseapp.com",  // Cole aqui
    projectId: "dislexia-app-1494e",  // Cole aqui
    storageBucket: "dislexia-app-1494e.firebasestorage.app",  // Cole aqui
    messagingSenderId: "123456789",  // Cole aqui
    appId: "1:123456789:web:abc123def456",  // Cole aqui
    measurementId: "G-XXXXXXXXXX",  // Cole aqui (opcional)
  ),
);
```

---

## ✅ Exemplo Real

Baseado no seu `google-services.json` existente, suas configurações provavelmente são:

```dart
await Firebase.initializeApp(
  options: const FirebaseOptions(
    apiKey: "AIzaSyAi-J-kfKAQT8WkHGRdTfLPELm0YhkDZY0",
    authDomain: "dislexia-app-1494e.firebaseapp.com",
    projectId: "dislexia-app-1494e",
    storageBucket: "dislexia-app-1494e.firebasestorage.app",
    messagingSenderId: "648476093862",
    appId: "1:648476093862:web:SEU_WEB_APP_ID_AQUI",
    // measurementId opcional - obtenha no Firebase Console
  ),
);
```

**⚠️ ATENÇÃO**: Você precisa obter o `appId` correto do Firebase Console seguindo os passos acima!

---

## 🔒 Segurança

### Para desenvolvimento:

É seguro deixar as credenciais no código, pois o Firebase tem regras de segurança configuradas no Firestore e Authentication.

### Para produção:

- ✅ Mantenha as regras do Firestore restritas
- ✅ Configure o Authentication corretamente
- ✅ Adicione domínios autorizados no Firebase Console
- ✅ Use variáveis de ambiente se necessário

---

## 🚀 Testando

Após substituir as credenciais:

```bash
# Limpar cache
flutter clean

# Instalar dependências
flutter pub get

# Rodar no Chrome
flutter run -d chrome
```

---

## 🐛 Problemas Comuns

### Erro: "FirebaseOptions cannot be null"

**Causa**: Você não substituiu os placeholders.

**Solução**: Siga os passos acima e substitua TODAS as credenciais.

### Erro: "Firebase app named '[DEFAULT]' already exists"

**Causa**: Firebase tentou inicializar duas vezes.

**Solução**: Reinicie o app com `flutter run -d chrome`.

### Erro: "Access to fetch at ... from origin ... has been blocked by CORS"

**Causa**: O domínio não está autorizado no Firebase.

**Solução**:
1. Vá em **Firebase Console > Authentication > Settings > Authorized domains**
2. Adicione `localhost` e seu domínio de produção

---

## 📚 Referências

- [Firebase Web Setup](https://firebase.google.com/docs/web/setup)
- [FlutterFire Web](https://firebase.flutter.dev/docs/overview)
- [Firebase Authentication](https://firebase.google.com/docs/auth/web/start)

---

## ✨ Pronto!

Após configurar, seu app funcionará perfeitamente em:
- ✅ Web (Chrome, Firefox, Safari, Edge)
- ✅ Android (usando google-services.json)
- ✅ iOS (usando GoogleService-Info.plist)

Se tiver dúvidas, consulte a documentação oficial do Firebase.
