import 'dart:async';
import 'dart:math';

import 'package:dio/dio.dart';

class RetryInterceptor extends Interceptor {
  final Dio dio;
  final int maxRetries;
  final Duration retryDelay;
  final int circuitThreshold;
  final Duration circuitDuration;

  bool _circuitOpen = false;
  DateTime? _circuitOpenedAt;
  int _failureCount = 0;

  RetryInterceptor({
    required this.dio,
    this.maxRetries = 3,
    this.retryDelay = const Duration(seconds: 1),
    this.circuitThreshold = 3,
    this.circuitDuration = const Duration(seconds: 20),
  });

  bool get isCircuitOpen {
    if (!_circuitOpen) return false;

    if (_circuitOpenedAt == null) return false;
    final age = DateTime.now().difference(_circuitOpenedAt!);
    if (age >= circuitDuration) {
      _circuitOpen = false;
      _failureCount = 0;
      return false;
    }
    return true;
  }

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (isCircuitOpen) {
      return handler.reject(DioException(
        requestOptions: options,
        error: 'Circuit open, istek atılmadı',
        type: DioErrorType.connectionError,
      ));
    }
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    _failureCount = 0;
    if (_circuitOpen) {
      _circuitOpen = false;
      _circuitOpenedAt = null;
    }
    handler.next(response);
  }

  @override
  Future<void> onError(DioException err, ErrorInterceptorHandler handler) async {
    final requestOptions = err.requestOptions;
    var retries = (requestOptions.extra['retries'] ?? 0) as int;

    _failureCount++;
    if (_failureCount >= circuitThreshold && !_circuitOpen) {
      _circuitOpen = true;
      _circuitOpenedAt = DateTime.now();
    }

    if (retries < maxRetries && _shouldRetry(err) && !isCircuitOpen) {
      retries += 1;
      requestOptions.extra['retries'] = retries;

      final waiting = Duration(milliseconds: retryDelay.inMilliseconds * pow(2, retries - 1).toInt());
      await Future<void>.delayed(waiting);

      try {
        final response = await dio.fetch(requestOptions);
        return handler.resolve(response);
      } catch (error) {
        return super.onError(error as DioException, handler);
      }
    }

    return handler.next(err);
  }

  bool _shouldRetry(DioException err) {
    return err.type == DioErrorType.connectionTimeout ||
        err.type == DioErrorType.receiveTimeout ||
        err.type == DioErrorType.sendTimeout ||
        err.type == DioErrorType.badResponse ||
        err.type == DioErrorType.unknown;
  }
}
