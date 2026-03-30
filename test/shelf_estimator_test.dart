import "package:eyeshopper_ai/features/scan/logic/shelf_estimator.dart";
import "package:flutter_test/flutter_test.dart";

void main() {
  test("temel gida anahtar kelimeleriyle reyon tahmini yapar", () {
    final r = ShelfEstimator.estimateFromObservedText(
      "makarna, un, seker paketleri",
    );
    expect(r.aisleName, "Temel Gida");
    expect(r.confidence, greaterThanOrEqualTo(0.55));
  });

  test("veri yoksa dusuk guvenli belirsiz doner", () {
    final r = ShelfEstimator.estimateFromObservedText("kamera goruntusu bulanik");
    expect(r.aisleName, "Belirsiz");
    expect(r.isLowConfidence, isTrue);
  });

  test("neredeyim komutunu algilar", () {
    expect(ShelfEstimator.isWhereAmICommand("Neredeyim"), isTrue);
    expect(ShelfEstimator.isWhereAmICommand("Hangi reyondayim"), isTrue);
    expect(ShelfEstimator.isWhereAmICommand("Fiyati oku"), isFalse);
  });
}
