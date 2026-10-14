class AlertaOrcamento {
  const AlertaOrcamento({
    required this.categoriaId,
    required this.categoriaNome,
    required this.grupo,
    required this.valorLimiteCentavos,
    required this.valorRealizadoCentavos,
    required this.status,
  });

  final int categoriaId;
  final String categoriaNome;
  final String grupo;
  final int valorLimiteCentavos;
  final int valorRealizadoCentavos;
  final String status;

  bool get isEstourado => status == 'estourado';
  bool get isEconomia => grupo == 'economia';
  bool get precisaAtencao => !isEconomia && status != 'ok';

  double get fracaoUtilizada {
    if (valorLimiteCentavos == 0) return 0;
    return valorRealizadoCentavos / valorLimiteCentavos;
  }

  factory AlertaOrcamento.fromJson(Map<String, dynamic> json) {
    return AlertaOrcamento(
      categoriaId: json['categoria_id'] as int,
      categoriaNome: json['categoria_nome'] as String,
      grupo: json['grupo'] as String,
      valorLimiteCentavos: json['valor_limite'] as int,
      valorRealizadoCentavos:
          json['valor_realizado'] as int? ?? json['valor_gasto'] as int? ?? 0,
      status: json['status'] as String,
    );
  }
}
