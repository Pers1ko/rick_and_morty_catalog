import 'package:rick_and_morty_catalog/features/characters/data/models/character_dto.dart';

final class CharacterPageDto {
  CharacterPageDto({
    required List<CharacterDto> characters,
    required this.totalCount,
    required this.nextPage,
  }) : characters = List.unmodifiable(characters);
  CharacterPageDto.empty()
    : characters = const [],
      totalCount = 0,
      nextPage = null;
  final List<CharacterDto> characters;
  final int totalCount;
  final int? nextPage;

  factory CharacterPageDto.fromJson(Map<String, dynamic> json) {
    final info = json['info'] as Map<String, dynamic>;
    final next = info['next'] as String?;
    final nextPage = next == null
        ? null
        : int.tryParse(Uri.parse(next).queryParameters['page'] ?? '');
    final count = info['count'] as int;
    if (count < 0 || (next != null && (nextPage == null || nextPage < 1))) {
      throw const FormatException('Invalid pagination metadata');
    }
    return CharacterPageDto(
      characters: (json['results'] as List<dynamic>)
          .map((item) => CharacterDto.fromJson(item as Map<String, dynamic>))
          .toList(),
      totalCount: count,
      nextPage: nextPage,
    );
  }
}
