import 'package:flutter/material.dart';

/// Показывает имя и университет в верхней части экрана профиля.
class ProfileHeader extends StatelessWidget {
  const ProfileHeader({
    super.key,
    required this.name,
    required this.university,
  });

  /// Имя пользователя, показанное основным текстом заголовка.
  final String name;

  /// Университет, показанный под именем.
  final String university;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Image.asset(
          'assets/images/profile.jpg',
          width: 120,
          height: 120,
          fit: BoxFit.cover,
        ),
        Padding(
          padding: const EdgeInsets.only(top: 12),
          child: Text(
            name,
            style: Theme.of(context).textTheme.headlineSmall
                ?.copyWith(fontFamily: 'ProfileFont'),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Text(university),
        ),
      ],
    );
  }
}
