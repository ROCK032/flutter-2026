// Создаёт и редактирует мероприятие, проверяет поля и возвращает Event через pop.
import 'package:flutter/material.dart';

import '../models/event.dart';
import '../models/event_category.dart';
import '../routes.dart';
import '../utils/format.dart';

class EventFormScreen extends StatefulWidget {
  const EventFormScreen({super.key, required this.arguments});
  final FormArguments arguments;

  @override
  State<EventFormScreen> createState() => _EventFormScreenState();
}

class _EventFormScreenState extends State<EventFormScreen> {
  // Ключ проверяет все поля; FocusNode управляет переходами клавиатуры.
  final _formKey = GlobalKey<FormState>();
  final _titleFocus = FocusNode();
  final _locationFocus = FocusNode();
  final _capacityFocus = FocusNode();
  final _descriptionFocus = FocusNode();
  final _dateFocus = FocusNode();
  final _timeFocus = FocusNode();
  // Контроллеры хранят текст, исходная модель нужна для сравнения изменений.
  late final Event _initialEvent;
  late final TextEditingController _titleController;
  late final TextEditingController _locationController;
  late final TextEditingController _capacityController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _dateController;
  late final TextEditingController _timeController;
  EventCategory? _category;
  DateTime? _date;
  TimeOfDay? _time;
  bool _isOnline = false;
  bool _dirty = false;
  bool _saving = false;
  bool _closing = false;
  bool _confirmingDiscard = false;

  // Собираем дату и часы с минутами в один DateTime.
  DateTime? get _selectedStartsAt {
    final date = _date;
    final time = _time;
    if (date == null || time == null) return null;
    return DateTime(date.year, date.month, date.day, time.hour, time.minute);
  }

  // Сравниваем текущие значения с теми, с которыми открылась форма.
  bool get _hasChanges =>
      _titleController.text != _initialEvent.title ||
      _locationController.text != _initialEvent.location ||
      _capacityController.text != _initialEvent.capacity.toString() ||
      _descriptionController.text != (_initialEvent.description ?? '') ||
      _category != _initialEvent.category ||
      _isOnline != _initialEvent.isOnline ||
      _date != DateUtils.dateOnly(_initialEvent.startsAt) ||
      _time != TimeOfDay.fromDateTime(_initialEvent.startsAt);

  // Создаём контроллеры один раз; для нового события используем Event.empty().
  @override
  void initState() {
    super.initState();
    _initialEvent = widget.arguments.event ?? Event.empty();
    _titleController = TextEditingController(text: _initialEvent.title);
    _locationController = TextEditingController(text: _initialEvent.location);
    _capacityController = TextEditingController(
      text: '${_initialEvent.capacity}',
    );
    _descriptionController = TextEditingController(
      text: _initialEvent.description ?? '',
    );
    _category = _initialEvent.category;
    _isOnline = _initialEvent.isOnline;
    _date = DateUtils.dateOnly(_initialEvent.startsAt);
    _time = TimeOfDay.fromDateTime(_initialEvent.startsAt);
    _dateController = TextEditingController(
      text: formatDate(_initialEvent.startsAt),
    );
    _timeController = TextEditingController(
      text: formatTime(_initialEvent.startsAt),
    );
  }

  // Освобождаем ресурсы при закрытии формы.
  @override
  void dispose() {
    for (final controller in [
      _titleController,
      _locationController,
      _capacityController,
      _descriptionController,
      _dateController,
      _timeController,
    ]) {
      controller.dispose();
    }
    for (final focus in [
      _titleFocus,
      _locationFocus,
      _capacityFocus,
      _descriptionFocus,
      _dateFocus,
      _timeFocus,
    ]) {
      focus.dispose();
    }
    super.dispose();
  }

  // Если вернуть исходные значения, предупреждение о выходе исчезнет.
  void _refreshDirty() {
    if (_closing) return;
    final changed = _hasChanges;
    if (changed == _dirty) return;
    setState(() => _dirty = changed);
  }

  // Cancel в календаре сохраняет прежнюю дату.
  Future<void> _pickDate() async {
    FocusScope.of(context).unfocus();
    final selected = await showDatePicker(
      context: context,
      initialDate: _date ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100, 12, 31),
    );
    if (!mounted || selected == null) return;
    setState(() {
      _date = selected;
      _dateController.text = formatDate(selected);
    });
    _refreshDirty();
  }

  // Cancel в выборе времени сохраняет прежние часы и минуты.
  Future<void> _pickTime() async {
    FocusScope.of(context).unfocus();
    final selected = await showTimePicker(
      context: context,
      initialTime: _time ?? TimeOfDay.now(),
    );
    if (!mounted || selected == null) return;
    setState(() {
      _time = selected;
      _timeController.text = formatTime(
        DateTime(2000, 1, 1, selected.hour, selected.minute),
      );
    });
    _refreshDirty();
  }

  // Новое событие должно быть в будущем; прошедшее разрешено редактировать.
  String? _validateSchedule() {
    final startsAt = _selectedStartsAt;
    if (startsAt == null) return 'Выберите дату и время';
    if (widget.arguments.event == null && !startsAt.isAfter(DateTime.now())) {
      return 'Начало должно быть в будущем';
    }
    return null;
  }

  // Разрешаем выход, ждём обновления PopScope и возвращаем результат.
  Future<void> _close(Event? result) async {
    setState(() {
      _closing = true;
      _dirty = false;
    });
    await WidgetsBinding.instance.endOfFrame;
    if (!mounted) return;
    Navigator.pop(context, result);
  }

  // Один диалог для стрелки AppBar и системного возврата Android.
  Future<void> _confirmDiscard(bool didPop) async {
    if (didPop || _saving || _closing || _confirmingDiscard) return;
    _confirmingDiscard = true;
    final discard = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Отменить изменения?'),
        content: const Text('Несохранённые данные будут потеряны.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Продолжить'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Выйти'),
          ),
        ],
      ),
    );
    if (!mounted) return;
    _confirmingDiscard = false;
    if (discard == true) await _close(null);
  }

  // Один validate, секундная задержка, защита от двойного нажатия, pop(Event).
  Future<void> _save() async {
    if (_saving || _closing) return;
    if (_formKey.currentState?.validate() != true) return;
    final startsAt = _selectedStartsAt;
    final category = _category;
    final capacity = int.tryParse(_capacityController.text.trim());
    // Проверки уточняют nullable-типы после успешной валидации полей.
    if (startsAt == null || category == null || capacity == null) return;
    final description = _descriptionController.text.trim();
    final result = _initialEvent.copyWith(
      title: _titleController.text.trim(),
      location: _locationController.text.trim(),
      capacity: capacity,
      category: category,
      startsAt: startsAt,
      isOnline: _isOnline,
      description: description,
      clearDescription: description.isEmpty,
    );
    FocusScope.of(context).unfocus();
    setState(() => _saving = true);
    await Future<void>.delayed(const Duration(seconds: 1));
    if (!mounted) return;
    await _close(result);
  }

  // Прокрутка позволяет добраться до Save даже с открытой клавиатурой.
  @override
  Widget build(BuildContext context) => PopScope<Event>(
    canPop: !_dirty,
    onPopInvokedWithResult: (didPop, result) => _confirmDiscard(didPop),
    child: Scaffold(
      appBar: AppBar(
        title: Text(
          widget.arguments.event == null
              ? 'Новое мероприятие'
              : 'Редактирование',
        ),
      ),
      body: SafeArea(
        child: AbsorbPointer(
          absorbing: _saving,
          child: Form(
            key: _formKey,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Название: 3–60 символов, счётчик под полем.
                  TextFormField(
                    controller: _titleController,
                    focusNode: _titleFocus,
                    decoration: const InputDecoration(labelText: 'Название'),
                    maxLength: 60,
                    keyboardType: TextInputType.text,
                    textInputAction: TextInputAction.next,
                    onFieldSubmitted: (_) => _locationFocus.requestFocus(),
                    onChanged: (_) => _refreshDirty(),
                    onTapOutside: (_) => FocusScope.of(context).unfocus(),
                    validator: (value) {
                      final title = value?.trim() ?? '';
                      return title.length < 3 || title.length > 60
                          ? 'Введите от 3 до 60 символов'
                          : null;
                    },
                  ),
                  const SizedBox(height: 16),
                  // map превращает значения enum в пункты выпадающего списка.
                  DropdownButtonFormField<EventCategory>(
                    initialValue: _category,
                    isExpanded: true,
                    decoration: const InputDecoration(labelText: 'Категория'),
                    items: EventCategory.values
                        .map(
                          (category) => DropdownMenuItem(
                            value: category,
                            child: Row(
                              children: [
                                Icon(category.icon),
                                const SizedBox(width: 8),
                                Expanded(child: Text(category.label)),
                              ],
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      setState(() => _category = value);
                      _refreshDirty();
                    },
                    validator: (value) =>
                        value == null ? 'Выберите категорию' : null,
                  ),
                  const SizedBox(height: 8),
                  // Онлайн-режим меняет подпись, клавиатуру и проверку ссылки.
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Онлайн-мероприятие'),
                    value: _isOnline,
                    onChanged: (value) {
                      setState(() => _isOnline = value);
                      _refreshDirty();
                    },
                  ),
                  TextFormField(
                    controller: _locationController,
                    focusNode: _locationFocus,
                    decoration: InputDecoration(
                      labelText: _isOnline ? 'Ссылка' : 'Место проведения',
                      hintText: _isOnline ? 'https://example.com' : null,
                    ),
                    keyboardType: _isOnline
                        ? TextInputType.url
                        : TextInputType.streetAddress,
                    textInputAction: TextInputAction.next,
                    onFieldSubmitted: (_) => _capacityFocus.requestFocus(),
                    onChanged: (_) => _refreshDirty(),
                    onTapOutside: (_) => FocusScope.of(context).unfocus(),
                    validator: (value) {
                      final location = value?.trim() ?? '';
                      if (location.isEmpty) {
                        return _isOnline ? 'Укажите ссылку' : 'Укажите место';
                      }
                      if (_isOnline && !location.contains('://')) {
                        return 'Ссылка должна содержать ://';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  // Лимит: целое 1–500, не меньше числа уже записанных участников.
                  TextFormField(
                    controller: _capacityController,
                    focusNode: _capacityFocus,
                    decoration: const InputDecoration(
                      labelText: 'Количество мест',
                    ),
                    keyboardType: TextInputType.number,
                    textInputAction: TextInputAction.next,
                    onFieldSubmitted: (_) => _descriptionFocus.requestFocus(),
                    onChanged: (_) => _refreshDirty(),
                    onTapOutside: (_) => FocusScope.of(context).unfocus(),
                    validator: (value) {
                      final capacity = int.tryParse(value?.trim() ?? '');
                      if (capacity == null || capacity < 1 || capacity > 500) {
                        return 'Введите целое число от 1 до 500';
                      }
                      if (capacity < _initialEvent.count) {
                        return 'Уже записано: ${_initialEvent.count}';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  // Поля только для чтения открывают системные диалоги выбора.
                  TextFormField(
                    controller: _dateController,
                    focusNode: _dateFocus,
                    readOnly: true,
                    decoration: const InputDecoration(
                      labelText: 'Дата',
                      suffixIcon: Icon(Icons.calendar_month),
                    ),
                    onTap: _pickDate,
                    onTapOutside: (_) => FocusScope.of(context).unfocus(),
                    validator: (_) =>
                        _date == null ? 'Выберите дату' : _validateSchedule(),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _timeController,
                    focusNode: _timeFocus,
                    readOnly: true,
                    decoration: const InputDecoration(
                      labelText: 'Время',
                      suffixIcon: Icon(Icons.schedule),
                    ),
                    onTap: _pickTime,
                    onTapOutside: (_) => FocusScope.of(context).unfocus(),
                    validator: (_) =>
                        _time == null ? 'Выберите время' : _validateSchedule(),
                  ),
                  const SizedBox(height: 16),
                  // Пустое описание допустимо; при сохранении оно превращается в null.
                  TextFormField(
                    controller: _descriptionController,
                    focusNode: _descriptionFocus,
                    decoration: const InputDecoration(
                      labelText: 'Описание (необязательно)',
                    ),
                    minLines: 2,
                    maxLines: 4,
                    keyboardType: TextInputType.multiline,
                    textInputAction: TextInputAction.done,
                    onFieldSubmitted: (_) => _descriptionFocus.unfocus(),
                    onChanged: (_) => _refreshDirty(),
                    onTapOutside: (_) => FocusScope.of(context).unfocus(),
                    validator: (_) => null,
                  ),
                  const SizedBox(height: 24),
                  FilledButton(
                    onPressed: _saving ? null : _save,
                    child: _saving
                        ? const SizedBox.square(
                            dimension: 24,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Сохранить'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    ),
  );
}
