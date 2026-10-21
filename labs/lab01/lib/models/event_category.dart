// Категории мероприятий: подписи, иконки и цвета из темы.
import 'package:flutter/material.dart';

enum EventCategory {
  technology('IT', Icons.computer),
  sport('Спорт', Icons.sports_soccer),
  science('Наука', Icons.science),
  creativity('Творчество', Icons.palette),
  volunteering('Волонтёрство', Icons.volunteer_activism);

  const EventCategory(this.label, this.icon);
  // У каждого значения enum есть подпись и иконка.
  final String label;
  final IconData icon;
  // Исчерпывающий switch: при добавлении категории компилятор потребует цвет.
  Color color(ColorScheme scheme) => switch (this) {
    // switch выбирает цвет по категории.
    EventCategory.technology => scheme.primary,
    EventCategory.sport => scheme.secondary,
    EventCategory.science => scheme.tertiary,
    EventCategory.creativity => scheme.primaryContainer,
    EventCategory.volunteering => scheme.secondaryContainer,
  };

  // Контрастный цвет текста и иконки для выбранного фона категории.
  Color foregroundColor(ColorScheme scheme) => switch (this) {
    EventCategory.technology => scheme.onPrimary,
    EventCategory.sport => scheme.onSecondary,
    EventCategory.science => scheme.onTertiary,
    EventCategory.creativity => scheme.onPrimaryContainer,
    EventCategory.volunteering => scheme.onSecondaryContainer,
  };
}
