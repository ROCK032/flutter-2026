// Показывает карточки списком на телефоне и сеткой на широком экране.
import 'package:flutter/material.dart';

import '../models/event.dart';
import 'event_card.dart';

class EventList extends StatelessWidget {
  const EventList({
    super.key,
    required this.events,
    required this.onToggleFavourite,
    this.onOpen,
  });
  final ValueChanged<Event>?
  onOpen; //Здесь onOpen — функция, которая принимает одно мероприятие Event
  final List<Event> events;
  final ValueChanged<Event> onToggleFavourite;

  @override
  // LayoutBuilder получает доступную ширину именно этого виджета.
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // От 600 px показываем сетку; ceil удерживает ширину ячейки не более 360.
        if (constraints.maxWidth >= 600) {
          final columns = (constraints.maxWidth / 360).ceil();

          return GridView.builder(
            padding: const EdgeInsets.all(12),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: columns,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              childAspectRatio: 1.4,
            ),
            itemCount: events.length,
            itemBuilder: (context, index) {
              final event = events[index];

              return EventCard(
                event: event,
                onToggleFavourite: () => onToggleFavourite(event),
                onTap: () => onOpen?.call(event),
              );
            },
          );
        }

        // На телефоне — вертикальный список с промежутками между карточками.
        return ListView.separated(
          padding: const EdgeInsets.all(12),
          itemCount: events.length,
          separatorBuilder: (context, index) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            final event = events[index];

            return EventCard(
              event: event,
              onToggleFavourite: () => onToggleFavourite(event),
              onTap: () => onOpen?.call(event),
            );
          },
        );
      },
    );
  }
}
