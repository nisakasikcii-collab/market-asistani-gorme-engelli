import 'package:eyeshopper_ai/core/config/app_config.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

class FirebaseBootstrap {
  static Future<void> initIfConfigured() async {
    final options = _resolveOptions();
    if (options != null) {
      await Firebase.initializeApp(options: options);
    }
  }

  static FirebaseOptions? _resolveOptions() {
    final apiKey = AppConfig.firebaseApiKey;
    final messagingSenderId = AppConfig.firebaseMessagingSenderId;
    final projectId = AppConfig.firebaseProjectId;
    if (apiKey == null || messagingSenderId == null || projectId == null) {
      return null;
    }

    if (kIsWeb) {
      final webAppId = AppConfig.firebaseWebAppId;
      if (webAppId == null) return null;
      return FirebaseOptions(
        apiKey: apiKey,
        appId: webAppId,
        messagingSenderId: messagingSenderId,
        projectId: projectId,
        authDomain: AppConfig.firebaseAuthDomain,
        storageBucket: AppConfig.firebaseStorageBucket,
      );
    }

    final platform = defaultTargetPlatform;
    final appId = platform == TargetPlatform.android
        ? AppConfig.firebaseAndroidAppId
        : AppConfig.firebaseIosAppId;
    if (appId == null) return null;

    return FirebaseOptions(
      apiKey: apiKey,
      appId: appId,
      messagingSenderId: messagingSenderId,
      projectId: projectId,
      storageBucket: AppConfig.firebaseStorageBucket,
    );
  }
}
