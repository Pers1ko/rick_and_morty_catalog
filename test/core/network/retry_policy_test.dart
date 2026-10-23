import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rick_and_morty_catalog/core/network/retry_policy.dart';

void main() {
  DioException error(int code, {String? retryAfter}) {
    final request = RequestOptions(path: '/character');
    return DioException(
      requestOptions: request,
      type: DioExceptionType.badResponse,
      response: Response<Object?>(
        requestOptions: request,
        statusCode: code,
        headers: Headers.fromMap({
          if (retryAfter != null) 'retry-after': [retryAfter],
        }),
      ),
    );
  }

  test('limits transient retries and increases delay for rate limiting', () {
    const policy = RetryPolicy();
    expect(policy.delayFor(error(503), 0), const Duration(milliseconds: 600));
    expect(policy.delayFor(error(429), 0), const Duration(milliseconds: 4800));
    expect(policy.delayFor(error(503), 2), isNull);
    expect(policy.delayFor(error(404), 0), isNull);
  });

  test('honors numeric Retry-After with a bounded maximum wait', () {
    const policy = RetryPolicy();
    expect(
      policy.delayFor(error(429, retryAfter: '3'), 0),
      const Duration(seconds: 3),
    );
    expect(
      policy.delayFor(error(429, retryAfter: '300'), 0),
      const Duration(seconds: 30),
    );
    expect(
      policy.delayFor(error(429, retryAfter: '-1'), 0),
      const Duration(milliseconds: 4800),
    );
  });
}
