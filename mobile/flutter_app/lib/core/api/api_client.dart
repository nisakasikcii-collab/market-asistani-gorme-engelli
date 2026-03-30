import 'package:dio/dio.dart';

import 'retry_interceptor.dart';

class ApiClient {
  ApiClient._() {
    _dio = Dio(BaseOptions(
      connectTimeout: const Duration(seconds: 5),
      receiveTimeout: const Duration(seconds: 5),
      sendTimeout: const Duration(seconds: 5),
      headers: {'Content-Type': 'application/json'},
    ));

    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        // Log/trace or global headers eklenebilir
        return handler.next(options);
      },
      onResponse: (response, handler) {
        return handler.next(response);
      },
      onError: (e, handler) {
        return handler.next(e);
      },
    ));

    _dio.interceptors.add(RetryInterceptor(dio: _dio, maxRetries: 3, retryDelay: const Duration(seconds: 1)));
  }

  static final ApiClient instance = ApiClient._();

  late final Dio _dio;

  Future<Response<T>> get<T>(String path, {Map<String, dynamic>? queryParameters}) {
    return _dio.get<T>(path, queryParameters: queryParameters);
  }

  Future<Response<T>> post<T>(String path,
      {Map<String, dynamic>? queryParameters, Object? data}) {
    return _dio.post<T>(path, queryParameters: queryParameters, data: data);
  }

  Future<bool> isConnected() async {
    try {
      await _dio.get('https://www.google.com', options: Options(receiveTimeout: const Duration(seconds: 3)));
      return true;
    } catch (_) {
      return false;
    }
  }
}
