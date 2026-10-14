class OrcamentoGrupo {
  const OrcamentoGrupo({
    required this.grupo,
    required this.valorLimiteCentavos,
    required this.valorRealizadoCentavos,
  });

  final String grupo;
  final int valorLimiteCentavos;
  final int valorRealizadoCentavos;

  double get progresso => valorLimiteCentavos == 0
      ? 0
      : valorRealizadoCentavos / valorLimiteCentavos;

  factory OrcamentoGrupo.fromJson(Map<String, dynamic> json) {
    return OrcamentoGrupo(
      grupo: json['grupo'] as String,
      valorLimiteCentavos: json['valor_limite'] as int,
      valorRealizadoCentavos: json['valor_realizado'] as int,
    );
  }
}
