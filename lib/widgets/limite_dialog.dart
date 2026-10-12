import 'package:flutter/material.dart';
import 'package:cashpath_app/utils/parsers.dart';

class LimiteDialog extends StatefulWidget {
  const LimiteDialog({
    super.key,
    required this.categoriaNome,
    this.limiteAtualCentavos,
  });

  final String categoriaNome;
  final int? limiteAtualCentavos;

  /// Devolve o limite em centavos, ou null se o usuário cancelou.
  static Future<int?> show(
    BuildContext context, {
    required String categoriaNome,
    int? limiteAtualCentavos,
  }) {
    return showDialog<int>(
      context: context,
      builder: (_) => LimiteDialog(
        categoriaNome: categoriaNome,
        limiteAtualCentavos: limiteAtualCentavos,
      ),
    );
  }

  @override
  State<LimiteDialog> createState() => _LimiteDialogState();
}

class _LimiteDialogState extends State<LimiteDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();

    final atual = widget.limiteAtualCentavos;
    final textoInicial = atual == null
        ? ''
        : (atual / 100).toStringAsFixed(2).replaceAll('.', ',');
    _controller = TextEditingController(text: textoInicial);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String? _validate(String? value) {
    final centavos = parseCentavos(value);
    if (centavos == null || centavos <= 0) {
      return 'Informe um valor maior que zero.';
    }
    return null;
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    Navigator.pop(context, parseCentavos(_controller.text));
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Limite de ${widget.categoriaNome}'),
      content: Form(
        key: _formKey,
        child: TextFormField(
          controller: _controller,
          autofocus: true,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(
            labelText: 'Limite mensal',
            prefixText: 'R\$ ',
          ),
          validator: _validate,
          onFieldSubmitted: (_) => _save(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        FilledButton(onPressed: _save, child: const Text('Salvar')),
      ],
    );
  }
}
