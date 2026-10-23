import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'package:rick_and_morty_catalog/core/theme/app_theme.dart';
import 'package:rick_and_morty_catalog/features/characters/domain/usecases/get_characters.dart';
import 'package:rick_and_morty_catalog/features/characters/presentation/catalog/catalog_scope.dart';

class RickAndMortyApp extends StatelessWidget {
  const RickAndMortyApp({super.key, required this.getCharacters});
  final GetCharacters getCharacters;

  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'Rick & Morty — каталог персонажей',
    debugShowCheckedModeBanner: false,
    theme: buildAppTheme(),
    locale: const Locale('ru'),
    supportedLocales: const [Locale('ru'), Locale('en')],
    localizationsDelegates: GlobalMaterialLocalizations.delegates,
    home: CatalogScope(getCharacters: getCharacters),
  );
}
