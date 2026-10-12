class MetaProgresso {
  const MetaProgresso({
    required this.metaId,
    required this.valorAtualCentavos,
    required this.percentualConcluido,
  });

  final int metaId;
  final int valorAtualCentavos;
  final double percentualConcluido;

  /// Fração de 0 a 1, própria para barras de progresso.
  double get fracao => (percentualConcluido / 100).clamp(0.0, 1.0).toDouble();

  factory MetaProgresso.fromJson(Map<String, dynamic> json) {
    return MetaProgresso(
      metaId: json['meta_id'] as int,
      valorAtualCentavos: json['valor_atual'] as int,
      percentualConcluido: (json['percentual_concluido'] as num).toDouble(),
    );
  }
}
