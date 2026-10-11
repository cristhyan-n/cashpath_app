import 'dart:convert';

import 'package:http/http.dart' as http;

class AuthService {
  static const _baseUrl = 'http://10.0.2.2:8000';

  Future<String> login(String email, String password) async {
    http.Response response;

    try {
      response = await http.post(
        Uri.parse('$_baseUrl/usuarios/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'senha': password}),
      );
    } on http.ClientException {
      throw Exception('Não foi possível conectar ao servidor.');
    }

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      return data['access_token'] as String;
    }

    if (response.statusCode == 401) {
      throw Exception('E-mail ou senha inválidos.');
    }

    throw Exception('Erro ao fazer login (${response.statusCode}).');
  }
}
