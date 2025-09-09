import 'package:dio/dio.dart';
import 'app_exceptions.dart';

/// Maps DioException to AppException
class ErrorMapper {
  static AppException fromDioException(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.sendTimeout:
        return const TimeoutException();
        
      case DioExceptionType.connectionError:
        return const ConnectionException();
        
      case DioExceptionType.badResponse:
        return _mapStatusCodeToException(error.response);
        
      case DioExceptionType.cancel:
        return const RequestCancelledException();
        
      case DioExceptionType.unknown:
      default:
        return const NetworkException('Wystąpił nieoczekiwany błąd sieciowy.');
    }
  }
  
  static AppException _mapStatusCodeToException(Response? response) {
    final statusCode = response?.statusCode;
    final message = _extractErrorMessage(response);
    
    switch (statusCode) {
      case 400:
        return ValidationException(message ?? 'Nieprawidłowe dane żądania.');
      case 401:
        return const SessionExpiredException();
      case 403:
        return const PermissionException();
      case 404:
        return const ResourceNotFoundException('Zasób');
      case 409:
        return const ConflictException();
      case 422:
        return ValidationException(message ?? 'Dane nie przeszły walidacji.');
      case 500:
      case 502:
      case 503:
      case 504:
        return const ServerException();
      default:
        return ServerException(message ?? 'Wystąpił błąd HTTP ($statusCode).');
    }
  }
  
  static String? _extractErrorMessage(Response? response) {
    if (response?.data == null) return null;
    
    try {
      final data = response!.data;
      if (data is Map<String, dynamic>) {
        // Try different common error message fields
        if (data.containsKey('message')) {
          return data['message'] as String?;
        }
        if (data.containsKey('error')) {
          final error = data['error'];
          if (error is String) {
            return error;
          }
          if (error is Map<String, dynamic> && error.containsKey('message')) {
            return error['message'] as String?;
          }
        }
        if (data.containsKey('detail')) {
          return data['detail'] as String?;
        }
      }
    } catch (e) {
      // Ignore parsing errors
    }
    
    return null;
  }
}