/// Transport-independent signal: cancellation is never a user-facing failure.
final class RequestCancelled implements Exception {
  const RequestCancelled([this.reason]);
  final String? reason;
}
