import "package:eyeshopper_ai/features/shopping_list/logic/shopping_list_voice_parser.dart";
import "package:flutter_test/flutter_test.dart";

void main() {
  test("listeye ekleme komutundan urun metnini ayiklar", () {
    final item = parseAddToListCommand("Listeme 1 litre sut ekle");
    expect(item, "1 litre sut");
  });

  test("liste komutu degilse null doner", () {
    final item = parseAddToListCommand("Fiyati oku");
    expect(item, isNull);
  });

  test("listeye gec komutunu algilar", () {
    expect(isGoToShoppingListCommand("Alisveris listesine gec"), isTrue);
    expect(isGoToShoppingListCommand("listeye geç"), isTrue);
    expect(isGoToShoppingListCommand("kamerayi ac"), isFalse);
  });
}
