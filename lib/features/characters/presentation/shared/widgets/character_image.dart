import 'package:flutter/material.dart';

import 'package:rick_and_morty_catalog/core/presentation/widgets/skeleton.dart';
import 'package:rick_and_morty_catalog/core/theme/app_colors.dart';

class CharacterImage extends StatelessWidget {
  const CharacterImage({super.key, required this.url});

  final String url;

  @override
  Widget build(BuildContext context) => Image.network(
    url,
    fit: BoxFit.cover,
    width: double.infinity,
    height: double.infinity,
    cacheWidth: 600,
    excludeFromSemantics: true,
    frameBuilder: (context, child, frame, synchronous) =>
        synchronous || frame != null ? child : const Skeleton(radius: 0),
    errorBuilder: (context, error, stackTrace) =>
        const _ImagePlaceholder(icon: Icons.image_not_supported_outlined),
  );
}

class _ImagePlaceholder extends StatelessWidget {
  const _ImagePlaceholder({this.icon = Icons.person_outline_rounded});

  final IconData icon;

  @override
  Widget build(BuildContext context) => ColoredBox(
    color: AppColors.surfaceRaised,
    child: Center(child: Icon(icon, size: 36, color: AppColors.secondary)),
  );
}
