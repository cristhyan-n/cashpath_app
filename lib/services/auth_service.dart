import 'dart:convert';

import 'package:http/http.dart' as http;

class AuthService {
  static const _baseUrl = 'http://10.0.2.2:8000';

  Future<String> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/usuarios/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'senha': password}), // nomes dos campos
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      return data['access_token'] as String; // nome do campo do token
    }

    if (response.statusCode == 401) {
      throw Exception('E-mail ou senha inválidos.');
    }

    throw Exception('Erro ao fazer login (${response.statusCode}).');
  }
}
