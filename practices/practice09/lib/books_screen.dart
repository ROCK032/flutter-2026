import 'package:flutter/material.dart';

import 'cart_badge.dart';
import 'main.dart';

class BooksScreen extends StatelessWidget {
  const BooksScreen({
    super.key,
    required this.cart,
    required this.onAdd,
    required this.total,
  });

  final List<Book> cart;
  final void Function(Book) onAdd;
  final int total;

  Widget _buildBookTile(Book book) {
    debugPrint('Book row: ${book.title}');

    return ListTile(
      title: Text(book.title),
      subtitle: Text(book.author),
      trailing: cart.contains(book)
          ? const Text('Добавлено в корзину')
          : OutlinedButton(
        onPressed: () {
          onAdd(book);
        },
        child: const Text('Добавить в корзину'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('BooksScreen.build');
    return Scaffold(
      appBar: AppBar(
        title: const Text('Книги'),
        actions: [
          CartBadge(count: cart.length, total: total),
        ],
      ),
      body: ListView(
        children: [
          for (final book in books)
            _buildBookTile(book),
        ],
      ),
    );
  }
}
