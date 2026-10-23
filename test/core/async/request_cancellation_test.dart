import 'dart:async';
import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rick_and_morty_catalog/core/async/request_cancellation.dart';
import 'package:rick_and_morty_catalog/core/async/request_cancelled.dart';

void main() {
  test('detaching a listener releases it and cancellation is idempotent', () {
    final operation = RequestCancellation();
    var calls = 0;
    final detach = operation.onCancel(() => calls++);
    detach();
    operation.onCancel(() => calls++);
    operation.cancel();
    operation.cancel();
    expect(calls, 1);
    operation.onCancel(() => calls++);
    expect(calls, 2);
  });

  test('cancelling backoff completes immediately and releases its timer', () {
    fakeAsync((time) {
      final operation = RequestCancellation();
      Object? failure;
      unawaited(
        operation.wait(const Duration(seconds: 30)).catchError((Object error) {
          failure = error;
        }),
      );
      operation.cancel();
      time.flushMicrotasks();
      expect(failure, isA<RequestCancelled>());
      expect(time.nonPeriodicTimerCount, 0);
    });
  });

  test(
    'completed delay removes its listener before subsequent cancellation',
    () {
      fakeAsync((time) {
        final operation = RequestCancellation();
        var completed = false;
        unawaited(
          operation
              .wait(const Duration(seconds: 1))
              .then((_) => completed = true),
        );
        time.elapse(const Duration(seconds: 1));
        operation.cancel();
        time.flushMicrotasks();
        expect(completed, isTrue);
        expect(time.nonPeriodicTimerCount, 0);
      });
    },
  );
}
