import 'dart:async';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

import 'core/api/api_client.dart';
import 'features/users/user_repository.dart';
import 'features/users/users_model.dart';
import 'features/users/users_screen.dart';

void main() {
  runApp(
    ChangeNotifierProvider<UsersModel>(
      create: (_) {
        final api = ApiClient(http.Client());
        final repository = UserRepository(api);
        final model = UsersModel(repository);

        // Запускаем первую загрузку и сразу передаём модель экрану.
        unawaited(model.load());
        return model;
      },
      child: const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: UsersScreen(),
      ),
    ),
  );
}
