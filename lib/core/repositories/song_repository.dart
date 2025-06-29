import 'dart:io';
import 'package:dio/dio.dart';
import 'package:bandspace_mobile/core/api/api_client.dart';
import 'package:bandspace_mobile/core/models/song_detail.dart';
import 'package:bandspace_mobile/core/models/song_file.dart';
import 'package:bandspace_mobile/core/repositories/base_repository.dart';

/// Repozytorium odpowiedzialne za operacje związane z szczegółami utworów.
///
/// Obsługuje pobieranie szczegółów utworu, listy plików, URL-i do pobierania
/// i inne operacje związane z plikami utworów.
class SongRepository extends BaseRepository {
  /// Konstruktor przyjmujący opcjonalną instancję ApiClient
  SongRepository({super.apiClient});

  /// Pobiera szczegóły utworu.
  ///
  /// Zwraca szczegółowe informacje o utworze wraz z metadanymi.
  Future<SongDetail> getSongDetails({
    required int projectId,
    required int songId,
  }) async {
    try {
      final response = await apiClient.get('api/projects/$projectId/songs/$songId');

      if (response.data == null) {
        throw ApiException(
          message: 'Brak danych w odpowiedzi podczas pobierania szczegółów utworu',
          statusCode: response.statusCode,
          data: response.data,
        );
      }

      return SongDetail.fromJson(response.data);
    } on ApiException {
      rethrow;
    } catch (e) {
      throw UnknownException('Wystąpił nieoczekiwany błąd podczas pobierania szczegółów utworu: $e');
    }
  }

  /// Pobiera listę plików dla danego utworu.
  ///
  /// Zwraca listę plików audio powiązanych z utworem.
  Future<List<SongFile>> getSongFiles(int songId) async {
    try {
      final response = await apiClient.get('api/songs/$songId/files');

      if (response.data == null) {
        return [];
      }

      final List<dynamic> filesData = response.data;
      return filesData.map((fileData) => SongFile.fromJson(fileData)).toList();
    } on ApiException {
      rethrow;
    } catch (e) {
      throw UnknownException('Wystąpił nieoczekiwany błąd podczas pobierania plików utworu: $e');
    }
  }

  /// Pobiera URL do pobierania/streamowania pliku.
  ///
  /// Zwraca presigned URL do bezpiecznego dostępu do pliku.
  Future<String> getFileDownloadUrl({
    required int songId,
    required int fileId,
  }) async {
    try {
      final response = await apiClient.get('api/songs/$songId/files/$fileId/download');

      if (response.data == null || response.data['download_url'] == null) {
        throw ApiException(
          message: 'Brak URL do pobierania w odpowiedzi serwera',
          statusCode: response.statusCode,
          data: response.data,
        );
      }

      return response.data['download_url'];
    } on ApiException {
      rethrow;
    } catch (e) {
      throw UnknownException('Wystąpił nieoczekiwany błąd podczas pobierania URL pliku: $e');
    }
  }

  /// Usuwa plik z utworu.
  ///
  /// Usuwa plik audio z utworu i z systemu plików.
  Future<void> deleteSongFile({
    required int songId,
    required int fileId,
  }) async {
    try {
      await apiClient.delete('api/songs/$songId/files/$fileId');
    } on ApiException {
      rethrow;
    } catch (e) {
      throw UnknownException('Wystąpił nieoczekiwany błąd podczas usuwania pliku: $e');
    }
  }

  /// Przesyła plik audio do utworu.
  ///
  /// Uploaduje plik audio do utworu z opcjonalnymi metadanymi.
  Future<SongFile> uploadFile({
    required int songId,
    required File file,
    String? description,
    int? duration,
    Function(double)? onProgress,
  }) async {
    try {
      // Przygotowanie FormData
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          file.path,
          filename: file.path.split('/').last,
        ),
        if (description != null) 'description': description,
        if (duration != null) 'duration': duration,
      });

      final response = await apiClient.post(
        'api/songs/$songId/files',
        data: formData,
        onSendProgress: onProgress != null
            ? (sent, total) {
                if (total > 0) {
                  onProgress(sent / total);
                }
              }
            : null,
      );

      if (response.data == null) {
        throw ApiException(
          message: 'Brak danych w odpowiedzi podczas przesyłania pliku',
          statusCode: response.statusCode,
          data: response.data,
        );
      }

      return SongFile.fromJson(response.data);
    } on ApiException {
      rethrow;
    } catch (e) {
      throw UnknownException('Wystąpił nieoczekiwany błąd podczas przesyłania pliku: $e');
    }
  }

  /// Aktualizuje metadane utworu.
  ///
  /// Aktualizuje informacje takie jak tytuł, notatki, BPM, tonacja, tekst.
  Future<SongDetail> updateSong({
    required int projectId,
    required int songId,
    String? title,
    String? notes,
    int? bpm,
    String? key,
    String? lyrics,
  }) async {
    try {
      final updateData = <String, dynamic>{};
      
      if (title != null) updateData['title'] = title;
      if (notes != null) updateData['notes'] = notes;
      if (bpm != null) updateData['bpm'] = bpm;
      if (key != null) updateData['key'] = key;
      if (lyrics != null) updateData['lyrics'] = lyrics;

      final response = await apiClient.put(
        'api/projects/$projectId/songs/$songId',
        data: updateData,
      );

      if (response.data == null) {
        throw ApiException(
          message: 'Brak danych w odpowiedzi podczas aktualizacji utworu',
          statusCode: response.statusCode,
          data: response.data,
        );
      }

      return SongDetail.fromJson(response.data);
    } on ApiException {
      rethrow;
    } catch (e) {
      throw UnknownException('Wystąpił nieoczekiwany błąd podczas aktualizacji utworu: $e');
    }
  }
}