class AlertaOrcamento {
  const AlertaOrcamento({
    required this.categoriaNome,
    required this.valorLimiteCentavos,
    required this.valorGastoCentavos,
    required this.status,
  });

  final String categoriaNome;
  final int valorLimiteCentavos;
  final int valorGastoCentavos;
  final String status;

  bool get isEstourado => status == 'estourado';
  bool get precisaAtencao => status != 'ok';

  double get fracaoUtilizada {
    if (valorLimiteCentavos == 0) return 0;
    return valorGastoCentavos / valorLimiteCentavos;
  }

  factory AlertaOrcamento.fromJson(Map<String, dynamic> json) {
    return AlertaOrcamento(
      categoriaNome: json['categoria_nome'] as String,
      valorLimiteCentavos: json['valor_limite'] as int,
      valorGastoCentavos: json['valor_gasto'] as int,
      status: json['status'] as String,
    );
  }
}
