import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/database/database_provider.dart';
import '../../../../core/router/app_routes.dart';
import '../../../categories/presentation/providers/categories_providers.dart';
import '../../domain/entities/activity.dart';
import '../../domain/enums/reminder_type.dart';

class ActivityFormScreen extends ConsumerStatefulWidget {
  const ActivityFormScreen({super.key, this.activityId});

  final int? activityId;

  bool get isEditing => activityId != null;

  @override
  ConsumerState<ActivityFormScreen> createState() => _ActivityFormScreenState();
}

class _ActivityFormScreenState extends ConsumerState<ActivityFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _categoryController = TextEditingController();
  final _notesController = TextEditingController();
  final _reminderDaysController = TextEditingController();

  ReminderType _reminderType = ReminderType.none;
  bool _reminderEnabled = false;
  bool _loading = true;
  bool _saving = false;
  Activity? _existing;

  @override
  void initState() {
    super.initState();
    if (widget.isEditing) {
      _loadActivity();
    } else {
      _loading = false;
    }
  }

  Future<void> _loadActivity() async {
    final activity =
        await ref.read(activityRepositoryProvider).getById(widget.activityId!);
    if (activity != null && mounted) {
      _existing = activity;
      _titleController.text = activity.title;
      _categoryController.text = activity.category ?? '';
      _notesController.text = activity.notes ?? '';
      _reminderType = activity.reminderType;
      _reminderEnabled =
          activity.reminderDays != null && activity.reminderDays! > 0;
      if (_reminderEnabled) {
        _reminderDaysController.text = '${activity.reminderDays}';
      }
    }
    if (mounted) setState(() => _loading = false);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _categoryController.dispose();
    _notesController.dispose();
    _reminderDaysController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(mergedCategoriesProvider);
    final categoryOptions = categoriesAsync.valueOrNull ?? [];

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isEditing ? 'Edit Activity' : 'New Activity'),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                children: [
                  TextFormField(
                    controller: _titleController,
                    decoration: const InputDecoration(
                      labelText: 'Title *',
                      hintText: 'e.g. Water plants',
                    ),
                    textCapitalization: TextCapitalization.sentences,
                    validator: (v) =>
                        v == null || v.trim().isEmpty ? 'Title is required' : null,
                  ),
                  const SizedBox(height: 16),
                  Autocomplete<String>(
                    // Remount when categories change — Autocomplete only refreshes
                    // options when field text changes, so new categories would stay hidden.
                    key: ValueKey(categoryOptions.join('\u0001')),
                    optionsBuilder: (textEditingValue) {
                      if (textEditingValue.text.isEmpty) {
                        return categoryOptions;
                      }
                      return categoryOptions.where(
                        (c) => c
                            .toLowerCase()
                            .contains(textEditingValue.text.toLowerCase()),
                      );
                    },
                    onSelected: (value) => _categoryController.text = value,
                    fieldViewBuilder: (context, controller, focusNode, onSubmitted) {
                      if (_categoryController.text.isNotEmpty &&
                          controller.text != _categoryController.text) {
                        controller.text = _categoryController.text;
                      }
                      return TextFormField(
                        controller: controller,
                        focusNode: focusNode,
                        decoration: InputDecoration(
                          labelText: 'Category',
                          hintText: 'Home, Vehicle, Personal...',
                          suffixIcon: IconButton(
                            icon: const Icon(Icons.settings_outlined, size: 20),
                            tooltip: 'Manage categories',
                            onPressed: () =>
                                context.push(AppRoutes.categories),
                          ),
                        ),
                        onChanged: (v) => _categoryController.text = v,
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _notesController,
                    decoration: const InputDecoration(
                      labelText: 'Notes',
                      alignLabelWithHint: true,
                    ),
                    maxLines: 3,
                    textCapitalization: TextCapitalization.sentences,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Reminder',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Remind if not done in X days'),
                    subtitle: const Text('Shows due soon / overdue status'),
                    value: _reminderEnabled,
                    onChanged: (v) {
                      setState(() {
                        _reminderEnabled = v;
                        if (v && _reminderDaysController.text.isEmpty) {
                          _reminderDaysController.text =
                              '${_reminderType.defaultDays ?? 7}';
                        }
                      });
                    },
                  ),
                  DropdownButtonFormField<ReminderType>(
                    initialValue: _reminderType,
                    decoration: const InputDecoration(labelText: 'Frequency preset'),
                    items: ReminderType.values
                        .map(
                          (t) => DropdownMenuItem(
                            value: t,
                            child: Text(t.label),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      if (value == null) return;
                      setState(() {
                        _reminderType = value;
                        if (_reminderEnabled && value.defaultDays != null) {
                          _reminderDaysController.text = '${value.defaultDays}';
                        }
                      });
                    },
                  ),
                  if (_reminderEnabled) ...[
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _reminderDaysController,
                      decoration: const InputDecoration(
                        labelText: 'Days until due',
                        suffixText: 'days',
                      ),
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      validator: (v) {
                        if (!_reminderEnabled) return null;
                        final days = int.tryParse(v ?? '');
                        if (days == null || days <= 0) {
                          return 'Enter a valid number of days';
                        }
                        return null;
                      },
                    ),
                  ],
                ],
              ),
            ),
      bottomNavigationBar: _loading
          ? null
          : SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                child: FilledButton(
                  onPressed: _saving ? null : _save,
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(52),
                  ),
                  child: _saving
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(widget.isEditing ? 'Save Changes' : 'Create Activity'),
                ),
              ),
            ),
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _saving = true);

    final repo = ref.read(activityRepositoryProvider);
    final now = DateTime.now();
    final category = _categoryController.text.trim();
    final reminderDays = _reminderEnabled
        ? int.parse(_reminderDaysController.text.trim())
        : null;

    if (widget.isEditing && _existing != null) {
      await repo.update(
        _existing!.copyWith(
          title: _titleController.text.trim(),
          category: category.isEmpty ? null : category,
          notes: _notesController.text.trim().isEmpty
              ? null
              : _notesController.text.trim(),
          reminderDays: reminderDays,
          clearReminderDays: reminderDays == null,
          reminderType: _reminderEnabled ? _reminderType : ReminderType.none,
          updatedAt: now,
        ),
      );
    } else {
      await repo.insert(
        Activity(
          id: 0,
          uuid: const Uuid().v4(),
          title: _titleController.text.trim(),
          category: category.isEmpty ? null : category,
          notes: _notesController.text.trim().isEmpty
              ? null
              : _notesController.text.trim(),
          reminderDays: reminderDays,
          reminderType: _reminderEnabled ? _reminderType : ReminderType.none,
          createdAt: now,
          updatedAt: now,
        ),
      );
    }

    if (mounted) context.pop();
  }
}
