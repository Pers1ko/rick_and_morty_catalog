import 'package:flutter/material.dart';

import 'package:rick_and_morty_catalog/core/presentation/widgets/skeleton.dart';
import 'package:rick_and_morty_catalog/core/theme/app_colors.dart';
import 'package:rick_and_morty_catalog/features/characters/presentation/catalog/cubit/catalog_state.dart';

class CatalogResultsSummary extends StatelessWidget {
  const CatalogResultsSummary({super.key, required this.state});
  final CatalogState state;
  @override
  Widget build(BuildContext context) => Wrap(
    spacing: 12,
    runSpacing: 6,
    crossAxisAlignment: WrapCrossAlignment.center,
    children: [
      Text(
        state.query.isEmpty && state.statusFilter == null
            ? 'Все персонажи'
            : 'Результаты поиска',
        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 17),
      ),
      if (state.phase == CatalogPhase.loading)
        const Skeleton(width: 86, height: 14)
      else if (state.phase == CatalogPhase.ready)
        Text(
          'Найдено: ${state.totalCount}',
          style: const TextStyle(color: AppColors.secondary, fontSize: 12),
        ),
    ],
  );
}
