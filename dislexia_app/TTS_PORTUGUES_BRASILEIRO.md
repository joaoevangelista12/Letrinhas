# 🔊 COMO HABILITAR TTS EM PORTUGUÊS BRASILEIRO

## ❗ PROBLEMA: TTS não está falando em português brasileiro

Se o Text-to-Speech estiver falando em **inglês ou outro idioma**, siga este guia:

---

## 🌐 SOLUÇÃO PARA WEB (Chrome/Edge/Brave)

### **1. Verifique as Vozes Disponíveis no Navegador**

O TTS no navegador usa as vozes instaladas no seu **sistema operacional**.

#### Para ver quais vozes você tem:

1. Abra o **Console do Navegador** (F12)
2. Vá na aba **Console**
3. Cole este código e aperte Enter:

```javascript
window.speechSynthesis.getVoices().forEach(voice => {
  console.log(voice.name, voice.lang);
});
```

4. Procure por vozes com `pt-BR` ou `pt_BR`

**Exemplo de saída:**
```
Google português do Brasil (pt-BR)
Microsoft Maria - Portuguese (Brazil) (pt-BR)
```

---

### **2. Se NÃO tiver voz em Português Brasileiro:**

#### 🪟 **Windows 10/11:**

1. **Configurações** → **Hora e idioma** → **Idioma e região**
2. Clique em **Adicionar um idioma**
3. Procure por **Português (Brasil)**
4. Selecione e clique em **Avançar**
5. Marque a opção **"Conversão de texto em fala"**
6. Clique em **Instalar**
7. Aguarde o download (pode levar alguns minutos)
8. **Reinicie o navegador**

---

#### 🍎 **macOS:**

1. **Preferências do Sistema** → **Acessibilidade** → **Conteúdo Falado**
2. Clique em **Vozes do Sistema...**
3. Procure por **Português (Brasil)** ou **Luciana** (voz brasileira)
4. Clique em **Baixar** (ícone de nuvem)
5. Aguarde o download
6. **Reinicie o navegador**

---

#### 🐧 **Linux (Ubuntu/Debian):**

```bash
# Instalar espeak-ng com português brasileiro
sudo apt-get update
sudo apt-get install espeak-ng espeak-ng-data

# Instalar vozes adicionais
sudo apt-get install mbrola mbrola-br1 mbrola-br3 mbrola-br4

# Testar
espeak-ng -v pt-BR "Olá, estou falando em português brasileiro"
```

**Reinicie o navegador após instalar.**

---

### **3. Configure o Navegador para Usar Português**

#### **Chrome/Edge/Brave:**

1. **Configurações** → **Idiomas**
2. Clique em **Adicionar idiomas**
3. Adicione **Português (Brasil)**
4. Arraste para o **topo da lista** (idioma preferencial)
5. **Reinicie o navegador**

---

### **4. Teste no Aplicativo**

Depois de instalar:

1. **Feche completamente o navegador** (não apenas a aba)
2. Abra novamente
3. Execute: `flutter run -d chrome`
4. Entre na atividade "Associar Palavras"
5. **Olhe no Console/Terminal** → Deve mostrar:

```
=== TTS CONFIGURAÇÃO ===
Idiomas disponíveis: [en-US, pt-BR, es-ES, ...]
✅ Idioma configurado: pt-BR
🇧🇷 Google português do Brasil (pt-BR)
✅ Voz selecionada: Google português do Brasil (pt-BR)
```

6. Clique em uma palavra → Deve falar em português!

---

## 📱 SOLUÇÃO PARA ANDROID

### **1. Instalar Voz Portuguesa no Android:**

1. **Configurações** → **Sistema** → **Idioma e entrada**
2. **Saída de conversão de texto em fala**
3. Clique no ícone de **⚙️ (configurações)** ao lado de "Motor de voz preferido"
4. Selecione **Google Text-to-Speech** (ou Samsung TTS)
5. Clique em **Instalar dados de voz**
6. Procure por **Português (Brasil)**
7. Baixe e instale
8. Teste: diga "Olá" e ouça se está em português

### **2. Defina Português como Idioma Principal:**

1. **Configurações** → **Sistema** → **Idioma e entrada**
2. **Idiomas**
3. Adicione **Português (Brasil)**
4. Arraste para o topo

---

## 🍎 SOLUÇÃO PARA iOS

### **1. Baixar Voz em Português:**

1. **Ajustes** → **Acessibilidade** → **Conteúdo Falado**
2. **Vozes**
3. **Português**
4. Baixe **Luciana (Melhorada)** ou **Português (Brasil)**
5. Aguarde o download

### **2. Configurar Idioma:**

1. **Ajustes** → **Geral** → **Idioma e Região**
2. Adicione **Português - Brasil**
3. Defina como idioma preferencial

---

## 🔍 DEBUG: Verificar Logs do TTS

### **No Terminal/Console** (quando roda o app):

Você deve ver algo assim:

```
=== TTS CONFIGURAÇÃO ===
Idiomas disponíveis: [en-US, pt-BR, pt-PT, es-ES, ...]
✅ Idioma configurado: pt-BR

=== VOZES DISPONÍVEIS (15) ===
🇧🇷 Google português do Brasil (pt-BR)
🇧🇷 Microsoft Maria - Portuguese (Brazil) (pt-BR)

=== VOZES EM PORTUGUÊS ENCONTRADAS: 2 ===
✅ Voz selecionada: Google português do Brasil (pt-BR)

=== CONFIGURAÇÃO FINALIZADA ===
SpeechRate: 0.5 (lento)
Volume: 1.0 (máximo)
Pitch: 1.0 (normal)
========================

🔊 Teste de fala executado
🔊 TTS falando: Olá! Estou falando em português brasileiro.
```

---

## ❌ SE AINDA NÃO FUNCIONAR

### **Verificação Manual no Console:**

1. Abra o app no Chrome
2. Pressione **F12** (DevTools)
3. Vá na aba **Console**
4. Digite e execute:

```javascript
// Listar todas as vozes
var voices = window.speechSynthesis.getVoices();
console.log('Total de vozes:', voices.length);

voices.forEach((voice, i) => {
  console.log(`${i}: ${voice.name} (${voice.lang})`);
});

// Procurar vozes em português
var ptVoices = voices.filter(v => v.lang.includes('pt'));
console.log('Vozes em português:', ptVoices);

// Testar fala em português
var utterance = new SpeechSynthesisUtterance('Olá, estou falando em português brasileiro');
utterance.lang = 'pt-BR';
utterance.rate = 0.5;

// Se encontrou voz brasileira, usar ela
if (ptVoices.length > 0) {
  utterance.voice = ptVoices[0];
}

window.speechSynthesis.speak(utterance);
```

---

## 🆘 ÚLTIMA OPÇÃO: Usar Google Translate TTS

Se **nada funcionar**, podemos integrar o Google Translate TTS como fallback:

```dart
// Adicionar ao pubspec.yaml:
dependencies:
  url_launcher: ^6.2.1

// Usar URL do Google Translate:
final url = 'https://translate.google.com/translate_tts?ie=UTF-8&tl=pt-BR&client=tw-ob&q=${Uri.encodeComponent(text)}';
await canLaunchUrl(Uri.parse(url)) ? launchUrl(Uri.parse(url)) : null;
```

**Mas isso requer internet!** Então tentamos evitar.

---

## 🎯 CHECKLIST DE SOLUÇÃO

- [ ] Verifiquei as vozes disponíveis no navegador
- [ ] Instalei voz em Português (Brasil) no sistema operacional
- [ ] Reiniciei o navegador completamente
- [ ] Configurei Português como idioma preferencial
- [ ] Verifiquei os logs no Console/Terminal
- [ ] Testei com o código JavaScript manual
- [ ] Ainda não funciona? Reportar o problema com os logs

---

## 📧 REPORTE O PROBLEMA

Se seguiu TODOS os passos e ainda não funciona, copie e cole:

### **1. Qual sistema operacional?**
- [ ] Windows 10/11
- [ ] macOS
- [ ] Linux (qual distribuição?)

### **2. Qual navegador?**
- [ ] Chrome
- [ ] Edge
- [ ] Firefox
- [ ] Safari
- [ ] Outro:

### **3. Saída do Console/Terminal:**
(cole os logs aqui)

### **4. Saída do JavaScript no Console:**
(cole resultado do `getVoices()` aqui)

---

## ✅ RESULTADO ESPERADO

Quando tudo estiver correto:

1. **Clica em "GATO"** → 🔊 Fala "GATO" em português brasileiro
2. **Arrasta corretamente** → 🔊 "Correto! GATO" em português
3. **Arrasta errado** → 🔊 "Ops! Tente novamente" em português
4. **Completa tudo** → 🔊 "Parabéns! Você completou a atividade!" em português

---

**🎊 Siga este guia passo a passo e o TTS vai funcionar em português brasileiro!**
