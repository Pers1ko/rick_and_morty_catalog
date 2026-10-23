final class CharacterDto {
  const CharacterDto({
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
  final String status;
  final String species;
  final String origin;
  final String location;
  final String imageUrl;
  final String gender;
  final int episodeCount;

  factory CharacterDto.fromJson(Map<String, dynamic> json) => CharacterDto(
    id: json['id'] as int,
    name: json['name'] as String,
    status: json['status'] as String,
    species: json['species'] as String,
    origin: (json['origin'] as Map<String, dynamic>)['name'] as String,
    location: (json['location'] as Map<String, dynamic>)['name'] as String,
    imageUrl: json['image'] as String,
    gender: json['gender'] as String,
    episodeCount: (json['episode'] as List<dynamic>).length,
  );
}
