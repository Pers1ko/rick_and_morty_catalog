import 'package:rick_and_morty_catalog/features/characters/domain/entities/character.dart';
import 'package:rick_and_morty_catalog/features/characters/domain/entities/character_page.dart';

/// Merge policy is independent of widget state and HTTP response formats.
abstract final class CharacterPagination {
  static CharacterPage merge({
    required CharacterPage current,
    required CharacterPage incoming,
    required int requestedPage,
  }) {
    final byId = <int, Character>{
      for (final character in current.characters) character.id: character,
      for (final character in incoming.characters) character.id: character,
    };
    final next = incoming.nextPage;
    return CharacterPage(
      characters: byId.values.toList(),
      totalCount: incoming.characters.isEmpty
          ? current.totalCount
          : incoming.totalCount,
      nextPage:
          incoming.characters.isEmpty || next == null || next <= requestedPage
          ? null
          : next,
    );
  }
}
