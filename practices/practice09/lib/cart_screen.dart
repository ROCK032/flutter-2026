// Экран корзины получает выбранные книги и функцию удаления.

import 'package:flutter/material.dart';

import 'main.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key, required this.items, required this.onRemove});
  final List<Book> items;
  final void Function(Book) onRemove;
  int _calculateTotal() {
    return items.fold(0, (sum, item) => sum + item.price);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Корзина')),
    body: Column(
      children: [
        Expanded(
          child: ListView(
            children: [
              for (final item in items)
                ListTile(
                  title: Text(item.title),
                  trailing: IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () {
                      onRemove(item);
                    },
                  ),
                ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text('Итого: ${_calculateTotal()} ₸'),
        ),
      ],
    ),
  );
}
