# Dislexia App - MVP TCC

Aplicativo Flutter para auxiliar pessoas com dislexia no aprendizado através de atividades interativas.

## 📱 Funcionalidades do MVP

- ✅ Tela Splash com animação
- ✅ Sistema de Login/Cadastro (simulado, sem backend)
- ✅ Validação de formulários
- ✅ Tela Home com menu de atividades
- ✅ Atividade de Associação de Palavras com Imagens
- ✅ Feedback visual e sonoro usando TTS (Text-to-Speech)
- ✅ Navegação entre telas
- ✅ Gerenciamento de estado com Provider

## 🏗️ Estrutura do Projeto

```
dislexia_app/
├── lib/
│   ├── main.dart                          # Entry point + Provider
│   ├── screens/
│   │   ├── splash_page.dart              # Tela inicial
│   │   ├── login_page.dart               # Tela de login
│   │   ├── register_page.dart            # Tela de cadastro
│   │   ├── home_page.dart                # Menu principal
│   │   └── activity_match_words.dart     # Atividade de associação
│   └── widgets/
│       ├── custom_button.dart            # Botão customizado
│       └── word_card.dart                # Card de palavra
├── assets/
│   ├── images/                           # Imagens do app
│   └── sounds/                           # Sons (opcional)
├── test/
│   └── widget_test.dart                  # Testes unitários
└── pubspec.yaml                          # Dependências
```

## 🚀 Como Executar

### Pré-requisitos

1. **Flutter SDK** instalado (versão 3.0+)
   - Baixe em: https://flutter.dev/docs/get-started/install

2. **VS Code** com extensões:
   - Flutter
   - Dart

3. **Emulador ou dispositivo físico** configurado

### Passo-a-passo

1. **Clone ou copie o projeto** para uma pasta local:
   ```bash
   cd /caminho/onde/quer/criar
   # O projeto já está na pasta dislexia_app/
   ```

2. **Abra o projeto no VS Code**:
   ```bash
   cd dislexia_app
   code .
   ```

3. **Instale as dependências**:
   ```bash
   flutter pub get
   ```

4. **Verifique se há dispositivos disponíveis**:
   ```bash
   flutter devices
   ```

5. **Execute o aplicativo**:
   ```bash
   flutter run
   ```

   Ou pressione `F5` no VS Code para executar em modo debug.

## 🧪 Executar Testes

```bash
flutter test
```

## 📦 Dependências Utilizadas

- **provider**: Gerenciamento de estado
- **flutter_tts**: Text-to-Speech para feedback sonoro

## 🎨 Assets Necessários

O aplicativo usa emojis no lugar de imagens reais para o MVP. Em produção, você deve adicionar imagens reais na pasta `assets/images/`.

### Estrutura de Assets Recomendada:

```
assets/
├── images/
│   ├── cat.png          # Imagem de gato
│   ├── sun.png          # Imagem de sol
│   ├── house.png        # Imagem de casa
│   └── ...              # Outras imagens
└── sounds/
    ├── correct.mp3      # Som de acerto (opcional)
    └── wrong.mp3        # Som de erro (opcional)
```

### Para Adicionar Imagens Reais:

1. Coloque as imagens na pasta `assets/images/`
2. Atualize o arquivo `activity_match_words.dart` para usar `Image.asset()` em vez de emojis
3. Certifique-se que as imagens estão listadas no `pubspec.yaml`

## 🎯 Como Testar o App

### Fluxo de Teste:

1. **Splash Screen** → Aguarde 3 segundos
2. **Login** → Digite qualquer email com @ e senha com 6+ caracteres
3. **Home** → Veja seu nome exibido
4. **Atividade** → Arraste as palavras para as imagens correspondentes
5. **Feedback** → Ouça o TTS e veja feedback visual

### Credenciais de Teste:
- Email: `teste@email.com`
- Senha: `123456` (ou qualquer senha com 6+ caracteres)

## 📝 Notas Importantes

### Login Simulado
O login é simulado para o MVP. Para produção:
- Integre com Firebase Authentication
- Adicione banco de dados (Firestore/SQLite)
- Implemente segurança adequada

### TTS (Text-to-Speech)
- Funciona em dispositivos físicos e emuladores com suporte a TTS
- Primeiro uso pode pedir permissões
- Configure idioma português no dispositivo para melhor resultado

### Responsividade
- Testado em telas de smartphones
- Para tablets, ajuste os tamanhos no código

## 🔧 Problemas Comuns

### Erro: "flutter: command not found"
- Adicione Flutter ao PATH do sistema
- Reinicie o terminal

### Erro: "No devices found"
- Inicie um emulador Android/iOS
- Ou conecte um dispositivo físico com USB debugging

### Erro ao executar testes
- Execute `flutter pub get` primeiro
- Verifique se todas as importações estão corretas

### TTS não funciona
- Verifique se o dispositivo tem suporte a TTS
- Configure o idioma português nas configurações do dispositivo
- Em emuladores, pode ser necessário instalar dados de voz

## 📚 Próximos Passos (Além do MVP)

- [ ] Integração com Firebase
- [ ] Mais atividades (soletrar, leitura guiada)
- [ ] Sistema de pontuação e progresso
- [ ] Níveis de dificuldade
- [ ] Modo offline com sincronização
- [ ] Relatórios para responsáveis/professores
- [ ] Personalização de fonte (OpenDyslexic)
- [ ] Modo escuro

## 📄 Licença

Projeto acadêmico - TCC

## 👨‍💻 Autor

Desenvolvido como MVP para TCC sobre aplicativo de apoio à dislexia.

---

**Boa sorte com seu TCC! 🎓**
