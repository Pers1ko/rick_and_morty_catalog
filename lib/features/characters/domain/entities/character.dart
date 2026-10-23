import 'package:rick_and_morty_catalog/features/characters/domain/entities/character_status.dart';

class Character {
  const Character({
    required this.id,
    required this.name,
    required this.status,
    required this.species,
    required this.origin,
    required this.location,
    required this.imageUrl,
    required this.gender,
    required this.episodeCount,
  });

  final int id;
  final String name;
  final CharacterStatus status;
  final String species;
  final String origin;
  final String location;
  final String imageUrl;
  final String gender;
  final int episodeCount;
}
