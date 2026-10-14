import 'package:flutter/material.dart';
import 'package:cashpath_app/models/alerta_orcamento.dart';
import 'package:cashpath_app/utils/formatters.dart';
import 'package:cashpath_app/widgets/categoria_visual.dart';

class AlertaOrcamentoTile extends StatelessWidget {
  const AlertaOrcamentoTile({super.key, required this.alerta});

  final AlertaOrcamento alerta;

  @override
  Widget build(BuildContext context) {
    final color = alerta.isEconomia
        ? const Color(0xFF2C8A62)
        : alerta.isEstourado
        ? const Color(0xFFB84242)
        : const Color(0xFFA47B28);
    final percentual = (alerta.fracaoUtilizada * 100).round();
    final visual = CategoriaVisual.para(
      alerta.categoriaNome,
      grupo: alerta.grupo,
    );

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: const Color(0xFFFAF7EC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFEEE4C8)),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: const Color(0xFFF1E6C5),
              borderRadius: BorderRadius.circular(11),
            ),
            child: Icon(visual.icone, color: const Color(0xFF9B792D), size: 18),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  alerta.categoriaNome,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(5),
                  child: LinearProgressIndicator(
                    minHeight: 5,
                    value: alerta.fracaoUtilizada.clamp(0.0, 1.0).toDouble(),
                    color: color,
                    backgroundColor: const Color(0xFFEDE7D5),
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  alerta.isEconomia
                      ? 'Aportes líquidos: ${formatCurrency(alerta.valorRealizadoCentavos)} de ${formatCurrency(alerta.valorLimiteCentavos)}'
                      : '${formatCurrency(alerta.valorRealizadoCentavos)} de ${formatCurrency(alerta.valorLimiteCentavos)}',
                  style: const TextStyle(
                    fontSize: 10,
                    color: Color(0xFF857C64),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            alerta.isEconomia && alerta.status == 'meta_alcancada'
                ? 'Meta atingida'
                : '$percentual%',
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w800,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
