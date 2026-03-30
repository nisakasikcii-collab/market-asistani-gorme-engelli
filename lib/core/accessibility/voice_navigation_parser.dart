/// Sesli komutlar için destek enum
enum VoiceNavigationCommand {
  scanOpen("Tarama aç"),
  listOpen("Listeyi aç"),
  listOpen2("Liste aç"),
  profileOpen("Profili aç"),
  profileOpen2("Ayarları aç"),
  communityOpen("Topluluk aç"),
  helpOpen("Yardım aç"),
  back("Geri dön"),
  back2("Geri"),
  next("İleri git"),
  next2("İleri"),
  select("Seç"),
  select2("Tamam"),
  exit("Çık"),
  repeat("Tekrar oku"),
  repeatDescription("Başlığı tekrar oku"),
  listItems("Öğeleri oku"),
  help("Komutları söyle"),
  unknown("Bilinmeyen");

  final String displayName;
  const VoiceNavigationCommand(this.displayName);
}

/// Sesli komut çözümleyici — Kullanıcı metni komuta ve
class VoiceNavigationParser {
  /// Input metnini bir [VoiceNavigationCommand]'a çevir
  VoiceNavigationCommand parseNavigation(String? input) {
    if (input == null || input.trim().isEmpty) {
      return VoiceNavigationCommand.unknown;
    }

    final normalized = input.toLowerCase().trim();

    // Tarama açma komutları
    if (normalized.contains("tarama") && normalized.contains("aç")) {
      return VoiceNavigationCommand.scanOpen;
    }
    if (normalized.contains("tara")) {
      return VoiceNavigationCommand.scanOpen;
    }

    // Alışveriş listesi açma komutları
    if (normalized.contains("liste") && normalized.contains("aç")) {
      return VoiceNavigationCommand.listOpen;
    }
    if (normalized.contains("listesini")) {
      return VoiceNavigationCommand.listOpen;
    }
    if (normalized.contains("alışveriş")) {
      return VoiceNavigationCommand.listOpen;
    }

    // Profil/Ayarlar açma komutları
    if (normalized.contains("profil") || normalized.contains("ayar")) {
      return VoiceNavigationCommand.profileOpen;
    }

    // Topluluk açma komutları
    if (normalized.contains("topluluk") || normalized.contains("geri bildirim")) {
      return VoiceNavigationCommand.communityOpen;
    }

    // Yardım komutları
    if (normalized.contains("yardım") || normalized.contains("help")) {
      return VoiceNavigationCommand.helpOpen;
    }

    // Geri dönme komutları
    if (normalized.contains("geri") || normalized.contains("back")) {
      return VoiceNavigationCommand.back;
    }
    if (normalized == "geri dön") {
      return VoiceNavigationCommand.back;
    }

    // İleri gitme komutları
    if (normalized.contains("ileri") || normalized.contains("next")) {
      return VoiceNavigationCommand.next;
    }

    // Seçme komutları
    if (normalized.contains("seç") || normalized.contains("select") || normalized == "tamam") {
      return VoiceNavigationCommand.select;
    }

    // Çıkış komutları
    if (normalized.contains("çık") || normalized.contains("exit")) {
      return VoiceNavigationCommand.exit;
    }

    // Tekrar okuma komutları
    if (normalized.contains("tekrar") || normalized.contains("oku")) {
      return VoiceNavigationCommand.repeat;
    }

    // Başlığı tekrar okuma
    if (normalized.contains("başlık")) {
      return VoiceNavigationCommand.repeatDescription;
    }

    // Öğeleri okuma
    if (normalized.contains("öğe") || normalized.contains("items")) {
      return VoiceNavigationCommand.listItems;
    }

    // Komutları söyleme
    if (normalized.contains("komut") || normalized == "ne söyleyebilirim") {
      return VoiceNavigationCommand.help;
    }

    return VoiceNavigationCommand.unknown;
  }

  /// Tüm kullanılabilir komutları açıkla
  String getAllCommandsDescription() {
    return "Kullanılabilir komutlar: "
        "Tarama aç - ürün taraması için. "
        "Listeyi aç - alışveriş listesi için. "
        "Profili aç - sağlık ayarları için. "
        "Topluluk aç - geri bildirim için. "
        "Geri dön - önceki ekrana dön. "
        "İleri git - bir sonraki öğeye geç. "
        "Seç - mevcut öğeyi seç. "
        "Tekrar oku - açıklamayı tekrar dinle. "
        "Yardım - bu listeyi tekrar dinle.";
  }
}
