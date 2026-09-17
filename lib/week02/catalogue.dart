import 'models.dart';

class Library {
  final List<LibraryItem> items = [];

  // Значение присваивается при открытии, а не в конструкторе.
  late final DateTime openedAt;
  bool _opened = false;
  String? _cachedReport;

  void open() {
    if (_opened) return;
    openedAt = DateTime.now();
    _opened = true;
  }

  void add(LibraryItem item) {
    items.add(item);
    // После изменения каталога старый отчёт больше не подходит.
    _cachedReport = null;
  }

  Book? findByTitle(String title) {
    for (final item in items) {
      if (item is Book && item.title == title) {
        return item;
      }
    }
    return null;
  }

  String countryOf(String title) =>
      findByTitle(title)?.author.country ?? 'unknown';

  // whereType оставляет только книги, исключая журналы и Ghost.
  List<Book> get books => items.whereType<Book>().toList();

  List<String> get titles => items.map((item) => item.title).toList();

  List<Book> get booksAfter2010 =>
      books.where((book) => book.year > 2010).toList();

  // fold начинает с 0 и работает с пустым списком; reduce на нём бросит ошибку.
  // Книга с неизвестным числом страниц участвует со значением 0.
  double get averagePages => books.isEmpty
      ? 0.0
      : books.fold<int>(0, (sum, book) => sum + book.pages) / books.length;

  Map<String, int> get booksByAuthor => books.fold<Map<String, int>>(
    <String, int>{},
    (counts, book) => {
      ...counts,
      book.author.name: (counts[book.author.name] ?? 0) + 1,
    },
  );

  Set<String> get authorNames => books.map((book) => book.author.name).toSet();

  Set<Genre> get genres => books.map((book) => book.genre).toSet();

  List<String> get displayLines => [
    'CATALOGUE',
    for (final book in books) '${book.title} (${book.year})',
    ...authorNames,
    if (books.any((book) => book.pages == 0)) '(incomplete data)',
  ];

  String buildReport() => _cachedReport ??= displayLines.join('\n');
}
