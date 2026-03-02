# Letrinhas

Aplicativo educacional desenvolvido em Flutter para auxiliar crianças com dislexia no aprendizado de letras, sílabas e palavras por meio de atividades gamificadas.

> **Projeto de TCC** — Trabalho de Conclusão de Curso em Análise e Desenvolvimento de Sistemas, 2025.

---

## Descrição

O **Letrinhas** é um MVP (Minimum Viable Product) mobile focado em oferecer uma experiência de aprendizado acessível e lúdica para crianças com dislexia. O app combina atividades educativas progressivas, sistema de pontuação e recursos de acessibilidade específicos para facilitar a leitura e o reconhecimento de letras.

---

## Objetivo Educacional

Apoiar crianças com dislexia no desenvolvimento das habilidades de:

- Identificação de vogais e consoantes
- Reconhecimento da posição das letras em palavras
- Completar palavras com a letra ausente
- Formação de palavras a partir de sílabas
- Associação de palavras a imagens

O app foi projetado com princípios de acessibilidade — fonte OpenDyslexic, alto contraste, tamanhos ajustáveis — para reduzir a sobrecarga cognitiva e aumentar o engajamento.

---

## Funcionalidades Principais

### Autenticação
- Cadastro com nome, email e senha
- Verificação obrigatória de email antes do primeiro acesso
- Login com email e senha
- Reenvio do email de verificação
- Redefinição de senha via email

### Atividades Educativas
Cinco atividades progressivas, cada uma com banco de 30 questões (5 sorteadas por sessão):

| # | Atividade | Nível | Descrição |
|---|-----------|-------|-----------|
| 1 | Vogais e Consoantes | 1 | Identifique vogais e consoantes do alfabeto |
| 2 | Reconhecendo Letras | 2 | Identifique a posição de letras em palavras |
| 3 | Complete a Palavra | 3 | Complete a palavra com a letra que falta |
| 4 | Formar Palavra com Sílabas | 4 | Monte a palavra na ordem correta das sílabas |
| 5 | Relacionar Palavra com Imagem | 5 | Associe a imagem à palavra correspondente |

### Sistema de Pontuação e Gamificação
- **Pontuação por atividade:** 0–100 pontos (baseada em acertos e tentativas)
- **Penalidade:** −10 pontos por 2 ou mais erros na mesma questão
- **Níveis:** 5 níveis desbloqueados progressivamente com base nos pontos acumulados
- **Progressão bidirecional:** perder pontos pode rebaixar o nível
- **Feedback visual:** confetti animado, sons de acerto/erro, mensagens motivacionais
- **Modo prática:** atividades fora do nível atual contam 0 pontos, mas podem ser praticadas

### Progresso do Usuário
- Barra de progresso de nível com atualização em tempo real
- Histórico de todas as atividades realizadas
- Estatísticas por atividade: pontos, precisão, tentativas, data
- Sincronização automática com Firestore
- Perfil do usuário com taxa de conclusão

### Geração de Relatório em PDF
- Relatório completo de desempenho do aluno
- Desempenho por atividade (precisão 24h/7 dias, sessões, duração média)
- Sumário geral de tempo e pontuação
- Exportável via sistema de impressão nativo (compartilhamento, Google Drive, etc.)

### Acessibilidade
- **Fonte OpenDyslexic:** fonte especialmente desenvolvida para facilitar a leitura de pessoas com dislexia
- **Modo Alto Contraste:** tema preto e branco de máxima legibilidade
- **Tamanho de texto ajustável:** multiplicador de 0.8× a 1.4× para todo o app
- **Tamanho de ícones ajustável:** multiplicador de 1.0× a 1.4×
- **Controle de animações:** opção de desativar animações para reduzir distrações
- **Espaçamento de linha:** 1.4–1.5× em todos os textos

---

## Tecnologias Utilizadas

| Tecnologia | Versão | Uso |
|------------|--------|-----|
| Flutter | SDK ≥3.0.0 | Framework principal |
| Firebase Authentication | ^5.3.1 | Login, cadastro e verificação de email |
| Cloud Firestore | ^5.4.4 | Banco de dados em tempo real |
| Provider | ^6.1.2 | Gerenciamento de estado |
| pdf + printing | ^3.11.1 / ^5.13.2 | Geração e exportação de relatórios |
| audioplayers | ^6.1.0 | Efeitos sonoros de feedback |
| confetti | ^0.7.0 | Animações de celebração |
| shared_preferences | ^2.3.3 | Persistência de configurações de acessibilidade |
| google_fonts | ^6.2.1 | Fontes de fallback |
| intl | ^0.19.0 | Formatação de datas |
| OpenDyslexic | — | Fonte customizada para dislexia |

---

## Estrutura de Pastas

```
dislexia_app/
├── lib/
│   ├── main.dart                        # Ponto de entrada, rotas e UserProvider
│   ├── firebase_options.dart            # Configuração do Firebase por plataforma
│   ├── models/
│   │   ├── user_model.dart              # Modelo do usuário e progresso de atividade
│   │   ├── activity_model.dart          # Modelo e lista de atividades disponíveis
│   │   └── time_stats_model.dart        # Estatísticas de tempo por sessão
│   ├── providers/
│   │   └── accessibility_provider.dart  # Estado global de acessibilidade
│   ├── services/
│   │   ├── auth_service.dart            # Login, cadastro, reset de senha
│   │   ├── firestore_service.dart       # CRUD de usuários e atividades
│   │   ├── time_tracking_service.dart   # Cronômetro invisível de sessão
│   │   └── report_service.dart          # Geração do relatório PDF
│   ├── screens/
│   │   ├── splash_page.dart
│   │   ├── login_page.dart
│   │   ├── register_page.dart
│   │   ├── home_page.dart
│   │   ├── profile_page.dart
│   │   ├── settings_page.dart
│   │   ├── activity_vowels_consonants.dart
│   │   ├── activity_recognize_letters.dart
│   │   ├── activity_syllabic.dart
│   │   ├── activity_form_word.dart
│   │   └── activity_match_image.dart
│   ├── widgets/
│   │   ├── custom_button.dart           # Botão reutilizável com estado de loading
│   │   ├── level_progress_bar.dart      # Barra de progresso animada
│   │   └── protected_activity.dart      # Guard de acesso por nível
│   ├── theme/
│   │   └── app_theme.dart               # Temas colorido e alto contraste
│   └── utils/
│       ├── sound_helper.dart            # Efeitos sonoros de acerto/erro
│       └── completion_feedback.dart     # Diálogo de conclusão de atividade
├── assets/
│   ├── images/
│   ├── sounds/
│   └── fonts/
│       ├── OpenDyslexic-Regular.ttf
│       └── OpenDyslexic-Bold.ttf
├── test/                                # Testes unitários e de widget
└── pubspec.yaml
```

---

## Como Rodar o Projeto Localmente

### Pré-requisitos

- [Flutter SDK](https://docs.flutter.dev/get-started/install) ≥3.0.0
- Android Studio ou VS Code com extensão Flutter
- Emulador Android/iOS ou dispositivo físico
- Conta no [Firebase Console](https://console.firebase.google.com/)

### Passo a passo

```bash
# 1. Clone o repositório
git clone https://github.com/joaoevangelista12/Letrinhas.git
cd Letrinhas/dislexia_app

# 2. Instale as dependências
flutter pub get

# 3. Configure o Firebase (veja seção abaixo)

# 4. Execute o projeto
flutter run
```

---

## Como Configurar o Firebase

### 1. Criar o projeto

1. Acesse [console.firebase.google.com](https://console.firebase.google.com/)
2. Crie um novo projeto
3. Ative **Authentication → Email/senha**
4. Ative **Firestore Database** (modo produção ou teste)

### 2. Registrar o app

- **Web:** Adicione um app web e copie as configurações para `lib/firebase_options.dart`
- **Android:** Baixe o `google-services.json` e coloque em `android/app/`
- **iOS:** Baixe o `GoogleService-Info.plist` e coloque em `ios/Runner/`

### 3. Atualizar firebase_options.dart

Substitua os valores em `lib/firebase_options.dart` pelas configurações do seu projeto Firebase.

---

## Regras do Firestore

Configure as regras de segurança em Firebase Console → Firestore → Regras:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;

      match /activities/{activityId} {
        allow read, write: if request.auth != null && request.auth.uid == userId;
      }

      match /time_stats/{activityId} {
        allow read, write: if request.auth != null && request.auth.uid == userId;
      }
    }
  }
}
```

### Estrutura dos documentos no Firestore

```
users/{uid}
  name, email, totalPoints, activitiesCompleted,
  completedActivities[], level (1–5), progress (0–99),
  createdAt, lastLoginAt

users/{uid}/activities/{id}
  activityId, activityName, points, accuracy,
  attempts, durationSeconds, completedAt

users/{uid}/time_stats/{activityId}
  lastSessionDuration, totalAccumulatedTime,
  sessionCount, lastSessionAt, recentSessions[]
```

---

## Sistema de Níveis

| Pontos Totais | Nível | Atividade Desbloqueada |
|---------------|-------|------------------------|
| 0–99 | 1 | Vogais e Consoantes |
| 100–199 | 2 | Reconhecendo Letras |
| 200–299 | 3 | Complete a Palavra |
| 300–399 | 4 | Formar Palavra com Sílabas |
| 400+ | 5 | Relacionar Palavra com Imagem |

> A progressão é **bidirecional** — se os pontos caírem abaixo do limiar, o nível é rebaixado automaticamente.

---

## Testes

```bash
# Executar todos os testes
flutter test
```

Os testes estão organizados em `test/` cobrindo models, services, providers e widgets.

---

## Autor

**João Victor Evangelista** — Análise e Desenvolvimento de Sistemas, 2025
