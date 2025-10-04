import '../models/product.dart';
import 'api_service.dart';

class ProductsService {
  final ApiService _api = ApiService();

  Future<List<Product>> fetchProducts({
    String? category,
    String? customerId,
  }) async {
    try {
      final queryParams = <String, String>{};
      if (category != null && category.toLowerCase() != 'all') {
        queryParams['category'] = category;
      }
      if (customerId != null) queryParams['customer_id'] = customerId;

      final queryString = queryParams.isNotEmpty
          ? '?' +
                queryParams.entries.map((e) => '${e.key}=${e.value}').join('&')
          : '';

      final response = await _api.get('products.php$queryString');

      if (response['success'] == true && response['products'] != null) {
        return (response['products'] as List)
            .map((productJson) => Product.fromJson(productJson))
            .toList();
      }
      return [];
    } catch (e) {
      print('[ProductsService] Error fetching products: $e');
      return [];
    }
  }
}
