import 'dart:async';

import 'package:dio/dio.dart';

import '../../application/auth/session_storage.dart';
import '../../domain/failure/failure.dart';
import '../auth/secure_session_storage.dart';

typedef SessionExpiredCallback = FutureOr<void> Function();

class ApiClient {
  static const defaultBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:8080/api/v1',
  );

  final Dio dio;
  final SessionStorage sessionStorage;
  final SessionExpiredCallback? onSessionExpired;

  ApiClient({
    Dio? dioClient,
    SessionStorage? sessionStore,
    this.onSessionExpired,
    String baseUrl = defaultBaseUrl,
  })  : dio = dioClient ?? Dio(BaseOptions(baseUrl: baseUrl)),
        sessionStorage = sessionStore ?? SecureSessionStorage() {
    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await sessionStorage.read('jwt_token');
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
    ));
  }

  bool _isExpiredSession(DioException error) {
    if (error.response?.statusCode != 401) return false;
    final data = error.response?.data;
    return data is Map<String, dynamic> && data['code'] == 'UNAUTHENTICATED';
  }

  Future<Map<String, dynamic>> post(String path, {dynamic data}) async {
    try {
      final response = await dio.post(path, data: data);
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw await _handleDioError(e);
    }
  }

  Future<Map<String, dynamic>> get(String path,
      {Map<String, dynamic>? queryParameters}) async {
    try {
      final response = await dio.get(path, queryParameters: queryParameters);
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw await _handleDioError(e);
    }
  }

  Future<List<dynamic>> getList(String path,
      {Map<String, dynamic>? queryParameters}) async {
    try {
      final response = await dio.get(path, queryParameters: queryParameters);
      return response.data as List<dynamic>;
    } on DioException catch (e) {
      throw await _handleDioError(e);
    }
  }

  Future<Failure> _handleDioError(DioException e) async {
    if (_isExpiredSession(e)) {
      await sessionStorage.deleteAll();
      await onSessionExpired?.call();
    }

    if (e.response != null) {
      final status = e.response!.statusCode;
      final data = e.response!.data;
      String message = 'An error occurred';
      String? code;

      if (data is Map<String, dynamic>) {
        message = data['detail'] ?? data['message'] ?? message;
        code = data['code'];
      }

      switch (status) {
        case 401:
          if (code == 'UNAUTHENTICATED') {
            return const SessionExpiredFailure();
          }
          return AuthFailure(message, code: code);
        case 403:
          return const ForbiddenFailure();
        case 404:
          return NotFoundFailure(message, code: code);
        case 409:
          return ConflictFailure(message, code: code);
        case 400:
          return ValidationFailure(message, code: code);
        default:
          return ServerFailure(message, code: code);
      }
    }
    return const NetworkFailure();
  }
}
