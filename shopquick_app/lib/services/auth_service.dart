import 'package:shared_preferences/shared_preferences.dart';
import 'package:shopquick_app/core/constants/api_constants.dart';
import 'package:shopquick_app/core/constants/app_constants.dart';
import 'package:shopquick_app/core/errors/index.dart';
import 'package:shopquick_app/core/services/api_service.dart';
import 'package:shopquick_app/core/utils/logger_service.dart';

/// Service for handling authentication operations.
///
/// Manages user login, logout, and token storage in SharedPreferences.
class AuthService {
  static final AuthService _instance = AuthService._internal();
  final ApiService _apiService = ApiService();
  final LoggerService _logger = LoggerService();

  factory AuthService() {
    return _instance;
  }

  AuthService._internal();

  /// Authenticate user with username and password.
  ///
  /// [username] - The user's username
  /// [password] - The user's password
  ///
  /// Returns the authentication token on success.
  ///
  /// Throws:
  /// - [ValidationException] if credentials are invalid
  /// - [NetworkException] if the API request fails
  /// - [TimeoutException] if the request times out
  Future<String> login({
    required String username,
    required String password,
  }) async {
    if (username.trim().isEmpty || password.isEmpty) {
      throw ValidationException(
        message: 'Username and password cannot be empty',
      );
    }

    try {
      _logger.info('Attempting login for user: $username');

      final url = '${ApiConstants.baseUrl}${ApiConstants.authLoginEndpoint}';
      final body = {'username': username, 'password': password};

      final response = await _apiService.post(url, body: body);

      if (response == null) {
        throw ValidationException(message: 'Invalid response from server');
      }

      final data = response as Map<String, dynamic>;
      final token = data['token'] as String?;

      if (token == null || token.isEmpty) {
        throw ValidationException(
          message: 'Token missing in response',
          code: '401',
        );
      }

      // Store token in SharedPreferences
      await _saveToken(token);
      _logger.info('Successfully logged in user: $username');
      return token;
    } on ValidationException {
      rethrow;
    } on AppException {
      rethrow;
    } catch (e, stackTrace) {
      _logger.error('Login error for user: $username', e, stackTrace);
      throw NetworkException(
        message: 'Login failed. Please try again.',
        originalError: e,
      );
    }
  }

  /// Logout the current user by removing the stored token.
  Future<void> logout() async {
    try {
      _logger.info('Logging out user');
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(AppConstants.authTokenKey);
      _logger.info('Successfully logged out user');
    } catch (e, stackTrace) {
      _logger.error('Logout error', e, stackTrace);
      throw NetworkException(message: 'Logout failed', originalError: e);
    }
  }

  /// Get the stored authentication token.
  ///
  /// Returns null if no token is stored.
  Future<String?> getToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(AppConstants.authTokenKey);
    } catch (e, stackTrace) {
      _logger.error('Error retrieving token', e, stackTrace);
      return null;
    }
  }

  /// Check if user is authenticated.
  Future<bool> isAuthenticated() async {
    try {
      final token = await getToken();
      return token != null && token.isNotEmpty;
    } catch (e) {
      _logger.error('Error checking authentication status', e);
      return false;
    }
  }

  /// Save token to SharedPreferences.
  Future<void> _saveToken(String token) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(AppConstants.authTokenKey, token);
    } catch (e, stackTrace) {
      _logger.error('Error saving token', e, stackTrace);
      throw NetworkException(
        message: 'Failed to save authentication token',
        originalError: e,
      );
    }
  }
}
