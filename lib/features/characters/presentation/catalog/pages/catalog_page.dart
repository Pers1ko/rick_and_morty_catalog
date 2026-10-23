import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:rick_and_morty_catalog/features/characters/domain/entities/character.dart';
import 'package:rick_and_morty_catalog/features/characters/presentation/catalog/cubit/catalog_cubit.dart';
import 'package:rick_and_morty_catalog/features/characters/presentation/catalog/cubit/catalog_state.dart';
import 'package:rick_and_morty_catalog/features/characters/presentation/catalog/models/catalog_grid_layout.dart';
import 'package:rick_and_morty_catalog/features/characters/presentation/catalog/widgets/catalog_app_bar.dart';
import 'package:rick_and_morty_catalog/features/characters/presentation/catalog/widgets/catalog_body.dart';
import 'package:rick_and_morty_catalog/features/characters/presentation/catalog/widgets/catalog_header.dart';
import 'package:rick_and_morty_catalog/features/characters/presentation/catalog/widgets/catalog_refresh_control.dart';
import 'package:rick_and_morty_catalog/features/characters/presentation/shared/navigation/character_details_route.dart';

class CatalogPage extends StatefulWidget {
  const CatalogPage({super.key});

  @override
  State<CatalogPage> createState() => _CatalogPageState();
}

class _CatalogPageState extends State<CatalogPage> {
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.hasClients &&
        _scrollController.position.extentAfter < 600) {
      context.read<CatalogCubit>().loadNextPage();
    }
  }

  void _scrollToTop() {
    if (_scrollController.hasClients) _scrollController.jumpTo(0);
  }

  void _resetFilters() {
    _searchController.clear();
    _scrollToTop();
    context.read<CatalogCubit>().resetFilters();
  }

  void _openCharacter(Character character) {
    FocusScope.of(context).unfocus();
    Navigator.of(context).push(CharacterDetailsRoute(character));
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: const CatalogAppBar(),
    body: SafeArea(
      top: false,
      child: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1160),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final layout = CatalogGridLayout(
                width: constraints.maxWidth,
                textScale: MediaQuery.textScalerOf(context).scale(1),
              );
              final cubit = context.read<CatalogCubit>();
              return BlocBuilder<CatalogCubit, CatalogState>(
                builder: (context, state) => CustomScrollView(
                  key: const PageStorageKey('catalog-scroll'),
                  controller: _scrollController,
                  physics: const BouncingScrollPhysics(
                    parent: AlwaysScrollableScrollPhysics(),
                  ),
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                  slivers: [
                    CatalogRefreshControl(onRefresh: cubit.retry),
                    SliverPadding(
                      padding: EdgeInsets.fromLTRB(
                        layout.padding,
                        20,
                        layout.padding,
                        18,
                      ),
                      sliver: SliverToBoxAdapter(
                        child: CatalogHeader(
                          controller: _searchController,
                          state: state,
                          onQueryChanged: (value) {
                            _scrollToTop();
                            cubit.setQuery(value);
                          },
                          onClearQuery: () {
                            _searchController.clear();
                            _scrollToTop();
                            cubit.setQuery('');
                          },
                          onFilterChanged: (status) {
                            _scrollToTop();
                            cubit.setStatusFilter(status);
                          },
                        ),
                      ),
                    ),
                    CatalogBody(
                      state: state,
                      layout: layout,
                      onRetry: cubit.retry,
                      onReset: _resetFilters,
                      onRetryPagination: cubit.retryNextPage,
                      onCharacterTap: _openCharacter,
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    ),
  );
}
