import 'package:flutter/material.dart';

import 'package:rick_and_morty_catalog/core/theme/app_colors.dart';
import 'package:rick_and_morty_catalog/features/characters/domain/entities/character_status.dart';

extension CharacterStatusPresentation on CharacterStatus {
  String get label => switch (this) {
    CharacterStatus.alive => 'Жив',
    CharacterStatus.dead => 'Мёртв',
    CharacterStatus.unknown => 'Неизвестно',
  };

  Color get color => switch (this) {
    CharacterStatus.alive => AppColors.accent,
    CharacterStatus.dead => AppColors.dead,
    CharacterStatus.unknown => AppColors.secondary,
  };
}

String readableValue(String value) =>
    value.isEmpty || value.toLowerCase() == 'unknown' ? 'Неизвестно' : value;
