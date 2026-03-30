import "dart:convert";

import "package:shared_preferences/shared_preferences.dart";

import "../domain/shopping_list_item.dart";

class ShoppingListLocalStore {
  static const _kShoppingList = "es_shopping_list_json";

  Future<List<ShoppingListItem>> loadItems() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_kShoppingList);
    if (raw == null || raw.isEmpty) return const [];
    final decoded = jsonDecode(raw);
    if (decoded is! List) return const [];
    return decoded
        .whereType<Map<String, dynamic>>()
        .map(ShoppingListItem.fromJson)
        .toList();
  }

  Future<void> saveItems(List<ShoppingListItem> items) async {
    final prefs = await SharedPreferences.getInstance();
    final list = items.map((e) => e.toJson()).toList();
    await prefs.setString(_kShoppingList, jsonEncode(list));
  }
}
