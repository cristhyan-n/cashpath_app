class Meta {
  const Meta({
    required this.id,
    required this.nome,
    required this.tipo,
    required this.categoriaId,
    required this.categoriaNome,
    required this.valorAlvoCentavos,
    required this.dataInicio,
    required this.dataAlvo,
    required this.status,
  });

  final int id;
  final String nome;
  final String tipo;
  final int categoriaId;
  final String categoriaNome;
  final int valorAlvoCentavos;
  final DateTime dataInicio;
  final DateTime? dataAlvo;
  final String status;

  bool get isEconomizar => tipo == 'economizar';

  factory Meta.fromJson(Map<String, dynamic> json) {
    return Meta(
      id: json['id'] as int,
      nome: json['nome'] as String? ?? 'Minha meta',
      tipo: json['tipo'] as String,
      categoriaId: json['categoria_id'] as int? ?? 0,
      categoriaNome:
          json['categoria_nome'] as String? ??
          (json['tipo'] == 'investir'
              ? 'Investimentos'
              : 'Objetivos financeiros'),
      valorAlvoCentavos: json['valor_alvo'] as int,
      dataInicio: DateTime.parse(json['data_inicio'] as String),
      dataAlvo: json['data_alvo'] == null
          ? null
          : DateTime.parse(json['data_alvo'] as String),
      status: json['status'] as String,
    );
  }
}
