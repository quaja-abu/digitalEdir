import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:digitaledir/core/config/environment.dart';
import 'package:digitaledir/core/config/api_config.dart';
import 'package:digitaledir/core/services/storage_service.dart';

class HttpService {
  static final HttpService _instance = HttpService._internal();
  factory HttpService() => _instance;
  HttpService._internal() {
    _init();
  }

  late Dio _dio;
  final StorageService _storageService = StorageService();

  void _init() {
    _dio = Dio(
      BaseOptions(
        baseUrl: EnvironmentConfig.apiBaseUrl,
        connectTimeout: ApiConfig.connectTimeout,
        receiveTimeout: ApiConfig.receiveTimeout,
        sendTimeout: ApiConfig.sendTimeout,
        headers: ApiConfig.defaultHeaders,
        responseType: ResponseType.json,
      ),
    );

    // Add interceptors
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        // Add auth token if available
        final token = await _storageService.getAuthToken();
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }

        if (kDebugMode) {
          print('🚀 [REQUEST] ${options.method} ${options.path}');
          if (options.data != null) {
            print('📦 [DATA] ${options.data}');
          }
        }

        return handler.next(options);
      },
      onResponse: (response, handler) {
        if (kDebugMode) {
          print(
              '✅ [RESPONSE] ${response.statusCode} ${response.requestOptions.path}');
          print('📦 [DATA] ${response.data}');
        }
        return handler.next(response);
      },
      onError: (error, handler) {
        if (kDebugMode) {
          print('❌ [ERROR] ${error.type} ${error.response?.statusCode}');
          print('📦 [ERROR DATA] ${error.response?.data}');
        }
        return handler.next(error);
      },
    ));
  }

  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onReceiveProgress,
  }) async {
    try {
      final response = await _dio.get(
        path,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onReceiveProgress: onReceiveProgress,
      );
      return response;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Response> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    try {
      final response = await _dio.post(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );
      return response;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Response> put(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    try {
      final response = await _dio.put(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );
      return response;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Response> patch(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    try {
      final response = await _dio.patch(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );
      return response;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Response> delete(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      final response = await _dio.delete(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
      return response;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Response> uploadFile(
    String path,
    String filePath, {
    String fieldName = 'file',
    Map<String, dynamic>? data,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
  }) async {
    try {
      final formData = FormData.fromMap({
        fieldName: await MultipartFile.fromFile(filePath),
        ...?data,
      });

      final response = await _dio.post(
        path,
        data: formData,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
      );
      return response;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  dynamic _handleError(DioException error) {
    if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout ||
        error.type == DioExceptionType.sendTimeout) {
      throw ApiException(ApiConfig.timeoutError, 408);
    } else if (error.type == DioExceptionType.connectionError) {
      throw ApiException(ApiConfig.networkError, 0);
    } else if (error.response != null) {
      final int statusCode = error.response!.statusCode ?? 0;
      final responseData = error.response!.data;

      String message = _extractErrorMessage(responseData);

      switch (statusCode) {
        case 400:
          throw BadRequestException(message, statusCode);
        case 401:
          throw UnauthorizedException(message, statusCode);
        case 403:
          throw ForbiddenException(message, statusCode);
        case 404:
          throw NotFoundException(message, statusCode);
        case 500:
          throw ServerException(message, statusCode);
        default:
          throw ApiException(message, statusCode ?? 0);
      }
    } else {
      throw ApiException(error.message ?? 'Unknown error', 0);
    }
  }

  String _extractErrorMessage(dynamic responseData) {
    try {
      if (responseData is String) {
        final json = jsonDecode(responseData);
        return json['message'] ?? json['error'] ?? 'Unknown error';
      } else if (responseData is Map) {
        return responseData['message'] ??
            responseData['error'] ??
            'Unknown error';
      }
    } catch (e) {
      return 'Unknown error';
    }
    return 'Unknown error';
  }

  // Clear auth header
  void clearAuthHeader() {
    _dio.options.headers.remove('Authorization');
  }

  // Update base URL (for development/testing)
  void updateBaseUrl(String baseUrl) {
    _dio.options.baseUrl = baseUrl;
  }
}

// Custom Exceptions
class ApiException implements Exception {
  final String message;
  final int statusCode;

  ApiException(this.message, this.statusCode);

  @override
  String toString() => 'ApiException: $message (Status: $statusCode)';
}

class BadRequestException extends ApiException {
  BadRequestException(String message, int statusCode)
      : super(message, statusCode);
}

class UnauthorizedException extends ApiException {
  UnauthorizedException(String message, int statusCode)
      : super(message, statusCode);
}

class ForbiddenException extends ApiException {
  ForbiddenException(String message, int statusCode)
      : super(message, statusCode);
}

class NotFoundException extends ApiException {
  NotFoundException(String message, int statusCode)
      : super(message, statusCode);
}

class ServerException extends ApiException {
  ServerException(String message, int statusCode) : super(message, statusCode);
}
