import 'package:flutter_test/flutter_test.dart';
import 'package:rick_and_morty_catalog/features/characters/domain/entities/character_page.dart';
import 'package:rick_and_morty_catalog/features/characters/domain/services/character_pagination.dart';

import '../../../support/fixtures.dart';

void main() {
  test('merges in order, updates duplicates and keeps the next cursor', () {
    final result = CharacterPagination.merge(
      current: pageOf([1, 2], nextPage: 2),
      incoming: pageOf([2, 3], nextPage: 3, name: 'Updated'),
      requestedPage: 2,
    );
    expect(result.characters.map((item) => item.id), [1, 2, 3]);
    expect(result.characters[1].name, 'Updated');
    expect(result.nextPage, 3);
    expect(() => result.characters.clear(), throwsUnsupportedError);
  });

  test(
    'empty beyond-end result preserves cards and total without another cursor',
    () {
      final result = CharacterPagination.merge(
        current: pageOf([1, 2], nextPage: 2),
        incoming: CharacterPage.empty(),
        requestedPage: 2,
      );
      expect(result.characters.length, 2);
      expect(result.totalCount, 40);
      expect(result.nextPage, isNull);
    },
  );

  test('non-advancing cursors cannot create an infinite pagination loop', () {
    for (final next in [1, 2]) {
      final result = CharacterPagination.merge(
        current: pageOf([1], nextPage: 2),
        incoming: pageOf([2], nextPage: next),
        requestedPage: 2,
      );
      expect(result.nextPage, isNull);
    }
  });
}
