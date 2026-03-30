/// Sesli geri bildirim önceliği: bilgi / uyarı / kritik.
/// TTS tarafında konuşma hızı ve kısa duraklarla ayrıştırılır.
enum SpeechPriority {
  /// Rutin bilgilendirme
  info,

  /// Profil uyumsuzluğu, dikkat gerektiren durum
  warning,

  /// Güvenlik veya ciddi hata; daha yavaş ve net telaffuz
  critical,
}

extension SpeechPriorityMaps on SpeechPriority {
  /// 0.0–1.0 arası; platform varsayılanı genelde ~0.5.
  double get rate {
    return switch (this) {
      SpeechPriority.info => 0.48,
      SpeechPriority.warning => 0.42,
      SpeechPriority.critical => 0.36,
    };
  }

  /// 0.0–1.0 arası ses seviyesi önerisi.
  double get volume {
    return switch (this) {
      SpeechPriority.info => 0.9,
      SpeechPriority.warning => 0.95,
      SpeechPriority.critical => 1.0,
    };
  }

  String get debugLabel {
    return switch (this) {
      SpeechPriority.info => "bilgi",
      SpeechPriority.warning => "uyarı",
      SpeechPriority.critical => "kritik",
    };
  }
}
