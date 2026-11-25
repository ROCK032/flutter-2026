import '../../core/api/api_client.dart';
import '../../core/api/api_exception.dart';
import 'user.dart';

import 'dart:io' show FileSystemException;

import 'users_cache.dart';

class UserRepository {
  UserRepository(this._api, this._cache);

  final ApiClient _api;
  final UsersCache _cache;

  Future<({List<User> items, bool fromCache})> getAll() async {
    final List<User> fresh;
    try {
      fresh = await _fetchUsers();
    } on NoConnectionException {
      final saved = await _cache.load();
      if (saved == null) rethrow;

      return (items: saved, fromCache: true);
    }

    try {
      await _cache.save(fresh);
    } on FileSystemException {
      // Показываем загруженный список, даже если файл сохранить не удалось.
    }

    return (items: fresh, fromCache: false);
  }

  Future<List<User>> _fetchUsers() async {
    final data = await _api.get('/users');

    if (data is! List<dynamic>) {
      // означает, что снаружи должен быть список
      throw const BadResponseException('/users: ожидался список');
    }
    return [
      for (var index = 0; index < data.length; index++)
        _parseUser(data[index], '/user[$index]'),
    ];
  }

  Future<User> getById(int id) async {
    final path = '/users/$id';
    final data = await _api.get(path);
    return _parseUser(data, path);
  }

  Future<User> create(User draft) async {
    final body = draft.toJson();
    // Удаляем временный ID из запроса. Новый ID берём из ответа сервера.
    body.remove('id');

    final data = await _api.post('/users', body);
    return _parseUser(data, 'POST /users');
  }

  User _parseUser(Object? data, String source) {
    if (data is! Map<String, dynamic>) {
      throw BadResponseException('$source:  ожидался JSON-объект');
    }
    try {
      return User.fromJson(data);
    } on TypeError catch (error) {
      throw BadResponseException('$source: $error');
    } on FormatException catch (error) {
      throw BadResponseException('$source: ${error.message}');
    }
  }
}
