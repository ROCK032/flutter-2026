// Значок показывает количество книг и открывает корзину.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'models/cart.dart';

class CartBadge extends StatelessWidget {
  const CartBadge({super.key});
  @override
  Widget build(BuildContext context) {
    debugPrint('badge build');
    final count = context.select<Cart, int>((cart) => cart.count);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Consumer<Cart>(
          builder: (context, cart, _) {
            return Text('Итого: ${cart.total} ₸');
          },
        ),
        IconButton(
          icon: Badge(
            label: Text('$count'),
            child: const Icon(Icons.shopping_cart),
          ),
          onPressed: () {
            Navigator.of(context).pushNamed('/cart');
          },
        ),
      ],
    );
  }
}
