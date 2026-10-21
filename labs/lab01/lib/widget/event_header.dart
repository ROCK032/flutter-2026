// Шапка подробностей: изображение из assets, категория и обратный отсчёт поверх него.
import 'package:flutter/material.dart';

import '../models/event.dart';

class EventHeader extends StatelessWidget {
  const EventHeader({
    super.key,
    required this.event,
    required this.countdownText,
  });

  final Event event;
  final String countdownText;

  // Stack накладывает подписи на картинку; цвета берём из текущей темы.
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final foreground = event.category.foregroundColor(scheme);
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: AspectRatio(
        aspectRatio: 16 / 9,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(
              'assets/campus_header.png',
              fit: BoxFit.cover,
              semanticLabel: 'Студенты в университетском кампусе',
            ),
            Positioned(
              top: 12,
              left: 12,
              right: 12,
              child: Align(
                alignment: Alignment.topLeft,
                child: Chip(
                  avatar: Icon(event.category.icon, color: foreground),
                  label: Text(event.category.label),
                  labelStyle: TextStyle(color: foreground),
                  backgroundColor: event.category.color(scheme),
                  side: BorderSide.none,
                ),
              ),
            ),
            Positioned(
              bottom: 12,
              left: 12,
              right: 12,
              child: Align(
                alignment: Alignment.bottomRight,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: scheme.surface.withValues(alpha: 0.95),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Text(
                      countdownText,
                      style: Theme.of(context).textTheme.labelLarge
                          ?.copyWith(color: scheme.onSurface),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
