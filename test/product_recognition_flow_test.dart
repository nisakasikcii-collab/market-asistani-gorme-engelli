import "package:eyeshopper_ai/features/scan/logic/product_recognition_flow.dart";
import "package:flutter_test/flutter_test.dart";

void main() {
  test("guvenli urun tanimada urun adini ses metnine koyar", () {
    const raw = """
Ürün: Makarna
Uyarı: yok
Güven: 0.89
""";
    final out = buildProductRecognitionOutcome(raw);
    expect(out.isConfident, isTrue);
    expect(out.productName, "Makarna");
    expect(out.speechMessage, "Bu urun: Makarna");
  });

  test("dusuk guvende yeniden tarama ister", () {
    const raw = """
Ürün: Kuru Fasulye
Uyarı: yok
Güven: 0.31
""";
    final out = buildProductRecognitionOutcome(raw);
    expect(out.isConfident, isFalse);
    expect(out.speechMessage, contains("Emin degilim"));
  });
}
