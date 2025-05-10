import 'package:flutter/material.dart';

import 'package:bandspace_mobile/auth/auth_screen.dart';
import 'package:bandspace_mobile/theme/theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Ustawienie przezroczystego statusbara
  AppTheme.setStatusBarColor();

  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BandSpace',
      theme: AppTheme.darkTheme,
      home: const AuthScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
