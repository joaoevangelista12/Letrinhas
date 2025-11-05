// arquivo: lib/utils/tts_helper.dart

import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';

/// Helper para configurar e testar TTS em Português Brasileiro
class TtsHelper {
  /// Configura TTS em Português Brasileiro com todas as tentativas possíveis
  static Future<bool> configurePortugueseBrazilian(FlutterTts tts) async {
    try {
      // Lista idiomas disponíveis
      var languages = await tts.getLanguages;
      debugPrint('=== TTS CONFIGURAÇÃO ===');
      debugPrint('Idiomas disponíveis: $languages');

      // Tenta configurar português brasileiro em diferentes formatos
      bool languageSet = false;

      // Tenta pt-BR primeiro (formato correto)
      if (languages.contains('pt-BR') || languages.contains('pt_BR')) {
        await tts.setLanguage('pt-BR');
        languageSet = true;
        debugPrint('✅ Idioma configurado: pt-BR');
      }
      // Tenta pt-br (minúsculo)
      else if (languages.contains('pt-br') || languages.contains('pt_br')) {
        await tts.setLanguage('pt-br');
        languageSet = true;
        debugPrint('✅ Idioma configurado: pt-br');
      }
      // Tenta apenas pt (português genérico)
      else if (languages.contains('pt') || languages.contains('pt-PT')) {
        await tts.setLanguage('pt');
        languageSet = true;
        debugPrint('⚠️ Idioma configurado: pt (genérico, pode ser Portugal)');
      }

      if (!languageSet) {
        debugPrint('❌ ERRO: Português não encontrado!');
        debugPrint('Idiomas disponíveis: $languages');
        return false;
      }

      // Lista todas as vozes disponíveis
      var voices = await tts.getVoices;
      debugPrint('\n=== VOZES DISPONÍVEIS (${voices.length}) ===');

      // Procura e lista vozes em português
      var portugueseVoices = <Map<String, dynamic>>[];

      for (var voice in voices) {
        final locale = voice['locale']?.toString() ?? '';
        final name = voice['name']?.toString() ?? '';

        // Se for voz em português
        if (locale.toLowerCase().contains('pt') ||
            name.toLowerCase().contains('portuguese') ||
            name.toLowerCase().contains('portugues')) {
          portugueseVoices.add(voice);
          debugPrint('🇧🇷 $name (${locale})');
        }
      }

      debugPrint('\n=== VOZES EM PORTUGUÊS ENCONTRADAS: ${portugueseVoices.length} ===');

      // Tenta selecionar a melhor voz brasileira
      Map<String, dynamic>? selectedVoice;

      // Prioridade 1: Vozes explicitamente brasileiras
      selectedVoice = portugueseVoices.firstWhere(
        (voice) {
          final locale = voice['locale']?.toString().toLowerCase() ?? '';
          final name = voice['name']?.toString().toLowerCase() ?? '';
          return locale.contains('br') ||
              locale == 'pt-br' ||
              locale == 'pt_br' ||
              name.contains('brazil');
        },
        orElse: () => {},
      );

      // Prioridade 2: Qualquer voz em português
      if (selectedVoice.isEmpty && portugueseVoices.isNotEmpty) {
        selectedVoice = portugueseVoices.first;
      }

      // Tenta configurar a voz selecionada
      if (selectedVoice.isNotEmpty) {
        try {
          await tts.setVoice({
            "name": selectedVoice["name"],
            "locale": selectedVoice["locale"]
          });
          debugPrint('✅ Voz selecionada: ${selectedVoice["name"]} (${selectedVoice["locale"]})');
        } catch (e) {
          debugPrint('⚠️ Erro ao configurar voz: $e');
        }
      } else {
        debugPrint('⚠️ Nenhuma voz em português encontrada, usando padrão do sistema');
      }

      // Configurações de velocidade e tom (ideal para dislexia)
      await tts.setSpeechRate(0.5); // 50% da velocidade normal
      await tts.setVolume(1.0); // Volume máximo
      await tts.setPitch(1.0); // Tom normal

      debugPrint('\n=== CONFIGURAÇÃO FINALIZADA ===');
      debugPrint('SpeechRate: 0.5 (lento)');
      debugPrint('Volume: 1.0 (máximo)');
      debugPrint('Pitch: 1.0 (normal)');
      debugPrint('========================\n');

      return true;
    } catch (e) {
      debugPrint('❌ ERRO CRÍTICO ao configurar TTS: $e');
      return false;
    }
  }

  /// Testa o TTS falando uma frase em português
  static Future<void> testSpeak(FlutterTts tts) async {
    try {
      await tts.speak('Olá! Estou falando em português brasileiro.');
      debugPrint('🔊 Teste de fala executado');
    } catch (e) {
      debugPrint('❌ Erro no teste de fala: $e');
    }
  }

  /// Lista todos os idiomas e vozes disponíveis (para debug)
  static Future<void> debugAvailableVoices(FlutterTts tts) async {
    try {
      debugPrint('\n========================================');
      debugPrint('DEBUG: IDIOMAS E VOZES DISPONÍVEIS');
      debugPrint('========================================\n');

      // Idiomas
      var languages = await tts.getLanguages;
      debugPrint('IDIOMAS (${languages.length}):');
      for (var lang in languages) {
        debugPrint('  - $lang');
      }

      // Vozes
      var voices = await tts.getVoices;
      debugPrint('\nVOZES (${voices.length}):');
      for (var voice in voices) {
        debugPrint('  - ${voice["name"]} (${voice["locale"]})');
      }

      debugPrint('\n========================================\n');
    } catch (e) {
      debugPrint('❌ Erro ao listar vozes: $e');
    }
  }
}
