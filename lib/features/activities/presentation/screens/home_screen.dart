import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/database/database_provider.dart';
import '../../../../core/widgets/activity_card.dart';
import '../../../../core/widgets/app_brand_title.dart';
import '../../../../core/widgets/confirm_dialog.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../occurrences/domain/entities/occurrence.dart';
import '../providers/activities_providers.dart';
import '../widgets/home_filters_bar.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activitiesAsync = ref.watch(filteredActivitiesProvider);
    final allActivitiesAsync = ref.watch(activitiesWithLastDoneProvider);
    final filter = ref.watch(activityFilterProvider);
    final elapsedNow = ref.watch(elapsedTickerProvider).valueOrNull;
    final hasActiveFilters =
        filter.searchQuery.isNotEmpty || filter.category != null;

    return Scaffold(
      appBar: AppBar(
        title: const AppBrandTitle(),
        actions: [
          PopupMenuButton<ActivitySort>(
            icon: const Icon(Icons.sort),
            tooltip: 'Sort',
            onSelected: (sort) =>
                ref.read(activityFilterProvider.notifier).setSort(sort),
            itemBuilder: (context) => const [
              PopupMenuItem(
                value: ActivitySort.recentlyDone,
                child: Text('Recently done'),
              ),
              PopupMenuItem(
                value: ActivitySort.overdue,
                child: Text('Overdue first'),
              ),
              PopupMenuItem(
                value: ActivitySort.alphabetical,
                child: Text('A–Z'),
              ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.insights_outlined),
            tooltip: 'Insights',
            onPressed: () => context.push('/insights'),
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            tooltip: 'Settings',
            onPressed: () => context.push('/settings'),
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: HomeFiltersBar(),
          ),
          Expanded(
            child: activitiesAsync.when(
              data: (items) {
                if (items.isNotEmpty) {
                  return _ActivityList(
                    items: items,
                    elapsedNow: elapsedNow,
                  );
                }

                return allActivitiesAsync.when(
                  data: (all) {
                    if (all.isEmpty) {
                      return EmptyState(
                        title: 'Nothing here yet',
                        message:
                            'Track when you last did anything — water plants, car wash, call family.',
                        actionLabel: 'Add activity',
                        onAction: () => context.push('/activity/new'),
                      );
                    }
                    return EmptyState(
                      title: 'No matches',
                      message: hasActiveFilters
                          ? 'No activities match your search or filter.'
                          : 'Nothing to show right now.',
                      actionLabel: hasActiveFilters ? 'Clear filters' : null,
                      actionIcon: Icons.filter_alt_off,
                      onAction: hasActiveFilters
                          ? () => ref
                              .read(activityFilterProvider.notifier)
                              .clearFilters()
                          : null,
                      icon: Icons.search_off_outlined,
                    );
                  },
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (e, _) => Center(child: Text('Error: $e')),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Error: $e')),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/activity/new'),
        icon: const Icon(Icons.add),
        label: const Text('Add Activity'),
      ),
    );
  }
}

class _ActivityList extends ConsumerWidget {
  const _ActivityList({
    required this.items,
    this.elapsedNow,
  });

  final List<ActivityListItem> items;
  final DateTime? elapsedNow;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 700;
        final maxWidth = isWide ? 900.0 : double.infinity;

        return Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxWidth),
            child: isWide
                ? GridView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 56),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 2.1,
                    ),
                    itemCount: items.length,
                    itemBuilder: (context, index) => _buildDismissibleItem(
                      context,
                      ref,
                      items[index],
                      elapsedNow,
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 56),
                    itemCount: items.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 10),
                    itemBuilder: (context, index) => _buildDismissibleItem(
                      context,
                      ref,
                      items[index],
                      elapsedNow,
                    ),
                  ),
          ),
        );
      },
    );
  }

  Widget _buildDismissibleItem(
    BuildContext context,
    WidgetRef ref,
    ActivityListItem listItem,
    DateTime? elapsedNow,
  ) {
    final activity = listItem.item.activity;

    return Dismissible(
      key: ValueKey(activity.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.errorContainer,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Icon(
          Icons.delete_outline,
          color: Theme.of(context).colorScheme.onErrorContainer,
        ),
      ),
      confirmDismiss: (_) async {
        return showConfirmDialog(
          context,
          title: 'Delete activity?',
          message:
              'Delete "${activity.title}" and all its history? This cannot be undone.',
        );
      },
      onDismissed: (_) async {
        await ref.read(activityRepositoryProvider).delete(activity.id);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Deleted "${activity.title}"')),
          );
        }
      },
      child: ActivityCard(
        item: listItem.item,
        status: listItem.status,
        elapsedNow: elapsedNow,
        onTap: () => context.push('/activity/${activity.id}'),
        onQuickLog: () => _quickLog(context, ref, activity.id, activity.title),
      ),
    );
  }

  Future<void> _quickLog(
    BuildContext context,
    WidgetRef ref,
    int activityId,
    String title,
  ) async {
    await ref.read(occurrenceRepositoryProvider).insert(
          Occurrence(
            id: 0,
            activityId: activityId,
            doneAt: DateTime.now(),
          ),
        );
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Logged "$title" now')),
      );
    }
  }
}
