import 'package:flutter/material.dart';

import 'package:rick_and_morty_catalog/features/characters/domain/entities/character.dart';
import 'package:rick_and_morty_catalog/features/characters/presentation/shared/widgets/character_image.dart';

class CharacterPortrait extends StatelessWidget {
  const CharacterPortrait({super.key, required this.character});
  final Character character;
  @override
  Widget build(BuildContext context) => ClipRRect(
    borderRadius: BorderRadius.circular(24),
    child: AspectRatio(
      aspectRatio: 1.08,
      child: Hero(
        tag: 'character-image-${character.id}',
        child: CharacterImage(url: character.imageUrl),
      ),
    ),
  );
}
