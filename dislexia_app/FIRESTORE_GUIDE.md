# 🗄️ Cloud Firestore - Guia Completo

## 📋 Visão Geral

Este guia explica como configurar e usar o Cloud Firestore para armazenar dados do usuário e progresso das atividades.

---

## 🔧 O que foi Implementado

### ✅ Funcionalidades:

- **Armazenamento de usuários** na coleção `users`
- **Dados do usuário**: nome, email, pontos, atividades completadas
- **Sistema de níveis**: baseado em pontos (100 pontos = 1 nível)
- **Histórico de atividades**: subcoleção com cada atividade completada
- **Progresso em tempo real**: exibido na tela home
- **Pontuação automática**: +50 pontos ao completar atividade

---

## 📊 Estrutura do Banco de Dados

### Coleção `users`

```
users/
  {uid}/
    ├── name: string
    ├── email: string
    ├── totalPoints: number
    ├── activitiesCompleted: number
    ├── completedActivities: array<string>
    ├── createdAt: timestamp
    └── lastLoginAt: timestamp

    activities/ (subcoleção)
      match_words_basic/
        ├── activityId: string
        ├── activityName: string
        ├── points: number
        ├── completedAt: timestamp
        ├── attempts: number
        └── accuracy: number (0.0 - 1.0)
```

### Exemplo de Documento:

```json
{
  "name": "João Silva",
  "email": "joao@email.com",
  "totalPoints": 150,
  "activitiesCompleted": 3,
  "completedActivities": ["match_words_basic", "spell_words_01"],
  "createdAt": "2024-01-15T10:30:00Z",
  "lastLoginAt": "2024-01-20T14:45:00Z"
}
```

---

## ⚙️ Configuração do Firestore

### Passo 1: Ativar Firestore no Console

1. Acesse: https://console.firebase.google.com/
2. Selecione seu projeto "Dislexia App"
3. No menu lateral, clique em **Firestore Database**
4. Clique em **Criar banco de dados**

### Passo 2: Escolher Modo de Segurança

**Escolha**: Modo de **produção**

**Por quê?**: Mais seguro, usa regras de segurança

### Passo 3: Escolher Localização

**Recomendado**: `southamerica-east1` (São Paulo, Brasil)

**Motivo**: Menor latência para usuários brasileiros

Clique em **Ativar**

---

## 🔒 Regras de Segurança

### Configurar Regras no Console:

1. No Firestore, clique na aba **Regras**
2. Cole as regras abaixo:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {

    // Regra para coleção de usuários
    match /users/{userId} {
      // Permite leitura e escrita apenas para o próprio usuário
      allow read, write: if request.auth != null && request.auth.uid == userId;

      // Subcoleção de atividades
      match /activities/{activityId} {
        allow read, write: if request.auth != null && request.auth.uid == userId;
      }
    }
  }
}
```

3. Clique em **Publicar**

### Explicação das Regras:

- **`request.auth != null`**: Usuário deve estar autenticado
- **`request.auth.uid == userId`**: Usuário só acessa seus próprios dados
- **Impede**: Usuários lerem dados de outros usuários
- **Permite**: Cada usuário ler e escrever apenas seus dados

---

## 🚀 Como Funciona no App

### 1. Cadastro de Usuário

Quando um usuário se cadastra:

```dart
// AuthService cria documento no Firestore
await _firestoreService.createUser(
  uid: user.uid,
  name: 'João Silva',
  email: 'joao@email.com',
);
```

**Resultado**: Documento criado em `users/{uid}` com pontos zerados

### 2. Login de Usuário

Quando um usuário faz login:

```dart
// Atualiza lastLoginAt
await _firestoreService.createUser(
  uid: user.uid,
  name: user.displayName,
  email: user.email,
);
```

**Resultado**: Campo `lastLoginAt` atualizado

### 3. Carregar Progresso na Home

Quando abre a home:

```dart
// Busca dados do Firestore
final userData = await _firestoreService.getUser(uid);

// Atualiza Provider
userProvider.updateProgress(
  totalPoints: userData.totalPoints,
  activitiesCompleted: userData.activitiesCompleted,
);
```

**Resultado**: Exibe pontos, nível e progresso

### 4. Completar Atividade

Quando completa uma atividade:

```dart
// Salva no Firestore
await firestoreService.completeActivity(
  uid: uid,
  activityId: 'match_words_basic',
  activityName: 'Associar Palavras',
  points: 50,
  attempts: 1,
  accuracy: 1.0,
);
```

**Resultado**:
- Adiciona +50 pontos
- Incrementa atividades completadas
- Salva histórico na subcoleção

---

## 📱 Interface do Usuário

### Cards de Progresso na Home:

```
┌─────────────────────────────────────┐
│  Seu Progresso                      │
├─────────┬─────────┬─────────────────┤
│ ⭐ 150  │ 🏆 2    │ ✅ 3           │
│ Pontos  │ Nível   │ Completas      │
└─────────┴─────────┴─────────────────┘

Progresso do Nível 2: [████████░░] 50%
Faltam 50 pontos para o nível 3
```

### Sistema de Níveis:

- **Nível 1**: 0 - 99 pontos
- **Nível 2**: 100 - 199 pontos
- **Nível 3**: 200 - 299 pontos
- ...e assim por diante

---

## 🎯 Pontuação

### Pontos por Atividade:

| Atividade | Pontos |
|-----------|--------|
| Associar Palavras | 50 |
| Soletrar (futuro) | 30 |
| Leitura (futuro) | 40 |

### Fórmula de Nível:

```dart
nivel = (totalPontos / 100).floor() + 1
progressoNivel = (totalPontos % 100) / 100
```

**Exemplo**:
- 150 pontos = Nível 2, 50% de progresso
- 250 pontos = Nível 3, 50% de progresso

---

## 🧪 Testando o Firestore

### Teste 1: Cadastro

1. Cadastre novo usuário
2. Vá ao Firebase Console > Firestore
3. ✅ Deve ver documento em `users/{uid}`
4. ✅ Campos: name, email, totalPoints: 0

### Teste 2: Completar Atividade

1. Complete a atividade "Associar Palavras"
2. Veja diálogo "+50 pontos"
3. Volte para home
4. ✅ Deve mostrar 50 pontos, Nível 1, 1 atividade
5. No Firebase Console:
   - ✅ `totalPoints`: 50
   - ✅ `activitiesCompleted`: 1
   - ✅ Subcoleção `activities/match_words_basic`

### Teste 3: Múltiplas Completações

1. Complete a atividade 3 vezes
2. ✅ Deve mostrar 150 pontos
3. ✅ Deve mostrar Nível 2
4. ✅ Deve mostrar 50% de progresso

---

## 🔍 Visualizar Dados no Console

### Firebase Console:

1. Acesse Firestore Database
2. Navegue por coleções:
   ```
   users/
     {uid}/
       - Ver campos
       activities/
         - Ver histórico
   ```

### Dados em Tempo Real:

- Dados atualizam automaticamente
- Não precisa recarregar página
- Ideal para monitorar progresso

---

## 🛠️ Métodos do FirestoreService

### Disponíveis:

```dart
// Criar/atualizar usuário
createUser(uid, name, email)

// Buscar usuário
getUser(uid)

// Stream de atualizações
getUserStream(uid)

// Completar atividade
completeActivity(uid, activityId, activityName, points, ...)

// Histórico de atividades
getUserActivities(uid)

// Verificar se completou
hasCompletedActivity(uid, activityId)

// Ranking de usuários
getLeaderboard(limit)

// Resetar progresso (testes)
resetUserProgress(uid)
```

---

## 📈 Futuras Melhorias

### Sugestões de Expansão:

- [ ] **Ranking global**: Leaderboard de todos os usuários
- [ ] **Conquistas**: Badges por marcos (100 pontos, 10 atividades, etc)
- [ ] **Estatísticas**: Gráficos de progresso ao longo do tempo
- [ ] **Desafios diários**: Atividades especiais com pontos extras
- [ ] **Perfil de usuário**: Avatar, bio, preferências
- [ ] **Modo offline**: Sincronização quando voltar online
- [ ] **Compartilhamento**: Compartilhar progresso nas redes sociais

---

## ⚠️ Limitações Gratuitas do Firestore

### Plano Spark (Gratuito):

- **Leituras**: 50.000/dia
- **Escritas**: 20.000/dia
- **Armazenamento**: 1 GB

### Para o MVP:

- ✅ Mais que suficiente
- ✅ Suporta ~100-200 usuários ativos/dia
- ✅ Sem custo

### Upgrade (se necessário):

- Plano Blaze (pague conforme uso)
- Custos iniciam após limites gratuitos

---

## 🐛 Troubleshooting

### Erro: "Missing or insufficient permissions"

**Problema**: Regras de segurança bloqueando

**Solução**:
1. Verifique se usuário está autenticado
2. Verifique se UID está correto
3. Revise regras de segurança

### Erro: "Error saving to Firestore"

**Problema**: Conexão ou permissões

**Solução**:
1. Verifique internet
2. Confirme que Firestore está ativado
3. Veja logs no console

### Dados não atualizam na home

**Problema**: Provider não atualiza

**Solução**:
1. Verifique se `_loadUserData()` é chamado
2. Confirme que Provider é atualizado
3. Use `notifyListeners()`

---

## 📚 Recursos Adicionais

- [Documentação Firestore](https://firebase.google.com/docs/firestore)
- [Regras de Segurança](https://firebase.google.com/docs/firestore/security/get-started)
- [FlutterFire Firestore](https://firebase.flutter.dev/docs/firestore/overview)
- [Estrutura de Dados](https://firebase.google.com/docs/firestore/manage-data/structure-data)

---

**🎉 Cloud Firestore configurado e funcionando!**

**Seu app agora tem persistência de dados profissional com sincronização em tempo real!**
