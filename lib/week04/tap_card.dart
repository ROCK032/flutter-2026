import 'package:flutter/material.dart';

class TapCard extends StatefulWidget {
  const TapCard({super.key});

  @override
  State<TapCard> createState() => _TapCardState();
}

class _TapCardState extends State<TapCard> {
  int _taps = 0;
  Future<bool?> _askToReset() => showDialog(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: const Text('Reset the count?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(false),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(true),
          child: const Text('Reset'),
        ),
      ],
    ),
  );
  @override
  Widget build(BuildContext context) => Card(
    // Card рисует карточку
    child: InkWell(
      // InkWell принимает нажатие
      onTap: () {
        setState(() {
          _taps++;
        });
      },
      onLongPress: () async {
        final reset = await _askToReset();
        if (!mounted || reset != true) return;

        setState(() {
          _taps = 0;
        });
      },
      child: ListTile(
        // ListTile размещает текст и число в одной строке
        title: const Text('Tap this card'),
        trailing: Text(
          '$_taps',
        ), // '$_taps' вставляет значение переменной в текст
      ),
    ),
  );
}
