class Meta {
  const Meta({
    required this.id,
    required this.tipo,
    required this.valorAlvoCentavos,
    required this.dataInicio,
    required this.status,
  });

  final int id;
  final String tipo;
  final int valorAlvoCentavos;
  final DateTime dataInicio;
  final String status;

  bool get isEconomizar => tipo == 'economizar';

  factory Meta.fromJson(Map<String, dynamic> json) {
    return Meta(
      id: json['id'] as int,
      tipo: json['tipo'] as String,
      valorAlvoCentavos: json['valor_alvo'] as int,
      dataInicio: DateTime.parse(json['data_inicio'] as String),
      status: json['status'] as String,
    );
  }
}
