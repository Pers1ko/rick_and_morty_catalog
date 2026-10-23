import 'package:rick_and_morty_catalog/features/characters/domain/entities/character_status.dart';

import 'package:rick_and_morty_catalog/core/async/request_cancellation.dart';
import 'package:rick_and_morty_catalog/core/network/api_client.dart';
import 'package:rick_and_morty_catalog/core/network/api_exception.dart';
import 'package:rick_and_morty_catalog/features/characters/data/datasources/characters_remote_data_source.dart';
import 'package:rick_and_morty_catalog/features/characters/data/models/character_page_dto.dart';
import 'package:rick_and_morty_catalog/features/characters/domain/entities/character_query.dart';

/// Endpoint paths, request parameters and API-specific empty-result semantics.
final class CharactersApiService implements CharactersRemoteDataSource {
  const CharactersApiService(this._client);
  final ApiClient _client;

  @override
  Future<CharacterPageDto> fetchCharacters(
    CharacterQuery query, {
    RequestCancellation? cancellation,
  }) async {
    try {
      final body = await _client.getJson(
        '/character',
        queryParameters: {
          'page': query.page,
          if (query.name.isNotEmpty) 'name': query.name,
          if (query.status != null)
            'status': switch (query.status!) {
              CharacterStatus.alive => 'alive',
              CharacterStatus.dead => 'dead',
              CharacterStatus.unknown => 'unknown',
            },
        },
        cancellation: cancellation,
      );
      return CharacterPageDto.fromJson(body);
    } on ApiException catch (error) {
      if (error.statusCode == 404 &&
          error.body is Map &&
          (error.body as Map)['error'] == 'There is nothing here') {
        return CharacterPageDto.empty();
      }
      rethrow;
    }
  }
}
