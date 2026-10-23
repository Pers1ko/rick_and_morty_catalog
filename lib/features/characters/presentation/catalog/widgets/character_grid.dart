import 'package:flutter/material.dart';

import 'package:rick_and_morty_catalog/features/characters/domain/entities/character.dart';
import 'package:rick_and_morty_catalog/features/characters/presentation/catalog/models/catalog_grid_layout.dart';
import 'package:rick_and_morty_catalog/features/characters/presentation/shared/widgets/character_card.dart';

class CharacterGrid extends StatelessWidget {
  const CharacterGrid({
    super.key,
    required this.characters,
    required this.layout,
    required this.onCharacterTap,
  });
  final List<Character> characters;
  final CatalogGridLayout layout;
  final ValueChanged<Character> onCharacterTap;

  @override
  Widget build(BuildContext context) => SliverPadding(
    padding: EdgeInsets.symmetric(horizontal: layout.padding),
    sliver: SliverGrid.builder(
      itemCount: characters.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: layout.columns,
        mainAxisSpacing: CatalogGridLayout.gap,
        crossAxisSpacing: CatalogGridLayout.gap,
        mainAxisExtent: layout.cardExtent,
      ),
      itemBuilder: (context, index) {
        final character = characters[index];
        return CharacterCard(
          key: ValueKey('character-${character.id}'),
          character: character,
          imageHeight: layout.imageHeight,
          onTap: () => onCharacterTap(character),
        );
      },
    ),
  );
}
