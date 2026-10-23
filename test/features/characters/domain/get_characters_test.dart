import 'package:flutter_test/flutter_test.dart';
import 'package:rick_and_morty_catalog/core/async/request_cancellation.dart';
import 'package:rick_and_morty_catalog/core/async/request_cancelled.dart';
import 'package:rick_and_morty_catalog/features/characters/domain/entities/character_status.dart';
import 'package:rick_and_morty_catalog/features/characters/domain/usecases/get_characters.dart';

import '../../../support/fixtures.dart';

void main() {
  test(
    'normalizes search and forwards criteria and cancellation through the contract',
    () async {
      final repository = FakeCharactersRepository(
        respond: (_) async => pageOf([1]),
      );
      final cancellation = RequestCancellation();
      final result = await GetCharacters(repository)(
        page: 3,
        name: '  Rick  ',
        status: CharacterStatus.alive,
        cancellation: cancellation,
      );
      final request = repository.requests.single;
      expect(request.page, 3);
      expect(request.name, 'Rick');
      expect(request.status, CharacterStatus.alive);
      expect(request.cancellation, same(cancellation));
      expect(result.characters.single.id, 1);
    },
  );

  test('rejects invalid pages before reaching the repository', () async {
    final repository = FakeCharactersRepository();
    await expectLater(GetCharacters(repository)(page: 0), throwsArgumentError);
    expect(repository.requests, isEmpty);
  });

  test('an already cancelled operation never reaches the repository', () async {
    final repository = FakeCharactersRepository();
    final cancellation = RequestCancellation()..cancel();
    await expectLater(
      GetCharacters(repository)(cancellation: cancellation),
      throwsA(isA<RequestCancelled>()),
    );
    expect(repository.requests, isEmpty);
  });
}
