import 'package:flutter/material.dart';

import 'package:rick_and_morty_catalog/core/presentation/widgets/skeleton.dart';
import 'package:rick_and_morty_catalog/core/theme/app_colors.dart';

class CharacterCardSkeleton extends StatelessWidget {
  const CharacterCardSkeleton({super.key, required this.imageHeight});

  final double imageHeight;

  @override
  Widget build(BuildContext context) => Semantics(
    label: 'Загрузка персонажа',
    child: ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: ColoredBox(
        color: AppColors.surface,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Skeleton(height: imageHeight, radius: 0),
            const Padding(
              padding: EdgeInsets.all(13),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FractionallySizedBox(
                    widthFactor: .85,
                    child: Skeleton(height: 16),
                  ),
                  SizedBox(height: 12),
                  Skeleton(width: 64, height: 12),
                  SizedBox(height: 10),
                  Skeleton(width: 42, height: 10),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
