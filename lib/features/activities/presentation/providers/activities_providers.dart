import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/database/database_provider.dart';
import '../../../../core/utils/activity_status.dart';
import '../../../categories/presentation/providers/categories_providers.dart';
import '../../domain/entities/activity.dart';

/// Ticks every minute so relative timestamps stay fresh.
final elapsedTickerProvider = StreamProvider<DateTime>((ref) {
  return Stream.periodic(
    const Duration(minutes: 1),
    (_) => DateTime.now(),
  ).startWith(DateTime.now());
});

extension<T> on Stream<T> {
  Stream<T> startWith(T value) async* {
    yield value;
    yield* this;
  }
}

enum ActivitySort { recentlyDone, overdue, alphabetical }

class ActivityFilterState {
  const ActivityFilterState({
    this.searchQuery = '',
    this.category,
    this.sort = ActivitySort.recentlyDone,
  });

  final String searchQuery;
  final String? category;
  final ActivitySort sort;

  ActivityFilterState copyWith({
    String? searchQuery,
    String? category,
    bool clearCategory = false,
    ActivitySort? sort,
  }) {
    return ActivityFilterState(
      searchQuery: searchQuery ?? this.searchQuery,
      category: clearCategory ? null : (category ?? this.category),
      sort: sort ?? this.sort,
    );
  }
}

class ActivityFilterNotifier extends Notifier<ActivityFilterState> {
  @override
  ActivityFilterState build() => const ActivityFilterState();

  void setSearch(String query) => state = state.copyWith(searchQuery: query);
  void setCategory(String? category) => state = state.copyWith(
    category: category,
    clearCategory: category == null,
  );
  void setSort(ActivitySort sort) => state = state.copyWith(sort: sort);
  void clearFilters() => state = const ActivityFilterState();
}

final activityFilterProvider =
    NotifierProvider<ActivityFilterNotifier, ActivityFilterState>(
      ActivityFilterNotifier.new,
    );

/// Raw stream of all activities with last done timestamps.
final activitiesWithLastDoneProvider =
    StreamProvider<List<ActivityWithLastDone>>((ref) {
      return ref.watch(activityRepositoryProvider).watchAllWithLastDone();
    });

/// Filtered and sorted activities with computed status.
final filteredActivitiesProvider = Provider<AsyncValue<List<ActivityListItem>>>(
  (ref) {
    final activitiesAsync = ref.watch(activitiesWithLastDoneProvider);
    final filter = ref.watch(activityFilterProvider);
    final calculator = ActivityStatusCalculator();

    return activitiesAsync.whenData((items) {
      var filtered = items
          .where((item) {
            final matchesSearch =
                filter.searchQuery.isEmpty ||
                item.activity.title.toLowerCase().contains(
                  filter.searchQuery.toLowerCase(),
                ) ||
                (item.activity.category?.toLowerCase().contains(
                      filter.searchQuery.toLowerCase(),
                    ) ??
                    false);
            final matchesCategory =
                filter.category == null ||
                item.activity.category == filter.category;
            return matchesSearch && matchesCategory;
          })
          .map((item) {
            final status = calculator.compute(
              activity: item.activity,
              lastDoneAt: item.lastDoneAt,
            );
            return ActivityListItem(item: item, status: status);
          })
          .toList();

      filtered = switch (filter.sort) {
        ActivitySort.recentlyDone =>
          filtered..sort((a, b) {
            final aDate =
                a.item.lastDoneAt ?? DateTime.fromMillisecondsSinceEpoch(0);
            final bDate =
                b.item.lastDoneAt ?? DateTime.fromMillisecondsSinceEpoch(0);
            return bDate.compareTo(aDate);
          }),
        ActivitySort.overdue =>
          filtered..sort((a, b) {
            int priority(ActivityStatus s) => switch (s) {
              ActivityStatus.overdue => 0,
              ActivityStatus.dueSoon => 1,
              ActivityStatus.neverLogged => 2,
              ActivityStatus.recent => 3,
              ActivityStatus.noReminder => 4,
            };
            final cmp = priority(a.status).compareTo(priority(b.status));
            if (cmp != 0) return cmp;
            return a.item.activity.title.compareTo(b.item.activity.title);
          }),
        ActivitySort.alphabetical =>
          filtered..sort(
            (a, b) => a.item.activity.title.compareTo(b.item.activity.title),
          ),
      };

      return filtered;
    });
  },
);

class ActivityListItem {
  const ActivityListItem({required this.item, required this.status});

  final ActivityWithLastDone item;
  final ActivityStatus status;
}

final categoriesProvider = mergedCategoriesProvider;

final activityByIdProvider = StreamProvider.family<Activity?, int>((ref, id) {
  return ref.watch(activityRepositoryProvider).watchById(id);
});
