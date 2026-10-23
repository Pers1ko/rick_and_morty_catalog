import 'package:flutter/material.dart';

import 'package:rick_and_morty_catalog/features/characters/domain/entities/character.dart';
import 'package:rick_and_morty_catalog/features/characters/presentation/details/widgets/character_details.dart';
import 'package:rick_and_morty_catalog/features/characters/presentation/details/widgets/character_portrait.dart';

class CharacterDetailPage extends StatelessWidget {
  const CharacterDetailPage({super.key, required this.character});

  final Character character;

  @override
  Widget build(BuildContext context) => Scaffold(
    key: const ValueKey('character-detail'),
    appBar: AppBar(
      leading: IconButton(
        key: const ValueKey('detail-back'),
        tooltip: 'Назад к каталогу',
        icon: const Icon(Icons.arrow_back_rounded),
        onPressed: () => Navigator.of(context).pop(),
      ),
      title: const Text(
        'Досье персонажа',
        style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
      ),
    ),
    body: SafeArea(
      top: false,
      child: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1000),
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 36),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final image = CharacterPortrait(character: character);
                final details = CharacterDetails(character: character);
                if (constraints.maxWidth >= 720) {
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: image),
                      const SizedBox(width: 32),
                      Expanded(child: details),
                    ],
                  );
                }
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [image, const SizedBox(height: 24), details],
                );
              },
            ),
          ),
        ),
      ),
    ),
  );
}
