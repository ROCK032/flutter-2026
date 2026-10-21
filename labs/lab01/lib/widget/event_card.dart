// Карточка мероприятия: категория, дата, место, остаток мест и избранное.
import 'package:flutter/material.dart';

import '../models/event.dart';
import '../utils/format.dart';

class EventCard extends StatelessWidget {
  const EventCard({
    super.key,
    required this.event,
    required this.onToggleFavourite,
    this.onTap,
  });

  // Данные и callbacks приходят из списка; карточка не хранит общие данные.
  final Event event;
  final VoidCallback onToggleFavourite;
  final VoidCallback? onTap;
  @override
  // InkWell ловит нажатие карточки; IconButton отдельно меняет избранное.
  Widget build(BuildContext context) => Card(
    child: InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            // Значок FULL или остатка мест накладывается на аватар.
            Stack(
              clipBehavior: Clip.none,
              children: [
                CircleAvatar(child: Icon(event.category.icon)),
                if (event.isFull || event.freePlaces <= 5)
                  Positioned(
                    right: -8,
                    bottom: -6,
                    child: Badge(
                      label: Text(
                        event.isFull ? 'FULL' : '${event.freePlaces} left',
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 12),
            // Текст занимает свободную ширину, длинный заголовок обрезается.
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min, // Это позволит колонке текста занимать только необходимую высоту внутри ячейки.
                crossAxisAlignment: CrossAxisAlignment
                    .start, // выравнивает элементы по левому краю
                children: [
                  Text(
                    event.title,
                    style: Theme.of(context).textTheme.titleMedium,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(formatDateTime(event.startsAt)),
                  Text(
                    event.location,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            IconButton(
              tooltip: event.isFavourite
                  ? 'Убрать из избранного'
                  : 'Добавить в избранное',
              icon: Icon(
                event.isFavourite ? Icons.favorite : Icons.favorite_border,
              ),
              onPressed: onToggleFavourite,
            ),
          ],
        ),
      ),
    ),
  );
}
