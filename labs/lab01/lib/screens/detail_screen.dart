// Подробности мероприятия: отсчёт, участники, запись, редактирование и удаление.
import 'package:flutter/material.dart';

import '../models/countdown.dart';
import '../routes.dart';
import '../utils/format.dart';
import '../widget/empty_state.dart';
import '../widget/event_header.dart';
import '../models/event.dart';

import 'dart:async';

// Команды меню AppBar: enum позволяет избежать опечаток в строках.
enum _DetailAction { edit, delete }

class DetailScreen extends StatefulWidget {
  const DetailScreen({super.key, required this.arguments});

  final DetailArguments arguments;

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  // Текущая модель и статус времени; Timer обновляет только отсчёт.
  late Event _event;
  late Countdown _countdown;
  late final Timer _timer;

  @override
  // Запускает обновление раз в минуту при открытии экрана.
  void initState() {
    super.initState();
    _event = widget.arguments.event;
    _countdown = _event.countdown;

    _timer = Timer.periodic(const Duration(minutes: 1), (_) {
      final next = _event.countdown;

      if (_countdown is Ended && next is Ended) return;

      setState(() {
        _countdown = next;
      });
    });
  }

  @override
  // Обязательно останавливаем таймер при закрытии подробностей.
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  // Проверяет имя/места, спрашивает подтверждение и меняет список участников.
  Future<void> _toggleRegistration() async {
    final name = widget.arguments.profile.name.trim();

    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Сначала укажите имя в профиле'),
          action: SnackBarAction(
            label: 'Профиль',
            onPressed: widget.arguments.onProfileRequested,
          ),
        ),
      );
      return;
    }

    final isJoined = _event.contains(name);
    if (!isJoined && _event.isFull) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(isJoined ? 'Отменить запись?' : 'Записаться?'),
        content: Text(_event.title),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Назад'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Подтвердить'),
          ),
        ],
      ),
    );

    if (!mounted || confirmed != true) return;

    final attendees = isJoined
        ? _event.attendees.where((person) => person != name).toList()
        : [..._event.attendees, name];

    final updatedEvent = _event.copyWith(attendees: attendees);

    setState(() {
      _event = updatedEvent;
    });

    widget.arguments.onChanged(updatedEvent);
  }

  // Удаляет только после true из диалога; само удаление выполняет Shell.
  Future<void> _deleteEvent() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Удалить мероприятие?'),
        content: Text(_event.title),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Отмена'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Удалить'),
          ),
        ],
      ),
    );

    if (!mounted || confirmed != true) return;

    widget.arguments.onDelete();
  }

  // Форма возвращает модель; обновляем подробности, отсчёт и общий список.
  Future<void> _editEvent() async {
    final updatedEvent = await Navigator.pushNamed<Event>(
      context,
      Routes.form,
      arguments: FormArguments(event: _event),
    );
    if (!mounted || updatedEvent == null) return;
    setState(() {
      _event = updatedEvent;
      _countdown = updatedEvent.countdown;
    });
    widget.arguments.onChanged(updatedEvent);
  }

  @override
  // Строит вкладки о событии и участников; данные берёт из текущего _event.
  Widget build(BuildContext context) {
    final event = _event;
    final (taken: taken, free: free) = event.places;
    final description = event.description;
    final locationLabel = event.isOnline ? 'Ссылка' : 'Место';
    final profileName = widget.arguments.profile.name.trim();
    final isJoined = profileName.isNotEmpty && event.contains(profileName);

    // Все варианты sealed Countdown обработаны явно, поэтому default не нужен.
    final countdownText = switch (_countdown) {
      Upcoming(:final remaining) =>
        'До начала: ${remaining.inHours} ч ${remaining.inMinutes % 60} мин',
      Started(:final elapsed) => 'Началось ${elapsed.inMinutes} мин назад',
      Ended() => 'Мероприятие завершилось',
    };

    return DefaultTabController(
      // хранит выбранную вкладку
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Мероприятие'),
          actions: [
            PopupMenuButton<_DetailAction>(
              tooltip: 'Действия',
              onSelected: (action) {
                switch (action) {
                  case _DetailAction.edit:
                    _editEvent();
                  case _DetailAction.delete:
                    _deleteEvent();
                }
              },
              itemBuilder: (context) => const [
                PopupMenuItem(
                  value: _DetailAction.edit,
                  child: Text('Редактировать'),
                ),
                PopupMenuItem(
                  value: _DetailAction.delete,
                  child: Text('Удалить'),
                ),
              ],
            ),
          ],
          bottom: TabBar(
            // показывает кнопки вкладок
            tabs: [
              const Tab(text: 'О событии'),
              Tab(text: 'Участники (${event.count})'),
            ],
          ),
        ),
        body: TabBarView(
          // показывает содержимое выбранной вкладки.
          children: [
            ListView(
              padding: const EdgeInsets.all(16),
              children: [
                EventHeader(event: event, countdownText: countdownText),
                const SizedBox(height: 12),
                Text(
                  event.title,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 12),
                Text('Дата: ${formatDateTime(event.startsAt)}'),
                Text('$locationLabel: ${event.location}'),
                Text('Занято: $taken. Свободно: $free.'),
                if (description != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Text(description),
                  ),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: event.isFull && !isJoined
                      ? null
                      : _toggleRegistration,
                  child: Text(
                    isJoined
                        ? 'Отменить запись'
                        : event.isFull
                        ? 'Мест нет'
                        : 'Записаться',
                  ),
                ),
              ],
            ),
            event.attendees.isEmpty
                ? const EmptyState(
                    icon: Icons.people_outline,
                    message: 'Пока никто не записался',
                  )
                : ListView.separated(
                    itemCount: event.count,
                    separatorBuilder: (context, index) => const Divider(),
                    itemBuilder: (context, index) {
                      final name = event.attendees[index];
                      final isYou =
                          profileName.isNotEmpty && name == profileName;

                      return ListTile(
                        title: Text(
                          name,
                          style: isYou
                              ? Theme.of(context).textTheme.titleMedium
                                    ?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .primary,
                                    )
                              : null,
                        ),
                        trailing: isYou ? const Text('Вы') : null,
                      );
                    },
                  ),
          ],
        ),
      ),
    );
  }
}
