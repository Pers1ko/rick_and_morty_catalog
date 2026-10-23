import 'package:rick_and_morty_catalog/features/characters/domain/entities/character.dart';
import 'package:rick_and_morty_catalog/features/characters/domain/entities/character_status.dart';

enum CatalogPhase { loading, ready, failure }

class CatalogState {
  CatalogState({
    this.phase = CatalogPhase.loading,
    this.query = '',
    this.statusFilter,
    List<Character> characters = const [],
    this.totalCount = 0,
    this.nextPage,
    this.isLoadingMore = false,
    this.errorMessage,
    this.paginationError,
  }) : characters = List.unmodifiable(characters);

  final CatalogPhase phase;
  final String query;
  final CharacterStatus? statusFilter;
  final List<Character> characters;
  final int totalCount;
  final int? nextPage;
  final bool isLoadingMore;
  final String? errorMessage;
  final String? paginationError;

  CatalogState copyWith({
    CatalogPhase? phase,
    List<Character>? characters,
    int? totalCount,
    int? nextPage,
    bool clearNextPage = false,
    bool? isLoadingMore,
    String? errorMessage,
    bool clearError = false,
    String? paginationError,
    bool clearPaginationError = false,
  }) => CatalogState(
    phase: phase ?? this.phase,
    query: query,
    statusFilter: statusFilter,
    characters: characters ?? this.characters,
    totalCount: totalCount ?? this.totalCount,
    nextPage: clearNextPage ? null : nextPage ?? this.nextPage,
    isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    paginationError: clearPaginationError
        ? null
        : paginationError ?? this.paginationError,
  );
}
