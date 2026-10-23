import 'dart:async';

import 'package:rick_and_morty_catalog/core/async/request_cancellation.dart';
import 'package:rick_and_morty_catalog/features/characters/domain/entities/character.dart';
import 'package:rick_and_morty_catalog/features/characters/domain/entities/character_page.dart';
import 'package:rick_and_morty_catalog/features/characters/domain/entities/character_query.dart';
import 'package:rick_and_morty_catalog/features/characters/domain/entities/character_status.dart';
import 'package:rick_and_morty_catalog/features/characters/domain/repositories/characters_repository.dart';

Map<String, dynamic> characterJson(int id, {String? name}) => {
  'id': id,
  'name': name ?? 'Character $id',
  'status': 'Alive',
  'species': 'Human',
  'origin': {'name': 'Earth (C-137)', 'url': ''},
  'location': {'name': 'Citadel of Ricks', 'url': ''},
  'image': 'https://example.test/characters/$id.png',
  'gender': 'Male',
  'episode': ['https://rickandmortyapi.com/api/episode/1'],
};

Character character(int id, {String? name}) => Character(
  id: id,
  name: name ?? 'Character $id',
  status: CharacterStatus.alive,
  species: 'Human',
  origin: 'Earth (C-137)',
  location: 'Citadel of Ricks',
  imageUrl: 'https://example.test/characters/$id.png',
  gender: 'Male',
  episodeCount: 1,
);

CharacterPage pageOf(List<int> ids, {int? nextPage, String? name}) =>
    CharacterPage(
      characters: [for (final id in ids) character(id, name: name)],
      totalCount: nextPage == null ? ids.length : 40,
      nextPage: nextPage,
    );

class PendingRequest {
  PendingRequest({
    required this.page,
    required this.name,
    required this.status,
    required this.cancellation,
  });

  final int page;
  final String name;
  final CharacterStatus? status;
  final RequestCancellation? cancellation;
  final completer = Completer<CharacterPage>();
}

/// Intentionally ignores cancellation: stale-response tests must also pass when
/// the transport has already completed and cancellation cannot stop a response.
class FakeCharactersRepository implements CharactersRepository {
  FakeCharactersRepository({this.respond});

  final Future<CharacterPage> Function(PendingRequest)? respond;
  final requests = <PendingRequest>[];

  @override
  Future<CharacterPage> fetchCharacters(
    CharacterQuery query, {
    RequestCancellation? cancellation,
  }) {
    final request = PendingRequest(
      page: query.page,
      name: query.name,
      status: query.status,
      cancellation: cancellation,
    );
    requests.add(request);
    return respond?.call(request) ?? request.completer.future;
  }
}
