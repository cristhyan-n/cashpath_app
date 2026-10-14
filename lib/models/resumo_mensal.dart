import 'package:cashpath_app/models/categoria.dart';
import 'package:cashpath_app/models/transacao.dart';

class ResumoMensal {
  const ResumoMensal({
    required this.mes,
    this.salarioBaseCentavos,
    required this.outrasReceitasCentavos,
    required this.despesasCentavos,
  });

  final DateTime mes;
  final int? salarioBaseCentavos;
  final int outrasReceitasCentavos;
  final int despesasCentavos;

  int get receitasCentavos =>
      (salarioBaseCentavos ?? 0) + outrasReceitasCentavos;

  int get saldoCentavos => receitasCentavos - despesasCentavos;

  factory ResumoMensal.fromTransacoes(
    List<Transacao> transacoes,
    DateTime mes, {
    int? salarioBaseCentavos,
    Set<int> categoriasSalario = const {},
  }) {
    var outrasReceitas = 0;
    var despesas = 0;

    for (final transacao in transacoes) {
      final isOutroMes =
          transacao.data.year != mes.year || transacao.data.month != mes.month;
      if (isOutroMes) continue;

      if (transacao.isReceita) {
        final salarioJaContabilizado =
            salarioBaseCentavos != null &&
            categoriasSalario.contains(transacao.categoriaId);
        if (!salarioJaContabilizado) {
          outrasReceitas += transacao.valorCentavos;
        }
      } else {
        despesas += transacao.valorCentavos;
      }
    }

    return ResumoMensal(
      mes: mes,
      salarioBaseCentavos: salarioBaseCentavos,
      outrasReceitasCentavos: outrasReceitas,
      despesasCentavos: despesas,
    );
  }
}
