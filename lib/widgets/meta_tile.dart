import 'package:flutter/material.dart';
import 'package:cashpath_app/models/meta.dart';
import 'package:cashpath_app/models/meta_progresso.dart';
import 'package:cashpath_app/utils/formatters.dart';

class MetaTile extends StatelessWidget {
  const MetaTile({super.key, required this.meta, required this.progresso});

  final Meta meta;
  final MetaProgresso progresso;

  @override
  Widget build(BuildContext context) {
    final tipoLabel = meta.isEconomizar ? 'Economizar' : 'Investir';
    final percentual = progresso.percentualConcluido.round();

    return ListTile(
      title: Text('$tipoLabel ${formatCurrency(meta.valorAlvoCentavos)}'),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 4),
          LinearProgressIndicator(value: progresso.fracao),
          const SizedBox(height: 4),
          Text(
            '${formatCurrency(progresso.valorAtualCentavos)} de '
            '${formatCurrency(meta.valorAlvoCentavos)} • '
            'desde ${formatDate(meta.dataInicio)}',
          ),
        ],
      ),
      trailing: Text(
        '$percentual%',
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
    );
  }
}
