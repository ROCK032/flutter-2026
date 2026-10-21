// Общий вид пустого экрана: иконка, сообщение и необязательная кнопка.
import 'package:flutter/material.dart';

class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.icon,
    required this.message,
    this.onAction,
    this.actionLabel = 'Повторить',
  });
  final IconData icon;
  final String message;
  final VoidCallback? onAction;
  final String actionLabel;

  @override
  // Кнопка появляется только если родитель передал onAction.
  Widget build(BuildContext context) => Center(
    child: SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 48),
          const SizedBox(height: 12),
          Text(message, textAlign: TextAlign.center),
          if (onAction != null)
            TextButton(onPressed: onAction, child: Text(actionLabel)),
        ],
      ),
    ),
  );
}
