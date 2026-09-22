import 'package:flutter/material.dart';

/// Показывает один факт профиля: подпись слева, значение справа.
class InfoRow extends StatelessWidget {
  const InfoRow({super.key, required this.label, required this.value});

  /// Название факта, например `Course`.
  final String label;

  /// Значение факта, например `2`.
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        // Раздвигает подпись и значение по разным краям строки.
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          Text(value),
        ],
      ),
    );
  }
}
