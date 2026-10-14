import 'dart:async';

import 'package:flutter/material.dart';
import 'package:cashpath_app/screens/home_screen.dart';
import 'package:cashpath_app/screens/register_screen.dart';
import 'package:cashpath_app/services/auth_service.dart';
import 'package:cashpath_app/services/google_auth_service.dart';
import 'package:cashpath_app/services/token_storage.dart';
import 'package:cashpath_app/screens/recuperar_senha_screen.dart';
import 'package:cashpath_app/widgets/cashpath_brand.dart';
import 'package:cashpath_app/theme/app_theme.dart';
import 'package:flutter/services.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key, this.initialEmail = ''});

  final String initialEmail;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  late final TextEditingController _emailController;
  final _passwordController = TextEditingController();
  final _authService = AuthService();
  final _googleAuthService = GoogleAuthService();
  final _tokenStorage = TokenStorage();

  bool _isLoading = false;
  bool _mostrarSenha = false;
  String? _errorMessage;
  final _confirmationCodeController = TextEditingController();
  bool _isConfirmationOpen = false;
  bool _isConfirmationSubmitting = false;
  bool _isSendingConfirmation = false;
  bool _confirmationIsError = false;
  bool _confirmationSendFailed = false;
  String? _confirmationMessage;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController(text: widget.initialEmail);
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmationCodeController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() {
    return _runLogin(
      () => _authService.login(_emailController.text, _passwordController.text),
      offerEmailConfirmation: true,
    );
  }

  Future<void> _handleGoogleLogin() {
    return _runLogin(() async {
      final idToken = await _googleAuthService.getIdToken();
      if (idToken == null) return null;
      return _authService.loginWithGoogle(idToken);
    });
  }

  void _showEmailConfirmationDialog() {
    setState(() {
      _isLoading = false;
      _errorMessage = null;
      _confirmationCodeController.clear();
      _isConfirmationSubmitting = false;
      _isSendingConfirmation = false;
      _confirmationIsError = false;
      _confirmationSendFailed = false;
      _confirmationMessage = null;
      _isConfirmationOpen = true;
    });
    unawaited(_requestConfirmationCode());
  }

  Future<void> _confirmEmail() async {
    final code = _confirmationCodeController.text.trim();
    if (code.length != 6) {
      setState(() {
        _confirmationIsError = true;
        _confirmationMessage = 'Digite os 6 n\u00fameros do c\u00f3digo.';
      });
      return;
    }

    setState(() {
      _isConfirmationSubmitting = true;
      _confirmationMessage = null;
    });
    try {
      await _authService.confirmEmail(code);
      if (!mounted) return;
      setState(() {
        _isConfirmationOpen = false;
        _isConfirmationSubmitting = false;
        _confirmationCodeController.clear();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('E-mail confirmado. Agora entre com sua conta.'),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isConfirmationSubmitting = false;
        _confirmationIsError = true;
        _confirmationMessage = e.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  Future<void> _requestConfirmationCode() async {
    if (_isSendingConfirmation || _isConfirmationSubmitting) return;
    setState(() {
      _isSendingConfirmation = true;
      _confirmationIsError = false;
      _confirmationSendFailed = false;
      _confirmationMessage = 'Enviando o c\u00f3digo...';
    });
    try {
      await _authService.resendConfirmation(_emailController.text.trim());
      if (!mounted || !_isConfirmationOpen) return;
      setState(() {
        _isSendingConfirmation = false;
        _confirmationSendFailed = false;
        _confirmationIsError = false;
        _confirmationMessage = 'C\u00f3digo enviado para o e-mail informado.';
      });
    } catch (e) {
      if (!mounted || !_isConfirmationOpen) return;
      setState(() {
        _isSendingConfirmation = false;
        _confirmationSendFailed = true;
        _confirmationIsError = true;
        _confirmationMessage = e.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  Widget _buildConfirmationOverlay() {
    final email = _emailController.text.trim();
    return Material(
      color: Colors.black54,
      child: Center(
        child: AlertDialog(
          icon: const Icon(Icons.mark_email_unread_outlined, size: 34),
          title: const Text('Confirme seu e-mail'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  _isSendingConfirmation
                      ? 'Enviando o c\u00f3digo para $email...'
                      : _confirmationSendFailed
                      ? 'N\u00e3o foi poss\u00edvel enviar o c\u00f3digo para $email.'
                      : 'Enviamos um c\u00f3digo de 6 d\u00edgitos para $email.',
                ),
                const SizedBox(height: 18),
                TextField(
                  controller: _confirmationCodeController,
                  keyboardType: TextInputType.number,
                  maxLength: 6,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 8,
                  ),
                  decoration: const InputDecoration(
                    labelText: 'C\u00f3digo de confirma\u00e7\u00e3o',
                    counterText: '',
                  ),
                ),
                if (_confirmationMessage != null) ...[
                  const SizedBox(height: 10),
                  Text(
                    _confirmationMessage!,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: _confirmationIsError
                          ? Theme.of(context).colorScheme.error
                          : Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ],
                const SizedBox(height: 4),
                TextButton(
                  onPressed: _isConfirmationSubmitting || _isSendingConfirmation
                      ? null
                      : _requestConfirmationCode,
                  child: const Text('Reenviar c\u00f3digo'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: _isConfirmationSubmitting
                  ? null
                  : () => setState(() {
                      _isConfirmationOpen = false;
                      _confirmationCodeController.clear();
                    }),
              child: const Text('Agora n\u00e3o'),
            ),
            FilledButton(
              onPressed: _isConfirmationSubmitting || _isSendingConfirmation
                  ? null
                  : _confirmEmail,
              child: _isConfirmationSubmitting || _isSendingConfirmation
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Confirmar'),
            ),
          ],
        ),
      ),
    );
  }

  /// Executa um fluxo de login. `obtainToken` devolve null se o usuário cancelou.
  Future<void> _runLogin(
    Future<String?> Function() obtainToken, {
    bool offerEmailConfirmation = false,
  }) async {
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
      if (offerEmailConfirmation &&
          error.toLowerCase().contains('confirme seu e-mail')) {
        _showEmailConfirmationDialog();
        return;
      }
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
      body: SafeArea(
        child: Stack(
          children: [
            Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(22, 18, 22, 28),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 460),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Center(child: CashPathWordmark(markSize: 48)),
                      const SizedBox(height: 24),
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [AppTheme.forest, Color(0xFF245845)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(28),
                        ),
                        child: Row(
                          children: [
                            const Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Seu dinheiro,\nno caminho certo.',
                                    style: TextStyle(
                                      fontSize: 25,
                                      height: 1.12,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: -0.7,
                                      color: Colors.white,
                                    ),
                                  ),
                                  SizedBox(height: 9),
                                  Text(
                                    'Organize seus gastos e acompanhe seus planos com clareza.',
                                    style: TextStyle(
                                      fontSize: 13,
                                      height: 1.4,
                                      color: Color(0xFFD9E8DF),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            Container(
                              width: 62,
                              height: 62,
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: .12),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.trending_up_rounded,
                                size: 34,
                                color: AppTheme.lime,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      Card(
                        margin: EdgeInsets.zero,
                        child: Padding(
                          padding: const EdgeInsets.all(22),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Text(
                                'Bem-vindo de volta',
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                              const SizedBox(height: 5),
                              const Text(
                                'Entre para continuar sua jornada financeira.',
                                style: TextStyle(color: AppTheme.muted),
                              ),
                              const SizedBox(height: 22),
                              TextField(
                                controller: _emailController,
                                keyboardType: TextInputType.emailAddress,
                                decoration: const InputDecoration(
                                  labelText: 'E-mail',
                                  prefixIcon: Icon(Icons.mail_outline_rounded),
                                ),
                              ),
                              const SizedBox(height: 14),
                              TextField(
                                controller: _passwordController,
                                obscureText: !_mostrarSenha,
                                decoration: InputDecoration(
                                  labelText: 'Senha',
                                  prefixIcon: const Icon(Icons.lock_outline_rounded),
                                  suffixIcon: IconButton(
                                    tooltip: _mostrarSenha
                                        ? 'Ocultar senha'
                                        : 'Mostrar senha',
                                    onPressed: () => setState(
                                      () => _mostrarSenha = !_mostrarSenha,
                                    ),
                                    icon: Icon(
                                      _mostrarSenha
                                          ? Icons.visibility_off_outlined
                                          : Icons.visibility_outlined,
                                    ),
                                  ),
                                ),
                              ),
                              if (_errorMessage != null) ...[
                                const SizedBox(height: 13),
                                Text(
                                  _errorMessage!,
                                  style: TextStyle(
                                    color: Theme.of(context).colorScheme.error,
                                  ),
                                ),
                              ],
                              const SizedBox(height: 19),
                              FilledButton(
                                onPressed: _isLoading ? null : _handleLogin,
                                child: _isLoading
                                    ? const SizedBox(
                                        height: 20,
                                        width: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : const Text('Entrar na minha conta'),
                              ),
                              Align(
                                alignment: Alignment.centerRight,
                                child: TextButton(
                                  onPressed: _isLoading
                                      ? null
                                      : () => Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) =>
                                                const RecuperarSenhaScreen(),
                                          ),
                                        ),
                                  child: const Text('Esqueci minha senha'),
                                ),
                              ),
                              const Padding(
                                padding: EdgeInsets.symmetric(vertical: 4),
                                child: Row(
                                  children: [
                                    Expanded(child: Divider()),
                                    Padding(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 12,
                                      ),
                                      child: Text(
                                        'ou continue com',
                                        style: TextStyle(color: AppTheme.muted),
                                      ),
                                    ),
                                    Expanded(child: Divider()),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 12),
                              OutlinedButton.icon(
                                onPressed: _isLoading
                                    ? null
                                    : _handleGoogleLogin,
                                icon: const _GoogleGMark(),
                                label: const Text('Continuar com Google'),
                              ),
                              const SizedBox(height: 14),
                              Wrap(
                                alignment: WrapAlignment.center,
                                crossAxisAlignment: WrapCrossAlignment.center,
                                spacing: 2,
                                runSpacing: 0,
                                children: [
                                  const Text(
                                    'Ainda não tem uma conta?',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(color: AppTheme.muted),
                                  ),
                                  TextButton(
                                    onPressed: _isLoading
                                        ? null
                                        : () async {
                                            final messenger =
                                                ScaffoldMessenger.of(context);
                                            final registeredEmail =
                                                await Navigator.push<String>(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (_) =>
                                                        const RegisterScreen(),
                                                  ),
                                                );
                                            if (registeredEmail != null &&
                                                mounted) {
                                              _emailController.text =
                                                  registeredEmail;
                                              messenger.showSnackBar(
                                                const SnackBar(
                                                  content: Text(
                                                    'Conta criada. Entre com seu e-mail e senha para confirmar o endereço.',
                                                  ),
                                                ),
                                              );
                                            }
                                          },
                                    child: const Text('Criar conta'),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            if (_isConfirmationOpen)
              Positioned.fill(child: _buildConfirmationOverlay()),
          ],
        ),
      ),
    );
  }
}

class _GoogleGMark extends StatelessWidget {
  const _GoogleGMark();

  @override
  Widget build(BuildContext context) => const Text(
    'G',
    style: TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.w800,
      color: Color(0xFF4285F4),
    ),
  );
}
