/// API configuration and endpoint constants
class ApiConstants {
  /// Base URL for the fake store API
  static const String baseUrl = 'https://fakestoreapi.com';

  /// API Endpoints
  static const String productsEndpoint = '/products';
  static const String categoriesEndpoint = '/products/categories';
  static const String authLoginEndpoint = '/auth/login';

  /// Network configuration
  static const int connectTimeoutDuration = 30; // seconds
  static const int receiveTimeoutDuration = 30; // seconds
  static const int maxRetries = 3;

  /// Build full URLs
  static String getProductUrl(int id) => '$baseUrl$productsEndpoint/$id';
  static String getProductsByCategory(String category) =>
      '$baseUrl$productsEndpoint/category/$category';
}
