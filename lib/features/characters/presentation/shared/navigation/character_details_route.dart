import 'package:flutter/material.dart';

import 'package:rick_and_morty_catalog/features/characters/domain/entities/character.dart';
import 'package:rick_and_morty_catalog/features/characters/presentation/details/pages/character_detail_page.dart';

final class CharacterDetailsRoute extends MaterialPageRoute<void> {
  CharacterDetailsRoute(Character character)
    : super(
        settings: RouteSettings(name: '/characters/${character.id}'),
        builder: (_) => CharacterDetailPage(character: character),
      );
}
