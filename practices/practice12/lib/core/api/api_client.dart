import 'dart:async'; // TimeoutException.
import 'dart:convert'; // jsonDecode().
import 'dart:developer' as developer; // developer.log().
import 'dart:io' show SocketException;

import '../storage/secure_store.dart';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import 'api_exception.dart';

class ApiClient {
  ApiClient(
    this._client,
    this._store, {
    this.host = 'jsonplaceholder.typicode.com',
  });

  final http.Client _client;
  final SecureStore _store;
  final String host;

  Future<Map<String, String>> get _headers async {
    final token = await _store.readToken();

    return {
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Future<Object?> get(String path) async {
    final uri = Uri.https(host, path);
    final headers = await _headers;
    final response = await _send(() => _client.get(uri, headers: headers));

    _check(response, expectedStatus: 200);
    return _decode(response);
  }

  Future<Object?> post(String path, Map<String, dynamic> body) async {
    final uri = Uri.https(host, path);
    final headers = await _headers;
    final response = await _send(
      () => _client.post(
        uri,
        headers: {...headers, 'Content-Type': 'application/json'},
        body: jsonEncode(body),
        encoding: utf8,
      ),
    );

    _check(response, expectedStatus: 201);
    return _decode(response);
  }

  Future<http.Response> _send(Future<http.Response> Function() call) async {
    try {
      final response = await call().timeout(const Duration(seconds: 10));

      if (kDebugMode) {
        final request = response.request;
        developer.log(
          '${request?.method} ${request?.url.path} → ${response.statusCode}',
          name: 'api',
        );
      }

      return response;
    } on SocketException {
      throw const NoConnectionException();
    } on TimeoutException {
      throw const NoConnectionException();
    } on http.ClientException {
      throw const NoConnectionException();
    }
  }

  void _check(http.Response response, {required int expectedStatus}) {
    final status = response.statusCode;

    if (status == 401) throw const UnauthorizedException();
    if (status == 404) throw const NotFoundException();
    if (status >= 500) throw ServerException(status);

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
