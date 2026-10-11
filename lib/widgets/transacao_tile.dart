import 'package:flutter/material.dart';
import 'package:cashpath_app/models/transacao.dart';
import 'package:cashpath_app/utils/formatters.dart';

class TransacaoTile extends StatelessWidget {
  const TransacaoTile({
    super.key,
    required this.transacao,
    required this.categoriaNome,
  });

  final Transacao transacao;
  final String categoriaNome;

  @override
  Widget build(BuildContext context) {
    final color = transacao.isReceita ? Colors.green : Colors.red;
    final sign = transacao.isReceita ? '+' : '-';

    return ListTile(
      leading: Icon(
        transacao.isReceita ? Icons.arrow_upward : Icons.arrow_downward,
        color: color,
      ),
      title: Text(
        transacao.descricao.isEmpty ? categoriaNome : transacao.descricao,
      ),
      subtitle: Text('$categoriaNome • ${formatDate(transacao.data)}'),
      trailing: Text(
        '$sign ${formatCurrency(transacao.valorCentavos)}',
        style: TextStyle(color: color, fontWeight: FontWeight.bold),
      ),
    );
  }
}
