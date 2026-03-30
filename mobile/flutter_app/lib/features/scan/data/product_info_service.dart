import '../../../core/api/api_client.dart';
import 'barcode_cache_store.dart';

class ProductInfoService {
  ProductInfoService._();
  static final ProductInfoService instance = ProductInfoService._();

  Future<String?> resolveProduct(String barcode) async {
    final localValue = BarcodeCacheStore.instance.lookupProduct(barcode);
    if (localValue != null) return localValue;

    final isOnline = await ApiClient.instance.isConnected();
    if (!isOnline) {
      return null;
    }

    try {
      final response = await ApiClient.instance.get('https://api.example.com/barcode/$barcode');
      if (response.statusCode == 200 && response.data != null) {
        final product = response.data['name']?.toString();
        if (product != null && product.isNotEmpty) {
          await BarcodeCacheStore.instance.saveProductByBarcode(barcode, product);
          return product;
        }
      }
      return null;
    } catch (e) {
      return localValue;
    }
  }
}
