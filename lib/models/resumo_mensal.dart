import 'package:cashpath_app/models/transacao.dart';

class ResumoMensal {
  const ResumoMensal({
    required this.mes,
    required this.receitasCentavos,
    required this.despesasCentavos,
  });

  final DateTime mes;
  final int receitasCentavos;
  final int despesasCentavos;

  int get saldoCentavos => receitasCentavos - despesasCentavos;

  factory ResumoMensal.fromTransacoes(
    List<Transacao> transacoes,
    DateTime mes,
  ) {
    var receitas = 0;
    var despesas = 0;

    for (final transacao in transacoes) {
      final isOutroMes =
          transacao.data.year != mes.year || transacao.data.month != mes.month;
      if (isOutroMes) continue;

      if (transacao.isReceita) {
        receitas += transacao.valorCentavos;
      } else {
        despesas += transacao.valorCentavos;
      }
    }

    return ResumoMensal(
      mes: mes,
      receitasCentavos: receitas,
      despesasCentavos: despesas,
    );
  }
}
