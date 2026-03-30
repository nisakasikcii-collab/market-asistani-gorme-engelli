import "package:flutter_dotenv/flutter_dotenv.dart";

/// Uygulama geneli yapılandırma (dotenv asset üzerinden).
class AppConfig {
  AppConfig._();

  static bool _loaded = false;

  static bool get isLoaded => _loaded;

  /// [assetPath] öntanımlı: `assets/config/.env`
  static Future<void> load({String assetPath = "assets/config/.env"}) async {
    if (_loaded) return;
    await dotenv.load(fileName: assetPath);
    _loaded = true;
  }

  static String? _value(String key) {
    final value = dotenv.maybeGet(key)?.trim();
    if (value == null || value.isEmpty) return null;
    return value;
  }

  static String? get geminiApiKey => _value("GEMINI_API_KEY");

  static String? get firebaseProjectId => _value("FIREBASE_PROJECT_ID");
  static String? get firebaseApiKey => _value("FIREBASE_API_KEY");
  static String? get firebaseMessagingSenderId =>
      _value("FIREBASE_MESSAGING_SENDER_ID");
  static String? get firebaseStorageBucket =>
      _value("FIREBASE_STORAGE_BUCKET");
  static String? get firebaseAuthDomain => _value("FIREBASE_AUTH_DOMAIN");

  static String? get firebaseAndroidAppId =>
      _value("FIREBASE_APP_ID_ANDROID");
  static String? get firebaseIosAppId => _value("FIREBASE_APP_ID_IOS");
  static String? get firebaseWebAppId => _value("FIREBASE_APP_ID_WEB");

  static bool get hasFirebaseCoreConfig =>
      firebaseProjectId != null &&
      firebaseApiKey != null &&
      firebaseMessagingSenderId != null;
}
