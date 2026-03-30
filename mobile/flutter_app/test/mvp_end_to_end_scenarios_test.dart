import "package:eyeshopper_ai/features/profile/domain/dietary_restriction.dart";
import "package:eyeshopper_ai/features/profile/domain/user_health_profile.dart";
import "package:eyeshopper_ai/features/profile/logic/profile_match_engine.dart";
import "package:eyeshopper_ai/features/scan/logic/price_tag_parser.dart";
import "package:eyeshopper_ai/features/scan/logic/product_recognition_flow.dart";
import "package:eyeshopper_ai/features/scan/logic/shelf_estimator.dart";
import "package:flutter_test/flutter_test.dart";

void main() {
  test("MVP#1 urun tanima senaryosu", () {
    const ai = "Ürün: Süt\nUyarı: yok\nGüven: 0.91";
    final out = buildProductRecognitionOutcome(ai);
    expect(out.isConfident, isTrue);
    expect(out.speechMessage, "Bu urun: Süt");
  });

  test("MVP#2 profil uyum uyarisi senaryosu", () {
    final profile = UserHealthProfile(
      restrictions: {DietaryRestriction.diabetes},
    );
    final r = ProfileMatchEngine.evaluate(
      profile: profile,
      productText: "Icindekiler: seker, glikoz surubu",
    );
    expect(r.hasConflict, isTrue);
  });

  test("MVP#3 fiyat okuma senaryosu", () {
    final p = parsePriceTagFromOcr("Fiyat 45 TL\nIndirimli fiyat 38 TL");
    expect(p.priceTl, 45);
    expect(p.discountedPriceTl, 38);
  });

  test("MVP#4 neredeyim senaryosu", () {
    final est = ShelfEstimator.estimateFromObservedText("un seker makarna");
    expect(est.aisleName, "Temel Gida");
    expect(est.isLowConfidence, isFalse);
  });
}
