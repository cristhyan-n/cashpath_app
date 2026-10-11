import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:cashpath_app/config/api_config.dart';
import 'package:flutter/foundation.dart';

class AuthService {
  Future<String> login(String email, String password) async {
    final response = await _post('/usuarios/login', {
      'email': email,
      'senha': password,
    });

    if (response.statusCode != 200) {
      debugPrint('Google login ${response.statusCode}: ${response.body}');
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

  Future<String> loginWithGoogle(String idToken) async {
    final response = await _post('/usuarios/login/google', {
      'id_token': idToken,
    });

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      return data['access_token'] as String;
    }

    if (response.statusCode == 401) {
      throw Exception('Não foi possível validar a conta Google.');
    }

    throw Exception('Erro ao entrar com o Google (${response.statusCode}).');
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
        Uri.parse('$apiBaseUrl$path'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );
    } on http.ClientException {
      throw Exception('Não foi possível conectar ao servidor.');
    }
  }
}
