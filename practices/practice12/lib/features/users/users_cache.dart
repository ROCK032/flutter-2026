// В нём будем сохранять последний список пользователей в файл users.json.
import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

import 'user.dart';

class UsersCache {
  Future<File> _file() async {
    final directory = await getApplicationDocumentsDirectory();
    return File(
      '${directory.path}${Platform.pathSeparator}users.json',
    ); // собирает полный путь к файлу users.json
  }

  Future<void> save(List<User> users) async {
    // превращает объекты User в JSON и записывает его
    final file = await _file();
    final json = jsonEncode([for (final user in users) user.toJson()]);

    final tempFile = File('${file.path}.tmp');
    await tempFile.writeAsString(json, flush: true);
    await tempFile.rename(file.path);
  }

  Future<List<User>?> load() async {
    // load() читает JSON и восстанавливает объекты User
    final file = await _file();
    if (!await file.exists()) {
      return null; // 	Проверяет, есть ли файл по этому адресу
    }
    final data = jsonDecode(await file.readAsString()) as List<dynamic>;
    return [
      for (final item in data) User.fromJson(item as Map<String, dynamic>),
    ];
  }
}
