// arquivo: lib/firebase_options.dart
//
// ============================================================================
// AUDITORIA DE CONFIGURACAO FIREBASE — 26/02/2026
// ============================================================================
// PROBLEMA ENCONTRADO:
//   Os blocos "android" e "ios" usavam credenciais de um PROJETO FIREBASE
//   DIFERENTE do projeto correto, causando "API key not valid".
//
//   Evidencia: o App ID codifica o project_number no formato:
//     1:{project_number}:{platform}:{hash}
//
//   Configuracao ANTERIOR (ERRADA):
//     android.appId            = "1:648476093862:android:..."  <- project 648476093862
//     android.messagingSenderId= "648476093862"                <- project 648476093862
//     android.apiKey           = "AIzaSyAi-J-..."              <- API key de 648476093862
//     android.projectId        = "dislexia-app-1494e"          <- CONTRADICAO: 1494e != 648476...
//
//   Configuracao Web (referencia CORRETA):
//     web.messagingSenderId    = "944349150169"                <- project_number de dislexia-app-1494e
//     web.projectId            = "dislexia-app-1494e"          <- consistente
//
//   A API key do projeto errado tentava acessar "dislexia-app-1494e"
//   e o Firebase retornava "API key not valid".
//
// CORRECAO APLICADA:
//   Android e iOS agora usam a API key e messagingSenderId do projeto correto
//   (dislexia-app-1494e, project_number 944349150169), identico ao bloco Web.
//
// ACAO PENDENTE — para obter o App ID Android definitivo:
//   1. Acesse https://console.firebase.google.com -> projeto "dislexia-app-1494e"
//   2. Project Settings -> "Your apps" -> Add app -> Android
//   3. Package name: com.example.dislexia_app
//   4. Clique em "Register app" e copie o App ID gerado (formato: 1:944349150169:android:HASH)
//   5. Substitua android.appId abaixo pelo valor obtido no passo 4
//   O appId atual (web, mesmo projeto) e compativel com Auth + Firestore.
// ============================================================================

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Configuracoes do Firebase para cada plataforma.
/// Todas as plataformas apontam para o projeto "dislexia-app-1494e"
/// (GCP project_number 944349150169).
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
  // WEB — projeto dislexia-app-1494e (project_number 944349150169)
  // ============================================================================
  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyBA5mUVvmyACQWDVUiVd5s0qyy1b6DIg4A',
    appId: '1:944349150169:web:5bdcf0adcfca45b2fef7c8',
    messagingSenderId: '944349150169',
    projectId: 'dislexia-app-1494e',
    authDomain: 'dislexia-app-1494e.firebaseapp.com',
    storageBucket: 'dislexia-app-1494e.firebasestorage.app',
    measurementId: 'G-YMXLC1YYZ0',
  );

  // ============================================================================
  // ANDROID — CORRIGIDO (estava apontando para projeto 648476093862, agora 944349150169)
  //
  // TODO: Apos registrar app Android no Firebase Console, substituir appId por
  //       "1:944349150169:android:<HASH>" obtido no Firebase Console.
  // ============================================================================
  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBA5mUVvmyACQWDVUiVd5s0qyy1b6DIg4A',
    appId: '1:944349150169:web:5bdcf0adcfca45b2fef7c8',
    messagingSenderId: '944349150169',
    projectId: 'dislexia-app-1494e',
    storageBucket: 'dislexia-app-1494e.firebasestorage.app',
  );

  // ============================================================================
  // iOS — CORRIGIDO (estava apontando para projeto 648476093862, agora 944349150169)
  //
  // TODO: Apos registrar app iOS no Firebase Console, substituir appId por
  //       "1:944349150169:ios:<HASH>" obtido no Firebase Console.
  // ============================================================================
  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBA5mUVvmyACQWDVUiVd5s0qyy1b6DIg4A',
    appId: '1:944349150169:web:5bdcf0adcfca45b2fef7c8',
    messagingSenderId: '944349150169',
    projectId: 'dislexia-app-1494e',
    storageBucket: 'dislexia-app-1494e.firebasestorage.app',
    iosBundleId: 'com.example.dislexiaApp',
  );
}
