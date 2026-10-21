// Запускает приложение, хранит тему и создаёт экраны по именованным маршрутам.
import 'package:flutter/material.dart';

import 'routes.dart';
import 'screens/detail_screen.dart';
import 'screens/shell_screen.dart';
import 'models/event.dart';
import 'screens/event_form_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // Тема хранится выше MaterialApp и передаётся вниз через параметры.
  ThemeMode _themeMode = ThemeMode.system;

  @override
  // Светлая и тёмная темы используют один seed; маршруты создаёт Navigator.
  Widget build(BuildContext context) {
    final seed = ThemeData().colorScheme.primary;

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Мероприятия университета',
      theme: ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: seed)),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: seed,
          brightness: Brightness.dark,
        ),
      ),
      themeMode: _themeMode,
      routes: {
        // задаёт главный экран.
        Routes.shell: (context) => ShellScreen(
          themeMode: _themeMode,
          onThemeModeChanged: (mode) {
            // Профиль сообщает новую тему; setState перестраивает MaterialApp.
            setState(() => _themeMode = mode);
          },
        ),
      },
      // Проверяем тип arguments, затем строим нужный экран.
      onGenerateRoute: (settings) {
        final args = settings.arguments;

        if (settings.name == Routes.detail && args is DetailArguments) {
          return MaterialPageRoute<void>(
            settings: settings,
            builder: (context) => DetailScreen(arguments: args),
          );
        }
        if (settings.name == Routes.form && args is FormArguments) {
          return MaterialPageRoute<Event>(
            settings: settings,
            builder: (context) => EventFormScreen(arguments: args),
          );
        }
        return null;
      },
      onUnknownRoute: (settings) => MaterialPageRoute<void>(
        // показывает сообщение, если маршрут не найден.
        settings: settings,
        builder: (context) => Scaffold(
          appBar: AppBar(title: const Text('Not found')),
          body: const Center(child: Text('Страница не найдена')),
        ),
      ),
    );
  }
}
