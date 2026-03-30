import "dart:async";
import "package:audioplayers/audioplayers.dart";
import "package:flutter/services.dart";

import "../logging/app_logger.dart";
import "speech_priority.dart";
import "stt_service.dart";
import "tts_service.dart";

/// TTS/STT üzerinde ortak sesli geri bildirim katmanı.
class VoiceFeedback {
  VoiceFeedback._();
  static final VoiceFeedback instance = VoiceFeedback._();

  final TtsService _tts = TtsService.instance;
  final SttService _stt = SttService.instance;
  final AudioPlayer _audioPlayer = AudioPlayer();

  // Çakışmaları önlemek için kilit
  bool _isListening = false;

  Future<void> speakInfo(String message) =>
      _tts.speak(message, priority: SpeechPriority.info);

  Future<void> speakWarning(String message) =>
      _tts.speak(message, priority: SpeechPriority.warning);

  Future<void> speakCritical(String message) =>
      _tts.speak(message, priority: SpeechPriority.critical);

  /// Dinleme başlamadan önce sesli geri bildirimi
  Future<void> _playListeningFeedback() async {
    try {
      // Önce titreşim
      await HapticFeedback.mediumImpact();

      // Kısa bekleme
      await Future.delayed(const Duration(milliseconds: 100));

      // Ses dosyası çal (beep sesi)
      await _audioPlayer.play(AssetSource('sounds/listening_beep.wav'));

      // Alternatif: Eğer ses dosyası yoksa haptic fallback
      // await HapticFeedback.selectionClick();
    } catch (e) {
      AppLogger.d("Ses geri bildirimi hatası: $e");
      // Fallback olarak haptic kullan
      try {
        await HapticFeedback.selectionClick();
      } catch (hapticError) {
        AppLogger.d("Haptic fallback da başarısız: $hapticError");
      }
    }
  }

  /// Dinleme oturumu bitince sonucu döndürür.
  Future<String?> listenOnce({
    Duration listenFor = const Duration(seconds: 10),
    String localeId = "tr_TR",
  }) async {
    // Eğer zaten bir dinleme yapılıyorsa hata vermemesi için koruma
    if (_isListening) {
      AppLogger.w("Zaten dinleme yapılıyor, işlem iptal edildi.");
      return null;
    }

    final ok = await _stt.ensureInitialized(localeId: localeId);
    if (!ok) {
      AppLogger.w("Dinleme başlatılamadı: STT yok");
      await speakWarning("Sesli komut şu an kullanılamıyor. Mikrofon iznini kontrol edin.");
      return null;
    }

    _isListening = true;
    final Completer<String?> completer = Completer<String?>();
    String? lastFinal;

    try {
      // Önceki ses işlemlerini durdur ve temizle
      await _stt.stopListening();
      await Future.delayed(const Duration(milliseconds: 300));

      // Dinleme başladığını kullanıcıya hissettir
      await _playListeningFeedback();

      await _stt.startListening(
        listenFor: listenFor,
        localeId: localeId,
        onResult: (words, isFinal) {
          if (words.trim().isNotEmpty) {
            lastFinal = words.trim();
          }
          // Sonuç kesinleştiğinde veya durduğunda completer'ı bitir
          if (isFinal && !completer.isCompleted) {
            completer.complete(lastFinal);
          }
        },
      );

      // Güvenlik: Eğer 10 saniye boyunca hiçbir sonuç gelmezse otomatik kapat
      Future.delayed(listenFor + const Duration(milliseconds: 500), () {
        if (!completer.isCompleted) {
          completer.complete(lastFinal);
        }
      });

      // Burada sonuç gelene kadar bekliyoruz (HATA BURADAYDI, ARTIK BEKLİYOR)
      final result = await completer.future;
      _isListening = false;
      return result;

    } catch (e) {
      AppLogger.e("Dinleme sürecinde hata oluştu: $e");
      _isListening = false;
      if (!completer.isCompleted) completer.complete(null);
      return null;
    }
  }

  /// AudioPlayer kaynaklarını temizle
  void dispose() {
    _audioPlayer.dispose();
  }
}