import 'package:dio/dio.dart';

/// Helper do mapowania błędów na przyjazne komunikaty użytkownika
class TrackErrorHandler {
  /// Mapuje błąd na przyjazny komunikat dla operacji aktualizacji
  static String getUpdateErrorMessage(dynamic error) {
    if (error is DioException) {
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.receiveTimeout:
        case DioExceptionType.sendTimeout:
          return 'Przekroczono limit czasu. Sprawdź połączenie z internetem i spróbuj ponownie.';
        
        case DioExceptionType.connectionError:
          return 'Brak połączenia z internetem. Sprawdź swoje połączenie i spróbuj ponownie.';
        
        case DioExceptionType.badResponse:
          switch (error.response?.statusCode) {
            case 400:
              return 'Nieprawidłowe dane. Sprawdź wprowadzone informacje.';
            case 401:
              return 'Sesja wygasła. Zaloguj się ponownie.';
            case 403:
              return 'Nie masz uprawnień do edycji tego utworu.';
            case 404:
              return 'Utwór nie został znaleziony. Możliwe, że został usunięty.';
            case 409:
              return 'Utwór został zmodyfikowany przez kogoś innego. Odśwież dane i spróbuj ponownie.';
            case 422:
              return 'Wprowadzone dane są nieprawidłowe. Sprawdź tytuł i tempo.';
            case 500:
              return 'Wystąpił błąd serwera. Spróbuj ponownie za chwilę.';
            default:
              return 'Nie udało się zaktualizować utworu. Spróbuj ponownie.';
          }
        
        case DioExceptionType.cancel:
          return 'Operacja została anulowana.';
        
        case DioExceptionType.unknown:
        default:
          return 'Wystąpił nieoczekiwany błąd. Sprawdź połączenie i spróbuj ponownie.';
      }
    }
    
    // Fallback dla innych typów błędów
    return 'Nie udało się zaktualizować utworu. Spróbuj ponownie.';
  }
  
  /// Mapuje błąd na przyjazny komunikat dla operacji usuwania
  static String getDeleteErrorMessage(dynamic error) {
    if (error is DioException) {
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.receiveTimeout:
        case DioExceptionType.sendTimeout:
          return 'Przekroczono limit czasu. Sprawdź połączenie z internetem i spróbuj ponownie.';
        
        case DioExceptionType.connectionError:
          return 'Brak połączenia z internetem. Sprawdź swoje połączenie i spróbuj ponownie.';
        
        case DioExceptionType.badResponse:
          switch (error.response?.statusCode) {
            case 401:
              return 'Sesja wygasła. Zaloguj się ponownie.';
            case 403:
              return 'Nie masz uprawnień do usuwania tego utworu.';
            case 404:
              return 'Utwór nie został znaleziony. Możliwe, że został już usunięty.';
            case 409:
              return 'Utwór jest obecnie używany i nie może zostać usunięty.';
            case 500:
              return 'Wystąpił błąd serwera. Spróbuj ponownie za chwilę.';
            default:
              return 'Nie udało się usunąć utworu. Spróbuj ponownie.';
          }
        
        case DioExceptionType.cancel:
          return 'Operacja została anulowana.';
        
        case DioExceptionType.unknown:
        default:
          return 'Wystąpił nieoczekiwany błąd. Sprawdź połączenie i spróbuj ponownie.';
      }
    }
    
    // Fallback dla innych typów błędów
    return 'Nie udało się usunąć utworu. Spróbuj ponownie.';
  }
  
  /// Mapuje błąd na przyjazny komunikat dla operacji ładowania
  static String getLoadErrorMessage(dynamic error) {
    if (error is DioException) {
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.receiveTimeout:
          return 'Przekroczono limit czasu ładowania. Spróbuj ponownie.';
        
        case DioExceptionType.connectionError:
          return 'Brak połączenia z internetem. Sprawdź swoje połączenie.';
        
        case DioExceptionType.badResponse:
          switch (error.response?.statusCode) {
            case 401:
              return 'Sesja wygasła. Zaloguj się ponownie.';
            case 403:
              return 'Nie masz dostępu do tego utworu.';
            case 404:
              return 'Utwór nie został znaleziony.';
            case 500:
              return 'Błąd serwera. Spróbuj ponownie za chwilę.';
            default:
              return 'Nie udało się załadować danych utworu.';
          }
        
        default:
          return 'Wystąpił błąd podczas ładowania. Spróbuj ponownie.';
      }
    }
    
    return 'Nie udało się załadować danych utworu.';
  }
}