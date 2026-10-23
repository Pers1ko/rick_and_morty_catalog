import 'package:rick_and_morty_catalog/core/async/request_cancellation.dart';
import 'package:rick_and_morty_catalog/features/characters/domain/entities/character_page.dart';
import 'package:rick_and_morty_catalog/features/characters/domain/entities/character_query.dart';
import 'package:rick_and_morty_catalog/features/characters/domain/entities/character_status.dart';
import 'package:rick_and_morty_catalog/features/characters/domain/repositories/characters_repository.dart';

final class GetCharacters {
  const GetCharacters(this._repository);
  final CharactersRepository _repository;

  Future<CharacterPage> call({
    int page = 1,
    String name = '',
    CharacterStatus? status,
    RequestCancellation? cancellation,
  }) async {
    cancellation?.throwIfCancelled();
    return _repository.fetchCharacters(
      CharacterQuery(page: page, name: name, status: status),
      cancellation: cancellation,
    );
  }
}
