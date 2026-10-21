// Вкладка всех мероприятий: поиск, категории и фильтр прошедших событий.
import 'package:flutter/material.dart';

import '../models/event.dart';
import '../widget/empty_state.dart';
import '../widget/event_list.dart';
import '../models/event_category.dart';

class EventsTab extends StatefulWidget {
  const EventsTab({
    super.key,
    required this.events,
    required this.onToggleFavourite,
    this.onOpen,
  });
  final ValueChanged<Event>? onOpen;
  final List<Event> events;
  final ValueChanged<Event> onToggleFavourite;

  @override
  State<EventsTab> createState() => _EventsTabState();
}

class _EventsTabState extends State<EventsTab> {
  final _searchController = TextEditingController();
  // Поля фильтра: текст поиска, категория (null = Все), показ прошлого.
  String _query = '';
  EventCategory? _category;
  bool _showPast = false;
  // Очищает введённый запрос; выбранные фильтры сохраняются.
  void _clearSearch() {
    _searchController.clear();
    setState(() {
      _query = '';
    });
  }

  @override
  // Освобождает контроллер поиска.
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  // Фильтрует данные и строит поиск, чипы и список.
  Widget build(BuildContext context) {
    final query = _query.trim().toLowerCase();
    // Поиск без учёта регистра + категория + фильтр по дате.
    final filtered = widget.events.where((event) {
      final matchesQuery = event.title.toLowerCase().contains(query);
      final matchesCategory = _category == null || event.category == _category;
      final matchesDate = _showPast || !event.isPast;
      return matchesCategory && matchesQuery && matchesDate;
    }).toList();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(12),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Поиск',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _query.isEmpty
                  ? null
                  : IconButton(
                      tooltip: 'Очистить',
                      icon: const Icon(Icons.clear),
                      onPressed: _clearSearch,
                    ),
            ),
            onChanged: (value) {
              setState(() {
                _query = value;
              });
            },
          ),
        ),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            children: [
              ChoiceChip(
                // кнопка выбора категории
                label: const Text('Все'),
                selected: _category == null,
                onSelected: (selected) {
                  setState(() {
                    _category = null;
                  });
                },
              ),
              for (final category in EventCategory.values)
                Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: ChoiceChip(
                    label: Text(category.label),
                    avatar: Icon(category.icon),
                    selected: _category == category,
                    onSelected: (selected) {
                      setState(() {
                        _category = selected ? category : null;
                      });
                    },
                  ),
                ),
            ],
          ),
        ),
        Align(
          alignment: Alignment.centerLeft,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: FilterChip(
              label: const Text('Показывать прошедшие'),
              selected: _showPast,
              onSelected: (selected) {
                setState(() {
                  _showPast = selected;
                });
              },
            ),
          ),
        ),
        // Expanded отдаёт списку оставшееся место и не даёт Column переполниться.
        Expanded(
          child: filtered.isEmpty
              ? EmptyState(
                  icon: Icons.search_off,
                  message: 'Ничего не найдено',
                  actionLabel: 'Очистить поиск',
                  onAction: _clearSearch,
                )
              : EventList(
                  events: filtered,
                  onToggleFavourite: widget.onToggleFavourite,
                  onOpen: widget.onOpen,
                ),
        ),
      ],
    );
  }
}
