import 'dart:async';
import 'package:permission_handler/permission_handler.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

import '../logging/app_logger.dart';

typedef ListenResultCallback = void Function(String words, bool isFinal);

class SttService {
  SttService._();
  static final SttService instance = SttService._();

  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _initialized = false;

  bool get isInitialized => _initialized;
  bool get isListening => _speech.isListening;

  // 🔥 DAHA SAĞLAM INIT
  Future<bool> ensureInitialized({String localeId = "tr_TR"}) async {
    if (_initialized) return true;

    final permission = await Permission.microphone.request();
    if (!permission.isGranted) {
      AppLogger.e("Mikrofon izni verilmedi");
      return false;
    }

    try {
      final available = await _speech.initialize(
        onStatus: (status) {
          AppLogger.d("STT STATUS: $status");
        },
        onError: (error) {
          AppLogger.e("STT ERROR: ${error.errorMsg}");
        },
      );

      _initialized = available;
      return available;
    } catch (e, st) {
      AppLogger.e("STT init hata", e, st);
      return false;
    }
  }

  // 🔥 DÜZELTİLMİŞ DİNLEME
  Future<void> startListening({
    required ListenResultCallback onResult,
    String localeId = "tr_TR",
    Duration listenFor = const Duration(seconds: 30),
  }) async {
    final ok = await ensureInitialized(localeId: localeId);

    if (!ok) {
      AppLogger.e("STT başlatılamadı");
      return;
    }

    try {
      await _speech.listen(
        localeId: localeId,
        listenFor: listenFor,
        pauseFor: const Duration(seconds: 5),
        partialResults: true,
        cancelOnError: true,
        onResult: (result) {
          final text = result.recognizedWords;

          AppLogger.d("STT RESULT: $text");

          if (text.isNotEmpty) {
            onResult(text, result.finalResult);
          }
        },
      );

      AppLogger.i("STT dinleme başladı");
    } catch (e, st) {
      AppLogger.e("STT listen hata", e, st);
    }
  }

  Future<void> stopListening() async {
    if (_speech.isListening) {
      await _speech.stop();
    }
  }

  Future<void> cancelListening() async {
    if (_speech.isListening) {
      await _speech.cancel();
    }
  }
}