import 'package:shopquick_app/core/constants/api_constants.dart';
import 'package:shopquick_app/core/errors/index.dart';
import 'package:shopquick_app/core/services/api_service.dart';
import 'package:shopquick_app/core/utils/logger_service.dart';

/// Service for handling category-related API calls.
///
/// Responsible for fetching product categories from the API.
class CategoryService {
  static final CategoryService _instance = CategoryService._internal();
  final ApiService _apiService = ApiService();
  final LoggerService _logger = LoggerService();

  List<String>? _cachedCategories;
  Future<List<String>>? _fetchFuture;

  factory CategoryService() {
    return _instance;
  }

  CategoryService._internal();

  /// Fetch all available product categories.
  ///
  /// Returns an empty list if no categories are found.
  /// Results are cached after first successful fetch.
  ///
  /// Throws:
  /// - [NetworkException] if the API request fails
  /// - [TimeoutException] if the request times out
  Future<List<String>> fetchCategories() async {
    // Return cached result if available
    if (_cachedCategories != null) {
      _logger.info(
        'Returning cached categories (${_cachedCategories!.length} items)',
      );
      return _cachedCategories!;
    }

    // Return existing future if request is already in progress
    if (_fetchFuture != null) {
      _logger.info(
        'API request already in progress, returning existing future',
      );
      return _fetchFuture!;
    }

    _fetchFuture = _performFetch();
    return _fetchFuture!;
  }

  Future<List<String>> _performFetch() async {
    try {
      _logger.info('Fetching product categories');
      final url = '${ApiConstants.baseUrl}${ApiConstants.categoriesEndpoint}';
      final response = await _apiService.get(url);

      if (response == null) {
        _logger.warning('Empty response from categories API');
        _cachedCategories = [];
        return [];
      }

      final List<dynamic> data = response;
      final categories = data.whereType<String>().toList();

      _logger.info('Successfully fetched ${categories.length} categories');
      _cachedCategories = categories;
      return categories;
    } on AppException {
      rethrow;
    } catch (e, stackTrace) {
      _logger.error('Error fetching categories', e, stackTrace);
      throw NetworkException(
        message: 'Failed to fetch categories',
        originalError: e,
      );
    } finally {
      _fetchFuture = null;
    }
  }

  /// Clear cached categories
  void clearCache() {
    _cachedCategories = null;
    _logger.info('Categories cache cleared');
  }
}
