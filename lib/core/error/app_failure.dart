enum FailureKind {
  timeout,
  connection,
  rateLimit,
  server,
  invalidData,
  unexpected,
}

/// Stable error contract shared by domain and presentation. No UI text or Dio.
final class AppFailure implements Exception {
  const AppFailure(this.kind);
  final FailureKind kind;

  @override
  String toString() => 'AppFailure(${kind.name})';
}
