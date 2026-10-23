import 'package:dio/dio.dart';
import 'package:rick_and_morty_catalog/app/config/app_config.dart';
import 'package:rick_and_morty_catalog/core/network/api_client.dart';
import 'package:rick_and_morty_catalog/features/characters/data/repositories/characters_repository_impl.dart';
import 'package:rick_and_morty_catalog/features/characters/data/services/characters_api_service.dart';
import 'package:rick_and_morty_catalog/features/characters/domain/usecases/get_characters.dart';

/// Composition root: dependencies are explicit, scoped and disposed by bootstrap.
/// No service locator or feature-level global state.
final class AppDependencies {
  AppDependencies._(this._dio, this.getCharacters);

  factory AppDependencies.create({AppConfig config = const AppConfig()}) {
    final dio = Dio(
      BaseOptions(
        baseUrl: config.apiBaseUrl,
        connectTimeout: config.connectTimeout,
        receiveTimeout: config.receiveTimeout,
        headers: {'Accept': 'application/json'},
      ),
    );
    final client = ApiClient(dio);
    final remote = CharactersApiService(client);
    final repository = CharactersRepositoryImpl(remote);
    return AppDependencies._(dio, GetCharacters(repository));
  }
  final Dio _dio;
  final GetCharacters getCharacters;

  void dispose() => _dio.close(force: true);
}
