import 'package:flutter/material.dart';
import 'package:cashpath_app/services/perfil_service.dart';
import 'package:cashpath_app/services/api_client.dart';
import 'package:cashpath_app/utils/parsers.dart';
import 'package:cashpath_app/services/token_storage.dart';
import 'package:cashpath_app/screens/login_screen.dart';

class PerfilScreen extends StatefulWidget {
  const PerfilScreen({super.key});
  @override
  State<PerfilScreen> createState() => _PerfilScreenState();
}

class _PerfilScreenState extends State<PerfilScreen> {
  final _service = PerfilService();
  final _form = GlobalKey<FormState>();
  final _nome = TextEditingController();
  final _email = TextEditingController();
  final _atual = TextEditingController();
  final _nova = TextEditingController();
  final _renda = TextEditingController();
  bool _loading = true;
  bool _isGoogleAccount = false;
  bool _salvandoRenda = false;
  bool _resetando = false;
  bool _mostrarSenhaAtual = false;
  bool _mostrarNovaSenha = false;
  PerfilFinanceiro? _perfilFinanceiro;
  String? _erro;
  String _emailOriginal = '';

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _nome.dispose();
    _email.dispose();
    _atual.dispose();
    _nova.dispose();
    _renda.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final user = await _service.usuario();
      final financeiro = await _service.financeiroAtual();
      _nome.text = user['nome'] as String;
      _email.text = user['email'] as String;
      _emailOriginal = _email.text.trim().toLowerCase();
      _isGoogleAccount = user['provider'] == 'google';
      _perfilFinanceiro = financeiro;
      if (financeiro != null) {
        _renda.text = (financeiro.rendaCentavos / 100).toStringAsFixed(2);
      }
      if (mounted) setState(() => _loading = false);
    } on UnauthorizedException {
      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const LoginScreen()),
          (_) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _erro = e.toString();
          _loading = false;
        });
      }
    }
  }

  Future<void> _saveRenda() async {
    final centavos = parseCentavos(_renda.text);
    if (centavos == null || centavos <= 0) {
      setState(() => _erro = 'Informe uma renda mensal maior que zero.');
      return;
    }
    setState(() {
      _salvandoRenda = true;
      _erro = null;
    });
    try {
      await _service.salvarFinanceiro(
        centavos,
        _perfilFinanceiro?.objetivo ?? 'economizar',
      );
      _perfilFinanceiro = await _service.financeiroAtual();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Renda planejada atualizada.')),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _erro = e.toString().replaceFirst('Exception: ', ''));
      }
    } finally {
      if (mounted) setState(() => _salvandoRenda = false);
    }
  }

  Future<void> _resetarDados() async {
    final aceitar =
        await showDialog<bool>(
          context: context,
          builder: (_) => const _ConfirmarResetDialog(),
        ) ??
        false;
    if (!aceitar) return;
    setState(() => _resetando = true);
    try {
      await _service.resetarDadosFinanceiros();
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (mounted) {
        setState(() {
          _resetando = false;
          _erro = e.toString().replaceFirst('Exception: ', '');
        });
      }
    }
  }

  Future<void> _save() async {
    if (!_form.currentState!.validate()) return;
    final emailNovo = _email.text.trim();
    final emailAlterado = emailNovo.toLowerCase() != _emailOriginal;
    if (_isGoogleAccount && emailAlterado) {
      setState(
        () =>
            _erro = 'Altere este e-mail nas configurações da sua Conta Google.',
      );
      return;
    }
    try {
      await ApiClient().put('/usuarios/me', {
        'nome': _nome.text.trim(),
        'email': emailNovo,
        if (_nova.text.isNotEmpty) 'senha_atual': _atual.text,
        if (_nova.text.isNotEmpty) 'nova_senha': _nova.text,
      });
      if (mounted) {
        if (emailAlterado) {
          await TokenStorage().delete();
          if (!mounted) return;
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (_) => LoginScreen(initialEmail: emailNovo),
            ),
            (_) => false,
          );
        } else {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Perfil atualizado.')));
          Navigator.pop(context);
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _erro = e.toString().replaceFirst('Exception: ', ''));
      }
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Meu perfil')),
    body: _loading
        ? const Center(child: CircularProgressIndicator())
        : SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _form,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextFormField(
                    controller: _nome,
                    decoration: const InputDecoration(labelText: 'Nome'),
                    validator: (v) => (v == null || v.trim().length < 2)
                        ? 'Informe seu nome.'
                        : null,
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _email,
                    enabled: !_isGoogleAccount,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      labelText: 'E-mail',
                      helperText: _isGoogleAccount
                          ? 'Este e-mail vem da sua Conta Google e não pode ser alterado aqui.'
                          : null,
                    ),
                    validator: (v) =>
                        (v == null ||
                            !RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(v))
                        ? 'Informe um e-mail válido.'
                        : null,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Perfil financeiro',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: _renda,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: const InputDecoration(
                      labelText: 'Salário mensal',
                      prefixText: 'R\$ ',
                      helperText: 'Inicia o saldo do mês. Registre outras receitas nas transações; a categoria Salário não será somada novamente.',
                    ),
                  ),
                  const SizedBox(height: 8),
                  OutlinedButton.icon(
                    onPressed: _salvandoRenda ? null : _saveRenda,
                    icon: const Icon(Icons.savings_outlined),
                    label: Text(
                      _salvandoRenda ? 'Salvando…' : 'Atualizar renda',
                    ),
                  ),
                  const SizedBox(height: 20),
                  if (_isGoogleAccount) ...[
                    const SizedBox(height: 8),
                    const ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Icon(Icons.info_outline_rounded),
                      title: Text('Senha gerenciada pelo Google'),
                      subtitle: Text(
                        'Para alterar sua senha, acesse as configurações da sua Conta Google.',
                      ),
                    ),
                  ] else ...[
                    const Text('Alterar senha (opcional)'),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: _atual,
                      obscureText: !_mostrarSenhaAtual,
                      decoration: InputDecoration(
                        labelText: 'Senha atual',
                        suffixIcon: IconButton(
                          tooltip: _mostrarSenhaAtual
                              ? 'Ocultar senha'
                              : 'Mostrar senha',
                          onPressed: () => setState(
                            () => _mostrarSenhaAtual = !_mostrarSenhaAtual,
                          ),
                          icon: Icon(
                            _mostrarSenhaAtual
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: _nova,
                      obscureText: !_mostrarNovaSenha,
                      decoration: InputDecoration(
                        labelText: 'Nova senha',
                        suffixIcon: IconButton(
                          tooltip: _mostrarNovaSenha
                              ? 'Ocultar senha'
                              : 'Mostrar senha',
                          onPressed: () => setState(
                            () => _mostrarNovaSenha = !_mostrarNovaSenha,
                          ),
                          icon: Icon(
                            _mostrarNovaSenha
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                          ),
                        ),
                      ),
                      validator: (v) =>
                          (v != null && v.isNotEmpty && v.length < 8)
                          ? 'Use ao menos 8 caracteres.'
                          : null,
                    ),
                  ],
                  if (_erro != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: Text(
                        _erro!,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                        ),
                      ),
                    ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _save,
                    child: const Text('Salvar alterações'),
                  ),
                  const SizedBox(height: 36),
                  const Divider(),
                  const SizedBox(height: 12),
                  Text(
                    'Dados do aplicativo',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Você pode apagar os dados financeiros e manter sua conta para começar novamente.',
                  ),
                  const SizedBox(height: 10),
                  OutlinedButton.icon(
                    onPressed: _resetando ? null : _resetarDados,
                    icon: const Icon(Icons.restart_alt_rounded),
                    label: Text(
                      _resetando ? 'Apagando dados…' : 'Recomeçar do zero',
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ],
              ),
            ),
          ),
  );
}

class _ConfirmarResetDialog extends StatefulWidget {
  const _ConfirmarResetDialog();

  @override
  State<_ConfirmarResetDialog> createState() => _ConfirmarResetDialogState();
}

class _ConfirmarResetDialogState extends State<_ConfirmarResetDialog> {
  final _codigo = TextEditingController();

  @override
  void dispose() {
    _codigo.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final confirmado = _codigo.text.trim().toUpperCase() == 'ZERAR';

    return AlertDialog(
      scrollable: true,
      title: const Text('Recomeçar do zero?'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Serão apagados suas transações, rendas registradas, orçamentos, metas e categorias personalizadas. Sua conta, senha e acesso continuam ativos. Esta ação não pode ser desfeita.',
          ),
          const SizedBox(height: 16),
          const Text('Digite ZERAR para confirmar.'),
          const SizedBox(height: 8),
          TextField(
            controller: _codigo,
            textCapitalization: TextCapitalization.characters,
            onChanged: (_) => setState(() {}),
            decoration: const InputDecoration(labelText: 'Confirmação'),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Cancelar'),
        ),
        FilledButton.tonal(
          onPressed: confirmado ? () => Navigator.pop(context, true) : null,
          child: const Text('Apagar dados'),
        ),
      ],
    );
  }
}
