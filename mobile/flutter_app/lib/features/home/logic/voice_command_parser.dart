/// Sesli komutlar - enum olarak tanımlanan komutlar
enum VoiceCommand {
  openProfile,
  openScan,
  openShoppingList,
  openCommunityFeedback,
  unknown,
}

/// Sesli komutları Türkçe'den algılaması için parser
class VoiceCommandParser {
  /// Kullanıcı konuşmasını ayrıştırarak komut belirle
  VoiceCommand parseCommand(String input) {
    final text = input.toLowerCase().trim();

    // Profil açma komutları
    if (_contains(text, ["profil", "profili", "açmak", "düzenleme"])) {
      return VoiceCommand.openProfile;
    }

    // Tarama açma komutları
    if (_contains(text, ["tarama", "kamera", "taraması", "taramayı"])) {
      return VoiceCommand.openScan;
    }

    // Alışveriş listesi komutları
    if (_contains(
      text,
      ["liste", "alışveriş", "listeye", "listesi", "listeyi"],
    )) {
      return VoiceCommand.openShoppingList;
    }

    // Topluluk geri bildirimi komutları
    if (_contains(text, ["topluluk", "geri bildirim", "bildirim", "feedback"])) {
      return VoiceCommand.openCommunityFeedback;
    }

    return VoiceCommand.unknown;
  }

  /// Metinde belirtilen anahtar kelimelerin herhangi birinin olup olmadığını kontrol et
  bool _contains(String text, List<String> keywords) {
    for (final keyword in keywords) {
      if (text.contains(keyword)) {
        return true;
      }
    }
    return false;
  }
}
