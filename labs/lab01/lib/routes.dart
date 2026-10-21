// Имена маршрутов и типизированные данные для экрана подробностей и формы.
import 'package:flutter/material.dart';

import 'models/event.dart';
import 'models/profile.dart';

// Все имена экранов собраны здесь, чтобы не повторять строки по проекту.
class Routes {
  // хранит имена экранов в одном месте
  static const shell = '/';
  static const detail = '/detail';
  static const form = '/form';
}

// Подробности получают модель и callbacks для изменения данных в Shell.
class DetailArguments {
  // объединяет мероприятие, профиль и функции, которые понадобятся экрану подробностей.
  const DetailArguments({
    required this.event,
    required this.profile,
    required this.onChanged,
    required this.onDelete,
    required this.onProfileRequested,
  });

  final Event event;
  final Profile profile;
  final ValueChanged<Event> onChanged;
  final VoidCallback onDelete;
  final VoidCallback onProfileRequested;
}

// Для создания event == null; для редактирования передаём существующий Event.
class FormArguments {
  // передаст мероприятие в форму редактирования. Если event == null, форма будет создавать новое.
  const FormArguments({this.event});

  final Event? event;
}
