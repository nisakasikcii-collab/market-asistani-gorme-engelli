import "gemini_product_parser.dart";

class ProductRecognitionOutcome {
  const ProductRecognitionOutcome({
    required this.speechMessage,
    required this.isConfident,
    this.productName,
    this.nutritionSpeech,
  });

  final String speechMessage;
  final bool isConfident;
  final String? productName;
  final String? nutritionSpeech;
}

ProductRecognitionOutcome buildProductRecognitionOutcome(
  String geminiRawText, {
  double threshold = 0.55,
}) {
  final parsed = parseGeminiProductAnalysis(geminiRawText);
  final productName = parsed.productName?.trim();
  if (productName == null || productName.isEmpty) {
    return const ProductRecognitionOutcome(
      speechMessage: "Emin degilim. Lutfen tekrar tarayin.",
      isConfident: false,
    );
  }
  
  final nutritionSpeech = parsed.nutrition?.hasAnyValue == true
      ? parsed.nutrition!.toSpeechText()
      : null;
  
  if (parsed.isConfidentEnough(threshold: threshold)) {
    return ProductRecognitionOutcome(
      speechMessage: "Bu urun: $productName",
      isConfident: true,
      productName: productName,
      nutritionSpeech: nutritionSpeech,
    );
  }

  return const ProductRecognitionOutcome(
    speechMessage: "Emin degilim. Lutfen tekrar tarayin.",
    isConfident: false,
  );
}
