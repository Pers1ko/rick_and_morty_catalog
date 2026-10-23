import 'package:flutter_test/flutter_test.dart';
import 'package:rick_and_morty_catalog/core/async/request_cancellation.dart';
import 'package:rick_and_morty_catalog/core/async/request_cancelled.dart';
import 'package:rick_and_morty_catalog/core/error/app_failure.dart';
import 'package:rick_and_morty_catalog/core/network/api_exception.dart';
import 'package:rick_and_morty_catalog/features/characters/data/datasources/characters_remote_data_source.dart';
import 'package:rick_and_morty_catalog/features/characters/data/models/character_page_dto.dart';
import 'package:rick_and_morty_catalog/features/characters/data/repositories/characters_repository_impl.dart';
import 'package:rick_and_morty_catalog/features/characters/domain/entities/character_query.dart';

final class FailingRemote implements CharactersRemoteDataSource {
  FailingRemote(this.failure);
  final Object failure;
  @override
  Future<CharacterPageDto> fetchCharacters(
    CharacterQuery query, {
    RequestCancellation? cancellation,
  }) async => throw failure;
}

void main() {
  test(
    'repository exposes a stable failure instead of an HTTP exception',
    () async {
      final repository = CharactersRepositoryImpl(
        FailingRemote(
          const ApiException(kind: FailureKind.rateLimit, statusCode: 429),
        ),
      );
      await expectLater(
        repository.fetchCharacters(CharacterQuery()),
        throwsA(
          isA<AppFailure>().having(
            (failure) => failure.kind,
            'kind',
            FailureKind.rateLimit,
          ),
        ),
      );
    },
  );

  test('malformed payloads become invalidData failures', () async {
    final repository = CharactersRepositoryImpl(
      FailingRemote(const FormatException('Broken JSON')),
    );
    await expectLater(
      repository.fetchCharacters(CharacterQuery()),
      throwsA(
        isA<AppFailure>().having(
          (failure) => failure.kind,
          'kind',
          FailureKind.invalidData,
        ),
      ),
    );
  });

  test(
    'cancellation passes through without becoming a user-facing failure',
    () async {
      const cancellation = RequestCancelled();
      final repository = CharactersRepositoryImpl(FailingRemote(cancellation));
      await expectLater(
        repository.fetchCharacters(CharacterQuery()),
        throwsA(same(cancellation)),
      );
    },
  );
}
