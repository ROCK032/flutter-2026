// Вкладка профиля: сохраняет имя и группу, показывает участие и переключает тему.
import 'package:flutter/material.dart';

import '../models/profile.dart';
import '../models/event.dart';

class ProfileTab extends StatefulWidget {
  const ProfileTab({
    super.key,
    required this.profile,
    required this.onChanged,
    required this.events,
    required this.themeMode,
    required this.onThemeModeChanged,
  });
  final Profile profile;
  final ValueChanged<Profile> onChanged;
  final List<Event> events;
  final ThemeMode themeMode;
  final ValueChanged<ThemeMode> onThemeModeChanged;
  @override
  State<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> {
  final _nameKey = GlobalKey<FormFieldState<String>>();
  late final TextEditingController _nameController;
  final _groupKey = GlobalKey<FormFieldState<String>>();
  late final TextEditingController _groupController;
  final _groupPattern = RegExp(
    r'^[A-Za-zА-Яа-яЁё]{1,6}-\d{1,4}$',
  ); // RegExp проверяет формат: буквы-дефис-цифры, например CS-101
  // Считается заново при каждом build из общего списка Shell.
  int get _joinedCount {
    final name = widget.profile.name.trim();
    if (name.isEmpty) return 0;
    // fold накапливает число мероприятий с участием пользователя.
    return widget.events.fold<int>(
      0,
      (count, event) => count + (event.contains(name) ? 1 : 0),
    );
  }

  @override
  // Начальный текст контроллеров берём из сохранённого профиля.
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.profile.name);
    _groupController = TextEditingController(text: widget.profile.group);
  }

  @override
  // Синхронизирует поля после изменения профиля родителем.
  void didUpdateWidget(covariant ProfileTab oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.profile.name != widget.profile.name) {
      _nameController.text = widget.profile.name;
    }

    if (oldWidget.profile.group != widget.profile.group) {
      _groupController.text = widget.profile.group;
    }
  }

  @override
  // Освобождает контроллеры ввода.
  void dispose() {
    _nameController.dispose();
    _groupController.dispose();
    super.dispose();
  }

  @override
  // Поля сохраняются по Enter; ChoiceChip отправляет выбранную тему вверх.
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.all(16),
    children: [
      TextFormField(
        key: _nameKey,
        controller: _nameController,
        decoration: const InputDecoration(labelText: 'Имя'),
        keyboardType: TextInputType.name,
        textInputAction: TextInputAction.done,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        validator: (value) =>
            value == null || value.trim().isEmpty ? 'Введите имя' : null,
        onFieldSubmitted: (value) {
          if (_nameKey.currentState?.validate() != true) return;
          widget.onChanged(widget.profile.copyWith(name: value.trim()));
          FocusScope.of(context).unfocus();
        },
        onTapOutside: (_) => FocusScope.of(context).unfocus(),
      ),
      const SizedBox(height: 16),
      TextFormField(
        key: _groupKey,
        controller: _groupController,
        decoration: const InputDecoration(
          labelText: 'Группа',
          hintText: 'CS-101',
        ),
        keyboardType: TextInputType.text,
        textInputAction: TextInputAction.done,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        validator: (value) => _groupPattern.hasMatch(value?.trim() ?? '')
            ? null
            : 'Формат группы: CS-101',
        onFieldSubmitted: (value) {
          if (_groupKey.currentState?.validate() != true) return;

          widget.onChanged(widget.profile.copyWith(group: value.trim()));
          FocusScope.of(context).unfocus();
        },
        onTapOutside: (_) => FocusScope.of(context).unfocus(),
      ),
      const SizedBox(height: 16),
      Text('Мероприятий с вашим участием: $_joinedCount'),
      const SizedBox(height: 24),
      const Text('Тема приложения'),
      const SizedBox(height: 8),
      Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          for (final mode in ThemeMode.values)
            ChoiceChip(
              label: Text(switch (mode) {
                ThemeMode.system => 'Системная',
                ThemeMode.light => 'Светлая',
                ThemeMode.dark => 'Тёмная',
              }),
              selected: widget.themeMode == mode,
              onSelected: (selected) {
                if (selected) {
                  widget.onThemeModeChanged(mode);
                }
              },
            ),
        ],
      ),
    ],
  );
}
