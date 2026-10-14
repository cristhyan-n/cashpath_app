import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:cashpath_app/config/api_config.dart';
import 'package:cashpath_app/services/token_storage.dart';

class AuthService {
  Future<void> logout() async {
    final response = await _postAuthenticated('/usuarios/logout');
    if (response.statusCode != 200) {
      throw Exception('Não foi possível encerrar a sessão no servidor.');
    }
  }

  Future<void> requestPasswordReset(String email) async {
    final response = await _post('/usuarios/recuperar-senha', {'email': email});
    if (response.statusCode == 200) return;
    final body = jsonDecode(response.body) as Map<String, dynamic>;
    throw Exception(
      body['detail'] ?? 'Não foi possível solicitar a recuperação.',
    );
  }

  Future<void> resetPassword(
    String token,
    String password,
    String confirmation,
  ) async {
    final response = await _post('/usuarios/redefinir-senha', {
      'token': token,
      'nova_senha': password,
      'confirmar_senha': confirmation,
    });
    if (response.statusCode == 200) return;
    final body = jsonDecode(response.body) as Map<String, dynamic>;
    throw Exception(body['detail'] ?? 'Não foi possível redefinir a senha.');
  }

  Future<void> confirmEmail(String token) async {
    final response = await _post('/usuarios/confirmar-email', {'token': token});
    if (response.statusCode == 200) return;
    throw Exception(
      _detail(response) ?? 'Não foi possível confirmar o e-mail.',
    );
  }

  Future<void> resendConfirmation(String email) async {
    final response = await _post('/usuarios/reenviar-confirmacao', {
      'email': email,
    });
    if (response.statusCode == 200) return;
    throw Exception(_detail(response) ?? 'Não foi possível reenviar o código.');
  }

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

    if (response.statusCode == 403) {
      throw Exception('Confirme seu e-mail antes de entrar.');
    }

    throw Exception('Erro ao fazer login (${response.statusCode}).');
  }

  Future<String> loginWithGoogle(String idToken) async {
    final response = await _post('/usuarios/login/google', {
      'id_token': idToken,
    });

    switch (response.statusCode) {
      case 200:
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return data['access_token'] as String;
      case 401:
        throw Exception('Não foi possível validar a conta Google.');
      case 409:
        throw Exception(
          'Este e-mail já está cadastrado com senha. Entre com e-mail e senha.',
        );
      case 503:
        throw Exception('Login com Google indisponível no momento.');
      default:
        throw Exception(
          'Erro ao entrar com o Google (${response.statusCode}).',
        );
    }
  }

  Future<void> register(String name, String email, String password) async {
    final response = await _post('/usuarios', {
      'nome': name,
      'email': email,
      'senha': password,
    });

    if (response.statusCode == 200 || response.statusCode == 201) return;

    if (response.statusCode == 400) {
      throw Exception(_detail(response) ?? 'Este e-mail já está cadastrado.');
    }

    throw Exception(
      _detail(response) ?? 'Erro ao criar conta (${response.statusCode}).',
    );
  }

  String? _detail(http.Response response) {
    try {
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      return body['detail'] as String?;
    } catch (_) {
      return null;
    }
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

  Future<http.Response> _postAuthenticated(String path) async {
    try {
      final token = await TokenStorage().read();
      if (token == null || token.isEmpty) {
        throw Exception('Sessão não encontrada.');
      }
      return await http.post(
        Uri.parse('$apiBaseUrl$path'),
        headers: {'Authorization': 'Bearer $token'},
      );
    } on http.ClientException {
      throw Exception('Não foi possível conectar ao servidor.');
    }
  }
}
