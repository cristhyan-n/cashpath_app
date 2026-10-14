import 'package:flutter/material.dart';
import 'package:cashpath_app/models/alerta_orcamento.dart';
import 'package:cashpath_app/models/categoria.dart';
import 'package:cashpath_app/models/orcamento_grupo.dart';
import 'package:cashpath_app/utils/formatters.dart';
import 'package:cashpath_app/widgets/categoria_visual.dart';

class DivisaoOrcamentoLinha extends StatelessWidget {
  const DivisaoOrcamentoLinha({
    required this.titulo,
    required this.descricao,
    required this.valor,
    required this.cor,
  });

  final String titulo;
  final String descricao;
  final int valor;
  final Color cor;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(11),
      decoration: BoxDecoration(
        color: cor.withValues(alpha: .08),
        borderRadius: BorderRadius.circular(13),
      ),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 38,
            decoration: BoxDecoration(
              color: cor,
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  titulo,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  descricao,
                  style: const TextStyle(
                    fontSize: 10,
                    color: Color(0xFF718078),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            formatCurrency(valor),
            style: TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 12,
              color: cor,
            ),
          ),
        ],
      ),
    );
  }
}

class OrcamentoGrupoCard extends StatelessWidget {
  const OrcamentoGrupoCard({
    required this.orcamento,
    required this.nome,
    required this.onEditar,
  });

  final OrcamentoGrupo orcamento;
  final String nome;
  final VoidCallback onEditar;

  @override
  Widget build(BuildContext context) {
    final isEconomia = orcamento.grupo == 'economia';
    final hasLimit = orcamento.valorLimiteCentavos > 0;
    final percent = hasLimit ? orcamento.progresso : 0.0;
    final color = isEconomia
        ? const Color(0xFF2C8A62)
        : percent >= 1
        ? const Color(0xFFB84242)
        : percent >= .8
        ? const Color(0xFFA47B28)
        : const Color(0xFF2C8A62);
    final message = !hasLimit
        ? 'Defina um valor geral para acompanhar este grupo.'
        : isEconomia
        ? orcamento.valorRealizadoCentavos >= orcamento.valorLimiteCentavos
              ? 'Meta mensal de aportes alcançada.'
              : 'Faltam ${formatCurrency(orcamento.valorLimiteCentavos - orcamento.valorRealizadoCentavos)} em aportes no mês.'
        : '${(percent * 100).round()}% do limite utilizado';
    final icon = CategoriaVisual.para(nome, grupo: orcamento.grupo);

    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(15, 13, 10, 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: icon.fundo,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon.icone, color: icon.cor, size: 19),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        nome,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        isEconomia
                            ? 'Aportes e retiradas registrados'
                            : 'Limite geral do mês',
                        style: const TextStyle(
                          color: Color(0xFF718078),
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ),
                if (hasLimit)
                  IconButton(
                    tooltip: 'Editar valor geral',
                    onPressed: onEditar,
                    icon: const Icon(Icons.edit_outlined),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              isEconomia ? 'Aportes líquidos nas metas' : 'Gasto no mês',
              style: const TextStyle(color: Color(0xFF718078), fontSize: 10),
            ),
            const SizedBox(height: 2),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      formatCurrency(orcamento.valorRealizadoCentavos),
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 20,
                        letterSpacing: -.4,
                      ),
                    ),
                  ),
                ),
                if (hasLimit) ...[
                  const SizedBox(width: 5),
                  Flexible(
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 2),
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerRight,
                        child: Text(
                          'de ${formatCurrency(orcamento.valorLimiteCentavos)}',
                          style: const TextStyle(
                            color: Color(0xFF718078),
                            fontSize: 11,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
            if (hasLimit) ...[
              const SizedBox(height: 11),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  minHeight: 6,
                  value: percent.clamp(0.0, 1.0),
                  color: color,
                  backgroundColor: const Color(0xFFEDF2ED),
                ),
              ),
            ],
            if (!hasLimit) ...[
              Container(
                width: double.infinity,
                margin: const EdgeInsets.only(top: 7),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFF3F5F2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Nenhum orçamento definido para este grupo.',
                        style: TextStyle(
                          color: Color(0xFF718078),
                          fontSize: 11,
                        ),
                      ),
                    ),
                    TextButton.icon(
                      onPressed: onEditar,
                      icon: const Icon(Icons.add_rounded, size: 16),
                      label: const Text('Definir'),
                    ),
                  ],
                ),
              ),
            ] else ...[
              const SizedBox(height: 7),
              Text(
                message,
                style: TextStyle(
                  color: !isEconomia && percent >= 1
                      ? color
                      : const Color(0xFF718078),
                  fontSize: 10,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class CategoriaOrcamentoTile extends StatelessWidget {
  const CategoriaOrcamentoTile({
    required this.categoria,
    required this.orcamento,
    required this.onTap,
  });

  final Categoria categoria;
  final AlertaOrcamento? orcamento;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isEconomia = categoria.grupo == 'economia';
    final hasLimit = orcamento != null;
    final fracaoBruta = hasLimit ? orcamento!.fracaoUtilizada : 0.0;
    final progresso = fracaoBruta.clamp(0.0, 1.0).toDouble();
    final corProgresso = isEconomia
        ? const Color(0xFF2C8A62)
        : fracaoBruta >= 1
        ? const Color(0xFFB84242)
        : fracaoBruta >= .8
        ? const Color(0xFFA47B28)
        : const Color(0xFF2C8A62);

    return Card(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 7),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 11, 10, 11),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CategoriaIcone(
                    nome: categoria.nome,
                    grupo: categoria.grupo,
                    size: 36,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      categoria.nome,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  if (hasLimit)
                    IconButton(
                      tooltip: 'Editar limite',
                      visualDensity: VisualDensity.compact,
                      onPressed: onTap,
                      icon: const Icon(Icons.edit_outlined, size: 19),
                    )
                  else
                    TextButton.icon(
                      onPressed: onTap,
                      icon: const Icon(Icons.add_rounded, size: 17),
                      label: const Text('Definir limite'),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 7),
                        visualDensity: VisualDensity.compact,
                      ),
                    ),
                ],
              ),
              if (!hasLimit)
                const Padding(
                  padding: EdgeInsets.only(left: 46, top: 2),
                  child: Text(
                    'Sem limite. Defina um valor para acompanhar esta categoria no mês.',
                    style: TextStyle(color: Color(0xFF718078), fontSize: 11),
                  ),
                )
              else ...[
                Padding(
                  padding: const EdgeInsets.only(left: 46, top: 3),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          '${isEconomia ? 'Aportes líquidos' : 'Gasto'}: ${formatCurrency(orcamento!.valorRealizadoCentavos)} de ${formatCurrency(orcamento!.valorLimiteCentavos)}',
                          style: const TextStyle(
                            color: Color(0xFF718078),
                            fontSize: 11,
                          ),
                        ),
                      ),
                      Text(
                        isEconomia && fracaoBruta >= 1
                            ? 'Meta atingida'
                            : '${(fracaoBruta * 100).round()}%',
                        style: TextStyle(
                          color: corProgresso,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 46, top: 6),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      minHeight: 5,
                      value: progresso.clamp(0.0, 1.0),
                      color: corProgresso,
                      backgroundColor: const Color(0xFFEDF2ED),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
