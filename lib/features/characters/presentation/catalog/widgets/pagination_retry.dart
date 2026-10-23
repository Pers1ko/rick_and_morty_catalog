import 'package:flutter/material.dart';

class PaginationRetry extends StatelessWidget {
  const PaginationRetry({super.key, required this.onRetry});
  final VoidCallback onRetry;
  @override
  Widget build(BuildContext context) => SliverToBoxAdapter(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: OutlinedButton(
          key: const ValueKey('retry-pagination'),
          onPressed: onRetry,
          child: const Text('Не удалось загрузить ещё. Повторить'),
        ),
      ),
    ),
  );
}
