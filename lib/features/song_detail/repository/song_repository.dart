// import 'dart:io';

// import 'package:dio/dio.dart';

// import 'package:bandspace_mobile/core/api/api_client.dart';
// import 'package:bandspace_mobile/core/api/base_repository.dart';
// import 'package:bandspace_mobile/shared/models/song_detail.dart';
// import 'package:bandspace_mobile/shared/models/song_file.dart';

// /// Repozytorium odpowiedzialne za operacje związane z szczegółami utworów.
// ///
// /// Obsługuje pobieranie szczegółów utworu, listy plików, URL-i do pobierania
// /// i inne operacje związane z plikami utworów.
// class SongRepository extends BaseRepository {
//   /// Konstruktor przyjmujący opcjonalną instancję ApiClient
//   SongRepository({super.apiClient});

//   /// Pobiera szczegóły utworu.
//   ///
//   /// Zwraca szczegółowe informacje o utworze wraz z metadanymi.
//   Future<SongDetail> getSongDetails({required int projectId, required int songId}) async {
//     try {
//       final response = await apiClient.get('/api/projects/$projectId/songs/$songId');

//       if (response.data == null) {
//         throw ApiException(
//           message: 'Brak danych w odpowiedzi podczas pobierania szczegółów utworu',
//           statusCode: response.statusCode,
//           data: response.data,
//         );
//       }

//       return SongDetail.fromJson(response.data);
//     } on ApiException {
//       rethrow;
//     } catch (e) {
//       throw UnknownException('Wystąpił nieoczekiwany błąd podczas pobierania szczegółów utworu: $e');
//     }
//   }

//   /// Pobiera listę plików dla danego utworu.
//   ///
//   /// Zwraca listę plików audio powiązanych z utworem.
//   Future<List<SongFile>> getSongFiles({required int projectId, required int songId}) async {
//     try {
//       final response = await apiClient.get('/api/projects/$projectId/songs/$songId/files');

//       if (response.data == null) {
//         return [];
//       }

//       final List<dynamic> filesData = response.data;
//       return filesData.map((fileData) => SongFile.fromJson(fileData)).toList();
//     } on ApiException {
//       rethrow;
//     } catch (e) {
//       throw UnknownException('Wystąpił nieoczekiwany błąd podczas pobierania plików utworu: $e');
//     }
//   }

//   /// Pobiera metadane pliku.
//   ///
//   /// Zwraca szczegółowe informacje o pliku.
//   Future<SongFile> getFileMetadata({
//     required int projectId,
//     required int songId,
//     required int fileId,
//   }) async {
//     try {
//       final response = await apiClient.get('/api/projects/$projectId/songs/$songId/files/$fileId');

//       if (response.data == null) {
//         throw ApiException(
//           message: 'Brak danych w odpowiedzi podczas pobierania metadanych pliku',
//           statusCode: response.statusCode,
//           data: response.data,
//         );
//       }

//       return SongFile.fromJson(response.data);
//     } on ApiException {
//       rethrow;
//     } catch (e) {
//       throw UnknownException('Wystąpił nieoczekiwany błąd podczas pobierania metadanych pliku: $e');
//     }
//   }

//   /// Aktualizuje metadane pliku.
//   ///
//   /// Przyjmuje ID projektu, ID utworu, ID pliku i nowe metadane.
//   /// Zwraca zaktualizowany plik.
//   Future<SongFile> updateFileMetadata({
//     required int projectId,
//     required int songId,
//     required int fileId,
//     String? name,
//     String? description,
//   }) async {
//     try {
//       final updateData = <String, dynamic>{};
//       if (name != null) updateData['name'] = name;
//       if (description != null) updateData['description'] = description;

//       final response = await apiClient.patch(
//         '/api/projects/$projectId/songs/$songId/files/$fileId',
//         data: updateData,
//       );

//       if (response.data == null) {
//         throw ApiException(
//           message: 'Brak danych w odpowiedzi podczas aktualizacji metadanych pliku',
//           statusCode: response.statusCode,
//           data: response.data,
//         );
//       }

//       return SongFile.fromJson(response.data);
//     } on ApiException {
//       rethrow;
//     } catch (e) {
//       throw UnknownException('Wystąpił nieoczekiwany błąd podczas aktualizacji metadanych pliku: $e');
//     }
//   }

//   /// Pobiera URL do pobierania/streamowania pliku.
//   ///
//   /// Zwraca presigned URL do bezpiecznego dostępu do pliku.
//   Future<String> getFileDownloadUrl({
//     required int projectId,
//     required int songId,
//     required int fileId,
//   }) async {
//     try {
//       final response = await apiClient.get('/api/projects/$projectId/songs/$songId/files/$fileId/download-url');
//       final url = response.data?['url'];

//       if (url == null) {
//         throw ApiException(
//           message: 'Brak URL do pobierania w odpowiedzi serwera',
//           statusCode: response.statusCode,
//           data: response.data,
//         );
//       }

//       return url;
//     } on ApiException {
//       rethrow;
//     } catch (e) {
//       throw UnknownException('Wystąpił nieoczekiwany błąd podczas pobierania URL pliku: $e');
//     }
//   }

//   /// Usuwa plik z utworu.
//   ///
//   /// Usuwa plik audio z utworu i z systemu plików.
//   Future<void> deleteSongFile({
//     required int projectId,
//     required int songId,
//     required int fileId,
//   }) async {
//     try {
//       await apiClient.delete('/api/projects/$projectId/songs/$songId/files/$fileId');
//     } on ApiException {
//       rethrow;
//     } catch (e) {
//       throw UnknownException('Wystąpił nieoczekiwany błąd podczas usuwania pliku: $e');
//     }
//   }

//   /// Przesyła plik audio do utworu.
//   ///
//   /// Uploaduje plik audio do utworu z opcjonalnymi metadanymi.
//   Future<SongFile> uploadFile({
//     required int projectId,
//     required int songId,
//     required File file,
//     String? description,
//     Function(double)? onProgress,
//   }) async {
//     try {
//       // Przygotowanie FormData
//       final formData = FormData.fromMap({
//         'file': await MultipartFile.fromFile(file.path, filename: file.path.split('/').last),
//         if (description != null) 'description': description,
//       });

//       final response = await apiClient.post(
//         '/api/projects/$projectId/songs/$songId/files',
//         data: formData,
//         onSendProgress:
//             onProgress != null
//                 ? (sent, total) {
//                   if (total > 0) {
//                     onProgress(sent / total);
//                   }
//                 }
//                 : null,
//       );

//       if (response.data == null) {
//         throw ApiException(
//           message: 'Brak danych w odpowiedzi podczas przesyłania pliku',
//           statusCode: response.statusCode,
//           data: response.data,
//         );
//       }

//       return SongFile.fromJson(response.data);
//     } on ApiException {
//       rethrow;
//     } catch (e) {
//       throw UnknownException('Wystąpił nieoczekiwany błąd podczas przesyłania pliku: $e');
//     }
//   }

//   /// Aktualizuje metadane utworu.
//   ///
//   /// Aktualizuje informacje takie jak tytuł, opis, tekst piosenki.
//   Future<SongDetail> updateSong({
//     required int projectId,
//     required int songId,
//     String? title,
//     String? description,
//     String? lyrics,
//   }) async {
//     try {
//       final updateData = <String, dynamic>{};

//       if (title != null) updateData['title'] = title;
//       if (description != null) updateData['description'] = description;
//       if (lyrics != null) updateData['lyrics'] = lyrics;

//       final response = await apiClient.patch('/api/projects/$projectId/songs/$songId', data: updateData);

//       if (response.data == null) {
//         throw ApiException(
//           message: 'Brak danych w odpowiedzi podczas aktualizacji utworu',
//           statusCode: response.statusCode,
//           data: response.data,
//         );
//       }

//       return SongDetail.fromJson(response.data);
//     } on ApiException {
//       rethrow;
//     } catch (e) {
//       throw UnknownException('Wystąpił nieoczekiwany błąd podczas aktualizacji utworu: $e');
//     }
//   }
// }
