import 'package:flutter/material.dart';

import 'package:rick_and_morty_catalog/core/theme/app_colors.dart';
import 'package:rick_and_morty_catalog/features/characters/domain/entities/character_status.dart';
import 'package:rick_and_morty_catalog/features/characters/presentation/catalog/cubit/catalog_state.dart';
import 'package:rick_and_morty_catalog/features/characters/presentation/catalog/widgets/catalog_results_summary.dart';
import 'package:rick_and_morty_catalog/features/characters/presentation/catalog/widgets/character_search_field.dart';
import 'package:rick_and_morty_catalog/features/characters/presentation/catalog/widgets/character_status_filters.dart';

class CatalogHeader extends StatelessWidget {
  const CatalogHeader({
    super.key,
    required this.controller,
    required this.state,
    required this.onQueryChanged,
    required this.onClearQuery,
    required this.onFilterChanged,
  });

  final TextEditingController controller;
  final CatalogState state;
  final ValueChanged<String> onQueryChanged;
  final VoidCallback onClearQuery;
  final ValueChanged<CharacterStatus?> onFilterChanged;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text(
        'ПУТЕВОДИТЕЛЬ ПО МУЛЬТИВСЕЛЕННОЙ',
        style: TextStyle(
          color: AppColors.accent,
          fontSize: 10,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.5,
        ),
      ),
      const SizedBox(height: 14),
      Text(
        'Знакомые лица.\nДругие измерения.',
        style: Theme.of(context).textTheme.displaySmall,
      ),
      const SizedBox(height: 24),
      CharacterSearchField(
        controller: controller,
        onChanged: onQueryChanged,
        onClear: onClearQuery,
      ),
      const SizedBox(height: 14),
      CharacterStatusFilters(
        selectedStatus: state.statusFilter,
        onChanged: onFilterChanged,
      ),
      const SizedBox(height: 24),
      CatalogResultsSummary(state: state),
    ],
  );
}
