import 'package:flutter/material.dart';
import 'package:cashpath_app/models/alerta_orcamento.dart';
import 'package:cashpath_app/utils/formatters.dart';

class AlertaOrcamentoTile extends StatelessWidget {
  const AlertaOrcamentoTile({super.key, required this.alerta});

  final AlertaOrcamento alerta;

  @override
  Widget build(BuildContext context) {
    final color = alerta.isEstourado ? Colors.red : Colors.orange;
    final percentual = (alerta.fracaoUtilizada * 100).round();

    return ListTile(
      title: Text(alerta.categoriaNome),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 4),
          LinearProgressIndicator(
            value: alerta.fracaoUtilizada.clamp(0.0, 1.0).toDouble(),
            color: color,
          ),
          const SizedBox(height: 4),
          Text(
            '${formatCurrency(alerta.valorGastoCentavos)} de '
            '${formatCurrency(alerta.valorLimiteCentavos)}',
          ),
        ],
      ),
      trailing: Text(
        '$percentual%',
        style: TextStyle(color: color, fontWeight: FontWeight.bold),
      ),
    );
  }
}
