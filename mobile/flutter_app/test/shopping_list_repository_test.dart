import "package:eyeshopper_ai/features/shopping_list/data/shopping_list_repository.dart";
import "package:flutter_test/flutter_test.dart";
import "package:shared_preferences/shared_preferences.dart";

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test("listeye urun ekler ve taranan urunle tamamlar", () async {
    SharedPreferences.setMockInitialValues({});
    final repo = ShoppingListRepository.instance;
    await repo.clearAllForTest();

    await repo.addItem("sut");
    expect(repo.items.length, 1);
    expect(repo.items.first.isCompleted, isFalse);

    final matched = await repo.markFoundByScannedProduct("Pinar sut 1L");
    expect(matched, isTrue);
    expect(repo.items.first.isCompleted, isTrue);
  });
}
