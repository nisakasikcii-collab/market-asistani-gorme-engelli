import "../logging/app_logger.dart";
import "../voice/voice_feedback.dart";

/// Görme engelli kullanıcılar için akıllı asistan.
/// Uygulama başladığında sesli rehberlik sağlar.
class SmartAssistant {
  SmartAssistant._();

  static final SmartAssistant instance = SmartAssistant._();

  final VoiceFeedback _voice = VoiceFeedback.instance;
  bool _assistantShown = false;

  bool get assistantShown => _assistantShown;

  /// İlk açılışta akıllı asistan rehberliğini başlat
  Future<void> showInitialGuidance() async {
    if (_assistantShown) return;
    _assistantShown = true;

    try {
      // Adım 1: Hoş geldiniz mesajı
      await _voice.speakInfo(
        "Eyeshopper AI'ye hoş geldiniz. "
        "Bu uygulama görme engelli kullanıcılar için tasarlanmıştır. "
        "Tüm özellikler sesli komutlar ve ekran okuyucular ile kullanılabilir.",
      );

      await Future<void>.delayed(const Duration(milliseconds: 1500));

      // Adım 2: Ana özellikler
      await _voice.speakInfo(
        "Ana özellikleri tanıtıyorum. "
        "Birinci özellik: Tarama ekranı. "
        "Ürünleri kamera ile tarayıp fiyat, besin değeri ve uyarı alabilirsiniz.",
      );

      await Future<void>.delayed(const Duration(milliseconds: 1500));

      // Adım 3: Alışveriş listesi
      await _voice.speakInfo(
        "İkinci özellik: Alışveriş listesi. "
        "Sesle ürün ekleyebilir, listeyi yönetebilirsiniz.",
      );

      await Future<void>.delayed(const Duration(milliseconds: 1500));

      // Adım 4: Profil ayarları
      await _voice.speakInfo(
        "Üçüncü özellik: Profil ayarları. "
        "Sağlık kısıtlamalarınızı kaydedin. "
        "Uygulama bu kısıtlamalara göre uyarı verecektir.",
      );

      await Future<void>.delayed(const Duration(milliseconds: 1500));

      // Adım 5: Sesli komutlar
      await _voice.speakInfo(
        "Dördüncü özellik: Sesli komutlar. "
        "İstediğiniz zaman tarama aç, listeyi aç, profili aç gibi komutlar verebilirsiniz.",
      );

      await Future<void>.delayed(const Duration(milliseconds: 1500));

      // Adım 6: Kısayollar
      await _voice.speakInfo(
        "Beşinci özellik: Hızlı kısayollar. "
        "Şu komutları söyleyin: "
        "Tarama aç, Listeyi aç, Profili aç, "
        "Geri dön, Seç, veya Ileri git.",
      );

      await Future<void>.delayed(const Duration(milliseconds: 1500));

      // Son: Hazırlık bitişi
      await _voice.speakInfo(
        "Rehberlik tamamlandı. "
        "Artık uygulama için hazırsınız. "
        "İstediğiniz zaman sesli komut verebilir ya da dokunarak navigasyon yapabilirsiniz. "
        "Eğlenin!",
      );
    } catch (e, st) {
      AppLogger.e("Akıllı asistan hatası", e, st);
    }
  }

  /// Belirtilen ekran için rehberlik seslendir
  Future<void> announceScreen(String screenName, String description) async {
    try {
      await _voice.speakInfo("$screenName ekranına hoş geldiniz. $description");
    } catch (e, st) {
      AppLogger.e("Ekran duyurusu hatası", e, st);
    }
  }

  /// Buton eylemi için geri bildirim seslendir
  Future<void> announceAction(String actionName) async {
    try {
      await _voice.speakInfo("$actionName seçildi.");
    } catch (e, st) {
      AppLogger.e("Eylem duyurusu hatası", e, st);
    }
  }

  /// Hata durumunu seslendir
  Future<void> announceError(String error) async {
    try {
      await _voice.speakWarning("Hata: $error");
    } catch (e, st) {
      AppLogger.e("Hata duyurusu hatası", e, st);
    }
  }

  /// Başarı durumunu seslendir
  Future<void> announceSuccess(String message) async {
    try {
      await _voice.speakInfo("Başarılı: $message");
    } catch (e, st) {
      AppLogger.e("Başarı duyurusu hatası", e, st);
    }
  }

  /// Rehbet modunu sıfırla (test için)
  void resetForTesting() {
    _assistantShown = false;
  }
}
