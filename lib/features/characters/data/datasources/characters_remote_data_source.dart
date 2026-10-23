import 'package:rick_and_morty_catalog/core/async/request_cancellation.dart';
import 'package:rick_and_morty_catalog/features/characters/data/models/character_page_dto.dart';
import 'package:rick_and_morty_catalog/features/characters/domain/entities/character_query.dart';

abstract interface class CharactersRemoteDataSource {
  Future<CharacterPageDto> fetchCharacters(
    CharacterQuery query, {
    RequestCancellation? cancellation,
  });
}
