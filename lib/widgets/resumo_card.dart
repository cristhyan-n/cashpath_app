import 'package:flutter/material.dart';
import 'package:cashpath_app/models/resumo_mensal.dart';
import 'package:cashpath_app/utils/formatters.dart';
import 'package:cashpath_app/theme/app_theme.dart';

class ResumoCard extends StatelessWidget {
  const ResumoCard({super.key, required this.resumo});

  final ResumoMensal resumo;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final saldoColor = resumo.saldoCentavos < 0
        ? const Color(0xFFB84242)
        : AppTheme.lime;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 10, 16, 18),
      decoration: BoxDecoration(
        color: AppTheme.forest,
        borderRadius: BorderRadius.circular(26),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1A12352B),
            blurRadius: 22,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(22, 20, 22, 22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    formatMonthYear(resumo.mes),
                    style: textTheme.labelLarge?.copyWith(
                      color: Colors.white70,
                    ),
                  ),
                ),
                const Icon(
                  Icons.trending_up_rounded,
                  color: AppTheme.lime,
                  size: 22,
                ),
              ],
            ),
            const SizedBox(height: 18),
            Text(
              'Saldo disponível',
              style: textTheme.bodyMedium?.copyWith(color: Colors.white70),
            ),
            const SizedBox(height: 3),
            SizedBox(
              width: double.infinity,
              child: FittedBox(
                alignment: Alignment.centerLeft,
                fit: BoxFit.scaleDown,
                child: Text(
                  formatCurrency(resumo.saldoCentavos),
                  style: textTheme.headlineMedium?.copyWith(
                    color: saldoColor,
                    fontSize: 34,
                  ),
                ),
              ),
            ),
            if (resumo.salarioBaseCentavos != null) ...[
              const SizedBox(height: 6),
              Text(
                'Salário base: ${formatCurrency(resumo.salarioBaseCentavos!)}',
                style: textTheme.bodySmall?.copyWith(color: Colors.white70),
              ),
            ],
            const SizedBox(height: 6),
            Text(
              'Salário + outras receitas − despesas. Aportes ficam em Economia.',
              style: textTheme.bodySmall?.copyWith(color: Colors.white70),
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(
                  child: _Total(
                    label: 'Outras receitas',
                    centavos: resumo.outrasReceitasCentavos,
                    color: const Color(0xFF9DE0B1),
                  ),
                ),
                Expanded(
                  child: _Total(
                    label: 'Despesas',
                    centavos: resumo.despesasCentavos,
                    color: const Color(0xFFFFB4A9),
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
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 12),
        ),
        SizedBox(
          width: double.infinity,
          child: FittedBox(
            alignment: Alignment.centerLeft,
            fit: BoxFit.scaleDown,
            child: Text(
              formatCurrency(centavos),
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w700,
                fontSize: 16,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
