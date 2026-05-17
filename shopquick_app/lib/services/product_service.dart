import 'package:shopquick_app/core/constants/api_constants.dart';
import 'package:shopquick_app/core/errors/index.dart';
import 'package:shopquick_app/core/services/api_service.dart';
import 'package:shopquick_app/core/utils/logger_service.dart';
import 'package:shopquick_app/models/product.dart';

/// Service for handling product-related API calls.
///
/// Responsible for fetching products from the API and converting responses
/// to Product objects. Throws [AppException] on errors.
class ProductService {
  static final ProductService _instance = ProductService._internal();
  final ApiService _apiService = ApiService();
  final LoggerService _logger = LoggerService();

  factory ProductService() {
    return _instance;
  }

  ProductService._internal();

  /// Fetch all products from the API.
  ///
  /// Throws:
  /// - [NetworkException] if the API request fails
  /// - [TimeoutException] if the request times out
  Future<List<Product>> fetchAllProducts() async {
    try {
      _logger.info('Fetching all products');
      final url = '${ApiConstants.baseUrl}${ApiConstants.productsEndpoint}';
      final response = await _apiService.get(url);

      if (response == null) {
        _logger.warning('Empty response from products API');
        return [];
      }

      final List<dynamic> data = response;
      final products = data
          .map((json) => Product.fromJson(json as Map<String, dynamic>))
          .toList();

      _logger.info('Successfully fetched ${products.length} products');
      return products;
    } on AppException {
      rethrow;
    } catch (e, stackTrace) {
      _logger.error('Error fetching products', e, stackTrace);
      throw NetworkException(
        message: 'Failed to fetch products',
        originalError: e,
      );
    }
  }

  /// Fetch products by a specific category.
  ///
  /// [category] - The product category to filter by
  ///
  /// Throws:
  /// - [NetworkException] if the API request fails
  /// - [TimeoutException] if the request times out
  /// - [ValidationException] if category is invalid
  Future<List<Product>> fetchProductsByCategory(String category) async {
    if (category.trim().isEmpty) {
      throw ValidationException(message: 'Category cannot be empty');
    }

    try {
      _logger.info('Fetching products for category: $category');
      final url = ApiConstants.getProductsByCategory(category);
      final response = await _apiService.get(url);

      if (response == null) {
        _logger.warning('Empty response for category: $category');
        return [];
      }

      final List<dynamic> data = response;
      final products = data
          .map((json) => Product.fromJson(json as Map<String, dynamic>))
          .toList();

      _logger.info(
        'Successfully fetched ${products.length} products for category: $category',
      );
      return products;
    } on AppException {
      rethrow;
    } catch (e, stackTrace) {
      _logger.error(
        'Error fetching products for category: $category',
        e,
        stackTrace,
      );
      throw NetworkException(
        message: 'Failed to fetch products for category: $category',
        originalError: e,
      );
    }
  }

  /// Fetch a single product by its ID.
  ///
  /// [id] - The product ID
  ///
  /// Returns null if the product is not found.
  ///
  /// Throws:
  /// - [NetworkException] if the API request fails
  /// - [TimeoutException] if the request times out
  /// - [ValidationException] if ID is invalid
  Future<Product?> fetchProductById(int id) async {
    if (id <= 0) {
      throw ValidationException(message: 'Product ID must be greater than 0');
    }

    try {
      _logger.info('Fetching product with ID: $id');
      final url = ApiConstants.getProductUrl(id);
      final response = await _apiService.get(url);

      if (response == null) {
        _logger.warning('Product with ID $id not found');
        return null;
      }

      final product = Product.fromJson(response as Map<String, dynamic>);
      _logger.info('Successfully fetched product: ${product.title}');
      return product;
    } on AppException {
      rethrow;
    } catch (e, stackTrace) {
      _logger.error('Error fetching product with ID: $id', e, stackTrace);
      throw NetworkException(
        message: 'Failed to fetch product',
        originalError: e,
      );
    }
  }
}
