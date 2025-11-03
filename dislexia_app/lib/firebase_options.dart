// arquivo: lib/firebase_options.dart
// Arquivo gerado para configuração do Firebase em múltiplas plataformas
// Este arquivo foi criado manualmente baseado nas configurações do seu projeto

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Classe DefaultFirebaseOptions fornece as configurações do Firebase
/// para diferentes plataformas (Android, iOS, Web, etc.)
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macos - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  // ============================================================================
  // CONFIGURAÇÃO WEB
  // ============================================================================
  // ATENÇÃO: As credenciais abaixo são PLACEHOLDERS!
  // Para obter suas credenciais reais:
  // 1. Acesse https://console.firebase.google.com
  // 2. Selecione o projeto "dislexia-app-1494e"
  // 3. Clique em ⚙️ (Project Settings)
  // 4. Role até "Your apps" e clique no ícone Web (</>)
  // 5. Se não tiver app Web, clique em "Add app" > Web
  // 6. Copie os valores do firebaseConfig
  // 7. Substitua os valores abaixo
  // ============================================================================

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyBA5mUVvmyACQWDVUiVd5s0qyy1b6DIg4A'
    appId: '1:944349150169:android:19e6124742d5313bfef7c8',
    messagingSenderId: '648476093862',
    projectId: 'dislexia-app-1494e',
    authDomain: 'dislexia-app-1494e.firebaseapp.com',
    storageBucket: 'dislexia-app-1494e.firebasestorage.app',
    measurementId: 'G-XXXXXXXXXX', // ← Opcional: substitua se tiver Google Analytics
  );

  // ============================================================================
  // CONFIGURAÇÃO ANDROID (Extraída do google-services.json)
  // ============================================================================

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAi-J-kfKAQT8WkHGRdTfLPELm0YhkDZY0',
    appId: '1:648476093862:android:59a5baaa3ad58bb2e1f6bb',
    messagingSenderId: '648476093862',
    projectId: 'dislexia-app-1494e',
    storageBucket: 'dislexia-app-1494e.firebasestorage.app',
  );

  // ============================================================================
  // CONFIGURAÇÃO iOS (Placeholder - adicione quando for usar iOS)
  // ============================================================================

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyAi-J-kfKAQT8WkHGRdTfLPELm0YhkDZY0',
    appId: '1:648476093862:ios:0123456789abcdef', // ← Substitua se usar iOS
    messagingSenderId: '648476093862',
    projectId: 'dislexia-app-1494e',
    storageBucket: 'dislexia-app-1494e.firebasestorage.app',
    iosBundleId: 'com.example.dislexiaApp',
  );
}
