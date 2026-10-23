import 'package:dio/dio.dart';
import 'package:rick_and_morty_catalog/core/error/app_failure.dart';
import 'package:rick_and_morty_catalog/core/network/api_exception.dart';

abstract final class ApiErrorMapper {
  static ApiException map(DioException error) => ApiException(
    statusCode: error.response?.statusCode,
    body: error.response?.data,
    kind: switch (error.type) {
      DioExceptionType.connectionTimeout ||
      DioExceptionType.sendTimeout ||
      DioExceptionType.receiveTimeout => FailureKind.timeout,
      DioExceptionType.connectionError => FailureKind.connection,
      DioExceptionType.badResponse when error.response?.statusCode == 429 =>
        FailureKind.rateLimit,
      DioExceptionType.badResponse => FailureKind.server,
      _ => FailureKind.unexpected,
    },
  );
}
