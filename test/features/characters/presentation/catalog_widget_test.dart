import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:rick_and_morty_catalog/app/app.dart';
import 'package:rick_and_morty_catalog/core/error/app_failure.dart';
import 'package:rick_and_morty_catalog/core/presentation/widgets/skeleton.dart';
import 'package:rick_and_morty_catalog/features/characters/domain/entities/character_page.dart';
import 'package:rick_and_morty_catalog/features/characters/domain/usecases/get_characters.dart';
import 'package:rick_and_morty_catalog/features/characters/presentation/shared/widgets/character_card.dart';
import 'package:rick_and_morty_catalog/features/characters/presentation/shared/widgets/character_card_skeleton.dart';

import '../../../support/fixtures.dart';

void main() {
  Future<void> configurePhone(WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 844));
    addTearDown(() => tester.binding.setSurfaceSize(null));
  }

  testWidgets('shows loading until the initial request finishes', (
    tester,
  ) async {
    await configurePhone(tester);
    final repository = FakeCharactersRepository();
    await tester.pumpWidget(
      RickAndMortyApp(getCharacters: GetCharacters(repository)),
    );
    expect(find.byType(CharacterCardSkeleton), findsWidgets);
    expect(find.text('Загрузка…'), findsNothing);
    expect(find.byTooltip('Обновить каталог'), findsNothing);
    expect(
      find.text('Найдите своего персонажа во вселенной Rick and Morty.'),
      findsNothing,
    );
    repository.requests.single.completer.complete(pageOf([1, 2]));
    await tester.pumpAndSettle();
    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(find.byType(CharacterCard), findsWidgets);
  });

  testWidgets(
    'scroll loads the next page and offers a local retry on failure',
    (tester) async {
      await configurePhone(tester);
      var pageTwoAttempts = 0;
      final repository = FakeCharactersRepository(
        respond: (request) async {
          if (request.page == 1) return pageOf([1, 2, 3, 4], nextPage: 2);
          if (pageTwoAttempts++ == 0) {
            throw const AppFailure(FailureKind.server);
          }
          return pageOf([5, 6]);
        },
      );
      await tester.pumpWidget(
        RickAndMortyApp(getCharacters: GetCharacters(repository)),
      );
      await tester.pumpAndSettle();
      await tester.drag(
        find.byKey(const PageStorageKey('catalog-scroll')),
        const Offset(0, -500),
      );
      await tester.pumpAndSettle();
      final retry = find.byKey(const ValueKey('retry-pagination'));
      await tester.scrollUntilVisible(
        retry,
        150,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();
      expect(find.text('Не удалось загрузить ещё. Повторить'), findsOneWidget);
      await tester.tap(retry);
      await tester.pumpAndSettle();
      expect(repository.requests.map((request) => request.page), [1, 2, 2]);
      await tester.scrollUntilVisible(
        find.byKey(const ValueKey('character-6')),
        150,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();
      expect(find.text('Ошибка догрузки'), findsNothing);
      expect(find.text('Character 6'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('pull refresh reloads the current search using skeletons', (
    tester,
  ) async {
    await configurePhone(tester);
    final repository = FakeCharactersRepository();
    await tester.pumpWidget(
      RickAndMortyApp(getCharacters: GetCharacters(repository)),
    );
    repository.requests.last.completer.complete(pageOf([1, 2]));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const ValueKey('character-search')),
      'Rick',
    );
    await tester.pump(const Duration(milliseconds: 400));
    repository.requests.last.completer.complete(pageOf([3, 4], name: 'Rick'));
    await tester.pumpAndSettle();
    await tester.drag(
      find.byKey(const PageStorageKey('catalog-scroll')),
      const Offset(0, 650),
    );
    await tester.pump(const Duration(seconds: 1));
    expect(repository.requests.length, 3);
    expect(repository.requests.last.name, 'Rick');
    expect(find.byType(Skeleton), findsWidgets);
    expect(find.byType(CircularProgressIndicator), findsNothing);
    repository.requests.last.completer.complete(pageOf([5, 6], name: 'Rick'));
    await tester.pumpAndSettle();
    expect(find.byType(CharacterCardSkeleton), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('pagination uses skeletons and ends without an error footer', (
    tester,
  ) async {
    await configurePhone(tester);
    final repository = FakeCharactersRepository();
    await tester.pumpWidget(
      RickAndMortyApp(getCharacters: GetCharacters(repository)),
    );
    repository.requests.single.completer.complete(
      pageOf([1, 2, 3, 4], nextPage: 2),
    );
    await tester.pumpAndSettle();
    await tester.drag(
      find.byKey(const PageStorageKey('catalog-scroll')),
      const Offset(0, -500),
    );
    await tester.pump(const Duration(milliseconds: 400));
    expect(repository.requests.last.page, 2);
    expect(find.byType(CharacterCardSkeleton), findsWidgets);
    repository.requests.last.completer.complete(CharacterPage.empty());
    await tester.pumpAndSettle();
    await tester.drag(
      find.byKey(const PageStorageKey('catalog-scroll')),
      const Offset(0, -1000),
    );
    await tester.pumpAndSettle();
    expect(repository.requests.length, 2);
    expect(find.byType(CharacterCardSkeleton), findsNothing);
    expect(find.byKey(const ValueKey('retry-pagination')), findsNothing);
    expect(find.textContaining('Сервис временно недоступен'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'back navigation retains the query, cards and exact scroll offset',
    (tester) async {
      await configurePhone(tester);
      final repository = FakeCharactersRepository(
        respond: (request) async => CharacterPage(
          characters: [
            for (var id = 1; id <= 20; id++) character(id, name: 'Rick $id'),
          ],
          totalCount: 20,
          nextPage: null,
        ),
      );
      await tester.pumpWidget(
        RickAndMortyApp(getCharacters: GetCharacters(repository)),
      );
      await tester.pumpAndSettle();
      await tester.enterText(
        find.byKey(const ValueKey('character-search')),
        'Rick',
      );
      await tester.pump(const Duration(milliseconds: 400));
      await tester.pumpAndSettle();
      final catalogue = find.byKey(const PageStorageKey('catalog-scroll'));
      await tester.drag(catalogue, const Offset(0, -700));
      await tester.pumpAndSettle();
      final before = tester
          .widget<CustomScrollView>(catalogue)
          .controller!
          .offset;
      final card = find.byType(CharacterCard).hitTestable().first;
      final selected = tester.widget<CharacterCard>(card).character;
      final requestCount = repository.requests.length;
      await tester.tap(card);
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('character-detail')), findsOneWidget);
      expect(
        tester.widget<Text>(find.byKey(const ValueKey('detail-name'))).data,
        selected.name,
      );
      expect(find.text('Earth (C-137)'), findsOneWidget);
      expect(find.text('Citadel of Ricks'), findsOneWidget);
      await tester.tap(find.byKey(const ValueKey('detail-back')));
      await tester.pumpAndSettle();
      expect(
        tester.widget<CustomScrollView>(catalogue).controller!.offset,
        before,
      );
      final search = tester.widget<TextField>(
        find.byKey(const ValueKey('character-search'), skipOffstage: false),
      );
      expect(search.controller!.text, 'Rick');
      expect(repository.requests.length, requestCount);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('empty search has a reset action that restores the catalogue', (
    tester,
  ) async {
    await configurePhone(tester);
    final repository = FakeCharactersRepository(
      respond: (request) async =>
          request.name.isNotEmpty ? CharacterPage.empty() : pageOf([1, 2]),
    );
    await tester.pumpWidget(
      RickAndMortyApp(getCharacters: GetCharacters(repository)),
    );
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const ValueKey('character-search')),
      'Nobody',
    );
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pumpAndSettle();
    expect(find.text('Никого не нашли'), findsOneWidget);
    await tester.ensureVisible(find.text('Сбросить поиск'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Сбросить поиск'));
    await tester.pumpAndSettle();
    expect(find.text('Никого не нашли'), findsNothing);
    expect(repository.requests.last.name, '');
    expect(
      tester.widget<TextField>(find.byType(TextField)).controller!.text,
      '',
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('initial network error can be retried from the screen', (
    tester,
  ) async {
    await configurePhone(tester);
    var attempts = 0;
    final repository = FakeCharactersRepository(
      respond: (_) async {
        if (attempts++ == 0) throw const AppFailure(FailureKind.connection);
        return pageOf([1, 2]);
      },
    );
    await tester.pumpWidget(
      RickAndMortyApp(getCharacters: GetCharacters(repository)),
    );
    await tester.pumpAndSettle();
    expect(find.textContaining('Проверьте интернет'), findsOneWidget);
    await tester.ensureVisible(find.text('Попробовать снова'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Попробовать снова'));
    await tester.pumpAndSettle();
    expect(find.text('Портал не открылся'), findsNothing);
    expect(find.byType(CharacterCard), findsWidgets);
    expect(attempts, 2);
    expect(tester.takeException(), isNull);
  });

  for (final size in [const Size(320, 640), const Size(1280, 800)]) {
    testWidgets('catalogue and details fit viewport $size', (tester) async {
      await tester.binding.setSurfaceSize(size);
      addTearDown(() => tester.binding.setSurfaceSize(null));
      final repository = FakeCharactersRepository(
        respond: (_) async => pageOf([1, 2, 3, 4]),
      );
      await tester.pumpWidget(
        RickAndMortyApp(getCharacters: GetCharacters(repository)),
      );
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(
        find.byKey(const ValueKey('character-1')),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byType(CharacterCard).hitTestable().first);
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('character-detail')), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('supports enlarged system text without overflowing', (
    tester,
  ) async {
    await configurePhone(tester);
    tester.platformDispatcher.textScaleFactorTestValue = 2;
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    final repository = FakeCharactersRepository(
      respond: (_) async => pageOf([1, 2]),
    );
    await tester.pumpWidget(
      RickAndMortyApp(getCharacters: GetCharacters(repository)),
    );
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.byKey(const ValueKey('character-1')),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byType(CharacterCard).hitTestable().first);
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('character-detail')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
