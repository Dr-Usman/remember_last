import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../activities/presentation/providers/activities_providers.dart';
import '../../../../core/database/database_provider.dart';
import '../../../../core/utils/activity_status.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/widgets/confirm_dialog.dart';
import '../../../../core/widgets/status_indicator.dart';
import '../../domain/entities/occurrence.dart';
import '../providers/occurrences_providers.dart';
import '../widgets/log_entry_sheet.dart';

class ActivityDetailScreen extends ConsumerWidget {
  const ActivityDetailScreen({super.key, required this.activityId});

  final int activityId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activityAsync = ref.watch(activityByIdProvider(activityId));
    final occurrencesAsync = ref.watch(occurrencesProvider(activityId));
    final elapsedNow = ref.watch(elapsedTickerProvider).valueOrNull;
    final calculator = ActivityStatusCalculator();

    return activityAsync.when(
      data: (activity) {
        if (activity == null) {
          return Scaffold(
            appBar: AppBar(),
            body: const Center(child: Text('Activity not found')),
          );
        }

        return occurrencesAsync.when(
          data: (occurrences) {
            final lastDone = occurrences.isNotEmpty ? occurrences.first.doneAt : null;
            final status = calculator.compute(
              activity: activity,
              lastDoneAt: lastDone,
            );
            final nextDue = calculator.nextDueDate(
              activity: activity,
              lastDoneAt: lastDone,
            );

            return Scaffold(
              appBar: AppBar(
                title: Text(activity.title),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.edit_outlined),
                    onPressed: () =>
                        context.push('/activity/$activityId/edit'),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline),
                    onPressed: () => _deleteActivity(context, ref, activity),
                  ),
                ],
              ),
              body: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _HeaderCard(
                    lastDone: lastDone,
                    nextDue: nextDue,
                    status: status,
                    elapsedNow: elapsedNow,
                  ),
                  const SizedBox(height: 16),
                  FilledButton.icon(
                    onPressed: () => _logNow(ref),
                    icon: const Icon(Icons.add),
                    label: const Text('Log Now'),
                    style: FilledButton.styleFrom(
                      minimumSize: const Size.fromHeight(52),
                    ),
                  ),
                  const SizedBox(height: 8),
                  OutlinedButton.icon(
                    onPressed: () => LogEntrySheet.show(
                      context,
                      activityId: activityId,
                    ),
                    icon: const Icon(Icons.edit_calendar_outlined),
                    label: const Text('Add Custom Entry'),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size.fromHeight(52),
                    ),
                  ),
                  if (activity.notes != null && activity.notes!.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    Text('Notes', style: Theme.of(context).textTheme.titleSmall),
                    const SizedBox(height: 4),
                    Text(activity.notes!),
                  ],
                  const SizedBox(height: 24),
                  Text(
                    'History',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  if (occurrences.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 24),
                      child: Center(child: Text('No logs yet')),
                    )
                  else
                    ...occurrences.map(
                      (o) => _HistoryTile(
                        occurrence: o,
                        activityId: activityId,
                      ),
                    ),
                ],
              ),
            );
          },
          loading: () => Scaffold(
            appBar: AppBar(title: Text(activity.title)),
            body: const Center(child: CircularProgressIndicator()),
          ),
          error: (e, _) => Scaffold(
            appBar: AppBar(title: Text(activity.title)),
            body: Center(child: Text('Error: $e')),
          ),
        );
      },
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Scaffold(
        body: Center(child: Text('Error: $e')),
      ),
    );
  }

  Future<void> _logNow(WidgetRef ref) async {
    await ref.read(occurrenceRepositoryProvider).insert(
          Occurrence(
            id: 0,
            activityId: activityId,
            doneAt: DateTime.now(),
          ),
        );
  }

  Future<void> _deleteActivity(
    BuildContext context,
    WidgetRef ref,
    activity,
  ) async {
    final confirmed = await showConfirmDialog(
      context,
      title: 'Delete activity?',
      message: 'Delete "${activity.title}" and all history?',
    );
    if (!confirmed || !context.mounted) return;
    await ref.read(activityRepositoryProvider).delete(activityId);
    if (context.mounted) context.pop();
  }
}

class _HeaderCard extends StatelessWidget {
  const _HeaderCard({
    required this.lastDone,
    required this.nextDue,
    required this.status,
    this.elapsedNow,
  });

  final DateTime? lastDone;
  final DateTime? nextDue;
  final ActivityStatus status;
  final DateTime? elapsedNow;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Last done', style: theme.textTheme.labelLarge),
            const SizedBox(height: 4),
            Text(
              lastDone != null
                  ? DateFormatter.formatElapsed(lastDone!, now: elapsedNow)
                  : 'Never logged',
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: statusColor(status),
              ),
            ),
            if (lastDone != null) ...[
              const SizedBox(height: 4),
              Text(
                DateFormatter.formatAbsoluteDateTime(lastDone!),
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
            const SizedBox(height: 16),
            StatusIndicator(status: status),
            if (nextDue != null) ...[
              const SizedBox(height: 16),
              Text('Next due', style: theme.textTheme.labelLarge),
              const SizedBox(height: 4),
              Text(
                DateFormatter.formatAbsoluteDate(nextDue!),
                style: theme.textTheme.titleLarge,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _HistoryTile extends ConsumerWidget {
  const _HistoryTile({
    required this.occurrence,
    required this.activityId,
  });

  final Occurrence occurrence;
  final int activityId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: const Icon(Icons.history),
        title: Text(DateFormatter.formatAbsoluteDateTime(occurrence.doneAt)),
        subtitle: occurrence.note != null ? Text(occurrence.note!) : null,
        trailing: PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert),
          itemBuilder: (context) => const [
            PopupMenuItem(value: 'edit', child: Text('Edit')),
            PopupMenuItem(value: 'delete', child: Text('Delete')),
          ],
          onSelected: (value) async {
            if (value == 'edit') {
              await LogEntrySheet.show(
                context,
                activityId: activityId,
                occurrenceToEdit: occurrence,
              );
            } else if (value == 'delete') {
              final confirmed = await showConfirmDialog(
                context,
                title: 'Delete entry?',
                message: 'Remove this log entry permanently?',
              );
              if (confirmed) {
                await ref
                    .read(occurrenceRepositoryProvider)
                    .delete(occurrence.id);
              }
            }
          },
        ),
      ),
    );
  }
}
