import 'package:flutter/material.dart';

import 'package:bandspace_mobile/main.dart' as app;

/// Punkt wejścia dla lokalnego środowiska.
///
/// Uruchamia aplikację z plikiem konfiguracyjnym .env.local.
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  app.main(envFileName: '.env.local');
}
