import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:cashpath_app/config/api_config.dart';
import 'package:cashpath_app/services/token_storage.dart';

class UnauthorizedException implements Exception {}

class ApiException implements Exception {
  const ApiException(this.statusCode);

  final int statusCode;

  @override
  String toString() => 'Erro na comunicação com o servidor ($statusCode).';
}

class ApiClient {
  final _tokenStorage = TokenStorage();

  Future<dynamic> get(String path) {
    return _send((headers) => http.get(_uri(path), headers: headers));
  }

  Future<dynamic> post(String path, Map<String, dynamic> body) {
    return _send(
      (headers) =>
          http.post(_uri(path), headers: headers, body: jsonEncode(body)),
    );
  }

  Uri _uri(String path) => Uri.parse('$apiBaseUrl$path');

  Future<dynamic> _send(
    Future<http.Response> Function(Map<String, String> headers) request,
  ) async {
    final token = await _tokenStorage.read();
    if (token == null) throw UnauthorizedException();

    http.Response response;
    try {
      response = await request({
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      });
    } on http.ClientException {
      throw Exception('Não foi possível conectar ao servidor.');
    }

    if (response.statusCode == 401) {
      await _tokenStorage.delete();
      throw UnauthorizedException();
    }

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw ApiException(response.statusCode);
    }

    if (response.body.isEmpty) return null;
    return jsonDecode(utf8.decode(response.bodyBytes));
  }
}
