import "package:flutter_tts/flutter_tts.dart";

import "../logging/app_logger.dart";
import "speech_priority.dart";

/// Merkezi metin-seslendirme servisi (TTS).
class TtsService {
  TtsService._();

  static final TtsService instance = TtsService._();

  final FlutterTts _engine = FlutterTts();
  bool _ready = false;
  bool _isSpeaking = false;

  bool get isReady => _ready;
  Future<bool> get isSpeaking async => _isSpeaking;

  Future<void> init({String language = "tr-TR"}) async {
    if (_ready) return;
    try {
      await _engine.setLanguage(language);
      await _engine.setSpeechRate(0.48);
      await _engine.setVolume(1.0);
      await _engine.setPitch(1.0);

      _engine.setStartHandler(() {
        _isSpeaking = true;
      });
      _engine.setCompletionHandler(() {
        _isSpeaking = false;
      });
      _engine.setErrorHandler((msg) {
        _isSpeaking = false;
      });

      _ready = true;
      AppLogger.i("TTS başlatıldı ($language)");
    } catch (e, st) {
      AppLogger.e("TTS başlatılamadı", e, st);
      rethrow;
    }
  }

  /// Metni seslendirir. Önceliğe göre hız ve ses seviyesi ayarlanır.
  Future<void> speak(
    String text, {
    SpeechPriority priority = SpeechPriority.info,
  }) async {
    if (!_ready) await init();
    final trimmed = text.trim();
    if (trimmed.isEmpty) return;

    // Önceki tüm sesleri kapat ve flag'i temizle
    await stop();
    
    // Küçük bir bekleme ile engine'in stop olmasını sağla
    await Future.delayed(const Duration(milliseconds: 50));

    await _engine.setSpeechRate(priority.rate);
    await _engine.setVolume(priority.volume);
    AppLogger.d("TTS [${priority.debugLabel}]: $trimmed");
    await _engine.speak(trimmed);
  }

  Future<void> stop() async {
    await _engine.stop();
    _isSpeaking = false; // Flag'i manuel olarak temizle
  }
}
