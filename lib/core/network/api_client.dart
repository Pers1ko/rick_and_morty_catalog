import 'package:dio/dio.dart';
import 'package:rick_and_morty_catalog/core/async/request_cancellation.dart';
import 'package:rick_and_morty_catalog/core/async/request_cancelled.dart';
import 'package:rick_and_morty_catalog/core/network/api_error_mapper.dart';
import 'package:rick_and_morty_catalog/core/network/retry_policy.dart';

/// HTTP transport, bounded retry and cancellation. No feature-specific rules.
final class ApiClient {
  ApiClient(this._dio, {RetryPolicy retryPolicy = const RetryPolicy()})
    : _retryPolicy = retryPolicy;
  final Dio _dio;
  final RetryPolicy _retryPolicy;

  Future<Map<String, dynamic>> getJson(
    String path, {
    Map<String, dynamic>? queryParameters,
    RequestCancellation? cancellation,
  }) async {
    final operation = cancellation ?? RequestCancellation();
    operation.throwIfCancelled();
    final token = CancelToken();
    final detach = operation.onCancel(() => token.cancel());
    try {
      for (var attempt = 0; ; attempt++) {
        operation.throwIfCancelled();
        try {
          final response = await _dio.get<Map<String, dynamic>>(
            path,
            queryParameters: queryParameters,
            cancelToken: token,
          );
          operation.throwIfCancelled();
          final body = response.data;
          if (body == null) {
            throw const FormatException('Missing response body');
          }
          return body;
        } on DioException catch (error, stack) {
          if (CancelToken.isCancel(error)) throw const RequestCancelled();
          final delay = _retryPolicy.delayFor(error, attempt);
          if (delay == null) {
            Error.throwWithStackTrace(ApiErrorMapper.map(error), stack);
          }
          await operation.wait(delay);
        }
      }
    } finally {
      detach();
    }
  }
}
