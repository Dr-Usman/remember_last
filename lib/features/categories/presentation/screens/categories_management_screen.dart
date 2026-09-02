import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/database/database_provider.dart';
import '../../../../core/theme/category_colors.dart';
import '../../../../core/widgets/confirm_dialog.dart';
import '../providers/categories_providers.dart';

final managedCategoryRowsProvider = StreamProvider((ref) {
  return ref.watch(databaseProvider).watchCategories();
});

class _CategoryNameDialog extends StatefulWidget {
  const _CategoryNameDialog({
    required this.title,
    required this.confirmLabel,
    this.initialValue,
    this.hintText,
  });

  final String title;
  final String confirmLabel;
  final String? initialValue;
  final String? hintText;

  @override
  State<_CategoryNameDialog> createState() => _CategoryNameDialogState();
}

class _CategoryNameDialogState extends State<_CategoryNameDialog> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() => Navigator.pop(context, _controller.text.trim());

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: TextField(
        controller: _controller,
        autofocus: true,
        textCapitalization: TextCapitalization.words,
        decoration: InputDecoration(hintText: widget.hintText),
        onTapOutside: (_) => FocusManager.instance.primaryFocus?.unfocus(),
        onSubmitted: (_) => _submit(),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(onPressed: _submit, child: Text(widget.confirmLabel)),
      ],
    );
  }
}

/// Screen for adding, renaming, and deleting custom categories.
class CategoriesManagementScreen extends ConsumerWidget {
  const CategoriesManagementScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(managedCategoryRowsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Categories')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddDialog(context, ref),
        icon: const Icon(Icons.add),
        label: const Text('Add'),
      ),
      body: categoriesAsync.when(
        data: (categories) {
          if (categories.isEmpty) {
            return const Center(
              child: Text('No categories yet. Tap Add to create one.'),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: categories.length,
            separatorBuilder: (_, _) => const Divider(height: 1, indent: 72),
            itemBuilder: (context, index) {
              final category = categories[index];
              return Dismissible(
                key: ValueKey(category.id),
                direction: DismissDirection.endToStart,
                background: Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 20),
                  color: Theme.of(context).colorScheme.errorContainer,
                  child: Icon(
                    Icons.delete_outline,
                    color: Theme.of(context).colorScheme.onErrorContainer,
                  ),
                ),
                confirmDismiss: (_) =>
                    _confirmDeleteCategory(context, category.name),
                onDismissed: (_) {
                  ref
                      .read(categoryRepositoryProvider)
                      .deleteCategory(category.id);
                },
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: CategoryColors.fromArgb(
                      category.color,
                    ).withValues(alpha: 0.2),
                    foregroundColor: CategoryColors.fromArgb(category.color),
                    child: Text(category.name[0].toUpperCase()),
                  ),
                  title: Text(category.name),
                  trailing: PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert),
                    itemBuilder: (context) => const [
                      PopupMenuItem(value: 'rename', child: Text('Rename')),
                      PopupMenuItem(value: 'delete', child: Text('Delete')),
                    ],
                    onSelected: (value) async {
                      if (value == 'rename') {
                        await _showRenameDialog(
                          context,
                          ref,
                          category.id,
                          category.name,
                        );
                      } else if (value == 'delete') {
                        final confirmed = await _confirmDeleteCategory(
                          context,
                          category.name,
                        );
                        if (confirmed) {
                          await ref
                              .read(categoryRepositoryProvider)
                              .deleteCategory(category.id);
                        }
                      }
                    },
                  ),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }

  Future<bool> _confirmDeleteCategory(BuildContext context, String name) {
    return showConfirmDialog(
      context,
      title: 'Delete category?',
      message:
          'Remove "$name" from suggestions? Activities using it will keep their category.',
    );
  }

  Future<void> _showAddDialog(BuildContext context, WidgetRef ref) async {
    final result = await showDialog<String>(
      context: context,
      builder: (context) => const _CategoryNameDialog(
        title: 'New category',
        confirmLabel: 'Add',
        hintText: 'e.g. Fitness',
      ),
    );
    if (result != null && result.isNotEmpty) {
      try {
        await ref.read(categoryRepositoryProvider).addCategory(result);
      } catch (_) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Category already exists')),
          );
        }
      }
    }
  }

  Future<void> _showRenameDialog(
    BuildContext context,
    WidgetRef ref,
    int id,
    String currentName,
  ) async {
    final result = await showDialog<String>(
      context: context,
      builder: (context) => _CategoryNameDialog(
        title: 'Rename category',
        confirmLabel: 'Save',
        initialValue: currentName,
      ),
    );
    if (result != null && result.isNotEmpty && result != currentName) {
      await ref.read(categoryRepositoryProvider).renameCategory(id, result);
    }
  }
}
