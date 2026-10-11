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
}
