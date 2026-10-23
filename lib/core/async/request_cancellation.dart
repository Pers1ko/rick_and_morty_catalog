import 'dart:async';

import 'package:rick_and_morty_catalog/core/async/request_cancelled.dart';

/// Owns cancellation listeners without depending on Flutter or an HTTP client.
final class RequestCancellation {
  final _listeners = <void Function()>[];
  bool _isCancelled = false;
  String? _reason;

  bool get isCancelled => _isCancelled;

  void cancel([String? reason]) {
    if (_isCancelled) return;
    _isCancelled = true;
    _reason = reason;
    for (final listener in List.of(_listeners)) {
      listener();
    }
    _listeners.clear();
  }

  /// Returns a disposer so completed requests do not retain their listeners.
  void Function() onCancel(void Function() listener) {
    if (_isCancelled) {
      listener();
      return () {};
    }
    _listeners.add(listener);
    return () => _listeners.remove(listener);
  }

  void throwIfCancelled() {
    if (_isCancelled) throw RequestCancelled(_reason);
  }

  Future<void> wait(Duration duration) async {
    throwIfCancelled();
    final completer = Completer<void>();
    final timer = Timer(duration, completer.complete);
    final detach = onCancel(() {
      if (!completer.isCompleted) {
        completer.completeError(RequestCancelled(_reason));
      }
    });
    try {
      await completer.future;
    } finally {
      timer.cancel();
      detach();
    }
  }
}
