import 'package:flutter/foundation.dart';

import '../../core/storage/secure_store.dart';

class AuthModel extends ChangeNotifier {
  AuthModel(this._store, this._token);

  final SecureStore _store;
  String? _token;

  bool get signedIn => _token != null;

  Future<void> login(String email, String password) async {
    if (password.length < 8) {
      throw ArgumentError('Password must have at least 8 characters.');
    }

    await Future<void>.delayed(const Duration(seconds: 1));
    final token = 'tok_${email.hashCode}';

    await _store.saveToken(token);
    _token = token;
    notifyListeners();
  }

  Future<void> logout() async {
    await _store.clear();
    _token = null;
    notifyListeners();
  }
}
