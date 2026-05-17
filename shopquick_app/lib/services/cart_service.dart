// import 'dart:convert';
import 'package:flutter/foundation.dart';
// import 'package:http/http.dart' as http;
import 'package:shopquick_app/core/constants/api_constants.dart';
import 'package:shopquick_app/core/errors/index.dart';
import 'package:shopquick_app/core/services/api_service.dart';
import 'package:shopquick_app/core/utils/logger_service.dart';
import 'package:shopquick_app/models/cart.dart';

/// Service for handling shopping cart operations.
///
/// Manages cart CRUD operations and broadcasts cart changes via [cartCount].
class CartService {
  static final CartService _instance = CartService._internal();
  final ApiService _apiService = ApiService();
  final LoggerService _logger = LoggerService();

  /// Notifier to broadcast cart item count changes to UI
  static final ValueNotifier<int> cartCount = ValueNotifier<int>(0);

  factory CartService() {
    return _instance;
  }

  CartService._internal();

  /// Static method to get total cart item count
  /// This is used by UI components that need quick access without instantiation
  static Future<int> getTotalCartItemCount() async {
    try {
      final instance = CartService();
      final carts = await instance.fetchAllCarts();
      int total = 0;
      for (var cart in carts) {
        total += cart.totalItems;
      }
      return total;
    } catch (e) {
      return 0;
    }
  }

  /// Add a product to the cart for a specific user.
  ///
  /// [userId] - The user ID
  /// [productId] - The product ID to add
  ///
  /// Returns the updated cart.
  ///
  /// Throws:
  /// - [ValidationException] if inputs are invalid
  /// - [NetworkException] if the API request fails
  /// - [TimeoutException] if the request times out
  Future<Cart> addToCart({required int userId, required int productId}) async {
    if (userId <= 0 || productId <= 0) {
      throw ValidationException(
        message: 'User ID and Product ID must be greater than 0',
      );
    }

    try {
      _logger.info('Adding product $productId to cart for user $userId');

      final url = '${ApiConstants.baseUrl}/carts';
      final body = {
        'userId': userId,
        'date': DateTime.now().toIso8601String(),
        'products': [
          {'id': productId, 'quantity': 1},
        ],
      };

      final response = await _apiService.post(url, body: body);

      if (response == null) {
        throw NetworkException(message: 'Empty response when adding to cart');
      }

      final cart = Cart.fromJson(response as Map<String, dynamic>);
      await _updateCartCount();

      _logger.info('Successfully added product to cart');
      return cart;
    } on AppException {
      rethrow;
    } catch (e, stackTrace) {
      _logger.error('Error adding to cart', e, stackTrace);
      throw NetworkException(
        message: 'Failed to add product to cart',
        originalError: e,
      );
    }
  }

  /// Fetch all carts for a specific user.
  ///
  /// [userId] - The user ID (defaults to 1 for demo)
  ///
  /// Throws:
  /// - [ValidationException] if user ID is invalid
  /// - [NetworkException] if the API request fails
  /// - [TimeoutException] if the request times out
  Future<List<Cart>> fetchAllCarts({int userId = 1}) async {
    if (userId <= 0) {
      throw ValidationException(message: 'User ID must be greater than 0');
    }

    try {
      _logger.info('Fetching carts for user $userId');

      final url = '${ApiConstants.baseUrl}/carts/user/$userId';
      final response = await _apiService.get(url);

      if (response == null) {
        _logger.warning('Empty response when fetching carts for user $userId');
        return [];
      }

      final List<dynamic> data = response;
      final carts = data
          .map((json) => Cart.fromJson(json as Map<String, dynamic>))
          .toList();

      _logger.info(
        'Successfully fetched ${carts.length} carts for user $userId',
      );
      return carts;
    } on AppException {
      rethrow;
    } catch (e, stackTrace) {
      _logger.error('Error fetching carts for user $userId', e, stackTrace);
      throw NetworkException(
        message: 'Failed to fetch carts',
        originalError: e,
      );
    }
  }

  /// Fetch a specific cart by its ID.
  ///
  /// [cartId] - The cart ID
  ///
  /// Throws:
  /// - [ValidationException] if cart ID is invalid
  /// - [NetworkException] if the API request fails
  /// - [TimeoutException] if the request times out
  Future<Cart> fetchCartById(int cartId) async {
    if (cartId <= 0) {
      throw ValidationException(message: 'Cart ID must be greater than 0');
    }

    try {
      _logger.info('Fetching cart with ID: $cartId');

      final url = '${ApiConstants.baseUrl}/carts/$cartId';
      final response = await _apiService.get(url);

      if (response == null) {
        throw NetworkException(message: 'Cart not found', code: '404');
      }

      final cart = Cart.fromJson(response as Map<String, dynamic>);
      _logger.info('Successfully fetched cart with ID: $cartId');
      return cart;
    } on AppException {
      rethrow;
    } catch (e, stackTrace) {
      _logger.error('Error fetching cart with ID: $cartId', e, stackTrace);
      throw NetworkException(message: 'Failed to fetch cart', originalError: e);
    }
  }

  /// Update a product's quantity in a cart.
  ///
  /// If quantity is 0 or less, the product will be removed from the cart.
  ///
  /// [cartId] - The cart ID
  /// [productId] - The product ID
  /// [quantity] - The new quantity (0 to remove)
  ///
  /// Throws:
  /// - [ValidationException] if inputs are invalid
  /// - [NetworkException] if the API request fails
  /// - [TimeoutException] if the request times out
  Future<Cart> updateProductQuantity({
    required int cartId,
    required int productId,
    required int quantity,
  }) async {
    if (cartId <= 0 || productId <= 0) {
      throw ValidationException(
        message: 'Cart ID and Product ID must be greater than 0',
      );
    }

    try {
      _logger.info(
        'Updating product $productId quantity to $quantity in cart $cartId',
      );

      // Get existing cart
      final existing = await fetchCartById(cartId);

      // Build updated products list
      final updatedProducts = existing.products
          .map(
            (p) => p.productId == productId
                ? {'id': p.productId, 'quantity': quantity}
                : {'id': p.productId, 'quantity': p.quantity},
          )
          .where((p) => (p['quantity'] as int) > 0)
          .toList();

      final url = '${ApiConstants.baseUrl}/carts/$cartId';
      final body = {
        'userId': existing.userId,
        'date': DateTime.now().toIso8601String(),
        'products': updatedProducts,
      };

      final response = await _apiService.put(url, body: body);

      if (response == null) {
        throw NetworkException(message: 'Empty response when updating cart');
      }

      final cart = Cart.fromJson(response as Map<String, dynamic>);
      await _updateCartCount();

      _logger.info('Successfully updated product quantity in cart');
      return cart;
    } on AppException {
      rethrow;
    } catch (e, stackTrace) {
      _logger.error('Error updating product quantity in cart', e, stackTrace);
      throw NetworkException(
        message: 'Failed to update product quantity',
        originalError: e,
      );
    }
  }

  /// Update an entire cart with a new products list.
  ///
  /// Updates a cart with the provided products list.
  /// API Endpoint: PUT /carts/{cartId}
  ///
  /// [cartId] - The cart ID
  /// [userId] - The user ID
  /// [products] - List of products as Map with 'id' key: [{'id': 2}, {'id': 3}]
  ///
  /// Returns the updated cart with full product details from API.
  ///
  /// Example:
  /// ```dart
  /// final updatedCart = await CartService().updateCart(
  ///   cartId: 1,
  ///   userId: 1,
  ///   products: [
  ///     {'id': 2},
  ///     {'id': 3},
  ///   ],
  /// );
  /// ```
  ///
  /// Throws:
  /// - [ValidationException] if inputs are invalid
  /// - [NetworkException] if the API request fails
  /// - [TimeoutException] if the request times out
  Future<Cart> updateCart({
    required int cartId,
    required int userId,
    required List<Map<String, dynamic>> products,
  }) async {
    if (cartId <= 0 || userId <= 0) {
      throw ValidationException(
        message: 'Cart ID and User ID must be greater than 0',
      );
    }

    if (products.isEmpty) {
      throw ValidationException(message: 'Products list cannot be empty');
    }

    try {
      _logger.info('Updating cart $cartId with new products');

      final url = '${ApiConstants.baseUrl}/carts/$cartId';
      final body = {'userId': userId, 'products': products};

      _logger.info('PUT $url with body: $body');
      final response = await _apiService.put(url, body: body);

      if (response == null) {
        throw NetworkException(message: 'Empty response when updating cart');
      }

      final cart = Cart.fromJson(response as Map<String, dynamic>);
      await _updateCartCount();

      _logger.info(
        'Successfully updated cart $cartId with ${cart.products.length} products',
      );
      return cart;
    } on AppException {
      rethrow;
    } catch (e, stackTrace) {
      _logger.error('Error updating cart', e, stackTrace);
      throw NetworkException(
        message: 'Failed to update cart',
        originalError: e,
      );
    }
  }

  /// Delete a cart by its ID.
  ///
  /// Permanently deletes a cart from the system.
  /// API Endpoint: DELETE /carts/{cartId}
  ///
  /// [cartId] - The cart ID to delete
  ///
  /// Returns true if deletion succeeded.
  ///
  /// Example:
  /// ```dart
  /// bool deleted = await CartService().deleteCart(1);
  /// if (deleted) {
  ///   print('Cart deleted successfully');
  /// }
  /// ```
  ///
  /// Throws:
  /// - [ValidationException] if cart ID is invalid
  /// - [NetworkException] if the API request fails
  /// - [TimeoutException] if the request times out
  Future<bool> deleteCart(int cartId) async {
    if (cartId <= 0) {
      throw ValidationException(message: 'Cart ID must be greater than 0');
    }

    try {
      _logger.info('Deleting cart with ID: $cartId');

      final url = '${ApiConstants.baseUrl}/carts/$cartId';
      _logger.info('DELETE $url');
      await _apiService.delete(url);

      await _updateCartCount();
      _logger.info('Successfully deleted cart with ID: $cartId');
      return true;
    } on AppException {
      rethrow;
    } catch (e, stackTrace) {
      _logger.error('Error deleting cart', e, stackTrace);
      throw NetworkException(
        message: 'Failed to delete cart',
        originalError: e,
      );
    }
  }

  /// Update the cart count notifier
  Future<void> _updateCartCount() async {
    try {
      final carts = await fetchAllCarts();
      int total = 0;
      for (var cart in carts) {
        total += cart.totalItems;
      }
      cartCount.value = total;
    } catch (e) {
      _logger.warning('Error updating cart count', e);
    }
  }
}
