import 'package:flutter/material.dart';

import 'package:rick_and_morty_catalog/core/theme/app_colors.dart';
import 'package:rick_and_morty_catalog/features/characters/domain/entities/character.dart';
import 'package:rick_and_morty_catalog/features/characters/presentation/details/widgets/character_info_row.dart';
import 'package:rick_and_morty_catalog/features/characters/presentation/shared/formatters/character_formatters.dart';
import 'package:rick_and_morty_catalog/features/characters/presentation/shared/widgets/status_badge.dart';

class CharacterDetails extends StatelessWidget {
  const CharacterDetails({super.key, required this.character});

  final Character character;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        'ПЕРСОНАЖ #${character.id.toString().padLeft(3, '0')}',
        style: const TextStyle(
          fontSize: 10,
          color: AppColors.accent,
          letterSpacing: 1.7,
          fontWeight: FontWeight.w700,
        ),
      ),
      const SizedBox(height: 10),
      Text(
        character.name,
        key: const ValueKey('detail-name'),
        style: Theme.of(context).textTheme.headlineMedium,
      ),
      const SizedBox(height: 16),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: character.status.color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: character.status.color.withValues(alpha: 0.25),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Статус: ',
              style: TextStyle(fontSize: 12, color: AppColors.secondary),
            ),
            Flexible(child: StatusBadge(status: character.status)),
          ],
        ),
      ),
      const SizedBox(height: 28),
      const Text(
        'О персонаже',
        style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
      ),
      const SizedBox(height: 12),
      DecoratedBox(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.outline),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18),
          child: Column(
            children: [
              CharacterInfoRow(
                icon: Icons.category_outlined,
                label: 'Вид',
                value: readableValue(character.species),
              ),
              const Divider(height: 1),
              CharacterInfoRow(
                icon: Icons.public_rounded,
                label: 'Происхождение',
                value: readableValue(character.origin),
              ),
              const Divider(height: 1),
              CharacterInfoRow(
                icon: Icons.location_on_outlined,
                label: 'Текущая локация',
                value: readableValue(character.location),
              ),
              const Divider(height: 1),
              CharacterInfoRow(
                icon: Icons.person_outline_rounded,
                label: 'Пол',
                value: switch (character.gender.toLowerCase()) {
                  'male' => 'Мужской',
                  'female' => 'Женский',
                  'genderless' => 'Бесполый',
                  _ => readableValue(character.gender),
                },
              ),
              const Divider(height: 1),
              CharacterInfoRow(
                icon: Icons.movie_outlined,
                label: 'Появлений в эпизодах',
                value: '${character.episodeCount}',
              ),
            ],
          ),
        ),
      ),
    ],
  );
}
