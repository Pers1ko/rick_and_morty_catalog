import 'package:flutter/material.dart';

import 'package:rick_and_morty_catalog/core/theme/app_colors.dart';
import 'package:rick_and_morty_catalog/features/characters/domain/entities/character.dart';
import 'package:rick_and_morty_catalog/features/characters/presentation/shared/formatters/character_formatters.dart';
import 'package:rick_and_morty_catalog/features/characters/presentation/shared/widgets/character_image.dart';
import 'package:rick_and_morty_catalog/features/characters/presentation/shared/widgets/status_badge.dart';

class CharacterCard extends StatelessWidget {
  const CharacterCard({
    super.key,
    required this.character,
    required this.imageHeight,
    required this.onTap,
  });

  final Character character;
  final double imageHeight;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scale = MediaQuery.textScalerOf(context).scale(1);
    return Semantics(
      button: true,
      label:
          '${character.name}, ${character.status.label}, ${character.species}',
      onTap: onTap,
      child: ExcludeSemantics(
        child: Material(
          color: AppColors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
            side: const BorderSide(color: AppColors.outline),
          ),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onTap,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: imageHeight,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Hero(
                        tag: 'character-image-${character.id}',
                        child: CharacterImage(url: character.imageUrl),
                      ),
                      Positioned(
                        left: 10,
                        top: 10,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            color: AppColors.background.withValues(alpha: 0.82),
                            borderRadius: BorderRadius.circular(7),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 7,
                              vertical: 4,
                            ),
                            child: Text(
                              '#${character.id.toString().padLeft(3, '0')}',
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: AppColors.text,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(13),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: 38 * scale,
                        child: Text(
                          character.name,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 15,
                            height: 1.23,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const SizedBox(height: 5),
                      StatusBadge(status: character.status),
                      const SizedBox(height: 4),
                      Text(
                        readableValue(character.species),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.secondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
