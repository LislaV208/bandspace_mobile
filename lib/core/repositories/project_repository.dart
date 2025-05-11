import 'package:bandspace_mobile/core/api/api_client.dart';
import 'package:bandspace_mobile/core/models/project.dart';
import 'package:bandspace_mobile/core/repositories/base_repository.dart';

/// Repozytorium odpowiedzialne za operacje związane z projektami.
///
/// Obsługuje pobieranie listy projektów, tworzenie nowych projektów
/// i inne operacje związane z projektami.
class ProjectRepository extends BaseRepository {
  /// Konstruktor przyjmujący opcjonalną instancję ApiClient
  ProjectRepository({super.apiClient});

  /// Pobiera listę projektów użytkownika.
  ///
  /// Zwraca listę projektów użytkownika wraz z dodatkowymi danymi
  /// potrzebnymi do wyświetlenia na ekranie dashboardu.
  Future<List<DashboardProject>> getProjects() async {
    try {
      // Wywołanie endpointu pobierania projektów
      final response = await apiClient.get('api/projects');

      // Sprawdzenie, czy odpowiedź zawiera dane
      if (response.data == null) {
        return [];
      }

      // Konwersja danych na listę projektów
      final List<dynamic> projectsData = response.data;
      return projectsData.map((projectData) => DashboardProject.fromJson(projectData)).toList();
    } on ApiException {
      rethrow;
    } catch (e) {
      throw UnknownException('Wystąpił nieoczekiwany błąd podczas pobierania projektów: $e');
    }
  }

  /// Tworzy nowy projekt.
  ///
  /// Przyjmuje nazwę projektu i opcjonalny opis.
  /// Zwraca utworzony projekt.
  Future<Project> createProject({required String name, String? description}) async {
    try {
      // Przygotowanie danych projektu
      final projectData = {'name': name, if (description != null) 'description': description};

      // Wywołanie endpointu tworzenia projektu
      final response = await apiClient.post('api/projects', data: projectData);

      // Sprawdzenie, czy odpowiedź zawiera dane
      if (response.data == null) {
        throw ApiException(
          message: 'Brak danych w odpowiedzi podczas tworzenia projektu',
          statusCode: response.statusCode,
          data: response.data,
        );
      }

      // Konwersja danych na obiekt projektu
      return Project.fromJson(response.data);
    } on ApiException {
      rethrow;
    } catch (e) {
      throw UnknownException('Wystąpił nieoczekiwany błąd podczas tworzenia projektu: $e');
    }
  }
}
