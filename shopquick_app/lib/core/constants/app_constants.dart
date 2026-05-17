/// General application constants
class AppConstants {
  /// SharedPreferences keys
  static const String authTokenKey = 'auth_token';
  static const String userPreferencesKey = 'user_preferences';
  static const String darkModeKey = 'dark_mode';

  /// App info
  static const String appName = 'ShopQuick';
  static const String appVersion = '1.0.0';

  /// Cache durations
  static const Duration productsCacheDuration = Duration(hours: 1);
  static const Duration categoriesCacheDuration = Duration(hours: 24);

  /// UI delays
  static const Duration navigationDelay = Duration(milliseconds: 300);
  static const Duration snackbarDuration = Duration(seconds: 2);
}
