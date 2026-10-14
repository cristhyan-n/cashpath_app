import 'package:flutter/material.dart';
import 'package:cashpath_app/models/meta.dart';
import 'package:cashpath_app/models/meta_progresso.dart';
import 'package:cashpath_app/utils/formatters.dart';

class MetaTile extends StatelessWidget {
  const MetaTile({
    super.key,
    required this.meta,
    required this.progresso,
    required this.onAddContribution,
    required this.onWithdraw,
    required this.onHistory,
    required this.onEdit,
    required this.onDelete,
  });

  final Meta meta;
  final MetaProgresso progresso;
  final VoidCallback onAddContribution;
  final VoidCallback onWithdraw;
  final VoidCallback onHistory;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final percentual = progresso.percentualConcluido.round();
    final concluida = progresso.status == 'concluido';

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: const Color(0xFFEAF4EB),
                    borderRadius: BorderRadius.circular(13),
                  ),
                  child: Icon(
                    meta.isEconomizar
                        ? Icons.savings_rounded
                        : Icons.trending_up_rounded,
                    color: const Color(0xFF2C8A62),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        meta.nome,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${meta.categoriaNome} · ${meta.isEconomizar ? 'saldo guardado' : 'saldo investido'}',
                        style: const TextStyle(
                          color: Color(0xFF718078),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                if (concluida)
                  const Icon(Icons.check_circle, color: Color(0xFF2C8A62)),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              formatCurrency(progresso.valorAtualCentavos),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 3),
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Meta: ${formatCurrency(meta.valorAlvoCentavos)}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Color(0xFF718078)),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '$percentual%',
                  style: const TextStyle(
                    color: Color(0xFF2C8A62),
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 9),
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: progresso.fracao,
                minHeight: 7,
                backgroundColor: const Color(0xFFEDF2ED),
                color: const Color(0xFF2C8A62),
              ),
            ),
            const SizedBox(height: 9),
            Text(
              concluida
                  ? 'Meta alcançada.'
                  : 'Faltam ${formatCurrency(progresso.valorRestanteCentavos)}',
              style: const TextStyle(color: Color(0xFF718078), fontSize: 12),
            ),
            if (meta.dataAlvo != null) ...[
              const SizedBox(height: 4),
              Text(
                'Prazo: ${formatDate(meta.dataAlvo!)}${progresso.aporteMensalSugeridoCentavos == null ? '' : ' · sugerido ${formatCurrency(progresso.aporteMensalSugeridoCentavos!)} por mês'}',
                style: const TextStyle(color: Color(0xFF718078), fontSize: 11),
              ),
            ],
            const SizedBox(height: 11),
            Wrap(
              alignment: WrapAlignment.end,
              spacing: 4,
              runSpacing: 2,
              children: [
                TextButton.icon(
                  onPressed: onHistory,
                  icon: const Icon(Icons.receipt_long_outlined, size: 18),
                  label: const Text('Movimentos'),
                ),
                TextButton.icon(
                  onPressed: onEdit,
                  icon: const Icon(Icons.edit_outlined, size: 18),
                  label: const Text('Editar'),
                ),
                IconButton(
                  tooltip: 'Excluir meta',
                  onPressed: onDelete,
                  icon: const Icon(Icons.delete_outline),
                ),
                if (progresso.valorAtualCentavos > 0)
                  TextButton.icon(
                    onPressed: onWithdraw,
                    icon: const Icon(Icons.remove_circle_outline, size: 18),
                    label: const Text('Retirar'),
                  ),
                FilledButton.icon(
                  onPressed: onAddContribution,
                  icon: const Icon(Icons.add_rounded, size: 18),
                  label: const Text('Aportar'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
