import "../domain/dietary_restriction.dart";
import "../domain/profile_match_result.dart";
import "../domain/user_health_profile.dart";

/// OCR / içindekiler metnini kullanıcı kısıtlarıyla karşılaştırır (Bölüm 2 son görev).
///
/// Anahtar kelime listeleri MVP içindir; gerçek ürün verisi veya model çıktısı ile genişletilebilir.
class ProfileMatchEngine {
  const ProfileMatchEngine._();

  static final Map<DietaryRestriction, List<String>> _keywordMap = {
    DietaryRestriction.diabetes: [
      "şeker",
      "seker",
      "sugar",
      "glucose",
      "glukoz",
      "fruktoz",
      "fructose",
      "dekstroz",
      "dextrose",
      "şeker ilavesi",
      "added sugar",
      "bal",
      "pekmez",
      "glikoz",
      "maltoz",
      "maltose",
      "high fructose",
    ],
    DietaryRestriction.celiac: [
      "gluten",
      "buğday",
      "bugday",
      "wheat",
      "arpa",
      "çavdar",
      "cavdar",
      "yulaf",
      "oat",
      "malt",
      "bulgur",
      "irmik",
      "çavdar unu",
    ],
    DietaryRestriction.vegan: [
      "süt",
      "sut",
      "milk",
      "tereyağı",
      "tereyagi",
      "butter",
      "peynir",
      "cheese",
      "yumurta",
      "egg",
      "bal",
      "honey",
      "et",
      "tavuk",
      "chicken",
      "beef",
      "balık",
      "balik",
      "fish",
      "whey",
      "kazein",
      "casein",
      "jelatin",
      "gelatin",
    ],
    DietaryRestriction.milkAllergy: [
      "süt",
      "sut",
      "milk",
      "laktoz",
      "lactose",
      "tereyağı",
      "tereyagi",
      "butter",
      "peynir",
      "cheese",
      "kazein",
      "casein",
      "whey",
      "peynir altı suyu",
    ],
    DietaryRestriction.hypertension: [
      "tuz",
      "salt",
      "sodyum",
      "sodium",
      "yağ",
      "yag",
      "fat",
      "doymuş yağ",
      "saturated fat",
      "kolesterol",
      "cholesterol",
      "konserve",
      "canned",
      "işlenmiş",
      "processed",
      "tatlı",
      "sweet",
      "şeker",
      "seker",
    ],
  };

  static final List<String> _ingredientContextHints = [
    "icindekiler",
    "içindekiler",
    "ingredients",
    "alerjen",
    "contains",
    "icerir",
    "içerir",
  ];

  static final Map<DietaryRestriction, List<String>> _safeSignals = {
    DietaryRestriction.diabetes: ["sekersiz", "şekersiz", "sugar free", "added sugar free"],
    DietaryRestriction.celiac: ["glutensiz", "gluten free"],
    DietaryRestriction.vegan: ["vegan"],
    DietaryRestriction.milkAllergy: ["laktozsuz", "lactose free", "dairy free"],
    DietaryRestriction.hypertension: ["tuzsuz", "salt free", "düşük tuz", "low sodium", "yağsız", "fat free", "az yağ"],
  };

  static ProfileMatchResult evaluate({
    required UserHealthProfile profile,
    required String productText,
  }) {
    if (profile.restrictions.isEmpty) {
      return const ProfileMatchResult(
        violations: {},
        matchedKeywords: {},
      );
    }

    final lower = productText.toLowerCase();
    final violations = <DietaryRestriction, String>{};
    final matched = <DietaryRestriction, String>{};
    final hasIngredientContext = _ingredientContextHints.any(lower.contains);
    final hasEnoughText = lower.trim().length >= 24;

    for (final r in profile.restrictions) {
      final keywords = _keywordMap[r];
      if (keywords == null) continue;
      final safeSignals = _safeSignals[r] ?? const <String>[];
      final hasSafeSignal = safeSignals.any(lower.contains);

      String? foundKeyword;
      for (final kw in keywords) {
        if (_containsWord(lower, kw.toLowerCase())) {
          foundKeyword = kw;
          break;
        }
      }

      if (foundKeyword != null && !hasSafeSignal) {
        matched[r] = foundKeyword;
        violations[r] = _messageFor(r);
      }
    }

    return ProfileMatchResult(
      violations: violations,
      matchedKeywords: matched,
      uncertainReason: violations.isEmpty && (!hasIngredientContext || !hasEnoughText)
          ? "Emin degilim. Icindekiler metni net degil, lutfen tekrar tarayin."
          : null,
    );
  }

  static bool _containsWord(String text, String keyword) {
    final escaped = RegExp.escape(keyword);
    final pattern = RegExp("(^|[^a-z0-9çğıöşü])$escaped([^a-z0-9çğıöşü]|\$)");
    return pattern.hasMatch(text);
  }

  static String _messageFor(DietaryRestriction r) {
    switch (r) {
      case DietaryRestriction.diabetes:
        return "Bu ürün şeker veya uygun olmayan tatlandırıcı içerebilir; profilinize uygun olmayabilir.";
      case DietaryRestriction.celiac:
        return "Bu ürün gluten veya gluten içeren tahıl içerebilir; profilinize uygun olmayabilir.";
      case DietaryRestriction.vegan:
        return "Bu ürün hayvansal içerik içerebilir; vegan profilinize uygun olmayabilir.";
      case DietaryRestriction.milkAllergy:
        return "Bu ürün süt veya süt türevi içerebilir; süt alerjisi profilinize uygun olmayabilir.";
      case DietaryRestriction.hypertension:
        return "Bu ürün yüksek tuz veya yağ içerebilir; tansiyon profilinize uygun olmayabilir.";
      case DietaryRestriction.other:
        return "Bu ürün sizin özel kısıtlamalarınıza uygun olmayabilir. Daha fazla bilgi için ürün etiketini kontrol edin.";
    }
  }
}
