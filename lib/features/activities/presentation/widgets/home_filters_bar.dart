import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../categories/presentation/providers/categories_providers.dart';
import '../providers/activities_providers.dart';

/// Search, category filter chips, and sort controls for the home screen.
class HomeFiltersBar extends ConsumerStatefulWidget {
  const HomeFiltersBar({super.key});

  @override
  ConsumerState<HomeFiltersBar> createState() => _HomeFiltersBarState();
}

class _HomeFiltersBarState extends ConsumerState<HomeFiltersBar> {
  static const double _filterControlHeight = 48;

  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(
      text: ref.read(activityFilterProvider).searchQuery,
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filter = ref.watch(activityFilterProvider);
    final categoriesAsync = ref.watch(mergedCategoriesProvider);

    // Keep controller in sync when filter is cleared externally.
    if (_searchController.text != filter.searchQuery) {
      _searchController.text = filter.searchQuery;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: SizedBox(
                height: _filterControlHeight,
                child: TextField(
                  controller: _searchController,
                  textAlignVertical: TextAlignVertical.center,
                  onTapOutside: (_) =>
                      FocusManager.instance.primaryFocus?.unfocus(),
                  decoration: InputDecoration(
                    hintText: 'Search activities...',
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: filter.searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              ref
                                  .read(activityFilterProvider.notifier)
                                  .setSearch('');
                            },
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  onChanged: (value) => ref
                      .read(activityFilterProvider.notifier)
                      .setSearch(value),
                ),
              ),
            ),
            const SizedBox(width: 8),
            PopupMenuButton<ActivitySort>(
              tooltip: 'Sort: ${_sortLabel(filter.sort)}',
              onSelected: (sort) =>
                  ref.read(activityFilterProvider.notifier).setSort(sort),
              itemBuilder: (context) => [
                _sortMenuItem(
                  value: ActivitySort.recentlyDone,
                  label: 'Recently done',
                  selected: filter.sort == ActivitySort.recentlyDone,
                ),
                _sortMenuItem(
                  value: ActivitySort.overdue,
                  label: 'Overdue first',
                  selected: filter.sort == ActivitySort.overdue,
                ),
                _sortMenuItem(
                  value: ActivitySort.alphabetical,
                  label: 'A–Z',
                  selected: filter.sort == ActivitySort.alphabetical,
                ),
              ],
              // Finite-width outlined control (InputDecorator needs bounded width).
              child: SizedBox(
                height: _filterControlHeight,
                child: Material(
                  color: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                    side: BorderSide(
                      color: Theme.of(context).colorScheme.outline,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Center(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.sort, size: 22),
                          const SizedBox(width: 2),
                          Icon(
                            Icons.arrow_drop_down,
                            size: 22,
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurfaceVariant,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        categoriesAsync.when(
          data: (categories) {
            if (categories.isEmpty) return const SizedBox.shrink();
            return SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _CategoryChip(
                    label: 'All',
                    selected: filter.category == null,
                    onSelected: () => ref
                        .read(activityFilterProvider.notifier)
                        .setCategory(null),
                  ),
                  const SizedBox(width: 8),
                  ...categories.map(
                    (cat) => Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: _CategoryChip(
                        label: cat,
                        selected: filter.category == cat,
                        onSelected: () => ref
                            .read(activityFilterProvider.notifier)
                            .setCategory(cat),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
          loading: () => const SizedBox.shrink(),
          error: (_, _) => const SizedBox.shrink(),
        ),
      ],
    );
  }

  PopupMenuItem<ActivitySort> _sortMenuItem({
    required ActivitySort value,
    required String label,
    required bool selected,
  }) {
    return PopupMenuItem(
      value: value,
      child: Row(
        children: [
          if (selected)
            const Icon(Icons.check, size: 18)
          else
            const SizedBox(width: 18),
          const SizedBox(width: 8),
          Text(label),
        ],
      ),
    );
  }

  String _sortLabel(ActivitySort sort) => switch (sort) {
    ActivitySort.recentlyDone => 'Recently done',
    ActivitySort.overdue => 'Overdue first',
    ActivitySort.alphabetical => 'A–Z',
  };
}

class _CategoryChip extends StatelessWidget {
  const _CategoryChip({
    required this.label,
    required this.selected,
    required this.onSelected,
  });

  final String label;
  final bool selected;
  final VoidCallback onSelected;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return FilterChip(
      label: Text(label),
      selected: selected,
      showCheckmark: true,
      onSelected: (_) => onSelected(),
      labelStyle: TextStyle(
        fontSize: 14,
        color: selected ? scheme.primary : scheme.onSurface,
        fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
      ),
    );
  }
}
