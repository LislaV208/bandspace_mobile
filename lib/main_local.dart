import 'package:bandspace_mobile/main.dart' as app;

/// Punkt wejścia dla lokalnego środowiska.
///
/// Uruchamia aplikację z plikiem konfiguracyjnym .env.local.
void main() {
  app.main(envFileName: '.env.local');
}
