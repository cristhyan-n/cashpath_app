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

  Future<void> criar({
    required String tipo,
    required int valorAlvoCentavos,
    required DateTime dataInicio,
  }) async {
    try {
      await _api.post('/metas', {
        'tipo': tipo,
        'valor_alvo': valorAlvoCentavos,
        'data_inicio': formatApiDate(dataInicio),
      });
    } on ApiException catch (e) {
      throw Exception(e.detail ?? 'Erro ao salvar meta (${e.statusCode}).');
    }
  }
}
