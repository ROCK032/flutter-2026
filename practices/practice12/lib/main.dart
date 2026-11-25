import 'dart:async';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

import 'features/users/users_cache.dart';
import 'core/storage/secure_store.dart';
import 'features/auth/auth_model.dart';
import 'core/api/api_client.dart';
import 'features/users/user_repository.dart';
import 'features/users/users_model.dart';
import 'features/users/users_screen.dart';
import 'features/auth/login_screen.dart';

import 'package:shared_preferences/shared_preferences.dart';

import 'features/settings/settings_model.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final prefs =
      SharedPreferencesAsync(); // подготавливает Flutter к работе с плагинами
  final dark = await prefs.getBool('darkMode') ?? false;
  final city = await prefs.getString('cityFilter');
  const store = SecureStore();
  final token = await store.readToken();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthModel>(
          create: (_) => AuthModel(store, token),
        ),
        ChangeNotifierProvider<SettingsModel>(
          create: (_) => SettingsModel(prefs, dark: dark, city: city),
        ),
        ChangeNotifierProvider<UsersModel>(
          create: (_) {
            final api = ApiClient(http.Client(), store);
            final repository = UserRepository(api, UsersCache());
            final model = UsersModel(repository);
            unawaited(model.load());
            return model;
          },
        ),
      ],
      child: const App(),
    ),
  );
}

class App extends StatelessWidget {
  const App({super.key});
  @override
  Widget build(BuildContext context) {
    final dark = context.watch<SettingsModel>().dark;
    final signedIn = context.watch<AuthModel>().signedIn;
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      themeMode: dark ? ThemeMode.dark : ThemeMode.light,
      home: signedIn ? const UsersScreen() : const LoginScreen(),
    );
  }
}
