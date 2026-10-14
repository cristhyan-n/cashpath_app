import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cashpath_app/services/auth_service.dart';
import 'package:cashpath_app/screens/login_screen.dart';

class ConfirmarEmailScreen extends StatefulWidget {
  const ConfirmarEmailScreen({super.key, this.emailInicial = ''});

  final String emailInicial;

  @override
  State<ConfirmarEmailScreen> createState() => _ConfirmarEmailScreenState();
}

class _ConfirmarEmailScreenState extends State<ConfirmarEmailScreen> {
  late final TextEditingController _emailController;
  final _codeController = TextEditingController();
  final _authService = AuthService();
  bool _isLoading = false;
  String? _message;
  bool _isError = false;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController(text: widget.emailInicial);
  }

  @override
  void dispose() {
    _emailController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _confirm() async {
    FocusScope.of(context).unfocus();
    setState(() {
      _isLoading = true;
      _message = null;
    });
    try {
      await _authService.confirmEmail(_codeController.text.trim());
      if (!mounted) return;
      final emailConfirmado = _emailController.text.trim();
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (_) => LoginScreen(initialEmail: emailConfirmado),
        ),
        (_) => false,
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _isError = true;
        _message = e.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  Future<void> _resend() async {
    FocusScope.of(context).unfocus();
    setState(() {
      _isLoading = true;
      _message = null;
    });
    try {
      await _authService.resendConfirmation(_emailController.text.trim());
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _isError = false;
        _message = 'Se a conta existir e ainda não estiver confirmada, enviaremos um novo código.';
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _isError = true;
        _message = e.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Confirmar e-mail')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(Icons.mark_email_unread_outlined, size: 56),
              const SizedBox(height: 16),
              Text(
                'Digite o código enviado para o e-mail do cadastro.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(labelText: 'E-mail usado no cadastro'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _codeController,
                keyboardType: TextInputType.number,
                autocorrect: false,
                maxLength: 6,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: const InputDecoration(labelText: 'Código de 6 dígitos'),
              ),
              if (_message != null) ...[
                const SizedBox(height: 8),
                Text(
                  _message!,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: _isError
                        ? Theme.of(context).colorScheme.error
                        : Theme.of(context).colorScheme.primary,
                  ),
                ),
              ],
              const SizedBox(height: 16),
              FilledButton(
                onPressed: _isLoading ? null : _confirm,
                child: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Confirmar e-mail'),
              ),
              TextButton(
                onPressed: _isLoading ? null : _resend,
                child: const Text('Reenviar código para este e-mail'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
