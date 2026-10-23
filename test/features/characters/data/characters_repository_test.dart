import 'package:flutter_test/flutter_test.dart';

import 'package:dio/dio.dart';
import 'package:rick_and_morty_catalog/core/async/request_cancellation.dart';
import 'package:rick_and_morty_catalog/core/async/request_cancelled.dart';
import 'package:rick_and_morty_catalog/core/error/app_failure.dart';
import 'package:rick_and_morty_catalog/core/network/api_client.dart';
import 'package:rick_and_morty_catalog/core/network/retry_policy.dart';
import 'package:rick_and_morty_catalog/features/characters/data/repositories/characters_repository_impl.dart';
import 'package:rick_and_morty_catalog/features/characters/data/services/characters_api_service.dart';
import 'package:rick_and_morty_catalog/features/characters/domain/entities/character_status.dart';
import 'package:rick_and_morty_catalog/features/characters/domain/usecases/get_characters.dart';

import '../../../support/fixtures.dart';
import '../../../support/stub_http_adapter.dart';

void main() {
  late Dio dio;
  late GetCharacters getCharacters;

  setUp(() {
    dio = Dio(BaseOptions(baseUrl: 'https://rickandmortyapi.com/api'));
    getCharacters = GetCharacters(
      CharactersRepositoryImpl(
        CharactersApiService(
          ApiClient(
            dio,
            retryPolicy: const RetryPolicy(baseDelay: Duration.zero),
          ),
        ),
      ),
    );
  });
  tearDown(() => dio.close(force: true));

  test('parses a page and safely encodes name and status parameters', () async {
    final adapter = StubAdapter(
      body: {
        'info': {
          'count': 2,
          'next': 'https://rickandmortyapi.com/api/character?page=3',
        },
        'results': [characterJson(1)],
      },
    );
    dio.httpClientAdapter = adapter;
    final page = await getCharacters(
      page: 2,
      name: '  Rick & Morty / Рик  ',
      status: CharacterStatus.alive,
    );
    expect(adapter.request!.uri.queryParameters['name'], 'Rick & Morty / Рик');
    expect(adapter.request!.uri.queryParameters['status'], 'alive');
    expect(adapter.request!.uri.queryParameters['page'], '2');
    expect(page.nextPage, 3);
    expect(page.totalCount, 2);
    expect(page.characters.single.origin, 'Earth (C-137)');
    expect(page.characters.single.location, 'Citadel of Ricks');
  });

  test('treats the API no-match 404 as an empty result', () async {
    dio.httpClientAdapter = StubAdapter(
      code: 404,
      body: {'error': 'There is nothing here'},
    );
    final result = await getCharacters(name: 'no-such-character');
    expect(result.characters, isEmpty);
    expect(result.totalCount, 0);
    expect(result.nextPage, isNull);
  });

  test('does not hide arbitrary HTTP errors as empty results', () async {
    for (final code in [404, 429, 500]) {
      dio.httpClientAdapter = StubAdapter(
        code: code,
        body: {'error': 'Unavailable'},
      );
      await expectLater(getCharacters(), throwsA(isA<AppFailure>()));
    }
  });

  test(
    'retries a temporary HTTP failure and returns the recovered page',
    () async {
      for (final code in [429, 503]) {
        final adapter = StubAdapter(
          code: code,
          recoverAfter: 1,
          body: {
            'info': {'count': 1, 'next': null},
            'results': [characterJson(1)],
          },
        );
        dio.httpClientAdapter = adapter;
        final result = await getCharacters(page: 2);
        expect(result.characters.single.id, 1);
        expect(adapter.calls, 2);
        expect(adapter.request!.queryParameters['page'], 2);
      }
    },
  );

  test('stops after three attempts for a persistent service failure', () async {
    final adapter = StubAdapter(code: 503, body: {'error': 'Unavailable'});
    dio.httpClientAdapter = adapter;
    await expectLater(getCharacters(), throwsA(isA<AppFailure>()));
    expect(adapter.calls, 3);
  });

  test(
    'cancels during retry backoff without issuing another request',
    () async {
      getCharacters = GetCharacters(
        CharactersRepositoryImpl(
          CharactersApiService(
            ApiClient(
              dio,
              retryPolicy: const RetryPolicy(baseDelay: Duration(seconds: 1)),
            ),
          ),
        ),
      );
      final adapter = StubAdapter(code: 503, body: {'error': 'Unavailable'});
      dio.httpClientAdapter = adapter;
      final token = RequestCancellation();
      final request = getCharacters(cancellation: token);
      final expectation = expectLater(
        request,
        throwsA(isA<RequestCancelled>()),
      );
      await Future<void>.delayed(const Duration(milliseconds: 20));
      token.cancel();
      await expectation;
      expect(adapter.calls, 1);
    },
  );

  test('reports malformed payloads as recoverable failures', () async {
    dio.httpClientAdapter = StubAdapter(body: {'results': []});
    await expectLater(getCharacters(), throwsA(isA<AppFailure>()));
  });

  test('does not turn request cancellation into a network failure', () async {
    final token = RequestCancellation()..cancel();
    await expectLater(
      getCharacters(cancellation: token),
      throwsA(isA<RequestCancelled>()),
    );
  });

  test('maps request timeouts to a readable message', () async {
    dio.httpClientAdapter = StubAdapter(
      failure: DioExceptionType.receiveTimeout,
    );
    await expectLater(
      getCharacters(),
      throwsA(
        isA<AppFailure>().having(
          (error) => error.kind,
          'kind',
          FailureKind.timeout,
        ),
      ),
    );
  });
}
