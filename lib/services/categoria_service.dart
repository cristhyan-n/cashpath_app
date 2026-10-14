import 'package:cashpath_app/models/categoria.dart';
import 'package:cashpath_app/services/api_client.dart';

class CategoriaService {
  final _api = ApiClient();

  Future<List<Categoria>> listar() async {
    final data = await _api.get('/categorias') as List<dynamic>;
    return data
        .map((item) => Categoria.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<List<Categoria>> listarTodasAdmin() async {
    final data = await _api.get('/categorias/admin') as List<dynamic>;
    return data
        .map((item) => Categoria.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<List<Categoria>> listarMinhas() async {
    final data = await _api.get('/categorias/minhas') as List<dynamic>;
    return data.map((item) => Categoria.fromJson(item as Map<String, dynamic>)).toList();
  }

  Future<void> criar(String nome, String grupo) async {
    await _api.post('/categorias', {'nome': nome, 'grupo': grupo});
  }

  Future<void> atualizar(
    Categoria categoria, {
    required String nome,
    required String grupo,
    required bool ativa,
  }) async {
    await _api.put('/categorias/${categoria.id}', {
      'nome': nome,
      'grupo': grupo,
      'ativa': ativa,
    });
  }

  Future<void> criarFixa(String nome, String grupo) async {
    await _api.post('/categorias/fixas', {'nome': nome, 'grupo': grupo});
  }
}
