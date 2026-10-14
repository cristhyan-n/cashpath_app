class Categoria {
  const Categoria({
    required this.id,
    required this.nome,
    required this.grupo,
    this.ativa = true,
    this.personalizada = false,
  });

  final int id;
  final String nome;
  final String grupo;
  final bool ativa;
  final bool personalizada;

  factory Categoria.fromJson(Map<String, dynamic> json) {
    return Categoria(
      id: json['id'] as int,
      nome: json['nome'] as String,
      grupo: json['grupo'] as String? ?? 'desejo',
      ativa: json['ativa'] as bool? ?? true,
      personalizada: json['personalizada'] as bool? ?? false,
    );
  }
}
