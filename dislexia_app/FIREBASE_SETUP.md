# 🔥 Configuração do Firebase - Passo a Passo

## 📋 Visão Geral

Este guia mostra como configurar o Firebase Authentication para o projeto Dislexia App.

---

## 🚀 Parte 1: Configuração no Firebase Console

### Passo 1: Criar Projeto no Firebase

1. Acesse: https://console.firebase.google.com/
2. Clique em **"Adicionar projeto"** (ou "Add project")
3. Nome do projeto: `Dislexia App` (ou nome de sua preferência)
4. Clique em **Continuar**
5. Google Analytics:
   - **Recomendado**: Desabilitar para MVP (mais rápido)
   - **Opcional**: Habilitar para analytics em produção
6. Clique em **Criar projeto**
7. Aguarde a criação (pode levar 1-2 minutos)
8. Clique em **Continuar**

---

### Passo 2: Ativar Firebase Authentication

1. No painel do Firebase, clique em **Authentication** (menu lateral)
2. Clique em **Começar** ou **Get started**
3. Vá para aba **Sign-in method**
4. Ative os seguintes provedores:

#### ✅ Email/Password:
   - Clique em **Email/Password**
   - Ative **Email/Password** (primeira opção)
   - Deixe **Email link** desativado (segunda opção)
   - Clique em **Salvar**

#### ✅ Google (Opcional - recomendado):
   - Clique em **Google**
   - Ative o provedor
   - Nome público do projeto: `Dislexia App`
   - Email de suporte: `seu-email@gmail.com`
   - Clique em **Salvar**

---

### Passo 3: Adicionar App Android ao Projeto

1. No overview do projeto, clique no ícone **Android** (robot)
2. Preencha os dados:

   **Nome do pacote Android**:
   ```
   com.example.dislexia_app
   ```

   **Apelido do app** (opcional):
   ```
   Dislexia App
   ```

   **Certificado SHA-1** (opcional por enquanto - necessário para Google Sign-In):
   ```
   (pode deixar em branco para MVP)
   ```

3. Clique em **Registrar app**

---

### Passo 4: Baixar google-services.json

1. Após registrar, você verá o botão **Fazer download do google-services.json**
2. Clique para baixar o arquivo
3. **IMPORTANTE**: Guarde este arquivo, vamos usá-lo no próximo passo

4. Clique em **Próximo** (pode pular as etapas de configuração manual)
5. Clique em **Continuar no console**

---

### Passo 5: Adicionar App iOS ao Projeto (Opcional)

Se você também quiser suporte iOS:

1. No overview do projeto, clique no ícone **iOS** (Apple)
2. Preencha:

   **ID do pacote iOS**:
   ```
   com.example.dislexiaApp
   ```

3. Clique em **Registrar app**
4. Baixe o arquivo **GoogleService-Info.plist**
5. Siga as instruções específicas para iOS

---

## 📱 Parte 2: Configuração no Projeto Flutter

### Passo 6: Adicionar google-services.json ao Projeto

1. **Localize o arquivo baixado**: `google-services.json`

2. **Copie para o projeto Android**:
   ```
   dislexia_app/android/app/google-services.json
   ```

   **Estrutura correta**:
   ```
   dislexia_app/
   └── android/
       └── app/
           ├── build.gradle
           ├── src/
           └── google-services.json  ← AQUI
   ```

3. **Verifique se está no local correto**:
   ```bash
   ls -la dislexia_app/android/app/google-services.json
   ```

---

### Passo 7: Configurar build.gradle (Nível Projeto)

Abra: `dislexia_app/android/build.gradle`

Adicione o plugin do Google Services:

```gradle
buildscript {
    repositories {
        google()
        mavenCentral()
    }

    dependencies {
        classpath 'com.android.tools.build:gradle:7.3.0'
        classpath 'org.jetbrains.kotlin:kotlin-gradle-plugin:1.7.10'
        // Adicione esta linha:
        classpath 'com.google.gms:google-services:4.4.0'
    }
}
```

---

### Passo 8: Configurar build.gradle (Nível App)

Abra: `dislexia_app/android/app/build.gradle`

No **final do arquivo**, adicione:

```gradle
apply plugin: 'com.google.gms.google-services'
```

E aumente o `minSdkVersion`:

```gradle
android {
    defaultConfig {
        minSdkVersion 21  // Era 19, mude para 21
        targetSdkVersion flutter.targetSdkVersion
    }
}
```

---

### Passo 9: Configurar AndroidManifest.xml

Abra: `dislexia_app/android/app/src/main/AndroidManifest.xml`

Adicione permissão de internet (se ainda não existir):

```xml
<manifest ...>
    <uses-permission android:name="android.permission.INTERNET" />

    <application ...>
        ...
    </application>
</manifest>
```

---

### Passo 10: Instalar Dependências

Execute no terminal:

```bash
cd dislexia_app
flutter pub get
```

---

### Passo 11: Limpar e Rebuildar

```bash
flutter clean
flutter pub get
cd android && ./gradlew clean
cd ..
flutter run
```

---

## ✅ Verificação

### Como testar se está funcionando:

1. Execute o app: `flutter run`
2. Se não houver erros de compilação relacionados ao Firebase, está OK!
3. Tente fazer cadastro com email/senha
4. Verifique no Firebase Console > Authentication > Users se o usuário foi criado

---

## 🔒 Regras de Segurança do Firestore (Se usar)

Se você adicionar Firestore depois, configure as regras:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /{document=**} {
      allow read, write: if request.auth != null;
    }
  }
}
```

---

## ⚠️ Problemas Comuns

### Erro: "google-services.json not found"
- Verifique se o arquivo está em `android/app/google-services.json`
- Nome do arquivo deve ser exatamente `google-services.json`

### Erro: "Default Firebase app has not been initialized"
- Certifique-se de que `Firebase.initializeApp()` está sendo chamado no `main.dart`
- Veja o arquivo `lib/main.dart` atualizado

### Erro: "Multidex"
Se aparecer erro de Multidex, adicione no `android/app/build.gradle`:

```gradle
android {
    defaultConfig {
        multiDexEnabled true
    }
}

dependencies {
    implementation 'androidx.multidex:multidex:2.0.1'
}
```

### Erro de compilação no Android
```bash
cd android
./gradlew clean
cd ..
flutter clean
flutter pub get
flutter run
```

---

## 📝 Checklist Completo

- [ ] Criar projeto no Firebase Console
- [ ] Ativar Authentication > Email/Password
- [ ] Adicionar app Android
- [ ] Baixar google-services.json
- [ ] Copiar google-services.json para android/app/
- [ ] Atualizar android/build.gradle (classpath)
- [ ] Atualizar android/app/build.gradle (plugin + minSdk 21)
- [ ] Adicionar permissão INTERNET no AndroidManifest.xml
- [ ] Executar flutter pub get
- [ ] Executar flutter clean
- [ ] Testar o app

---

## 📚 Recursos Adicionais

- **Documentação oficial**: https://firebase.google.com/docs/flutter/setup
- **FlutterFire**: https://firebase.flutter.dev/
- **Firebase Console**: https://console.firebase.google.com/

---

## 🎯 Próximos Passos

Após configurar o Firebase:

1. ✅ O app agora usa autenticação real
2. ✅ Usuários são salvos no Firebase
3. ✅ Senhas são criptografadas
4. ✅ Pode resetar senha por email
5. ✅ Pode adicionar login social (Google, Facebook, etc)

---

**🔥 Firebase configurado! Seu app agora tem autenticação profissional!**
