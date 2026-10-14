import 'package:cashpath_app/models/alerta_orcamento.dart';
import 'package:cashpath_app/models/orcamento_grupo.dart';
import 'package:cashpath_app/services/api_client.dart';

class OrcamentoService {
  final _api = ApiClient();

  Future<List<AlertaOrcamento>> listarAlertas(String periodo) async {
    final data =
        await _api.get('/orcamentos/alertas?periodo=$periodo') as List<dynamic>;

    return data
        .map((item) => AlertaOrcamento.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<List<OrcamentoGrupo>> listarGrupos(String periodo) async {
    final dados =
        await _api.get('/orcamentos/grupos?periodo=$periodo') as List<dynamic>;
    return dados
        .map((item) => OrcamentoGrupo.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<void> definirLimiteGrupo({
    required String grupo,
    required int valorLimiteCentavos,
    required String periodo,
  }) async {
    try {
      await _api.put('/orcamentos/grupos?periodo=$periodo', {
        'grupo': grupo,
        'valor_limite': valorLimiteCentavos,
      });
    } on ApiException catch (e) {
      throw Exception(e.detail ?? 'Erro ao salvar orçamento geral.');
    }
  }

  Future<void> definirDivisaoGrupos({
    required Map<String, int> limitesCentavos,
    required String periodo,
  }) async {
    try {
      await _api.put('/orcamentos/grupos/divisao?periodo=$periodo', {
        'itens': [
          for (final entry in limitesCentavos.entries)
            {'grupo': entry.key, 'valor_limite': entry.value},
        ],
      });
    } on ApiException catch (e) {
      throw Exception(e.detail ?? 'Erro ao salvar a divisão geral.');
    }
  }

  Future<void> resetarGrupos() async {
    try {
      await _api.delete('/orcamentos/grupos');
    } on ApiException catch (e) {
      throw Exception(
        e.detail ?? 'Não foi possível resetar os orçamentos gerais.',
      );
    }
  }

  Future<void> resetarCategorias() async {
    try {
      await _api.delete('/orcamentos/categorias');
    } on ApiException catch (e) {
      throw Exception(
        e.detail ?? 'Não foi possível resetar os limites por categoria.',
      );
    }
  }

  Future<List<Map<String, dynamic>>> sugerir() async =>
      (await _api.get('/orcamentos/sugestoes') as List<dynamic>)
          .cast<Map<String, dynamic>>();

  Future<void> definirLimite({
    required int categoriaId,
    required int valorLimiteCentavos,
  }) async {
    try {
      await _api.post('/orcamentos', {
        'categoria_id': categoriaId,
        'valor_limite': valorLimiteCentavos,
      });
    } on ApiException catch (e) {
      throw Exception(
        e.detail ?? 'Erro ao salvar orçamento (${e.statusCode}).',
      );
    }
  }
}
