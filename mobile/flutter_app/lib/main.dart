import "package:flutter/material.dart";
import "dart:ui";

import "app.dart";
import "bootstrap/firebase_bootstrap.dart";
import "core/config/app_config.dart";
import "core/logging/app_logger.dart";
import "core/voice/tts_service.dart";

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await AppConfig.load();
  AppLogger.init();
  AppLogger.i("Eyeshopper AI başlıyor");
  FlutterError.onError = (details) {
    AppLogger.e("Flutter framework hatasi", details.exception, details.stack);
  };
  PlatformDispatcher.instance.onError = (error, stack) {
    AppLogger.e("Yakalnmayan platform hatasi", error, stack);
    return true;
  };

  await FirebaseBootstrap.initIfConfigured();

  try {
    await TtsService.instance.init();
  } catch (e, st) {
    AppLogger.e("TTS ön başlatma başarısız", e, st);
  }

  runApp(const EsApp());
}
