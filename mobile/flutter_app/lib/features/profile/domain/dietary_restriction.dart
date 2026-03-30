/// Kullanıcının seçtiği sağlık / diyet kısıtları (PRD: Setup).
enum DietaryRestriction {
  /// Diyabet — şeker ve ilgili tatlandırıcılar
  diabetes,

  /// Çölyak — gluten içeren tahıllar
  celiac,

  /// Vegan — hayvansal içerik
  vegan,

  /// Süt ürünleri alerjisi
  milkAllergy,

  /// Hipertansiyon — yüksek tuz ve yağ hassasiyeti
  hypertension,

  /// Diğer — kullanıcı tanımlı kısıt
  other,
}

extension DietaryRestrictionLabels on DietaryRestriction {
  /// Ekran ve TTS için Türkçe kısa ad.
  String get displayNameTr {
    switch (this) {
      case DietaryRestriction.diabetes:
        return "Diyabet (şeker hassasiyeti)";
      case DietaryRestriction.celiac:
        return "Çölyak (gluten)";
      case DietaryRestriction.vegan:
        return "Vegan";
      case DietaryRestriction.milkAllergy:
        return "Süt alerjisi";
      case DietaryRestriction.hypertension:
        return "Tansiyon (tuz ve yağ)";
      case DietaryRestriction.other:
        return "Diğer (özel)";
    }
  }

  /// Semantics / yardım metni.
  String get hintTr {
    switch (this) {
      case DietaryRestriction.diabetes:
        return "Şeker ve uygun olmayan tatlandırıcılar için uyarı istiyorum";
      case DietaryRestriction.celiac:
        return "Gluten ve gluten içeren tahıllar için uyarı istiyorum";
      case DietaryRestriction.vegan:
        return "Hayvansal içerik için uyarı istiyorum";
      case DietaryRestriction.milkAllergy:
        return "Süt ve süt türevleri için uyarı istiyorum";
      case DietaryRestriction.hypertension:
        return "Yüksek tuz ve yağ içeren ürünler için uyarı istiyorum";
      case DietaryRestriction.other:
        return "Kendi özel koşullarınızı ekleyin";
    }
  }

  /// İkon kodu her kısıt için (Material Icons)
  String get iconName {
    switch (this) {
      case DietaryRestriction.diabetes:
        return "favorite"; // Kalp - sağlık sembolü
      case DietaryRestriction.celiac:
        return "grain"; // Tahıl
      case DietaryRestriction.vegan:
        return "leaf"; // Yaprak
      case DietaryRestriction.milkAllergy:
        return "local_drink"; // İçecek - süt
      case DietaryRestriction.hypertension:
        return "favorite_border"; // Kalp (boş) - hipertansiyon
      case DietaryRestriction.other:
        return "more_horiz"; // Diğer
    }
  }
}
