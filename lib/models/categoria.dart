class Categoria {
  const Categoria({required this.id, required this.nome});

  final int id;
  final String nome;

  factory Categoria.fromJson(Map<String, dynamic> json) {
    return Categoria(id: json['id'] as int, nome: json['nome'] as String);
  }
}
