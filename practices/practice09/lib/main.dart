import 'package:flutter/material.dart';

import 'books_screen.dart';
import 'cart_screen.dart';

import 'package:provider/provider.dart';

import 'models/cart.dart';

void main() {
  runApp(
    ChangeNotifierProvider<Cart>(create: (_) => Cart(), child: const Shell()),
  );
}

class Shell extends StatelessWidget {
  const Shell({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      routes: {'/': (_) => BooksScreen(), '/cart': (_) => CartScreen()},
    );
  }
}
