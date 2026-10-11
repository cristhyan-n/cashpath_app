import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:cashpath_app/config/api_config.dart';
import 'package:cashpath_app/services/token_storage.dart';

class UnauthorizedException implements Exception {}

class ApiClient {
  final _tokenStorage = TokenStorage();

  Future<dynamic> get(String path) async {
    final token = await _tokenStorage.read();
    if (token == null) throw UnauthorizedException();

    http.Response response;
    try {
      response = await http.get(
        Uri.parse('$apiBaseUrl$path'),
        headers: {'Authorization': 'Bearer $token'},
      );
    } on http.ClientException {
      throw Exception('Não foi possível conectar ao servidor.');
    }

    if (response.statusCode == 401) {
      await _tokenStorage.delete();
      throw UnauthorizedException();
    }

    if (response.statusCode != 200) {
      throw Exception('Erro ao buscar dados (${response.statusCode}).');
    }

    return jsonDecode(utf8.decode(response.bodyBytes));
  }
}
