import 'package:rick_and_morty_catalog/features/characters/domain/entities/character.dart';

class CharacterPage {
  CharacterPage({
    required List<Character> characters,
    required this.totalCount,
    required this.nextPage,
  }) : characters = List.unmodifiable(characters);

  CharacterPage.empty()
    : characters = const [],
      totalCount = 0,
      nextPage = null;

  final List<Character> characters;
  final int totalCount;
  final int? nextPage;
}
