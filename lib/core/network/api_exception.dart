import 'package:rick_and_morty_catalog/core/error/app_failure.dart';

/// Data-layer error retaining HTTP context for endpoint-specific handling.
final class ApiException implements Exception {
  const ApiException({required this.kind, this.statusCode, this.body});
  final FailureKind kind;
  final int? statusCode;
  final Object? body;
}
