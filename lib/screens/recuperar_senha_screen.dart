import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cashpath_app/services/auth_service.dart';
import 'package:cashpath_app/theme/app_theme.dart';

class RecuperarSenhaScreen extends StatefulWidget {
  const RecuperarSenhaScreen({super.key});

  @override
  State<RecuperarSenhaScreen> createState() => _RecuperarSenhaScreenState();
}

class _RecuperarSenhaScreenState extends State<RecuperarSenhaScreen> {
  final _email = TextEditingController();
  final _token = TextEditingController();
  final _senha = TextEditingController();
  final _confirmarSenha = TextEditingController();
  final _service = AuthService();
  bool _enviado = false;
  bool _concluido = false;
  bool _mostrarSenha = false;
  bool _mostrarConfirmacao = false;
  String? _erro;
  bool _loading = false;

  @override
  void dispose() {
    _email.dispose();
    _token.dispose();
    _senha.dispose();
    _confirmarSenha.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() {
      _loading = true;
      _erro = null;
    });
    try {
      if (!_enviado) {
        await _service.requestPasswordReset(_email.text.trim());
        if (mounted) setState(() => _enviado = true);
      } else {
        if (!RegExp(r'^\d{6}$').hasMatch(_token.text.trim())) {
          throw Exception('Informe o código de recuperação com 6 dígitos.');
        }
        if (_senha.text.length < 8) {
          throw Exception('A senha deve ter ao menos 8 caracteres.');
        }
        if (_senha.text != _confirmarSenha.text) {
          throw Exception('As senhas não coincidem.');
        }
        await _service.resetPassword(
          _token.text.trim(),
          _senha.text,
          _confirmarSenha.text,
        );
        if (mounted) setState(() => _concluido = true);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _erro = e.toString().replaceFirst('Exception: ', ''));
      }
    }
    if (mounted) setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final etapa = _enviado ? 2 : 1;

    return Scaffold(
      appBar: AppBar(title: const Text('Recuperar senha')),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) => Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 460),
                child: Card(
                  margin: EdgeInsets.zero,
                  child: Padding(
                    padding: EdgeInsets.all(constraints.maxWidth < 380 ? 20 : 28),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _RecoveryMark(
                          icon: _concluido
                              ? Icons.check_rounded
                              : Icons.lock_reset_rounded,
                          success: _concluido,
                        ),
                        const SizedBox(height: 20),
                        Text(
                          _concluido
                              ? 'Senha atualizada'
                              : _enviado
                              ? 'Crie uma nova senha'
                              : 'Vamos recuperar seu acesso',
                          textAlign: TextAlign.center,
                          style: theme.textTheme.headlineMedium?.copyWith(
                            fontSize: 24,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _concluido
                              ? 'Sua senha foi alterada. Agora você já pode entrar na sua conta.'
                              : _enviado
                              ? 'Digite o código enviado ao seu e-mail e escolha uma senha segura.'
                              : 'Informe o e-mail da sua conta. Enviaremos um código válido por 30 minutos.',
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: AppTheme.muted,
                            height: 1.5,
                          ),
                        ),
                        if (!_concluido) ...[
                          const SizedBox(height: 24),
                          _RecoverySteps(current: etapa),
                          const SizedBox(height: 24),
                        ] else
                          const SizedBox(height: 24),
                        if (_concluido)
                          FilledButton.icon(
                            onPressed: () => Navigator.pop(context),
                            icon: const Icon(Icons.arrow_back_rounded),
                            label: const Text('Voltar ao login'),
                          )
                        else ...[
                          if (!_enviado)
                            TextField(
                              controller: _email,
                              keyboardType: TextInputType.emailAddress,
                              textInputAction: TextInputAction.done,
                              onSubmitted: (_) => _loading ? null : _submit(),
                              decoration: const InputDecoration(
                                labelText: 'E-mail',
                                prefixIcon: Icon(Icons.mail_outline_rounded),
                              ),
                            )
                          else ...[
                            TextField(
                              controller: _token,
                              keyboardType: TextInputType.number,
                              textInputAction: TextInputAction.next,
                              maxLength: 6,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                              ],
                              decoration: const InputDecoration(
                                labelText: 'Código de 6 dígitos',
                                prefixIcon: Icon(Icons.pin_outlined),
                                counterText: '',
                              ),
                            ),
                            const SizedBox(height: 14),
                            TextField(
                              controller: _senha,
                              obscureText: !_mostrarSenha,
                              textInputAction: TextInputAction.next,
                              decoration: InputDecoration(
                                labelText: 'Nova senha',
                                helperText: 'Use pelo menos 8 caracteres',
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
                            const SizedBox(height: 14),
                            TextField(
                              controller: _confirmarSenha,
                              obscureText: !_mostrarConfirmacao,
                              textInputAction: TextInputAction.done,
                              onSubmitted: (_) => _loading ? null : _submit(),
                              decoration: InputDecoration(
                                labelText: 'Confirmar nova senha',
                                prefixIcon: const Icon(Icons.check_circle_outline_rounded),
                                suffixIcon: IconButton(
                                  tooltip: _mostrarConfirmacao
                                      ? 'Ocultar senha'
                                      : 'Mostrar senha',
                                  onPressed: () => setState(
                                    () => _mostrarConfirmacao =
                                        !_mostrarConfirmacao,
                                  ),
                                  icon: Icon(
                                    _mostrarConfirmacao
                                        ? Icons.visibility_off_outlined
                                        : Icons.visibility_outlined,
                                  ),
                                ),
                              ),
                            ),
                          ],
                          if (_erro != null) ...[
                            const SizedBox(height: 14),
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.errorContainer,
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Text(
                                _erro!,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: theme.colorScheme.onErrorContainer,
                                ),
                              ),
                            ),
                          ],
                          const SizedBox(height: 20),
                          FilledButton(
                            onPressed: _loading ? null : _submit,
                            child: _loading
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : Text(
                                    _enviado ? 'Redefinir senha' : 'Enviar código',
                                  ),
                          ),
                          if (_enviado) ...[
                            const SizedBox(height: 8),
                            TextButton.icon(
                              onPressed: _loading
                                  ? null
                                  : () => setState(() {
                                      _enviado = false;
                                      _erro = null;
                                    }),
                              icon: const Icon(Icons.edit_outlined, size: 18),
                              label: const Text('Corrigir e-mail'),
                            ),
                          ],
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _RecoveryMark extends StatelessWidget {
  const _RecoveryMark({required this.icon, this.success = false});

  final IconData icon;
  final bool success;

  @override
  Widget build(BuildContext context) => Center(
    child: Container(
      width: 68,
      height: 68,
      decoration: BoxDecoration(
        color: success ? const Color(0xFFE7F4E9) : const Color(0xFFEAF4EB),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Icon(
        icon,
        size: 34,
        color: success ? AppTheme.green : AppTheme.forest,
      ),
    ),
  );
}

class _RecoverySteps extends StatelessWidget {
  const _RecoverySteps({required this.current});

  final int current;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      _StepDot(number: '1', label: 'E-mail', active: current == 1),
      Expanded(
        child: Container(height: 1, color: const Color(0xFFDCE6DE)),
      ),
      _StepDot(number: '2', label: 'Nova senha', active: current == 2),
    ],
  );
}

class _StepDot extends StatelessWidget {
  const _StepDot({
    required this.number,
    required this.label,
    required this.active,
  });

  final String number;
  final String label;
  final bool active;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Container(
        width: 28,
        height: 28,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: active ? AppTheme.forest : const Color(0xFFEAF0EB),
          shape: BoxShape.circle,
        ),
        child: Text(
          number,
          style: TextStyle(
            color: active ? Colors.white : AppTheme.muted,
            fontWeight: FontWeight.w700,
            fontSize: 12,
          ),
        ),
      ),
      const SizedBox(width: 8),
      Text(
        label,
        style: TextStyle(
          color: active ? AppTheme.forest : AppTheme.muted,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    ],
  );
}
