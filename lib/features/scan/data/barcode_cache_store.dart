import 'package:hive/hive.dart';

class BarcodeCacheStore {
  static const _boxName = 'barcodeCache';
  static final BarcodeCacheStore instance = BarcodeCacheStore._();

  BarcodeCacheStore._();

  Future<void> init() async {
    if (!Hive.isAdapterRegistered(0)) {
      // No type adapter needed for String map.
    }
    await Hive.openBox<String>(_boxName);
  }

  Future<void> saveProductByBarcode(String barcode, String product) async {
    final box = Hive.box<String>(_boxName);
    await box.put(barcode, product);
  }

  String? lookupProduct(String barcode) {
    final box = Hive.box<String>(_boxName);
    return box.get(barcode);
  }

  Future<void> dispose() async {
    if (Hive.isBoxOpen(_boxName)) {
      await Hive.box<String>(_boxName).close();
    }
  }
}
