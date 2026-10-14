import 'package:flutter/material.dart';
import 'package:cashpath_app/services/perfil_service.dart';
import 'package:cashpath_app/utils/parsers.dart';

class OnboardingFinanceiroScreen extends StatefulWidget {
  const OnboardingFinanceiroScreen({super.key});
  @override
  State<OnboardingFinanceiroScreen> createState() =>
      _OnboardingFinanceiroScreenState();
}

class _OnboardingFinanceiroScreenState
    extends State<OnboardingFinanceiroScreen> {
  final _renda = TextEditingController();
  final _service = PerfilService();
  String _objetivo = 'economizar';
  String? _erro;
  bool _salvando = false;
  @override
  void dispose() {
    _renda.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final centavos = parseCentavos(_renda.text);
    if (centavos == null || centavos <= 0) {
      setState(() => _erro = 'Informe uma renda mensal maior que zero.');
      return;
    }
    setState(() {
      _erro = null;
      _salvando = true;
    });
    try {
      await _service.salvarFinanceiro(centavos, _objetivo);
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (mounted) {
        setState(() => _erro = e.toString().replaceFirst('Exception: ', ''));
      }
    }
    if (mounted) setState(() => _salvando = false);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Seu perfil financeiro')),
    body: SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Informe seu salário mensal. Ele inicia o saldo do mês; outras receitas podem ser registradas nas transações.',
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _renda,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: const InputDecoration(
                labelText: 'Salário mensal',
                prefixText: 'R\$ ',
              ),
            ),
            const SizedBox(height: 20),
            const Text('Objetivo principal'),
            SegmentedButton<String>(
              segments: const [
                ButtonSegment(value: 'economizar', label: Text('Economizar')),
                ButtonSegment(value: 'investir', label: Text('Investir')),
              ],
              selected: {_objetivo},
              onSelectionChanged: (v) => setState(() => _objetivo = v.first),
            ),
            if (_erro != null)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Text(
                  _erro!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _salvando ? null : _save,
              child: Text(_salvando ? 'Salvando…' : 'Continuar'),
            ),
          ],
        ),
      ),
    ),
  );
}
