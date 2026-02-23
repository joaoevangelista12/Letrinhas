# 🤖 Configuração Android

## 📋 Estrutura do Projeto Android

Esta pasta contém toda a configuração nativa do Android para o app Flutter.

```
android/
├── build.gradle                    # Configuração nível projeto
├── settings.gradle                 # Configuração de módulos
├── gradle.properties              # Propriedades do Gradle
└── app/
    ├── build.gradle               # Configuração nível app
    ├── google-services.json       # Config Firebase (não versionado)
    └── src/
        └── main/
            ├── AndroidManifest.xml
            ├── kotlin/
            │   └── com/example/dislexia_app/
            │       └── MainActivity.kt
            └── res/
                ├── drawable/
                ├── mipmap-*/          # Ícones do app
                └── values/
                    └── styles.xml
```

---

## 🔧 Arquivos Importantes

### 1. **build.gradle (nível projeto)**

Configurações globais do Android:

```gradle
dependencies {
    classpath 'com.android.tools.build:gradle:7.3.0'
    classpath 'com.google.gms:google-services:4.4.0'  // Firebase
}
```

### 2. **app/build.gradle (nível app)**

Configurações específicas do app:

```gradle
android {
    compileSdkVersion 34
    minSdkVersion 21        // Necessário para Firebase
    targetSdkVersion 34
    multiDexEnabled true    // Suporte para Firebase
}

// No final do arquivo:
apply plugin: 'com.google.gms.google-services'
```

**Importante**: O plugin `google-services` DEVE estar no final do arquivo!

### 3. **AndroidManifest.xml**

Configurações do app e permissões:

```xml
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />
```

### 4. **MainActivity.kt**

Activity principal do Flutter:

```kotlin
package com.example.dislexia_app

import io.flutter.embedding.android.FlutterActivity

class MainActivity: FlutterActivity() {
}
```

---

## 📦 Dependências Importantes

### Gradle:
- **Android Gradle Plugin**: 7.3.0
- **Kotlin**: 1.7.10
- **Google Services**: 4.4.0

### Android:
- **minSdkVersion**: 21 (Android 5.0 Lollipop)
- **targetSdkVersion**: 34 (Android 14)
- **compileSdkVersion**: 34

### Bibliotecas:
- **MultiDex**: Para suportar Firebase (mais de 64k métodos)

---

## 🔥 Configuração Firebase

### Passo 1: Adicionar google-services.json

```bash
# Baixe do Firebase Console
# Copie para:
android/app/google-services.json
```

**IMPORTANTE**: Este arquivo NÃO deve ser commitado no Git!

### Passo 2: Verificar build.gradle

Certifique-se que `android/app/build.gradle` tem no final:

```gradle
apply plugin: 'com.google.gms.google-services'
```

### Passo 3: Testar

```bash
cd ..
flutter pub get
flutter run
```

---

## 🎨 Customizar Ícone do App

### Opção 1: Manual

Adicione ícones em cada pasta `mipmap-*`:

```
mipmap-mdpi/ic_launcher.png     (48x48)
mipmap-hdpi/ic_launcher.png     (72x72)
mipmap-xhdpi/ic_launcher.png    (96x96)
mipmap-xxhdpi/ic_launcher.png   (144x144)
mipmap-xxxhdpi/ic_launcher.png  (192x192)
```

### Opção 2: Automática (Recomendado)

Use o package `flutter_launcher_icons`:

1. Adicione no `pubspec.yaml`:

```yaml
dev_dependencies:
  flutter_launcher_icons: ^0.13.1

flutter_launcher_icons:
  android: true
  image_path: "assets/icon/app_icon.png"
```

2. Execute:

```bash
flutter pub get
flutter pub run flutter_launcher_icons
```

### Opção 3: Online

Use https://appicon.co/
- Upload sua imagem
- Download ícones Android
- Substitua as pastas `mipmap-*`

---

## 🏗️ Build do APK

### Debug:

```bash
flutter build apk --debug
```

**Local**: `build/app/outputs/flutter-apk/app-debug.apk`

### Release:

```bash
flutter build apk --release
```

**Local**: `build/app/outputs/flutter-apk/app-release.apk`

### App Bundle (Para Google Play):

```bash
flutter build appbundle --release
```

**Local**: `build/app/outputs/bundle/release/app-release.aab`

---

## 🔐 Assinatura do App (Produção)

Para publicar na Google Play, você precisa assinar o app:

### 1. Criar Keystore:

```bash
keytool -genkey -v -keystore ~/upload-keystore.jks \
  -keyalg RSA -keysize 2048 -validity 10000 \
  -alias upload
```

### 2. Criar key.properties:

`android/key.properties`:

```properties
storePassword=<senha>
keyPassword=<senha>
keyAlias=upload
storeFile=<caminho>/upload-keystore.jks
```

### 3. Atualizar build.gradle:

```gradle
def keystoreProperties = new Properties()
def keystorePropertiesFile = rootProject.file('key.properties')
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(new FileInputStream(keystorePropertiesFile))
}

android {
    signingConfigs {
       release {
           keyAlias keystoreProperties['keyAlias']
           keyPassword keystoreProperties['keyPassword']
           storeFile keystoreProperties['storeFile'] ? file(keystoreProperties['storeFile']) : null
           storePassword keystoreProperties['storePassword']
       }
    }
    buildTypes {
        release {
            signingConfig signingConfigs.release
        }
    }
}
```

---

## 🐛 Problemas Comuns

### Erro: "google-services.json not found"

**Solução**: Copie o arquivo do Firebase Console para `android/app/`

### Erro: "Multidex"

**Solução**: Já está configurado no `build.gradle`. Se persistir:

```gradle
dependencies {
    implementation 'androidx.multidex:multidex:2.0.1'
}
```

### Erro: "minSdkVersion"

**Solução**: Firebase requer minSdkVersion 21. Já configurado.

### Erro de compilação

```bash
cd android
./gradlew clean
cd ..
flutter clean
flutter pub get
flutter run
```

### Gradle muito lento

Adicione em `gradle.properties`:

```properties
org.gradle.daemon=true
org.gradle.parallel=true
org.gradle.configureondemand=true
```

---

## 📱 Testar no Dispositivo

### USB:

1. Habilite "Opções do desenvolvedor" no Android
2. Ative "Depuração USB"
3. Conecte o cabo USB
4. Execute: `flutter run`

### WiFi:

```bash
# Conecte primeiro via USB
adb tcpip 5555
adb connect <IP_DO_CELULAR>:5555
flutter run
```

---

## 📊 Informações do App

### Package Name:
```
com.example.dislexia_app
```

### Versão:
```
versionCode: 1
versionName: 1.0.0
```

Para alterar, edite em `pubspec.yaml`:

```yaml
version: 1.0.0+1
#        ^      ^
#     nome   código
```

---

## 🚀 Publicar na Google Play

### 1. Criar conta de desenvolvedor
- https://play.google.com/console
- Taxa única: $25

### 2. Build do App Bundle
```bash
flutter build appbundle --release
```

### 3. Upload
- Google Play Console
- Criar app
- Upload do .aab
- Preencher informações
- Publicar

---

## 📚 Recursos Adicionais

- [Documentação Android do Flutter](https://docs.flutter.dev/deployment/android)
- [Configurar assinatura](https://docs.flutter.dev/deployment/android#signing-the-app)
- [Firebase para Android](https://firebase.google.com/docs/android/setup)
- [Google Play Console](https://play.google.com/console)

---

**✅ Estrutura Android completa e pronta para uso!**
