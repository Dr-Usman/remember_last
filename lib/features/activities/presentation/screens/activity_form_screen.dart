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
    final activity = await ref
        .read(activityRepositoryProvider)
        .getById(widget.activityId!);
    if (activity != null && mounted) {
      _existing = activity;
      _titleController.text = activity.title;
      _categoryController.text = activity.category ?? '';
      _notesController.text = activity.notes ?? '';
      _reminderEnabled =
          activity.reminderDays != null && activity.reminderDays! > 0;
      _reminderType = activity.reminderType;
      // Enabled + none is invalid; treat as custom so their day count is kept.
      if (_reminderEnabled && _reminderType == ReminderType.none) {
        _reminderType = ReminderType.custom;
      }
      if (_reminderEnabled) {
        _reminderDaysController.text =
            '${_reminderType.defaultDays ?? activity.reminderDays}';
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
                    validator: (v) => v == null || v.trim().isEmpty
                        ? 'Title is required'
                        : null,
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
                        (c) => c.toLowerCase().contains(
                          textEditingValue.text.toLowerCase(),
                        ),
                      );
                    },
                    onSelected: (value) => _categoryController.text = value,
                    fieldViewBuilder:
                        (context, controller, focusNode, onSubmitted) {
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
                                icon: const Icon(
                                  Icons.settings_outlined,
                                  size: 20,
                                ),
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
                    'Due interval',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Mark due every X days'),
                    subtitle: const Text('Shows due soon / overdue status'),
                    value: _reminderEnabled,
                    onChanged: (v) {
                      setState(() {
                        _reminderEnabled = v;
                        if (!v) return;
                        // Switch is on/off; preset should never stay on "None".
                        if (_reminderType == ReminderType.none) {
                          _reminderType = ReminderType.weekly;
                        }
                        _syncReminderDaysFromType();
                      });
                    },
                  ),
                  if (_reminderEnabled) ...[
                    const SizedBox(height: 4),
                    DropdownButtonFormField<ReminderType>(
                      initialValue: _reminderType,
                      decoration: const InputDecoration(
                        labelText: 'Frequency preset',
                      ),
                      items: ReminderType.selectable
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
                          _syncReminderDaysFromType();
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _reminderDaysController,
                      enabled: _reminderType == ReminderType.custom,
                      decoration: InputDecoration(
                        labelText: 'Days until due',
                        suffixText: 'days',
                        helperText: _reminderType == ReminderType.custom
                            ? null
                            : 'Fixed by ${_reminderType.label.toLowerCase()} preset',
                      ),
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      validator: (v) {
                        if (!_reminderEnabled) return null;
                        if (_reminderType.hasFixedDays) return null;
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
                      : Text(
                          widget.isEditing ? 'Save Changes' : 'Create Activity',
                        ),
                ),
              ),
            ),
    );
  }

  void _syncReminderDaysFromType() {
    final days = _reminderType.defaultDays;
    if (days != null) {
      _reminderDaysController.text = '$days';
    } else if (_reminderDaysController.text.isEmpty) {
      _reminderDaysController.text = '7';
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _saving = true);

    final repo = ref.read(activityRepositoryProvider);
    final now = DateTime.now();
    final category = _categoryController.text.trim();
    final reminderType = _reminderEnabled ? _reminderType : ReminderType.none;
    final reminderDays = _reminderEnabled
        ? (reminderType.defaultDays ??
              int.parse(_reminderDaysController.text.trim()))
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
          reminderType: reminderType,
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
          reminderType: reminderType,
          createdAt: now,
          updatedAt: now,
        ),
      );
    }

    if (mounted) context.pop();
  }
}
