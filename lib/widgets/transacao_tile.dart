import 'package:flutter/material.dart';
import 'package:cashpath_app/models/transacao.dart';
import 'package:cashpath_app/utils/formatters.dart';
import 'package:cashpath_app/widgets/categoria_visual.dart';
import 'package:cashpath_app/theme/app_theme.dart';

class TransacaoTile extends StatelessWidget {
  const TransacaoTile({
    super.key,
    required this.transacao,
    required this.categoriaNome,
    this.categoriaGrupo,
    this.onDelete,
  });

  final Transacao transacao;
  final String categoriaNome;
  final String? categoriaGrupo;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final color = transacao.isReceita ? const Color(0xFF2C8A62) : AppTheme.ink;
    final sign = transacao.isReceita ? '+' : '−';

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFEDF0ED)),
      ),
      child: Row(
        children: [
          CategoriaIcone(
            nome: categoriaNome,
            grupo: categoriaGrupo,
            receita: transacao.isReceita,
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transacao.descricao.isEmpty
                      ? categoriaNome
                      : transacao.descricao,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  '$categoriaNome • ${formatDate(transacao.data)}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: AppTheme.muted, fontSize: 10),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerRight,
              child: Text(
                '$sign ${formatCurrency(transacao.valorCentavos)}',
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                ),
              ),
            ),
          ),
          if (onDelete != null)
            IconButton(
              tooltip: 'Excluir transação',
              visualDensity: VisualDensity.compact,
              constraints: const BoxConstraints.tightFor(width: 34, height: 34),
              padding: EdgeInsets.zero,
              onPressed: onDelete,
              icon: const Icon(Icons.delete_outline, size: 19),
            ),
        ],
      ),
    );
  }
}
