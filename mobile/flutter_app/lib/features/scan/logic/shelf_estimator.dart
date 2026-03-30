class ShelfEstimateResult {
  const ShelfEstimateResult({
    required this.aisleName,
    required this.confidence,
    required this.matchedGroups,
  });

  final String aisleName;
  final double confidence;
  final List<String> matchedGroups;

  bool get isLowConfidence => confidence < 0.55;
}

class ShelfEstimator {
  const ShelfEstimator._();

  static final Map<String, List<String>> _aisleKeywords = {
    "Temel Gida": [
      "un",
      "seker",
      "şeker",
      "makarna",
      "pirinc",
      "pirinç",
      "bulgur",
      "irmik",
      "bakliyat",
    ],
    "Temizlik": [
      "deterjan",
      "camasir suyu",
      "çamaşır suyu",
      "yumusatici",
      "yumuşatıcı",
      "sabun",
      "dezenfektan",
    ],
    "Atistirmalik": [
      "cikolata",
      "çikolata",
      "biskuvi",
      "bisküvi",
      "cips",
      "kraker",
      "gofret",
    ],
    "Icecek": [
      "su",
      "maden suyu",
      "kola",
      "meyve suyu",
      "icecek",
      "içecek",
      "ayran",
    ],
  };

  static ShelfEstimateResult estimateFromObservedText(String observedText) {
    final lower = observedText.toLowerCase();
    String bestAisle = "Belirsiz";
    var bestScore = 0;
    List<String> bestMatched = const [];

    _aisleKeywords.forEach((aisle, keywords) {
      final matched = <String>[];
      for (final keyword in keywords) {
        if (_containsKeyword(lower, keyword.toLowerCase())) {
          matched.add(keyword);
        }
      }
      if (matched.length > bestScore) {
        bestScore = matched.length;
        bestAisle = aisle;
        bestMatched = matched;
      }
    });

    if (bestScore == 0) {
      return const ShelfEstimateResult(
        aisleName: "Belirsiz",
        confidence: 0.0,
        matchedGroups: [],
      );
    }

    final confidence = (bestScore / 3).clamp(0.2, 0.95).toDouble();
    return ShelfEstimateResult(
      aisleName: bestAisle,
      confidence: confidence,
      matchedGroups: bestMatched,
    );
  }

  static bool isWhereAmICommand(String commandText) {
    final lower = commandText.toLowerCase().trim();
    return lower.contains("neredeyim") ||
        lower.contains("nere deyim") ||
        lower.contains("hangi reyondayim") ||
        lower.contains("hangi reyondayim");
  }

  static bool _containsKeyword(String text, String keyword) {
    final escaped = RegExp.escape(keyword);
    final pattern = RegExp("(^|[^a-z0-9])$escaped([^a-z0-9]|\$)");
    return pattern.hasMatch(text);
  }
}
