import 'package:flutter/material.dart';
import 'package:cashpath_app/utils/formatters.dart';
import 'package:cashpath_app/utils/parsers.dart';

class MetaMovimentoDialog extends StatefulWidget {
  const MetaMovimentoDialog({
    super.key,
    required this.tipo,
    required this.metaNome,
    required this.saldoAtualCentavos,
  });

  final String tipo;
  final String metaNome;
  final int saldoAtualCentavos;

  static Future<int?> show(
    BuildContext context, {
    required String tipo,
    required String metaNome,
    required int saldoAtualCentavos,
  }) => showDialog<int>(
    context: context,
    builder: (_) => MetaMovimentoDialog(
      tipo: tipo,
      metaNome: metaNome,
      saldoAtualCentavos: saldoAtualCentavos,
    ),
  );

  @override
  State<MetaMovimentoDialog> createState() => _MetaMovimentoDialogState();
}

class _MetaMovimentoDialogState extends State<MetaMovimentoDialog> {
  final _formKey = GlobalKey<FormState>();
  final _valorController = TextEditingController();

  @override
  void dispose() {
    _valorController.dispose();
    super.dispose();
  }

  String? _validate(String? value) {
    final valor = parseCentavos(value);
    if (valor == null || valor <= 0) return 'Informe um valor maior que zero.';
    if (widget.tipo == 'retirada' && valor > widget.saldoAtualCentavos) {
      return 'O máximo disponível é ${formatCurrency(widget.saldoAtualCentavos)}.';
    }
    return null;
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    Navigator.pop(context, parseCentavos(_valorController.text));
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: Text(
      widget.tipo == 'aporte' ? 'Registrar aporte' : 'Registrar retirada',
    ),
    content: Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(widget.metaNome),
          if (widget.tipo == 'retirada') ...[
            const SizedBox(height: 8),
            Text('Disponível: ${formatCurrency(widget.saldoAtualCentavos)}'),
          ],
          const SizedBox(height: 14),
          TextFormField(
            controller: _valorController,
            autofocus: true,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(
              labelText: 'Valor',
              prefixText: 'R\$ ',
            ),
            validator: _validate,
            onFieldSubmitted: (_) => _save(),
          ),
        ],
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
