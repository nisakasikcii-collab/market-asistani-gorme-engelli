/// Gemini çıktısından ürün adı, güven skorunu ve besin değerlerini ayıklar.
///
/// Promptta hedeflediğimiz format:
/// - `Ürün: <tahmin>`
/// - `Besin Değerleri: <enerji (kcal/100g), protein (g/100g), yağ (g/100g), karbohidrat (g/100g), şeker (g/100g), tuz (g/100g) - yoksa 'bilgi yok'>`
/// - `Uyarı: <uyarı veya yok>`
/// - `Güven: <0-1>`
class NutritionalValues {
  NutritionalValues({
    this.caloriesPerHundredG,
    this.proteinG,
    this.fatG,
    this.carbsG,
    this.sugarG,
    this.saltG,
    this.rawText,
  });

  final double? caloriesPerHundredG;
  final double? proteinG;
  final double? fatG;
  final double? carbsG;
  final double? sugarG;
  final double? saltG;
  final String? rawText;

  bool get hasAnyValue =>
      caloriesPerHundredG != null ||
      proteinG != null ||
      fatG != null ||
      carbsG != null ||
      sugarG != null ||
      saltG != null;

  String toSpeechText() {
    if (rawText != null && (rawText == "bilgi yok" || rawText!.isEmpty)) {
      return "Besin değerleri bilgisi bulunamadı.";
    }
    final parts = <String>[];
    if (caloriesPerHundredG != null) {
      parts.add("${caloriesPerHundredG!.toStringAsFixed(0)} kalori");
    }
    if (proteinG != null) {
      parts.add("${proteinG!.toStringAsFixed(1)} gram protein");
    }
    if (fatG != null) {
      parts.add("${fatG!.toStringAsFixed(1)} gram yağ");
    }
    if (carbsG != null) {
      parts.add("${carbsG!.toStringAsFixed(1)} gram karbohidrat");
    }
    if (sugarG != null) {
      parts.add("${sugarG!.toStringAsFixed(1)} gram şeker");
    }
    if (saltG != null) {
      parts.add("${saltG!.toStringAsFixed(2)} gram tuz");
    }
    if (parts.isEmpty) {
      return "Besin değerleri bilgisi bulunamadı.";
    }
    return "Yüz gram başına: ${parts.join(", ")}.";
  }
}

class GeminiProductParseResult {
  GeminiProductParseResult({
    required this.productName,
    required this.confidence,
    required this.warningText,
    this.nutrition,
  });

  final String? productName;
  final double? confidence;
  final String? warningText;
  final NutritionalValues? nutrition;

  bool isConfidentEnough({double threshold = 0.55}) {
    if (confidence == null) return false;
    return confidence! >= threshold;
  }
}

GeminiProductParseResult parseGeminiProductAnalysis(String rawText) {
  final text = rawText.replaceAll("\r\n", "\n").trim();

  String? productName;
  double? confidence;
  String? warningText;
  NutritionalValues? nutrition;

  // Ürün: ...
  final productMatch = RegExp(r"Ürün\s*:\s*(.+)", multiLine: true)
      .firstMatch(text);
  if (productMatch != null) {
    productName = productMatch.group(1)?.trim();
  }

  // Besin Değerleri: ...
  final nutritionMatch = RegExp(r"Besin\s+Değerleri\s*:\s*(.+?)(?=\n|Uyarı|$)", multiLine: true, dotAll: true)
      .firstMatch(text);
  if (nutritionMatch != null) {
    final nutritionText = nutritionMatch.group(1)?.trim() ?? "";
    nutrition = _parseNutrition(nutritionText);
  }

  // Uyarı: ...
  final warningMatch = RegExp(r"Uyarı\s*:\s*(.+)", multiLine: true)
      .firstMatch(text);
  if (warningMatch != null) {
    warningText = warningMatch.group(1)?.trim();
  }

  // Güven: 0.85
  final confidenceMatch =
      RegExp(r"Güven\s*:\s*([0-9]*\.?[0-9]+)", multiLine: true)
          .firstMatch(text);
  if (confidenceMatch != null) {
    confidence = double.tryParse(confidenceMatch.group(1)!.trim());
  }

  return GeminiProductParseResult(
    productName: productName,
    confidence: confidence,
    warningText: warningText,
    nutrition: nutrition,
  );
}

NutritionalValues _parseNutrition(String nutritionText) {
  final text = nutritionText.toLowerCase();
  
  // Eğer "bilgi yok" diyorsa
  if (text.contains("bilgi yok") || text.isEmpty) {
    return NutritionalValues(rawText: "bilgi yok");
  }

  double? extractValue(String keyword) {
    final pattern = RegExp("$keyword[^0-9.]*([0-9]+(?:\\.[0-9]+)?)", caseSensitive: false);
    final match = pattern.firstMatch(text);
    if (match != null) {
      return double.tryParse(match.group(1)!);
    }
    return null;
  }

  return NutritionalValues(
    caloriesPerHundredG: extractValue("enerji|kalori|kcal"),
    proteinG: extractValue("protein"),
    fatG: extractValue("yağ|lipid"),
    carbsG: extractValue("karbohidrat|karb"),
    sugarG: extractValue("şeker|sugar"),
    saltG: extractValue("tuz|sodyum|salt"),
    rawText: nutritionText,
  );
}

