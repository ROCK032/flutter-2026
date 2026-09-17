class Author {
  final String name;
  final String? country;

  const Author({required this.name, this.country});
  @override
  String toString() {
    return '$name (${country ?? 'unknown'})';
  }
}

enum Genre {
  craft('Практика'),
  theory('Теория'),
  unknown('Неизвестно');

  final String label;

  const Genre(this.label);
  static Genre fromString(String? raw) {
    if (raw == 'craft') {
      return Genre.craft;
    }
    if (raw == 'theory') {
      return Genre.theory;
    }
    return Genre.unknown;
  }
}

abstract class LibraryItem {
  final String title;
  final int year;

  const LibraryItem({required this.title, required this.year});

  bool get isOld => year < 2000;

  String describe();
}

// Миксин добавляет поведение и имеет доступ к title благодаря on.
mixin Borrowable on LibraryItem {
  String borrowLabel() => 'Можно взять: $title';
}

class Book extends LibraryItem with Borrowable {
  final int pages;
  final Author author;
  final Genre genre;
  final String? description;

  const Book({
    required super.title,
    required super.year,
    required this.pages,
    required this.author,
    required this.genre,
    this.description,
  });
  bool get isLong => pages > 400;
  @override
  String describe() {
    return 'Книга: $title, автор: ${author.name}';
  }

  @override
  String toString() {
    return '$title ($year), автор: ${author.name}, '
        'страниц: $pages, жанр: ${genre.label}';
  }

  Book copyWith({
    String? title,
    int? year,
    int? pages,
    Author? author,
    Genre? genre,
    String? description,
  }) {
    return Book(
      title: title ?? this.title,
      year: year ?? this.year,
      pages: pages ?? this.pages,
      author: author ?? this.author,
      genre: genre ?? this.genre,
      description: description ?? this.description,
    );
  }

  factory Book.fromJson(Map<String, dynamic> json) {
    return Book(
      title: json['title'] as String? ?? 'Без названия',
      year: json['year'] as int? ?? 0,
      pages: json['pages'] as int? ?? 0,
      author: Author(
        name: json['author'] as String? ?? 'Unknown',
        country: json['country'] as String?,
      ),
      genre: Genre.fromString(json['genre'] as String?),
      description: json['description'] as String?,
    );
  }
}

class Magazine extends LibraryItem {
  final int issue;

  const Magazine({
    required super.title,
    required super.year,
    required this.issue,
  });

  @override
  String describe() {
    return 'Журнал: $title ($year), выпуск №$issue';
  }
}

// implements требует реализовать весь интерфейс, включая готовый isOld.
class Ghost implements LibraryItem {
  @override
  final String title;

  @override
  final int year;

  const Ghost({required this.title, required this.year});

  @override
  bool get isOld => year < 2000;

  @override
  String describe() => 'Призрачная запись: $title ($year)';
}
