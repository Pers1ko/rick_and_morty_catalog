import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:rick_and_morty_catalog/features/characters/domain/usecases/get_characters.dart';
import 'package:rick_and_morty_catalog/features/characters/presentation/catalog/cubit/catalog_cubit.dart';
import 'package:rick_and_morty_catalog/features/characters/presentation/catalog/pages/catalog_page.dart';

class CatalogScope extends StatelessWidget {
  const CatalogScope({super.key, required this.getCharacters});
  final GetCharacters getCharacters;
  @override
  Widget build(BuildContext context) => BlocProvider(
    create: (_) => CatalogCubit(getCharacters)..loadInitial(),
    child: const CatalogPage(),
  );
}
