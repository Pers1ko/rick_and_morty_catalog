import 'package:flutter/material.dart';

import 'package:rick_and_morty_catalog/app/app.dart';
import 'package:rick_and_morty_catalog/app/di/app_dependencies.dart';

class AppBootstrap extends StatefulWidget {
  const AppBootstrap({super.key});
  @override
  State<AppBootstrap> createState() => _AppBootstrapState();
}

class _AppBootstrapState extends State<AppBootstrap> {
  late final AppDependencies _dependencies = AppDependencies.create();

  @override
  void dispose() {
    _dependencies.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) =>
      RickAndMortyApp(getCharacters: _dependencies.getCharacters);
}
