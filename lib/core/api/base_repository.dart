import 'package:bandspace_mobile/core/api/api_client.dart';

/// Klasa bazowa dla wszystkich repozytoriów w aplikacji.
///
/// Dostarcza wspólne funkcjonalności dla repozytoriów, takie jak
/// dostęp do ApiClient. Wszystkie repozytoria powinny dziedziczyć
/// po tej klasie.
abstract class BaseRepository {
  /// Instancja ApiClient do wykonywania żądań HTTP
  final ApiClient apiClient;

  /// Konstruktor przyjmujący instancję ApiClient
  const BaseRepository({
    required this.apiClient,
  });
}
