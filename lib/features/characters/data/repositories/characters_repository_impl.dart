import 'package:rick_and_morty_catalog/core/async/request_cancellation.dart';
import 'package:rick_and_morty_catalog/core/error/app_failure.dart';
import 'package:rick_and_morty_catalog/core/network/api_exception.dart';
import 'package:rick_and_morty_catalog/features/characters/data/datasources/characters_remote_data_source.dart';
import 'package:rick_and_morty_catalog/features/characters/data/mappers/character_mapper.dart';
import 'package:rick_and_morty_catalog/features/characters/domain/entities/character_page.dart';
import 'package:rick_and_morty_catalog/features/characters/domain/entities/character_query.dart';
import 'package:rick_and_morty_catalog/features/characters/domain/repositories/characters_repository.dart';

final class CharactersRepositoryImpl implements CharactersRepository {
  const CharactersRepositoryImpl(this._remote);
  final CharactersRemoteDataSource _remote;

  @override
  Future<CharacterPage> fetchCharacters(
    CharacterQuery query, {
    RequestCancellation? cancellation,
  }) async {
    try {
      final dto = await _remote.fetchCharacters(
        query,
        cancellation: cancellation,
      );
      return dto.toDomain();
    } on ApiException catch (error, stack) {
      Error.throwWithStackTrace(AppFailure(error.kind), stack);
    } on FormatException catch (_, stack) {
      Error.throwWithStackTrace(
        const AppFailure(FailureKind.invalidData),
        stack,
      );
    } on TypeError catch (_, stack) {
      Error.throwWithStackTrace(
        const AppFailure(FailureKind.invalidData),
        stack,
      );
    }
  }
}
