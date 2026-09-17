import 'catalogue.dart';
import 'data.dart';
import 'models.dart';
import 'shelf_state.dart' as shelf;

void main() {
  final library = Library();
  library.open();

  // map превращает каждую исходную запись в объект Book
  final books = rawBooks.map(Book.fromJson).toList();
  for (final book in books) {
    library.add(book);
  }
  library.add(const Magazine(title: 'Science', year: 1998, issue: 12));
  library.add(const Ghost(title: 'Lost Manuscript', year: 1880));

  print('Открыта: ${library.openedAt}');
  print('\n--- Каталог ---');
  print(library.buildReport());

  print('\n--- Наследование и миксин ---');
  for (final item in library.items) {
    print('${item.describe()}, старое издание: ${item.isOld}');
  }
  print(books.first.borrowLabel());

  print('\n--- Копия книги ---');
  final shortBook = books.first.copyWith(
    title: 'Clean Code — краткая версия',
    pages: 120,
  );
  print('Оригинал: ${books.first}');
  print('Копия: $shortBook');
  print('Большая книга: ${books.first.isLong}');
  print('Большая копия: ${shortBook.isLong}');

  print('\n--- Поиск и неполные данные ---');
  print('Найдена: ${library.findByTitle('Refactoring')}');
  print('Нет такой книги: ${library.findByTitle('Missing')}');
  print('Страна Martin: ${library.countryOf('Clean Code')}');
  print('Страна Gamma: ${library.countryOf('Design Patterns')}');
  print('Страна отсутствующей книги: ${library.countryOf('Missing')}');
  print('Неполная книга: ${library.findByTitle('Broken Record')}');

  // Nullable-публичное поле копируем в локальную переменную для проверки
  final description = books[2].description;
  if (description == null) {
    print('Описание отсутствует');
  } else {
    print('Описание (${description.length} символов): $description');
  }

  print('\n--- Запросы к коллекциям ---');
  print('Все названия: ${library.titles}');
  print(
    'После 2010: ${library.booksAfter2010.map((book) => book.title).toList()}',
  );
  print('Среднее число страниц: ${library.averagePages.toStringAsFixed(2)}');
  print('Число книг по авторам: ${library.booksByAuthor}');
  print('Уникальные авторы: ${library.authorNames}');
  print('Жанры: ${library.genres.map((genre) => genre.label).toSet()}');

  print('\n--- Record и состояния полки ---');
  final stats = shelf.statsOf(library.books);
  print('Record: $stats');
  print('Книг: ${stats.count}, среднее: ${stats.avgPages.toStringAsFixed(2)}');
  print(shelf.describe(const shelf.Empty()));
  print(shelf.describe(shelf.Ready(library.books)));
  print(shelf.describe(const shelf.Broken('Не удалось загрузить каталог')));
}
