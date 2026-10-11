class Projecao {
  const Projecao({
    required this.mesesConsiderados,
    required this.usaPerfilFinanceiro,
    required this.rendaBaseCentavos,
    required this.mediaDespesasCentavos,
    required this.saldoProjetadoCentavos,
    required this.metaSugeridaCentavos,
  });

  final int mesesConsiderados;
  final bool usaPerfilFinanceiro;
  final int rendaBaseCentavos;
  final int mediaDespesasCentavos;
  final int saldoProjetadoCentavos;
  final int metaSugeridaCentavos;

  factory Projecao.fromJson(Map<String, dynamic> json) {
    return Projecao(
      mesesConsiderados: json['meses_considerados'] as int,
      usaPerfilFinanceiro: json['fonte_renda'] == 'perfil_financeiro',
      rendaBaseCentavos: json['renda_base'] as int,
      mediaDespesasCentavos: json['media_despesas_mensais'] as int,
      saldoProjetadoCentavos: json['saldo_projetado'] as int,
      metaSugeridaCentavos: json['valor_meta_sugerido'] as int,
    );
  }
}
