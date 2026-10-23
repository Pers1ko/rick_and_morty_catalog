import 'package:rick_and_morty_catalog/core/async/request_cancellation.dart';
import 'package:rick_and_morty_catalog/features/characters/domain/entities/character_page.dart';
import 'package:rick_and_morty_catalog/features/characters/domain/entities/character_query.dart';

abstract interface class CharactersRepository {
  Future<CharacterPage> fetchCharacters(
    CharacterQuery query, {
    RequestCancellation? cancellation,
  });
}
