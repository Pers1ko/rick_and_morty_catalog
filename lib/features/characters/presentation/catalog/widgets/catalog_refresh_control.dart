import 'package:flutter/cupertino.dart';

import 'package:rick_and_morty_catalog/core/presentation/widgets/skeleton.dart';

class CatalogRefreshControl extends StatelessWidget {
  const CatalogRefreshControl({super.key, required this.onRefresh});
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) => CupertinoSliverRefreshControl(
    onRefresh: onRefresh,
    builder: (context, mode, pulled, trigger, extent) => pulled <= 0
        ? const SizedBox.shrink()
        : const Center(child: Skeleton(width: 72, height: 6)),
  );
}
