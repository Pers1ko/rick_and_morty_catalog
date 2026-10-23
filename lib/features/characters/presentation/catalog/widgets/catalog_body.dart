import 'package:flutter/material.dart';

import 'package:rick_and_morty_catalog/features/characters/domain/entities/character.dart';
import 'package:rick_and_morty_catalog/features/characters/presentation/catalog/cubit/catalog_state.dart';
import 'package:rick_and_morty_catalog/features/characters/presentation/catalog/models/catalog_grid_layout.dart';
import 'package:rick_and_morty_catalog/features/characters/presentation/catalog/widgets/character_grid.dart';
import 'package:rick_and_morty_catalog/features/characters/presentation/catalog/widgets/character_skeleton_grid.dart';
import 'package:rick_and_morty_catalog/features/characters/presentation/catalog/widgets/pagination_retry.dart';
import 'package:rick_and_morty_catalog/features/characters/presentation/shared/widgets/catalog_feedback.dart';

/// Renders state only; feature actions and controller ownership stay in the page.
class CatalogBody extends StatelessWidget {
  const CatalogBody({
    super.key,
    required this.state,
    required this.layout,
    required this.onRetry,
    required this.onReset,
    required this.onRetryPagination,
    required this.onCharacterTap,
  });
  final CatalogState state;
  final CatalogGridLayout layout;
  final VoidCallback onRetry;
  final VoidCallback onReset;
  final VoidCallback onRetryPagination;
  final ValueChanged<Character> onCharacterTap;

  @override
  Widget build(BuildContext context) {
    if (state.phase == CatalogPhase.loading) {
      return CharacterSkeletonGrid(layout: layout, rows: 3);
    }
    if (state.phase == CatalogPhase.failure) {
      return SliverFillRemaining(
        hasScrollBody: false,
        child: CatalogFeedback(
          icon: Icons.wifi_off_rounded,
          title: 'Портал не открылся',
          message: state.errorMessage!,
          buttonLabel: 'Попробовать снова',
          onPressed: onRetry,
        ),
      );
    }
    if (state.characters.isEmpty) {
      return SliverFillRemaining(
        hasScrollBody: false,
        child: CatalogFeedback(
          icon: Icons.search_off_rounded,
          title: 'Никого не нашли',
          message: 'Попробуйте другое имя или измените фильтр статуса.',
          buttonLabel: 'Сбросить поиск',
          onPressed: onReset,
        ),
      );
    }
    return SliverMainAxisGroup(
      slivers: [
        CharacterGrid(
          characters: state.characters,
          layout: layout,
          onCharacterTap: onCharacterTap,
        ),
        if (state.isLoadingMore) CharacterSkeletonGrid(layout: layout, rows: 1),
        if (state.paginationError != null)
          PaginationRetry(onRetry: onRetryPagination),
        const SliverToBoxAdapter(child: SizedBox(height: 28)),
      ],
    );
  }
}
