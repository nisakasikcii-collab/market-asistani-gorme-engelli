import "package:eyeshopper_ai/features/scan/logic/price_tag_parser.dart";
import "package:eyeshopper_ai/features/scan/logic/shelf_estimator.dart";
import "package:flutter_test/flutter_test.dart";

void main() {
  test("bulanik OCR metninde fiyat ayiklama en az bir deger bulur", () {
    final r = parsePriceTagFromOcr("F1YAT: 4S TL  indirim 3B TL");
    expect(r.hasAnyPrice, isFalse);
  });

  test("dusuk bilgi iceren metinde reyon tahmini dusuk guven doner", () {
    final r = ShelfEstimator.estimateFromObservedText("etiket okunamadi");
    expect(r.isLowConfidence, isTrue);
  });
}
