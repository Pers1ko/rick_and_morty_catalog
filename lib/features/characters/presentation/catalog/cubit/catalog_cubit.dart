import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:rick_and_morty_catalog/core/async/request_cancellation.dart';
import 'package:rick_and_morty_catalog/core/async/request_cancelled.dart';
import 'package:rick_and_morty_catalog/core/presentation/formatters/failure_message.dart';
import 'package:rick_and_morty_catalog/features/characters/domain/entities/character_page.dart';
import 'package:rick_and_morty_catalog/features/characters/domain/entities/character_status.dart';
import 'package:rick_and_morty_catalog/features/characters/domain/services/character_pagination.dart';
import 'package:rick_and_morty_catalog/features/characters/domain/usecases/get_characters.dart';
import 'package:rick_and_morty_catalog/features/characters/presentation/catalog/cubit/catalog_state.dart';

class CatalogCubit extends Cubit<CatalogState> {
  CatalogCubit(
    this._getCharacters, {
    this.debounceDuration = const Duration(milliseconds: 350),
  }) : super(CatalogState());

  final GetCharacters _getCharacters;
  final Duration debounceDuration;
  Timer? _debounce;
  RequestCancellation? _requestToken;
  int _generation = 0;

  Future<void> loadInitial() =>
      _replaceCriteria(query: state.query, status: state.statusFilter);

  void setQuery(String value) {
    final query = value.trim();
    if (query == state.query || isClosed) return;
    unawaited(
      _replaceCriteria(
        query: query,
        status: state.statusFilter,
        debounce: query.isNotEmpty,
      ),
    );
  }

  void setStatusFilter(CharacterStatus? status) {
    if (status == state.statusFilter || isClosed) return;
    unawaited(_replaceCriteria(query: state.query, status: status));
  }

  Future<void> resetFilters() => _replaceCriteria(query: '', status: null);

  Future<void> retry() => loadInitial();

  Future<void> _replaceCriteria({
    required String query,
    required CharacterStatus? status,
    bool debounce = false,
  }) async {
    if (isClosed) return;
    _debounce?.cancel();
    _requestToken?.cancel('Search criteria changed');
    final generation = ++_generation;
    emit(CatalogState(query: query, statusFilter: status));
    if (debounce) {
      _debounce = Timer(debounceDuration, () {
        _debounce = null;
        unawaited(_loadFirstPage(generation));
      });
    } else {
      await _loadFirstPage(generation);
    }
  }

  bool _isCurrent(int generation) => !isClosed && generation == _generation;

  Future<void> _loadFirstPage(int generation) async {
    if (!_isCurrent(generation)) return;
    final token = RequestCancellation();
    _requestToken = token;
    try {
      final page = await _getCharacters(
        name: state.query,
        status: state.statusFilter,
        cancellation: token,
      );
      if (!_isCurrent(generation)) return;
      emit(
        state.copyWith(
          phase: CatalogPhase.ready,
          characters: page.characters,
          totalCount: page.totalCount,
          nextPage: page.nextPage,
          clearNextPage: page.nextPage == null,
          clearError: true,
        ),
      );
    } catch (error) {
      if (!_isCurrent(generation) || _isCancellation(error)) return;
      emit(
        state.copyWith(
          phase: CatalogPhase.failure,
          errorMessage: _messageFor(error),
        ),
      );
    } finally {
      if (identical(_requestToken, token)) _requestToken = null;
    }
  }

  Future<void> loadNextPage() async {
    if (isClosed ||
        state.phase != CatalogPhase.ready ||
        state.isLoadingMore ||
        state.nextPage == null ||
        state.paginationError != null) {
      return;
    }
    final generation = _generation;
    final nextPage = state.nextPage!;
    final token = RequestCancellation();
    _requestToken = token;
    emit(state.copyWith(isLoadingMore: true, clearPaginationError: true));
    try {
      final page = await _getCharacters(
        page: nextPage,
        name: state.query,
        status: state.statusFilter,
        cancellation: token,
      );
      if (!_isCurrent(generation)) return;
      final merged = CharacterPagination.merge(
        current: CharacterPage(
          characters: state.characters,
          totalCount: state.totalCount,
          nextPage: state.nextPage,
        ),
        incoming: page,
        requestedPage: nextPage,
      );
      emit(
        state.copyWith(
          characters: merged.characters,
          totalCount: merged.totalCount,
          nextPage: merged.nextPage,
          clearNextPage: merged.nextPage == null,
          isLoadingMore: false,
          clearPaginationError: true,
        ),
      );
    } catch (error) {
      if (!_isCurrent(generation) || _isCancellation(error)) return;
      emit(
        state.copyWith(
          isLoadingMore: false,
          paginationError: _messageFor(error),
        ),
      );
    } finally {
      if (identical(_requestToken, token)) _requestToken = null;
    }
  }

  Future<void> retryNextPage() async {
    if (isClosed || state.paginationError == null) return;
    emit(state.copyWith(clearPaginationError: true));
    await loadNextPage();
  }

  bool _isCancellation(Object error) => error is RequestCancelled;

  String _messageFor(Object error) => FailureMessage.forError(error);

  @override
  Future<void> close() {
    _generation++;
    _debounce?.cancel();
    _requestToken?.cancel('Catalogue closed');
    return super.close();
  }
}
