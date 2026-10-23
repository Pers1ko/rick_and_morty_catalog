import 'package:flutter/material.dart';

import 'package:rick_and_morty_catalog/features/characters/domain/entities/character_status.dart';
import 'package:rick_and_morty_catalog/features/characters/presentation/shared/formatters/character_formatters.dart';

class StatusBadge extends StatelessWidget {
  const StatusBadge({super.key, required this.status});

  final CharacterStatus status;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Container(
        width: 7,
        height: 7,
        decoration: BoxDecoration(color: status.color, shape: BoxShape.circle),
      ),
      const SizedBox(width: 7),
      Flexible(
        child: Text(
          status.label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 12,
            color: status.color,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    ],
  );
}
