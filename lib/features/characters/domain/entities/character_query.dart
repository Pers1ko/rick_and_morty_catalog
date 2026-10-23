import 'package:rick_and_morty_catalog/features/characters/domain/entities/character_status.dart';

final class CharacterQuery {
  CharacterQuery({this.page = 1, String name = '', this.status})
    : name = name.trim() {
    if (page < 1) throw ArgumentError.value(page, 'page', 'Must be positive');
  }
  final int page;
  final String name;
  final CharacterStatus? status;
}
