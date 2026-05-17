import 'package:flutter/material.dart';
import 'package:shopquick_app/core/utils/logger_service.dart';
import 'package:shopquick_app/services/app_settings.dart';
import 'package:shopquick_app/shared/theme/app_theme.dart';
import 'package:shopquick_app/splash_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppSettings.init();
  LoggerService().info('App started');
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: AppSettings.darkMode,
      builder: (context, isDark, _) {
        return MaterialApp(
          title: 'ShopQuick',
          theme: AppTheme.lightTheme(),
          darkTheme: AppTheme.darkTheme(),
          themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
          debugShowCheckedModeBanner: false,
          home: const SplashScreenPage(),
        );
      },
    );
  }
}
