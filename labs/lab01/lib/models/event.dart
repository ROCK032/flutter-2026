// Неизменяемая модель мероприятия: данные, вычисляемые свойства и copyWith.
import 'event_category.dart';
import 'countdown.dart';

class Event {
  // Приватный const-конструктор заполняет только final-поля.
  const Event._({
    // ._ это имя конструктора
    required this.title,
    required this.category,
    required this.startsAt,
    required this.location,
    required this.capacity,
    required this.attendees,
    this.isOnline = false,
    this.description,
    this.isFavourite = false,
  });
  // Основные данные. final запрещает менять поля существующего объекта.
  final String title;
  final EventCategory category;
  final DateTime startsAt;
  final String location;
  final int capacity;
  final List<String> attendees;
  final bool isOnline;
  final String? description;
  final bool isFavourite;

  // Фабрика защищает список: создаёт неизменяемую копию attendees.
  factory Event({
    required String title,
    required EventCategory category,
    required DateTime startsAt,
    required String location,
    required int capacity,
    List<String> attendees = const [],
    bool isOnline = false,
    String? description,
    bool isFavourite = false,
  }) {
    return Event._(
      title: title,
      category: category,
      startsAt: startsAt,
      location: location,
      capacity: capacity,
      attendees: List<String>.unmodifiable(
        attendees,
      ), // копия списка участников, который нельзя изменять
      isOnline: isOnline,
      description: description,
      isFavourite: isFavourite,
    );
  }
  int get count => attendees.length; // количество участников
  int get freePlaces =>
      capacity - count; //вместимость минус количество участников
  bool get isFull => count >= capacity; // если лимит достигнут или превышен
  // any проверяет, есть ли хотя бы один участник с таким именем.
  bool contains(String name) => attendees.any((person) => person == name);
  ({int taken, int free}) get places => (
    taken: count, // сколько мест занято
    free: freePlaces, //сколько свободно
  );
  bool get isPast => startsAt.isBefore(DateTime.now()); // Если мероприятие началось вчера — получим true. Если начнётся завтра — false
  //startsAt.isBefore(...) — проверяет, наступило ли начало мероприятия раньше текущего момента.

  // Принятое правило приложения: событие длится один час.
  Countdown get countdown {
    // Этот getter определяет состояние мероприятия по текущему времени:
    final now = DateTime.now();
    if (now.isBefore(startsAt)) {
      return Upcoming(startsAt.difference(now)); // сколько осталось до начала
    }
    final elapsed = now.difference(startsAt); // сколько прошло после начала
    if (elapsed < const Duration(hours: 1)) {
      return Started(elapsed);
    }
    return const Ended(); // Прошёл час или больше
  }

  // Значения по умолчанию для формы создания нового мероприятия.
  factory Event.empty() => Event(
    title: '',
    category: EventCategory.technology,
    startsAt: DateTime.now().add(
      const Duration(days: 1),
    ), // текущее время плюс одни сутки
    location: '',
    capacity: 30,
  );
  // Возвращает новый Event: заменяет переданные поля, сохраняет остальные.
  Event copyWith({
    String? title,
    EventCategory? category,
    DateTime? startsAt,
    String? location,
    int? capacity,
    List<String>? attendees,
    bool? isOnline,
    String? description,
    bool clearDescription = false,
    bool? isFavourite,
  }) {
    return Event(
      title: title ?? this.title,
      category: category ?? this.category,
      startsAt: startsAt ?? this.startsAt,
      location: location ?? this.location,
      capacity: capacity ?? this.capacity,
      attendees: attendees ?? this.attendees,
      isOnline: isOnline ?? this.isOnline,
      description: clearDescription ? null : description ?? this.description,
      isFavourite: isFavourite ?? this.isFavourite,
    );
  }
}
