import 'package:bandspace_mobile/core/api/api_client.dart';
import 'package:bandspace_mobile/core/models/project.dart';
import 'package:bandspace_mobile/core/models/song.dart';
import 'package:bandspace_mobile/core/repositories/base_repository.dart';

/// Repozytorium odpowiedzialne za operacje związane z projektami.
///
/// Obsługuje pobieranie listy projektów, tworzenie nowych projektów
/// i inne operacje związane z projektami.
class ProjectRepository extends BaseRepository {
  /// Konstruktor przyjmujący opcjonalną instancję ApiClient
  ProjectRepository({super.apiClient});

  /// Pobiera listę wszystkich projektów.
  ///
  /// Zwraca listę projektów posortowanych według daty utworzenia (najnowsze pierwsze).
  Future<List<Project>> getProjects() async {
    try {
      // Wywołanie endpointu pobierania projektów
      final response = await apiClient.get('api/projects');

      // Sprawdzenie, czy odpowiedź zawiera dane
      if (response.data == null) {
        return [];
      }

      // Konwersja danych na listę projektów
      final List<dynamic> projectsData = response.data;
      return projectsData.map((projectData) => Project.fromJson(projectData)).toList();
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

  /// Pobiera listę utworów dla danego projektu.
  ///
  /// Zwraca listę utworów posortowanych według daty utworzenia (najnowsze pierwsze).
  Future<List<Song>> getProjectSongs(int projectId) async {
    try {
      final response = await apiClient.get('api/projects/$projectId/songs');

      if (response.data == null) {
        return [];
      }

      final List<dynamic> songsData = response.data;
      return songsData.map((songData) => Song.fromJson(songData)).toList();
    } on ApiException {
      rethrow;
    } catch (e) {
      throw UnknownException('Wystąpił nieoczekiwany błąd podczas pobierania utworów: $e');
    }
  }

  /// Tworzy nowy utwór w projekcie.
  ///
  /// Przyjmuje ID projektu i tytuł utworu.
  /// Zwraca utworzony utwór.
  Future<Song> createSong({required int projectId, required String title}) async {
    try {
      final songData = {'title': title};

      final response = await apiClient.post('api/projects/$projectId/songs', data: songData);

      if (response.data == null) {
        throw ApiException(
          message: 'Brak danych w odpowiedzi podczas tworzenia utworu',
          statusCode: response.statusCode,
          data: response.data,
        );
      }

      return Song.fromJson(response.data);
    } on ApiException {
      rethrow;
    } catch (e) {
      throw UnknownException('Wystąpił nieoczekiwany błąd podczas tworzenia utworu: $e');
    }
  }

  /// Usuwa utwór z projektu.
  ///
  /// Przyjmuje ID projektu i ID utworu.
  Future<void> deleteSong({required int projectId, required int songId}) async {
    try {
      await apiClient.delete('api/projects/$projectId/songs/$songId');
    } on ApiException {
      rethrow;
    } catch (e) {
      throw UnknownException('Wystąpił nieoczekiwany błąd podczas usuwania utworu: $e');
    }
  }
}
