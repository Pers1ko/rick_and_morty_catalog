import 'package:flutter/material.dart';

import 'package:rick_and_morty_catalog/core/theme/app_colors.dart';
import 'package:rick_and_morty_catalog/features/characters/presentation/shared/widgets/portal_mark.dart';

class CatalogAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CatalogAppBar({super.key});
  @override
  Size get preferredSize => const Size.fromHeight(76);
  @override
  Widget build(BuildContext context) => AppBar(
    toolbarHeight: 76,
    title: const Row(
      children: [
        PortalMark(),
        SizedBox(width: 11),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'RICK & MORTY',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.5,
                ),
              ),
              SizedBox(height: 3),
              Text(
                'Каталог персонажей',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 11, color: AppColors.secondary),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}
