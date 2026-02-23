// arquivo: lib/utils/sound_helper.dart

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';

/// Helper para efeitos sonoros do app.
/// Toca sons curtos de acerto e erro.
class SoundHelper {
  static final AudioPlayer _player = AudioPlayer();

  /// Toca som de acerto (tom ascendente alegre)
  static Future<void> playCorrect() async {
    try {
      await _player.play(AssetSource('sounds/correct.wav'));
    } catch (e) {
      debugPrint('Erro ao tocar som de acerto: $e');
    }
  }

  /// Toca som de erro (tom descendente suave)
  static Future<void> playWrong() async {
    try {
      await _player.play(AssetSource('sounds/wrong.wav'));
    } catch (e) {
      debugPrint('Erro ao tocar som de erro: $e');
    }
  }
}
