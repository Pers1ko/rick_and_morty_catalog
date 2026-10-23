import 'dart:async';

import 'package:flutter_test/flutter_test.dart';

import 'package:fake_async/fake_async.dart';
import 'package:rick_and_morty_catalog/core/error/app_failure.dart';
import 'package:rick_and_morty_catalog/features/characters/domain/entities/character_page.dart';
import 'package:rick_and_morty_catalog/features/characters/domain/entities/character_status.dart';
import 'package:rick_and_morty_catalog/features/characters/domain/usecases/get_characters.dart';
import 'package:rick_and_morty_catalog/features/characters/presentation/catalog/cubit/catalog_cubit.dart';
import 'package:rick_and_morty_catalog/features/characters/presentation/catalog/cubit/catalog_state.dart';

import '../../../support/fixtures.dart';

void main() {
  late FakeCharactersRepository repository;
  late CatalogCubit cubit;

  setUp(() {
    repository = FakeCharactersRepository();
    cubit = CatalogCubit(
      GetCharacters(repository),
      debounceDuration: Duration.zero,
    );
  });

  tearDown(() async {
    if (!cubit.isClosed) await cubit.close();
  });

  Future<void> completeInitial({int? nextPage = 2}) async {
    final loading = cubit.loadInitial();
    repository.requests.last.completer.complete(
      pageOf([1, 2], nextPage: nextPage),
    );
    await loading;
  }

  test('loads the first page and reads its next-page cursor', () async {
    await completeInitial();
    expect(cubit.state.phase, CatalogPhase.ready);
    expect(cubit.state.characters.map((item) => item.id), [1, 2]);
    expect(cubit.state.nextPage, 2);
    expect(repository.requests.single.page, 1);
  });

  test('debounces input and only requests the final name', () {
    fakeAsync((time) {
      final localRepository = FakeCharactersRepository();
      final localCubit = CatalogCubit(GetCharacters(localRepository));
      localCubit.setQuery('r');
      time.elapse(const Duration(milliseconds: 200));
      localCubit.setQuery('rick');
      time.elapse(const Duration(milliseconds: 349));
      expect(localRepository.requests, isEmpty);
      time.elapse(const Duration(milliseconds: 1));
      expect(localRepository.requests.single.name, 'rick');
      localRepository.requests.single.completer.complete(pageOf([1]));
      time.flushMicrotasks();
      unawaited(localCubit.close());
      time.flushMicrotasks();
    });
  });

  test('ignores an older response that arrives after a new search', () async {
    final initial = cubit.loadInitial();
    cubit.setQuery('Morty');
    await Future<void>.delayed(Duration.zero);
    expect(repository.requests.first.cancellation!.isCancelled, isTrue);
    repository.requests.last.completer.complete(pageOf([2], name: 'Morty'));
    await Future<void>.delayed(Duration.zero);
    repository.requests.first.completer.complete(pageOf([1], name: 'Rick'));
    await initial;
    expect(cubit.state.query, 'Morty');
    expect(cubit.state.characters.single.name, 'Morty');
  });

  test('ignores errors from superseded searches', () async {
    final initial = cubit.loadInitial();
    cubit.setQuery('Morty');
    await Future<void>.delayed(Duration.zero);
    repository.requests.last.completer.complete(pageOf([2]));
    await Future<void>.delayed(Duration.zero);
    repository.requests.first.completer.completeError(
      const AppFailure(FailureKind.server),
    );
    await initial;
    expect(cubit.state.phase, CatalogPhase.ready);
    expect(cubit.state.errorMessage, isNull);
  });

  test('prevents parallel pagination and deduplicates characters', () async {
    await completeInitial();
    final first = cubit.loadNextPage();
    final second = cubit.loadNextPage();
    expect(repository.requests.length, 2);
    repository.requests.last.completer.complete(pageOf([2, 3]));
    await Future.wait([first, second]);
    expect(cubit.state.characters.map((item) => item.id), [1, 2, 3]);
    expect(cubit.state.nextPage, isNull);
    await cubit.loadNextPage();
    expect(repository.requests.length, 2);
  });

  test(
    'keeps cards after a pagination failure and retries the same page',
    () async {
      await completeInitial();
      final loading = cubit.loadNextPage();
      repository.requests.last.completer.completeError(
        const AppFailure(FailureKind.connection),
      );
      await loading;
      expect(cubit.state.characters.length, 2);
      expect(cubit.state.paginationError, contains('Проверьте интернет'));
      expect(cubit.state.isLoadingMore, isFalse);
      await cubit.loadNextPage();
      expect(repository.requests.length, 2, reason: 'No automatic retry loop');
      final retry = cubit.retryNextPage();
      expect(repository.requests.last.page, 2);
      repository.requests.last.completer.complete(pageOf([3]));
      await retry;
      expect(cubit.state.characters.map((item) => item.id), [1, 2, 3]);
      expect(cubit.state.paginationError, isNull);
    },
  );

  test(
    'an empty final page keeps the count and stops further requests',
    () async {
      await completeInitial();
      final total = cubit.state.totalCount;
      final loading = cubit.loadNextPage();
      repository.requests.last.completer.complete(CharacterPage.empty());
      await loading;
      expect(cubit.state.totalCount, total);
      expect(cubit.state.characters.length, 2);
      expect(cubit.state.nextPage, isNull);
      expect(cubit.state.paginationError, isNull);
      await cubit.loadNextPage();
      expect(repository.requests.length, 2);
    },
  );

  test(
    'pull refresh cancels old pagination and retains search criteria',
    () async {
      cubit.setQuery('Rick');
      await Future<void>.delayed(Duration.zero);
      repository.requests.last.completer.complete(pageOf([1, 2], nextPage: 2));
      await Future<void>.delayed(Duration.zero);
      final pagination = cubit.loadNextPage();
      final old = repository.requests.last;
      final refreshing = cubit.retry();
      expect(old.cancellation!.isCancelled, isTrue);
      expect(repository.requests.last.page, 1);
      expect(repository.requests.last.name, 'Rick');
      repository.requests.last.completer.complete(pageOf([3]));
      await refreshing;
      old.completer.complete(pageOf([4]));
      await pagination;
      expect(cubit.state.characters.single.id, 3);
      expect(cubit.state.paginationError, isNull);
    },
  );

  test('does not append an old page to a new search', () async {
    await completeInitial();
    final oldPagination = cubit.loadNextPage();
    final oldRequest = repository.requests.last;
    cubit.setQuery('Summer');
    await Future<void>.delayed(Duration.zero);
    repository.requests.last.completer.complete(pageOf([3], name: 'Summer'));
    await Future<void>.delayed(Duration.zero);
    oldRequest.completer.complete(pageOf([4, 5]));
    await oldPagination;
    expect(cubit.state.query, 'Summer');
    expect(cubit.state.characters.map((item) => item.id), [3]);
  });

  test(
    'keeps the name filter when the status changes and starts at page one',
    () async {
      cubit.setQuery('  Rick  ');
      await Future<void>.delayed(Duration.zero);
      repository.requests.last.completer.complete(pageOf([1], nextPage: 2));
      await Future<void>.delayed(Duration.zero);
      cubit.setStatusFilter(CharacterStatus.alive);
      expect(repository.requests.last.page, 1);
      expect(repository.requests.last.name, 'Rick');
      expect(repository.requests.last.status, CharacterStatus.alive);
      repository.requests.last.completer.complete(CharacterPage.empty());
      await Future<void>.delayed(Duration.zero);
      expect(cubit.state.characters, isEmpty);
      expect(cubit.state.phase, CatalogPhase.ready);
    },
  );

  test('retries an initial failure', () async {
    final loading = cubit.loadInitial();
    repository.requests.single.completer.completeError(
      const AppFailure(FailureKind.connection),
    );
    await loading;
    expect(cubit.state.phase, CatalogPhase.failure);
    final retry = cubit.retry();
    expect(cubit.state.phase, CatalogPhase.loading);
    repository.requests.last.completer.complete(pageOf([1]));
    await retry;
    expect(cubit.state.phase, CatalogPhase.ready);
    expect(cubit.state.errorMessage, isNull);
  });

  test('close cancels pending work and prevents late emissions', () async {
    final pending = cubit.loadInitial();
    await cubit.close();
    expect(repository.requests.single.cancellation!.isCancelled, isTrue);
    repository.requests.single.completer.complete(pageOf([1]));
    await pending;
    expect(cubit.isClosed, isTrue);
  });
}
