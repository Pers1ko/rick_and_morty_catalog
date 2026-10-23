import 'package:flutter/material.dart';

import 'package:rick_and_morty_catalog/features/characters/presentation/catalog/models/catalog_grid_layout.dart';
import 'package:rick_and_morty_catalog/features/characters/presentation/shared/widgets/character_card_skeleton.dart';

class CharacterSkeletonGrid extends StatelessWidget {
  const CharacterSkeletonGrid({
    super.key,
    required this.layout,
    required this.rows,
  });
  final CatalogGridLayout layout;
  final int rows;

  @override
  Widget build(BuildContext context) => SliverPadding(
    padding: EdgeInsets.fromLTRB(
      layout.padding,
      CatalogGridLayout.gap,
      layout.padding,
      0,
    ),
    sliver: SliverGrid.builder(
      itemCount: layout.columns * rows,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: layout.columns,
        mainAxisSpacing: CatalogGridLayout.gap,
        crossAxisSpacing: CatalogGridLayout.gap,
        mainAxisExtent: layout.cardExtent,
      ),
      itemBuilder: (context, index) =>
          CharacterCardSkeleton(imageHeight: layout.imageHeight),
    ),
  );
}
