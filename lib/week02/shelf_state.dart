import 'models.dart';

// Все прямые подтипы sealed-класса объявляются в этой библиотеке Dart.
sealed class ShelfState {
  const ShelfState();
}

final class Empty extends ShelfState {
  const Empty();
}

final class Ready extends ShelfState {
  final List<Book> books;

  const Ready(this.books);
}

final class Broken extends ShelfState {
  final String message;

  const Broken(this.message);
}

// Object patterns извлекают поля; switch обязан охватить все три состояния.
String describe(ShelfState state) => switch (state) {
  Empty() => 'Полка пуста',
  Ready(books: final books) => 'Полка готова: ${books.length} книг',
  Broken(message: final message) => 'Ошибка: $message',
};

// Record возвращает два именованных результата без отдельного класса.
({int count, double avgPages}) statsOf(List<Book> books) => (
  count: books.length,
  avgPages: books.isEmpty
      ? 0.0
      : books.fold<int>(0, (sum, book) => sum + book.pages) / books.length,
);
