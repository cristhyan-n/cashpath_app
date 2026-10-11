import 'package:cashpath_app/models/transacao.dart';
import 'package:cashpath_app/services/api_client.dart';

class TransacaoService {
  final _api = ApiClient();

  Future<List<Transacao>> listar() async {
    final data = await _api.get('/transacoes') as List<dynamic>;
    return data
        .map((item) => Transacao.fromJson(item as Map<String, dynamic>))
        .toList();
  }
}
