import 'package:flutter/material.dart';

import 'books_screen.dart';
import 'cart_screen.dart';

void main() => runApp(const Shell());

class Shell extends StatefulWidget {
  const Shell({super.key});

  @override
  State<Shell> createState() => _ShellState();
}

class _ShellState extends State<Shell> {
  final List<Book> _cart = [];

  void _add(Book book) {
    setState(() {
      _cart.add(book);
    });
  }

  void _remove(Book book) {
    setState(() {
      _cart.remove(book);
    });
  }

  int _cardTotal() {
    return _cart.fold(0, (sum, item) => sum + item.price);
  }

  @override
  Widget build(BuildContext context) => MaterialApp(
    routes: {
      '/': (_) => BooksScreen(cart: _cart, onAdd: _add, total: _cardTotal()),
      '/cart': (_) => CartScreen(items: _cart, onRemove: _remove),
    },
  );
}

class Book {
  const Book({required this.title, required this.author, required this.price});
  final String title;
  final String author;
  final int price;
}

const List<Book> books = [
  Book(
    title: 'Widgets All the Way Down',
    author: 'A. Nurmagambetova',
    price: 4200,
  ),
  Book(title: 'Null Safety for Humans', author: 'B. Seitkali', price: 3100),
  Book(
    title: 'Constraints Go Down, Sizes Go Up',
    author: 'C. Tashimova',
    price: 5600,
  ),
  Book(title: 'The Navigator Is a Stack', author: 'D. Alibekov', price: 2900),
  Book(
    title: 'Forms That Validate Themselves',
    author: 'E. Omarova',
    price: 3800,
  ),
  Book(
    title: 'Put It High, Subscribe Low',
    author: 'F. Kairatuly',
    price: 4700,
  ),
];
