# Guia de Assets

## 📁 Estrutura de Pastas

```
assets/
├── images/          # Imagens do aplicativo
└── sounds/          # Sons e efeitos (opcional)
```

## 🖼️ Imagens Necessárias

Para a atividade de associação de palavras, você precisará de imagens correspondentes às palavras. No MVP atual, estamos usando emojis como placeholder, mas você pode substituir por imagens reais.

### Lista de Imagens Recomendadas:

#### Atividade 1 - Associação Básica:
- `cat.png` - Imagem de um gato
- `sun.png` - Imagem do sol
- `house.png` - Imagem de uma casa

#### Futuras Atividades (Sugestões):
- `dog.png` - Cachorro
- `tree.png` - Árvore
- `car.png` - Carro
- `ball.png` - Bola
- `book.png` - Livro
- `apple.png` - Maçã
- `moon.png` - Lua

## 📐 Especificações das Imagens

### Formato:
- PNG com transparência (recomendado)
- JPG para fotos

### Tamanho:
- Resolução: 512x512 pixels (ideal)
- Mínimo: 256x256 pixels
- Máximo: 1024x1024 pixels

### Qualidade:
- Imagens simples e claras
- Alto contraste
- Cores vibrantes
- Fundo transparente ou branco

## 🎨 Onde Encontrar Imagens Gratuitas

1. **Flaticon** (https://www.flaticon.com/)
   - Ícones vetoriais gratuitos
   - Boa para objetos simples

2. **Freepik** (https://www.freepik.com/)
   - Ilustrações e vetores
   - Conta gratuita disponível

3. **Unsplash** (https://unsplash.com/)
   - Fotos de alta qualidade
   - Totalmente gratuitas

4. **Pixabay** (https://pixabay.com/)
   - Imagens e vetores
   - Licença livre

5. **OpenMoji** (https://openmoji.org/)
   - Emojis em SVG/PNG
   - Open source

## 🔊 Sons (Opcional)

Se quiser adicionar feedback sonoro além do TTS:

### Sons Necessários:
- `correct.mp3` - Som de acerto (ex: "ding", aplausos)
- `wrong.mp3` - Som de erro (ex: "buzz", "oh no")
- `completed.mp3` - Som de conclusão (ex: música de vitória)

### Especificações:
- Formato: MP3 ou OGG
- Duração: 1-3 segundos
- Volume: Normalizado

### Onde Encontrar Sons:
- **Freesound** (https://freesound.org/)
- **Zapsplat** (https://www.zapsplat.com/)
- **Mixkit** (https://mixkit.co/free-sound-effects/)

## 📝 Como Adicionar Assets

### 1. Adicionar Imagens:

Copie suas imagens para a pasta:
```bash
dislexia_app/assets/images/
```

### 2. Atualizar pubspec.yaml:

As imagens já estão configuradas no `pubspec.yaml`:
```yaml
flutter:
  assets:
    - assets/images/
    - assets/sounds/
```

### 3. Usar no Código:

Substitua os emojis em `activity_match_words.dart`:

```dart
// DE (emoji):
Text('🐱', style: TextStyle(fontSize: 50))

// PARA (imagem):
Image.asset(
  'assets/images/cat.png',
  width: 80,
  height: 80,
  fit: BoxFit.contain,
)
```

### 4. Atualizar WordImagePair:

```dart
class WordImagePair {
  final String word;
  final String imageAsset;  // Mude de emoji para imageAsset
  final Color color;

  WordImagePair({
    required this.word,
    required this.imageAsset,
    required this.color,
  });
}

// Uso:
final List<WordImagePair> _wordImagePairs = [
  WordImagePair(
    word: 'GATO',
    imageAsset: 'assets/images/cat.png',
    color: Colors.orange,
  ),
  // ...
];
```

## ⚠️ Observações Importantes

1. **Licenças**: Sempre verifique as licenças das imagens/sons antes de usar
2. **Atribuição**: Se necessário, adicione créditos aos autores
3. **Tamanho**: Otimize imagens para não aumentar muito o tamanho do app
4. **Acessibilidade**: Use imagens claras e de fácil reconhecimento

## 🎯 Para o MVP Atual

O MVP está usando emojis como placeholder, o que é suficiente para demonstração. Você pode:

**Opção 1**: Manter emojis (mais rápido, funciona sem assets externos)
**Opção 2**: Adicionar imagens reais (mais profissional, requer download/criação)

Para o TCC, emojis são aceitáveis se você explicar que é um MVP e que a versão final teria imagens reais.

## 📱 Testando Assets

Após adicionar imagens:

1. Execute `flutter pub get`
2. Reinicie o app (`flutter run`)
3. Verifique se as imagens carregam corretamente
4. Teste em diferentes dispositivos/resoluções

## 🚀 Próximos Passos

Para expandir o app:

1. Crie categorias de palavras (animais, frutas, cores, etc.)
2. Adicione mais níveis de dificuldade
3. Inclua palavras mais complexas
4. Adicione variações regionais
5. Implemente modo de prática livre

---

**Dica**: Para o TCC, documente suas escolhas de design visual e explique como elas ajudam pessoas com dislexia (alto contraste, imagens simples, fontes específicas, etc.)
