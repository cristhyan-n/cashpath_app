import 'package:flutter/material.dart';
import 'package:cashpath_app/models/meta.dart';
import 'package:cashpath_app/models/meta_progresso.dart';
import 'package:cashpath_app/utils/formatters.dart';

class HomeMetasSummary extends StatelessWidget {
  const HomeMetasSummary({
    required this.metas,
    required this.errored,
    required this.onOpenMetas,
    super.key,
  });

  final List<({Meta meta, MetaProgresso progresso})> metas;
  final bool errored;
  final VoidCallback onOpenMetas;

  @override
  Widget build(BuildContext context) {
    final exibidas = metas.take(3).toList();
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                const Icon(Icons.flag_outlined, color: Color(0xFF2C8A62)),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'Metas ativas',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
                TextButton(
                  onPressed: onOpenMetas,
                  child: Text(
                    errored
                        ? 'Abrir metas'
                        : metas.isEmpty
                        ? 'Criar meta'
                        : 'Ver todas',
                  ),
                ),
              ],
            ),
            if (exibidas.isEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 4, bottom: 7),
                child: Text(
                  errored
                      ? 'Não foi possível carregar as metas agora. Abra a tela de metas para tentar novamente.'
                      : 'Crie uma meta e acompanhe seus aportes por aqui.',
                  style: const TextStyle(
                    color: Color(0xFF718078),
                    fontSize: 12,
                  ),
                ),
              )
            else
              for (var i = 0; i < exibidas.length; i++) ...[
                if (i > 0) const SizedBox(height: 14),
                _HomeMetaProgressRow(
                  meta: exibidas[i].meta,
                  progresso: exibidas[i].progresso,
                ),
              ],
          ],
        ),
      ),
    );
  }
}

class _HomeMetaProgressRow extends StatelessWidget {
  const _HomeMetaProgressRow({required this.meta, required this.progresso});

  final Meta meta;
  final MetaProgresso progresso;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      Row(
        children: [
          Expanded(
            child: Text(
              meta.nome,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '${progresso.percentualConcluido.round()}%',
            style: const TextStyle(
              color: Color(0xFF2C8A62),
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
      const SizedBox(height: 7),
      ClipRRect(
        borderRadius: BorderRadius.circular(5),
        child: LinearProgressIndicator(
          value: progresso.fracao,
          minHeight: 6,
          backgroundColor: const Color(0xFFEDF2ED),
          color: const Color(0xFF2C8A62),
        ),
      ),
      const SizedBox(height: 5),
      Text(
        '${formatCurrency(progresso.valorAtualCentavos)} de ${formatCurrency(meta.valorAlvoCentavos)} · faltam ${formatCurrency(progresso.valorRestanteCentavos)}',
        style: const TextStyle(color: Color(0xFF718078), fontSize: 11),
      ),
    ],
  );
}

class HomeSectionTitle extends StatelessWidget {
  const HomeSectionTitle(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Text(text, style: Theme.of(context).textTheme.titleMedium),
    );
  }
}

class HomeIntro extends StatelessWidget {
  const HomeIntro({required this.month, super.key});

  final DateTime month;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 3),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'VISÃO GERAL · ${formatMonthYear(month).toUpperCase()}',
            style: const TextStyle(
              color: Color(0xFF718078),
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 7),
          Text(
            'Seu dinheiro,\nno caminho certo.',
            style: Theme.of(context).textTheme.headlineMedium
                ?.copyWith(fontSize: 25, height: 1.08),
          ),
          const SizedBox(height: 5),
          const Text(
            'Um passo de cada vez. Você está no controle.',
            style: TextStyle(color: Color(0xFF718078), fontSize: 12),
          ),
        ],
      ),
    );
  }
}
