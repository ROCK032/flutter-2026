// Корзина подписывается на модель через Consumer и подтверждает очистку.
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'models/cart.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  // Диалог возвращает ответ; модель очищается только после подтверждения.
  Future<void> _confirmClear(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Очистить корзину?'),
        content: const Text('Удалить все книги из корзины?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Отмена'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Очистить'),
          ),
        ],
      ),
    );

    if (!context.mounted) return;
    if (confirmed == true) {
      context.read<Cart>().clear();
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('Корзина'),
      actions: [
        IconButton(
          tooltip: 'Очистить корзину',
          icon: const Icon(Icons.delete_sweep),
          onPressed: () => _confirmClear(context),
        ),
      ],
    ),
    body: Column(
      children: [
        Expanded(
          child: Consumer<Cart>(
            builder: (context, cart, _) {
              return ListView(
                children: [
                  for (final item in cart.items)
                    ListTile(
                      title: Text(item.title),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('×${cart.qtyOf(item)}'),
                          IconButton(
                            icon: const Icon(Icons.add),
                            onPressed: () {
                              cart.increment(item);
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () {
                              cart.remove(item);
                            },
                          ),
                        ],
                      ),
                    ),
                ],
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: Consumer<Cart>(
            builder: (context, cart, child) {
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [child!, Text('${cart.total} ₸')],
              );
            },
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.receipt_long),
                SizedBox(width: 8),
                Text('Итого: '),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}
