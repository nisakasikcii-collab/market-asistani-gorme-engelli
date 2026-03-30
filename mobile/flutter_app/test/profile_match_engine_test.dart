import "package:eyeshopper_ai/features/profile/domain/dietary_restriction.dart";
import "package:eyeshopper_ai/features/profile/domain/user_health_profile.dart";
import "package:eyeshopper_ai/features/profile/logic/profile_match_engine.dart";
import "package:flutter_test/flutter_test.dart";

void main() {
  test("şeker anahtar kelimesi diyabet kısıtında ihlal üretir", () {
    final profile = UserHealthProfile(
      restrictions: {DietaryRestriction.diabetes},
    );
    final r = ProfileMatchEngine.evaluate(
      profile: profile,
      productText: "İçindekiler: şeker, su",
    );
    expect(r.hasConflict, isTrue);
    expect(r.violations[DietaryRestriction.diabetes], isNotNull);
  });

  test("kısıt yoksa ihlal yok", () {
    final profile = UserHealthProfile(restrictions: {});
    final r = ProfileMatchEngine.evaluate(
      profile: profile,
      productText: "İçindekiler: şeker, gluten, süt",
    );
    expect(r.hasConflict, isFalse);
  });

  test("vegan + örnek hayvansal içerik", () {
    final profile = UserHealthProfile(
      restrictions: {DietaryRestriction.vegan},
    );
    final r = ProfileMatchEngine.evaluate(
      profile: profile,
      productText: "yumurta tozu",
    );
    expect(r.hasConflict, isTrue);
  });

  test("sekersiz ifadesi yanlis pozitif uretmez", () {
    final profile = UserHealthProfile(
      restrictions: {DietaryRestriction.diabetes},
    );
    final r = ProfileMatchEngine.evaluate(
      profile: profile,
      productText: "Icindekiler: seker ilavesiz, sekersiz icecek",
    );
    expect(r.hasConflict, isFalse);
  });

  test("metin belirsizse uncertain doner", () {
    final profile = UserHealthProfile(
      restrictions: {DietaryRestriction.celiac},
    );
    final r = ProfileMatchEngine.evaluate(
      profile: profile,
      productText: "etiket bulanık",
    );
    expect(r.hasConflict, isFalse);
    expect(r.isUncertain, isTrue);
  });
}
