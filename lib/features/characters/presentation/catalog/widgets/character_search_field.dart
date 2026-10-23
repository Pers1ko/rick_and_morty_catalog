import 'package:flutter/material.dart';

class CharacterSearchField extends StatelessWidget {
  const CharacterSearchField({
    super.key,
    required this.controller,
    required this.onChanged,
    required this.onClear,
  });
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) => TextField(
    key: const ValueKey('character-search'),
    controller: controller,
    onChanged: onChanged,
    autocorrect: false,
    textInputAction: TextInputAction.search,
    onSubmitted: (_) => FocusScope.of(context).unfocus(),
    decoration: InputDecoration(
      hintText: 'Найти персонажа по имени',
      prefixIcon: const Icon(Icons.search_rounded),
      suffixIcon: ValueListenableBuilder<TextEditingValue>(
        valueListenable: controller,
        builder: (context, value, _) => value.text.isEmpty
            ? const SizedBox.shrink()
            : IconButton(
                key: const ValueKey('clear-search'),
                tooltip: 'Очистить поиск',
                onPressed: onClear,
                icon: const Icon(Icons.close_rounded, size: 20),
              ),
      ),
    ),
  );
}
