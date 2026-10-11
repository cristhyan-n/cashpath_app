class Transacao {
  const Transacao({
    required this.id,
    required this.descricao,
    required this.valorCentavos,
    required this.data,
    required this.tipo,
    required this.categoriaId,
  });

  final int id;
  final String descricao;
  final int valorCentavos;
  final DateTime data;
  final String tipo;
  final int categoriaId;

  bool get isReceita => tipo == 'receita';

  factory Transacao.fromJson(Map<String, dynamic> json) {
    return Transacao(
      id: json['id'] as int,
      descricao: json['descricao'] as String? ?? '',
      valorCentavos: json['valor'] as int,
      data: DateTime.parse(json['data'] as String),
      tipo: json['tipo'] as String,
      categoriaId: json['categoria_id'] as int,
    );
  }
}
