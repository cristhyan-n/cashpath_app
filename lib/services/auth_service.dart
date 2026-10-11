import 'dart:convert';

import 'package:http/http.dart' as http;

class AuthService {
  static const _baseUrl = 'http://10.0.2.2:8000';

  Future<String> login(String email, String password) async {
    final response = await _post('/usuarios/login', {
      'email': email,
      'senha': password,
    });

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      return data['access_token'] as String;
    }

    if (response.statusCode == 401) {
      throw Exception('E-mail ou senha inválidos.');
    }

    throw Exception('Erro ao fazer login (${response.statusCode}).');
  }

  Future<void> register(String name, String email, String password) async {
    final response = await _post('/usuarios', {
      'nome': name,
      'email': email,
      'senha': password,
    });

    if (response.statusCode == 200 || response.statusCode == 201) return;

    if (response.statusCode == 400) {
      throw Exception('Este e-mail já está cadastrado.');
    }

    throw Exception('Erro ao criar conta (${response.statusCode}).');
  }

  Future<http.Response> _post(String path, Map<String, dynamic> body) async {
    try {
      return await http.post(
        Uri.parse('$_baseUrl$path'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );
    } on http.ClientException {
      throw Exception('Não foi possível conectar ao servidor.');
    }
  }
}
