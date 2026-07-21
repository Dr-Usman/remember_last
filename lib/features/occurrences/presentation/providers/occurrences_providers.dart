import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/database/database_provider.dart';
import '../../domain/entities/occurrence.dart';

final occurrencesProvider = StreamProvider.family<List<Occurrence>, int>((
  ref,
  activityId,
) {
  return ref.watch(occurrenceRepositoryProvider).watchByActivityId(activityId);
});

final occurrenceCountProvider = FutureProvider.family<int, int>((
  ref,
  activityId,
) async {
  return ref.watch(occurrenceRepositoryProvider).countForActivity(activityId);
});
