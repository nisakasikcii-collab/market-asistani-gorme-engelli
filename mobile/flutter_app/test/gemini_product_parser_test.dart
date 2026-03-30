import "package:eyeshopper_ai/features/scan/logic/gemini_product_parser.dart";
import "package:flutter_test/flutter_test.dart";

void main() {
  test("Ürün ve güven skorunu parse eder", () {
    const raw = """
Ürün: Süt (1L)
Uyarı: yok
Güven: 0.82
""";

    final r = parseGeminiProductAnalysis(raw);
    expect(r.productName, "Süt (1L)");
    expect(r.confidence, 0.82);
    expect(r.warningText, "yok");
    expect(r.isConfidentEnough(threshold: 0.55), isTrue);
  });

  test("Düşük güven için confidentEnough false döner", () {
    const raw = """
Ürün: Ekmek
Uyarı: Glutene dikkat
Güven: 0.31
""";

    final r = parseGeminiProductAnalysis(raw);
    expect(r.isConfidentEnough(threshold: 0.55), isFalse);
  });

  test("Ürün satırı yoksa productName null olur", () {
    const raw = """
Uyarı: yok
Güven: 0.74
""";

    final r = parseGeminiProductAnalysis(raw);
    expect(r.productName, isNull);
    expect(r.confidence, 0.74);
  });
}

