// Каталог с локальным поиском и добавлением книг в общую корзину.
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'cart_badge.dart';
import 'models/book.dart';
import 'models/cart.dart';

class BooksScreen extends StatefulWidget {
  const BooksScreen({super.key});

  @override
  State<BooksScreen> createState() => _BooksScreenState();
}

class _BooksScreenState extends State<BooksScreen> {
  String _query = '';

  Widget _buildBookTile(BuildContext context, Book book) {
    debugPrint('Book row: ${book.title}');
    final inCart = context.select<Cart, bool>(
      (cart) => cart.items.contains(book),
    );

    return ListTile(
      title: Text(book.title),
      subtitle: Text(book.author),
      trailing: inCart
          ? const Text('Добавлено в корзину')
          : OutlinedButton(
              onPressed: () {
                final added = context.read<Cart>().add(book);
                if (added) {
                  ScaffoldMessenger.of(context)
                      .showSnackBar(const SnackBar(content: Text('Добавлен')));
                }
              },
              child: const Text('Добавить в корзину'),
            ),
    );
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('BooksScreen.build');
    final query = _query.trim().toLowerCase();
    final visibleBooks = books
        .where(
          (book) =>
              book.title.toLowerCase().contains(query) ||
              book.author.toLowerCase().contains(query),
        )
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Книги'),
        actions: const [CartBadge()],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(64),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: TextField(
              decoration: const InputDecoration(
                hintText: 'Поиск по названию или автору',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() {
                  _query = value;
                });
              },
            ),
          ),
        ),
      ),
      body: visibleBooks.isEmpty
          ? const Center(child: Text('Книги не найдены'))
          : ListView(
              children: [
                for (final book in visibleBooks) _buildBookTile(context, book),
              ],
            ),
    );
  }
}
