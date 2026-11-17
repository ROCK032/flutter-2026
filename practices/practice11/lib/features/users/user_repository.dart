import '../../core/api/api_client.dart';
import '../../core/api/api_exception.dart';
import 'user.dart';

class UserRepository {
  UserRepository(this._api);
  final ApiClient _api;

  Future<List<User>> getAll() async {
    final data = await _api.get('/users');

    if (data is! List<dynamic>) {
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
