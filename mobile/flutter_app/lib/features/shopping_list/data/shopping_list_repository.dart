import "package:flutter/foundation.dart";

import "../domain/shopping_list_item.dart";
import "shopping_list_local_store.dart";

class ShoppingListRepository extends ChangeNotifier {
  ShoppingListRepository._();

  static final ShoppingListRepository instance = ShoppingListRepository._();

  final ShoppingListLocalStore _local = ShoppingListLocalStore();

  bool _loaded = false;
  final List<ShoppingListItem> _items = [];

  bool get isLoaded => _loaded;
  List<ShoppingListItem> get items => List.unmodifiable(_items);

  Future<void> ensureLoaded() async {
    if (_loaded) return;
    final loadedItems = await _local.loadItems();
    _items
      ..clear()
      ..addAll(loadedItems);
    _loaded = true;
    notifyListeners();
  }

  Future<void> addItem(String label) async {
    final clean = label.trim();
    if (clean.isEmpty) return;
    final item = ShoppingListItem(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      label: clean,
      isCompleted: false,
      createdAt: DateTime.now(),
    );
    _items.insert(0, item);
    await _local.saveItems(_items);
    notifyListeners();
  }

  Future<void> toggleCompleted(String id) async {
    final idx = _items.indexWhere((e) => e.id == id);
    if (idx < 0) return;
    final current = _items[idx];
    _items[idx] = current.copyWith(isCompleted: !current.isCompleted);
    await _local.saveItems(_items);
    notifyListeners();
  }

  Future<void> removeItem(String id) async {
    _items.removeWhere((e) => e.id == id);
    await _local.saveItems(_items);
    notifyListeners();
  }

  Future<bool> markFoundByScannedProduct(String scannedProductName) async {
    final scan = _normalize(scannedProductName);
    if (scan.isEmpty) return false;

    final idx = _items.indexWhere((item) {
      if (item.isCompleted) return false;
      final target = _normalize(item.label);
      if (target.isEmpty) return false;
      return scan.contains(target) || target.contains(scan);
    });
    if (idx < 0) return false;

    _items[idx] = _items[idx].copyWith(isCompleted: true);
    await _local.saveItems(_items);
    notifyListeners();
    return true;
  }

  Future<void> clearAllForTest() async {
    _items.clear();
    await _local.saveItems(_items);
    notifyListeners();
  }

  String _normalize(String input) {
    return input
        .toLowerCase()
        .replaceAll(RegExp(r"[^a-z0-9çğıöşü ]"), " ")
        .replaceAll(RegExp(r"\s+"), " ")
        .trim();
  }
}
