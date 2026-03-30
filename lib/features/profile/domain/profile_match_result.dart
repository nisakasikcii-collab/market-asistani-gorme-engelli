import "dietary_restriction.dart";

/// Tarama metninde (içindekiler vb.) tespit edilen kısıt ihlalleri.
class ProfileMatchResult {
  const ProfileMatchResult({
    required this.violations,
    required this.matchedKeywords,
    this.uncertainReason,
  });

  /// Boş ise profil ile çakışma yok (veya kısıt seçilmemiş).
  final Map<DietaryRestriction, String> violations;

  /// Ayıklama için eşleşen anahtar kelime örnekleri (debug / güven).
  final Map<DietaryRestriction, String> matchedKeywords;

  bool get hasConflict => violations.isNotEmpty;
  bool get isUncertain => uncertainReason != null && uncertainReason!.isNotEmpty;
  final String? uncertainReason;
}
