import 'package:rick_and_morty_catalog/features/characters/data/models/character_dto.dart';
import 'package:rick_and_morty_catalog/features/characters/data/models/character_page_dto.dart';
import 'package:rick_and_morty_catalog/features/characters/domain/entities/character.dart';
import 'package:rick_and_morty_catalog/features/characters/domain/entities/character_page.dart';
import 'package:rick_and_morty_catalog/features/characters/domain/entities/character_status.dart';

extension CharacterDtoMapper on CharacterDto {
  Character toDomain() => Character(
    id: id,
    name: name,
    status: switch (status.toLowerCase()) {
      'alive' => CharacterStatus.alive,
      'dead' => CharacterStatus.dead,
      _ => CharacterStatus.unknown,
    },
    species: species,
    origin: origin,
    location: location,
    imageUrl: imageUrl,
    gender: gender,
    episodeCount: episodeCount,
  );
}

extension CharacterPageDtoMapper on CharacterPageDto {
  CharacterPage toDomain() => CharacterPage(
    characters: characters.map((character) => character.toDomain()).toList(),
    totalCount: totalCount,
    nextPage: nextPage,
  );
}
