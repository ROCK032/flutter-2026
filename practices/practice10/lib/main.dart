import 'package:flutter/material.dart';

import 'countdown_screen.dart';
import 'students_screen.dart';
import 'students_future_screen.dart';

void main() {
  runApp(
    const MaterialApp(debugShowCheckedModeBanner: false, home: HomeScreen()),
  );
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Practice 10')),
    body: Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FilledButton(
            onPressed: () async {
              await Navigator.of(context).push<void>(
                MaterialPageRoute<void>(builder: (_) => const StudentsScreen()),
              );
            },
            child: const Text('By hand'),
          ),
          const SizedBox(height: 12),
          FilledButton(
            onPressed: () async {
              await Navigator.of(context).push<void>(
                MaterialPageRoute<void>(
                  builder: (_) => const StudentsFutureScreen(),
                ),
              );
            },
            child: const Text('FutureBuilder'),
          ),
          const SizedBox(height: 12),
          FilledButton(
            onPressed: () async {
              await Navigator.of(context).push<void>(
                MaterialPageRoute<void>(
                  builder: (_) => const CountdownScreen(),
                ),
              );
            },
            child: const Text('Countdown'),
          ),
        ],
      ),
    ),
  );
}
