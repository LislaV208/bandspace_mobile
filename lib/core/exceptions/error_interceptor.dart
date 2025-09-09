import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'error_mapper.dart';
import 'app_exceptions.dart';

/// Dio interceptor that transforms DioException to AppException
class ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final appException = ErrorMapper.fromDioException(err);
    
    // Log error for debugging
    _logError(err, appException);
    
    // Create new DioException with AppException as error
    handler.reject(DioException(
      requestOptions: err.requestOptions,
      error: appException,
      type: err.type,
      response: err.response,
      stackTrace: err.stackTrace,
    ));
  }
  
  void _logError(DioException dioError, AppException appException) {
    // Only log in debug mode to avoid production logging issues
    if (kDebugMode) {
      // Log the original Dio error details for debugging
      debugPrint('[ErrorInterceptor] ${dioError.type.name}: ${dioError.message}');
      
      // Log the transformed app exception
      debugPrint('[ErrorInterceptor] Transformed to: ${appException.runtimeType} - ${appException.message}');
      
      // Log additional context in debug mode
      if (dioError.response != null) {
        debugPrint('[ErrorInterceptor] Response status: ${dioError.response!.statusCode}');
        debugPrint('[ErrorInterceptor] Response data: ${dioError.response!.data}');
      }
      
      // Log request details
      debugPrint('[ErrorInterceptor] Request: ${dioError.requestOptions.method} ${dioError.requestOptions.uri}');
      
      if (appException.context != null) {
        debugPrint('[ErrorInterceptor] Error context: ${appException.context}');
      }
    }
  }
}