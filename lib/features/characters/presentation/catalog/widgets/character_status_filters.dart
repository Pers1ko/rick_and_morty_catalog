import 'package:flutter/material.dart';

import 'package:rick_and_morty_catalog/core/theme/app_colors.dart';
import 'package:rick_and_morty_catalog/features/characters/domain/entities/character_status.dart';

class CharacterStatusFilters extends StatelessWidget {
  const CharacterStatusFilters({
    super.key,
    required this.selectedStatus,
    required this.onChanged,
  });
  final CharacterStatus? selectedStatus;
  final ValueChanged<CharacterStatus?> onChanged;

  @override
  Widget build(BuildContext context) => Wrap(
    spacing: 8,
    runSpacing: 8,
    children: [
      _filter(label: 'Все', status: null),
      _filter(label: 'Живые', status: CharacterStatus.alive),
      _filter(label: 'Мёртвые', status: CharacterStatus.dead),
      _filter(label: 'Неизвестно', status: CharacterStatus.unknown),
    ],
  );
  Widget _filter({required String label, required CharacterStatus? status}) {
    final selected = selectedStatus == status;
    return ChoiceChip(
      key: ValueKey('filter-${status?.name ?? 'all'}'),
      label: Text(label),
      selected: selected,
      onSelected: (_) => onChanged(status),
      showCheckmark: false,
      selectedColor: AppColors.accent,
      backgroundColor: AppColors.background,
      side: BorderSide(color: selected ? AppColors.accent : AppColors.outline),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(11)),
      labelStyle: TextStyle(
        color: selected ? AppColors.background : AppColors.secondary,
        fontSize: 12,
        fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
    );
  }
}
