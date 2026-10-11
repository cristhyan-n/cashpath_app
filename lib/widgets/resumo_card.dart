import 'package:flutter/material.dart';
import 'package:cashpath_app/models/resumo_mensal.dart';
import 'package:cashpath_app/utils/formatters.dart';

class ResumoCard extends StatelessWidget {
  const ResumoCard({super.key, required this.resumo});

  final ResumoMensal resumo;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final saldoColor = resumo.saldoCentavos < 0 ? Colors.red : Colors.green;

    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(formatMonthYear(resumo.mes), style: textTheme.labelLarge),
            const SizedBox(height: 8),
            const Text('Saldo do mês'),
            Text(
              formatCurrency(resumo.saldoCentavos),
              style: textTheme.headlineMedium?.copyWith(color: saldoColor),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _Total(
                    label: 'Receitas',
                    centavos: resumo.receitasCentavos,
                    color: Colors.green,
                  ),
                ),
                Expanded(
                  child: _Total(
                    label: 'Despesas',
                    centavos: resumo.despesasCentavos,
                    color: Colors.red,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Total extends StatelessWidget {
  const _Total({
    required this.label,
    required this.centavos,
    required this.color,
  });

  final String label;
  final int centavos;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label),
        Text(
          formatCurrency(centavos),
          style: TextStyle(color: color, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
