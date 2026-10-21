// Двенадцать начальных мероприятий с датами относительно текущего дня.
import '../models/event.dart';
import '../models/event_category.dart';

// При каждом сбросе создаёт новый список с актуальными датами.
List<Event> createSeedEvents() {
  final now = DateTime.now();

  return [
    // Обязательный пример: название ровно из 60 символов.
    Event(
      title: 'Университетский хакатон: делаем приложения на Flutter вместе',
      category: EventCategory.technology,
      startsAt: now.add(const Duration(days: 2)),
      location: 'Аудитория 301',
      capacity: 30,
      description: 'Разрабатываем приложение в командах.',
    ),
    // Обязательный пример FULL: 2 участника при лимите 2.
    Event(
      title: 'Тренировка по настольному теннису',
      category: EventCategory.sport,
      startsAt: now.add(const Duration(days: 1)),
      location: 'Спортивный зал',
      capacity: 2,
      attendees: ['Али', 'Дана'],
      description: 'Совместная тренировка для начинающих.',
    ),
    // Обязательный пример: мероприятие в прошлом.
    Event(
      title: 'Встреча научного клуба',
      category: EventCategory.science,
      startsAt: now.subtract(const Duration(days: 1)),
      location: 'Аудитория 205',
      capacity: 20,
      description: 'Обсуждение студенческих исследований.',
    ),
    // Обязательный пример: онлайн-режим, вместо адреса — ссылка.
    Event(
      title: 'Онлайн-встреча Flutter-клуба',
      category: EventCategory.technology,
      startsAt: now.add(const Duration(days: 3)),
      location: 'https://example.com/flutter',
      capacity: 40,
      isOnline: true,
      description: 'Обсуждаем вопросы по Flutter.',
    ),
    // Обязательный пример без description: текст в подробностях не выводится.
    Event(
      title: 'Выставка студенческих работ',
      category: EventCategory.creativity,
      startsAt: now.add(const Duration(days: 4)),
      location: 'Холл университета',
      capacity: 50,
      isFavourite: true,
    ),
    Event(
      title: 'Помощь приюту для животных',
      category: EventCategory.volunteering,
      startsAt: now.add(const Duration(days: 5)),
      location: 'Главный вход университета',
      capacity: 10,
      attendees: ['Али', 'Дана', 'Арман', 'Алия', 'Тимур', 'Асель'],
      description: 'Собираемся для поездки в приют.',
    ),
    Event(
      title: 'Волейбол после занятий',
      category: EventCategory.sport,
      startsAt: now.add(const Duration(days: 6)),
      location: 'Спортивная площадка',
      capacity: 12,
      attendees: ['Дана', 'Тимур'],
    ),
    Event(
      title: 'Лекция об искусственном интеллекте',
      category: EventCategory.science,
      startsAt: now.add(const Duration(days: 7)),
      location: 'Актовый зал',
      capacity: 60,
      isFavourite: true,
      description: 'Знакомство с возможностями и ограничениями ИИ.',
    ),
    Event(
      title: 'Вечер настольных игр',
      category: EventCategory.creativity,
      startsAt: now.add(const Duration(days: 8)),
      location: 'Студенческий центр',
      capacity: 15,
      attendees: ['Али', 'Асель'],
    ),
    Event(
      title: 'Сбор книг для школьной библиотеки',
      category: EventCategory.volunteering,
      startsAt: now.add(const Duration(days: 9)),
      location: 'Библиотека университета',
      capacity: 25,
      description: 'Приносим книги и помогаем их рассортировать.',
    ),
    Event(
      title: 'Введение в Git и GitHub',
      category: EventCategory.technology,
      startsAt: now.add(const Duration(days: 10)),
      location: 'Компьютерный класс 102',
      capacity: 20,
      description: 'Практикуемся сохранять изменения проекта.',
    ),
    Event(
      title: 'Утренняя зарядка',
      category: EventCategory.sport,
      startsAt: now.subtract(const Duration(days: 2)),
      location: 'Стадион университета',
      capacity: 20,
      attendees: ['Тимур'],
    ),
  ];
}
