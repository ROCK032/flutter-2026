# Уровень 1

Сумма вычисляется в _ShellState методом _cardTotal().
Передаётся по цепочке: Shell → BooksScreen → CartBadge.

Для добавления суммы изменены 3 файла:
- lib/main.dart
- lib/books_screen.dart
- lib/cart_badge.dart

Изменены определения 2 конструкторов:
BooksScreen и CartBadge.
Также обновлены 2 места их вызова.

После одного добавления книги:
- BooksScreen.build — 1 сообщение.
- Book row — 6 сообщений.

Метод создания строки вызывается для всех 6 книг каталога.