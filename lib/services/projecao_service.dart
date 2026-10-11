import 'package:cashpath_app/models/projecao.dart';
import 'package:cashpath_app/services/api_client.dart';

class HistoricoInsuficienteException implements Exception {
  const HistoricoInsuficienteException();
}

class ProjecaoService {
  final _api = ApiClient();

  Future<Projecao> buscar(int meses) async {
    try {
      final data =
          await _api.get('/projecao?meses=$meses') as Map<String, dynamic>;
      return Projecao.fromJson(data);
    } on ApiException catch (e) {
      if (e.statusCode == 400) throw const HistoricoInsuficienteException();
      rethrow;
    }
  }
}
