import 'package:cashpath_app/models/meta.dart';
import 'package:cashpath_app/models/meta_progresso.dart';
import 'package:cashpath_app/services/api_client.dart';
import 'package:cashpath_app/utils/formatters.dart';

class MetaService {
  final _api = ApiClient();

  Future<List<Meta>> listar() async {
    final data = await _api.get('/metas') as List<dynamic>;
    return data
        .map((item) => Meta.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<MetaProgresso> buscarProgresso(int metaId) async {
    final data =
        await _api.get('/metas/$metaId/progresso') as Map<String, dynamic>;
    return MetaProgresso.fromJson(data);
  }

  Future<List<MetaProgresso>> buscarProgressos() async {
    final data = await _api.get('/metas/progresso') as List<dynamic>;
    return data
        .map((item) => MetaProgresso.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<void> criar({
    required String nome,
    required String tipo,
    required int categoriaId,
    required int valorAlvoCentavos,
    required DateTime dataInicio,
    DateTime? dataAlvo,
  }) async {
    try {
      await _api.post('/metas', {
        'nome': nome,
        'tipo': tipo,
        'categoria_id': categoriaId,
        'valor_alvo': valorAlvoCentavos,
        'data_inicio': formatApiDate(dataInicio),
        'data_alvo': dataAlvo == null ? null : formatApiDate(dataAlvo),
      });
    } on ApiException catch (e) {
      throw Exception(e.detail ?? 'Erro ao salvar meta (${e.statusCode}).');
    }
  }

  Future<void> atualizar({
    required int metaId,
    required String nome,
    required int categoriaId,
    required int valorAlvoCentavos,
    DateTime? dataAlvo,
  }) async {
    try {
      await _api.put('/metas/$metaId', {
        'nome': nome,
        'categoria_id': categoriaId,
        'valor_alvo': valorAlvoCentavos,
        'data_alvo': dataAlvo == null ? null : formatApiDate(dataAlvo),
      });
    } on ApiException catch (e) {
      throw Exception(e.detail ?? 'Não foi possível atualizar a meta.');
    }
  }

  Future<void> excluir(int metaId) async {
    try {
      await _api.delete('/metas/$metaId');
    } on ApiException catch (e) {
      throw Exception(e.detail ?? 'Não foi possível excluir a meta.');
    }
  }

  Future<void> excluirMovimento(int metaId, int movimentoId) async {
    try {
      await _api.delete('/metas/$metaId/movimentos/$movimentoId');
    } on ApiException catch (e) {
      throw Exception(e.detail ?? 'Não foi possível corrigir a movimentação.');
    }
  }

  Future<void> registrarMovimento({
    required int metaId,
    required String tipo,
    required int valorCentavos,
  }) async {
    try {
      await _api.post('/metas/$metaId/movimentos', {
        'tipo': tipo,
        'valor': valorCentavos,
        'data': formatApiDate(DateTime.now()),
      });
    } on ApiException catch (e) {
      throw Exception(e.detail ?? 'Não foi possível registrar a movimentação.');
    }
  }

  Future<List<Map<String, dynamic>>> listarMovimentos(int metaId) async {
    final data = await _api.get('/metas/$metaId/movimentos') as List<dynamic>;
    return data.cast<Map<String, dynamic>>();
  }
}
