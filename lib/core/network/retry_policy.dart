import 'package:dio/dio.dart';

/// Applies only to idempotent GET requests. Attempt is zero-based.
final class RetryPolicy {
  const RetryPolicy({
    this.maxRetries = 2,
    this.baseDelay = const Duration(milliseconds: 600),
    this.maxDelay = const Duration(seconds: 30),
  });

  final int maxRetries;
  final Duration baseDelay;
  final Duration maxDelay;

  Duration? delayFor(DioException error, int attempt) {
    final status = error.response?.statusCode;
    final transient =
        status == 429 ||
        (status != null && status >= 500) ||
        error.type == DioExceptionType.connectionError ||
        error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout;
    if (attempt >= maxRetries || !transient || CancelToken.isCancel(error)) {
      return null;
    }
    final seconds = int.tryParse(
      error.response?.headers.value('retry-after') ?? '',
    );
    final delay = seconds != null && seconds >= 0
        ? Duration(seconds: seconds)
        : baseDelay * (attempt + 1) * (status == 429 ? 8 : 1);
    return delay > maxDelay ? maxDelay : delay;
  }
}
