import 'package:cashpath_app/models/alerta_orcamento.dart';
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
}
