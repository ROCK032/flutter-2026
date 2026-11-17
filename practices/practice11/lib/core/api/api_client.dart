import 'dart:async'; // TimeoutException.
import 'dart:convert'; // jsonDecode().
import 'dart:developer' as developer; // developer.log().
import 'dart:io' show SocketException;

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import 'api_exception.dart';

class ApiClient {
  ApiClient(this._client, {this.host = 'jsonplaceholder.typicode.com'});

  final http.Client _client;
  final String host;

  Map<String, String> get _headers => const {'Accept': 'application/json'};

  Future<Object?> get(String path) async {
    final uri = Uri.https(host, path);

    final response = await _send(() => _client.get(uri, headers: _headers));

    // Сначала проверяем статус. При исключении _decode уже не выполнится.
    _check(response, expectedStatus: 200);
    return _decode(response);
  }

  Future<Object?> post(String path, Map<String, dynamic> body) async {
    final uri = Uri.https(host, path);
    final response = await _send(
      () => _client.post(
        uri,
        headers: {..._headers, 'Content-Type': 'application/json'},
        body: jsonEncode(body),
        encoding: utf8,
      ),
    );
    _check(response, expectedStatus: 201);
    return _decode(response);
  }

  Future<http.Response> _send(Future<http.Response> Function() call) async {
    try {
      // call() запускает запрос, timeout ограничивает время ожидания.
      final response = await call().timeout(const Duration(seconds: 10));

      // В отладочном режиме записываем метод, путь и статус ответа.
      if (kDebugMode) {
        final request = response.request;
        developer.log(
          '${request?.method} ${request?.url.path} → ${response.statusCode}',
          name: 'api',
        );
      }

      // Возвращаем HTTP-ответ. Статус проверит метод get().
      return response;
    } on SocketException {
      // Сбой соединения на нативной платформе.
      throw const NoConnectionException();
    } on TimeoutException {
      // Ответ не получен за отведённое время.
      throw const NoConnectionException();
    } on http.ClientException {
      // В Chrome сетевой сбой может прийти в таком виде.
      throw const NoConnectionException();
    }
  }

  void _check(http.Response response, {required int expectedStatus}) {
    final status = response.statusCode;

    if (status == 401) throw const UnauthorizedException();
    if (status == 404) throw const NotFoundException();
    if (status >= 500) throw ServerException(status);

    // Если пришёл другой статус, считаем ответ неожиданным.
    if (status != expectedStatus) {
      throw BadResponseException('Unexpected HTTP status: $status');
    }
  }

  Object? _decode(http.Response response) {
    try {
      // response.body — текст. jsonDecode разбирает его в данные Dart.
      return jsonDecode(response.body);
    } on FormatException catch (error) {
      // Сюда попадём, если тело нельзя разобрать как JSON.
      throw BadResponseException(error.message);
    }
  }
}
