import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../domain/failure/failure.dart';

class ApiClient {
  final Dio dio;
  final FlutterSecureStorage storage;

  ApiClient({Dio? dioClient, FlutterSecureStorage? secureStorage})
      : dio = dioClient ?? Dio(BaseOptions(baseUrl: 'http://localhost:8080/api/v1')),
        storage = secureStorage ?? const FlutterSecureStorage() {
    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await storage.read(key: 'jwt_token');
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
      onError: (DioException error, handler) {
        return handler.next(error);
      },
    ));
  }

  Future<Map<String, dynamic>> post(String path, {dynamic data}) async {
    try {
      final response = await dio.post(path, data: data);
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<Map<String, dynamic>> get(String path, {Map<String, dynamic>? queryParameters}) async {
    try {
      final response = await dio.get(path, queryParameters: queryParameters);
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<List<dynamic>> getList(String path, {Map<String, dynamic>? queryParameters}) async {
    try {
      final response = await dio.get(path, queryParameters: queryParameters);
      return response.data as List<dynamic>;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Failure _handleDioError(DioException e) {
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
          return AuthFailure(message, code: code);
        case 403:
          return AuthFailure('Forbidden operation', code: 'FORBIDDEN');
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
