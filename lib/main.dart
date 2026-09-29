import 'package:flutter/material.dart';

import 'screens/splash_page.dart';
import 'screens/login_page.dart';
import 'theme/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(const CineMoraApp());
}

class CineMoraApp extends StatelessWidget {
  const CineMoraApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,

      title: 'CineMora',

      theme: AppTheme.theme,

      home: const SplashPage(),

      routes: {
        '/login': (context) => const LoginPage(),
      },
    );
  }
}