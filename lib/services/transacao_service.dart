import 'package:cashpath_app/models/transacao.dart';
import 'package:cashpath_app/services/api_client.dart';

class TransacaoService {
  final _api = ApiClient();

  Future<List<Transacao>> listar() async {
    final data = await _api.get('/transacoes') as List<dynamic>;
    final transacoes = data
        .map((item) => Transacao.fromJson(item as Map<String, dynamic>))
        .toList();

    transacoes.sort((a, b) {
      final byDate = b.data.compareTo(a.data);
      return byDate != 0 ? byDate : b.id.compareTo(a.id);
    });

    return transacoes;
  }

  Future<void> criar({
    required String descricao,
    required double valor,
    required DateTime data,
    required String tipo,
    required int categoriaId,
  }) async {
    try {
      await _api.post('/transacoes', {
        'descricao': descricao,
        'valor': (valor * 100).round(),
        'data': data.toIso8601String().substring(0, 10),
        'tipo': tipo,
        'categoria_id': categoriaId,
      });
    } on ApiException catch (e) {
      if (e.statusCode == 404) throw Exception('Categoria não encontrada.');
      throw Exception('Erro ao salvar transação (${e.statusCode}).');
    }
  }
}
