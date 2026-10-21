// Главная оболочка: хранит мероприятия и профиль, управляет вкладками и Drawer.
import 'package:flutter/material.dart';

import '../data/seed.dart';
import '../models/event.dart';
import '../widget/event_list.dart';
import '../widget/empty_state.dart';
import 'events_tab.dart';
import '../models/profile.dart';
import 'profile_tab.dart';
import '../routes.dart';

class ShellScreen extends StatefulWidget {
  const ShellScreen({
    super.key,
    required this.themeMode,
    required this.onThemeModeChanged,
  });

  final ThemeMode themeMode;
  final ValueChanged<ThemeMode> onThemeModeChanged;
  @override
  State<ShellScreen> createState() => _ShellScreenState();
}

class _ShellScreenState extends State<ShellScreen> {
  // Единственный общий список хранится здесь, вкладки получают его параметром.
  final List<Event> _events = createSeedEvents();
  Profile _profile =
      const Profile.empty(); // Здесь оболочка будет хранить профиль студента.
  int _selectedIndex =
      0; // Это номер выбранной вкладки: 0 — все, 1 — избранное.
  int _resetVersion = 0;
  // Ждёт результат формы. null означает, что пользователь вышел без сохранения.
  Future<void> _createEvent() async {
    FocusScope.of(context).unfocus();

    final createdEvent = await Navigator.pushNamed<Event>(
      context,
      Routes.form,
      arguments: const FormArguments(),
    );

    if (!mounted || createdEvent == null) return;

    setState(() {
      _events.add(createdEvent);
    });
  }

  // Открывает подробности; callbacks меняют данные в этой оболочке.
  void _openEvent(Event event) {
    // Запоминаем позицию в исходном списке; сортировка использует отдельную копию.
    final index = _events.indexOf(event);
    if (index == -1) return;

    FocusScope.of(context).unfocus();

    Navigator.pushNamed<void>(
      // открывает экран по имени маршрута
      context,
      Routes.detail,
      arguments: DetailArguments(
        // Через arguments передаём мероприятие, профиль и функции для будущих действий: изменения, удаления и перехода в профиль.
        event: event,
        profile: _profile,
        onChanged: (updatedEvent) {
          setState(() {
            _events[index] = updatedEvent;
          });
        },
        onDelete: () {
          setState(() {
            _events.removeAt(index);
          });
          Navigator.pop(context);
        },
        onProfileRequested: () {
          Navigator.pop(context);
          setState(() {
            _selectedIndex = 2;
          });
        },
      ),
    );
  }

  // Заменяет Event новой копией с противоположным isFavourite.
  void _toggleFavourite(Event event) {
    final index = _events.indexOf(event);
    if (index == -1) return;

    setState(() {
      _events[index] = event.copyWith(isFavourite: !event.isFavourite);
    });
  }

  // Закрывает Drawer и показывает информацию о приложении.
  void _showAbout() {
    Navigator.pop(context);

    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('О приложении'),
        content: const Text(
          'Находите университетские события '
          'и сохраняйте интересные в избранное.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Закрыть'),
          ),
        ],
      ),
    );
  }

  // После подтверждения возвращает seed, очищает профиль и черновики вкладок.
  Future<void> _resetData() async {
    FocusScope.of(context).unfocus();
    Navigator.pop(context);

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Сбросить данные?'),
        content: const Text(
          'Восстановить начальные мероприятия и очистить профиль?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Сбросить'),
          ),
        ],
      ),
    );

    if (!mounted || confirmed != true) return;

    final seed = createSeedEvents();

    setState(() {
      _events.clear();
      _events.addAll(seed);
      _profile = const Profile.empty();
      _selectedIndex = 0;
      _resetVersion++;
    });
  }

  @override
  // Строит три вкладки, Drawer и нижнюю навигацию.
  Widget build(BuildContext context) {
    final now = DateTime.now();
    // Сортируем копию: будущие первыми, затем по дате. Сам _events не сортируется.
    final sortedEvents = List<Event>.of(_events);

    sortedEvents.sort((a, b) {
      final aPast = a.startsAt.isBefore(now);
      final bPast = b.startsAt.isBefore(now);

      if (aPast != bPast) {
        return aPast ? 1 : -1;
      }
      return a.startsAt.compareTo(b.startsAt);
    });
    // where оставляет только избранные мероприятия.
    final favourites = sortedEvents
        .where((event) => event.isFavourite)
        .toList();
    return Scaffold(
      appBar: AppBar(title: const Text('Мероприятия университета')),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(child: Text('Мероприятия университета')),
            ListTile(title: const Text('О приложении'), onTap: _showAbout),
            ListTile(title: const Text('Сбросить данные'), onTap: _resetData),
          ],
        ),
      ),
      // IndexedStack сохраняет состояние вкладок при переключении.
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          EventsTab(
            key: ValueKey('events-$_resetVersion'),
            events: sortedEvents,
            onToggleFavourite: _toggleFavourite,
            onOpen: _openEvent,
          ),
          favourites.isEmpty
              ? EmptyState(
                  icon: Icons.favorite_border,
                  message: 'В избранном пока ничего нет',
                  actionLabel: 'Все мероприятия',
                  onAction: () {
                    setState(() {
                      _selectedIndex = 0;
                    });
                  },
                )
              : EventList(
                  events: favourites,
                  onToggleFavourite: _toggleFavourite,
                  onOpen: _openEvent,
                ),
          ProfileTab(
            profile: _profile,
            events: _events,
            themeMode: widget.themeMode,
            onThemeModeChanged: widget.onThemeModeChanged,
            key: ValueKey('profile-$_resetVersion'),
            onChanged: (updatedProfile) {
              // onChanged получает обновлённый профиль и сохраняет его в состоянии оболочки.
              setState(() {
                _profile = updatedProfile;
              });
            },
          ),
        ],
      ),
      floatingActionButton: _selectedIndex == 2
          ? null
          : FloatingActionButton(
              tooltip: 'Создать мероприятие',
              onPressed: _createEvent,
              child: const Icon(Icons.add),
            ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          FocusScope.of(context).unfocus();
          setState(() {
            _selectedIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(icon: Icon(Icons.list), label: 'Все'),
          NavigationDestination(icon: Icon(Icons.favorite), label: 'Избранное'),
          NavigationDestination(icon: Icon(Icons.person), label: 'Профиль'),
        ],
      ),
    );
  }
}
