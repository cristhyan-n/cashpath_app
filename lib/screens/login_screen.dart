import 'package:flutter/material.dart';
import 'package:cashpath_app/screens/home_screen.dart';
import 'package:cashpath_app/screens/register_screen.dart';
import 'package:cashpath_app/services/auth_service.dart';
import 'package:cashpath_app/services/google_auth_service.dart';
import 'package:cashpath_app/services/token_storage.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authService = AuthService();
  final _googleAuthService = GoogleAuthService();
  final _tokenStorage = TokenStorage();

  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() {
    return _runLogin(
      () => _authService.login(_emailController.text, _passwordController.text),
    );
  }

  Future<void> _handleGoogleLogin() {
    return _runLogin(() async {
      final idToken = await _googleAuthService.getIdToken();
      if (idToken == null) return null;
      return _authService.loginWithGoogle(idToken);
    });
  }

  /// Executa um fluxo de login. `obtainToken` devolve null se o usuário cancelou.
  Future<void> _runLogin(Future<String?> Function() obtainToken) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    String? error;
    try {
      final token = await obtainToken();

      if (token == null) {
        if (!mounted) return;
        setState(() => _isLoading = false);
        return;
      }

      await _tokenStorage.save(token);
    } catch (e) {
      error = e.toString().replaceFirst('Exception: ', '');
    }

    if (!mounted) return;

    if (error != null) {
      setState(() {
        _isLoading = false;
        _errorMessage = error;
      });
      return;
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const HomeScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('CashPath')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(labelText: 'E-mail'),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Senha'),
              ),
              if (_errorMessage != null) ...[
                const SizedBox(height: 16),
                Text(
                  _errorMessage!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ],
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isLoading ? null : _handleLogin,
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Entrar'),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: _isLoading ? null : _handleGoogleLogin,
                icon: const Icon(Icons.account_circle_outlined),
                label: const Text('Entrar com Google'),
              ),
              TextButton(
                onPressed: _isLoading
                    ? null
                    : () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const RegisterScreen(),
                        ),
                      ),
                child: const Text('Criar conta'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
