class Transacao {
  const Transacao({
    required this.id,
    required this.descricao,
    required this.valor,
    required this.data,
    required this.tipo,
    required this.categoriaId,
  });

  final int id;
  final String descricao;
  final double valor;
  final DateTime data;
  final String tipo;
  final int categoriaId;

  bool get isReceita => tipo == 'receita';

  factory Transacao.fromJson(Map<String, dynamic> json) {
    return Transacao(
      id: json['id'] as int,
      descricao: json['descricao'] as String? ?? '',
      valor: (json['valor'] as num).toDouble(),
      data: DateTime.parse(json['data'] as String),
      tipo: json['tipo'] as String,
      categoriaId: json['categoria_id'] as int,
    );
  }
}
