import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/widgets/confirm_dialog.dart';
import '../domain/backup_service.dart';

/// UI actions for exporting and importing JSON backups.
class BackupActions {
  BackupActions(this._ref);

  final WidgetRef _ref;

  Future<void> exportBackup(BuildContext context) async {
    try {
      final service = _ref.read(backupServiceProvider);
      final data = await service.exportToJson();
      final json = service.encodeExport(data);
      final timestamp = DateTime.now().toIso8601String().split('T').first;
      final filename = 'remember_last_$timestamp.json';

      if (kIsWeb) {
        await SharePlus.instance.share(
          ShareParams(
            files: [
              XFile.fromData(
                Uint8List.fromList(json.codeUnits),
                name: filename,
                mimeType: 'application/json',
              ),
            ],
            subject: '${AppConstants.appName} Backup',
          ),
        );
      } else {
        await SharePlus.instance.share(
          ShareParams(
            text: json,
            subject: '${AppConstants.appName} Backup',
          ),
        );
      }

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Backup exported successfully')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Export failed: $e')),
        );
      }
    }
  }

  Future<void> importBackup(BuildContext context) async {
    final merge = await showConfirmDialog(
      context,
      title: 'Import backup',
      message:
          'Merge imported data with existing activities? Choose Cancel then re-import to replace all data instead.',
      confirmLabel: 'Merge',
      isDestructive: false,
    );
    if (!context.mounted) return;

    var shouldMerge = merge;
    if (!merge) {
      final replace = await showConfirmDialog(
        context,
        title: 'Replace all data?',
        message:
            'This will delete all existing activities and occurrences before importing.',
        confirmLabel: 'Replace all',
      );
      if (!replace || !context.mounted) return;
      shouldMerge = false;
    }

    try {
      final result = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );
      if (result == null || result.files.isEmpty) return;

      final bytes = await result.files.single.readAsBytes();
      final json = String.fromCharCodes(bytes);
      final service = _ref.read(backupServiceProvider);
      final importResult =
          await service.importFromJson(json, merge: shouldMerge);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Imported ${importResult.activities} activities and '
              '${importResult.occurrences} logs',
            ),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Import failed: $e')),
        );
      }
    }
  }
}
