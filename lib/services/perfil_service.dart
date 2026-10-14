import 'package:cashpath_app/services/api_client.dart';

class PerfilFinanceiro {
  const PerfilFinanceiro({
    required this.rendaCentavos,
    required this.periodo,
    required this.objetivo,
  });
  final int rendaCentavos;
  final String periodo;
  final String objetivo;
}

class PerfilService {
  final _api = ApiClient();

  Future<Map<String, dynamic>> usuario() async =>
      await _api.get('/usuarios/me') as Map<String, dynamic>;

  Future<String> papelUsuario() async =>
      (await usuario())['role'] as String? ?? 'usuario';

  Future<PerfilFinanceiro?> financeiroAtual() async {
    final dados = await _api.get('/perfil-financeiro') as List<dynamic>;
    if (dados.isEmpty) return null;
    final atual = dados.cast<Map<String, dynamic>>().reduce((
      maisRecente,
      item,
    ) {
      final periodoAtual = item['renda_periodo'] as String;
      final periodoMaisRecente = maisRecente['renda_periodo'] as String;
      return periodoAtual.compareTo(periodoMaisRecente) > 0
          ? item
          : maisRecente;
    });
    return PerfilFinanceiro(
      rendaCentavos: atual['valor_renda'] as int,
      periodo: atual['renda_periodo'] as String,
      objetivo: atual['objetivo'] as String? ?? 'economizar',
    );
  }

  Future<void> salvarFinanceiro(int rendaCentavos, String objetivo) async {
    final agora = DateTime.now();
    await _api.post('/perfil-financeiro', {
      'valor_renda': rendaCentavos,
      'renda_periodo':
          '${agora.year}-${agora.month.toString().padLeft(2, '0')}',
      'objetivo': objetivo,
    });
  }

  Future<void> resetarDadosFinanceiros() async {
    try {
      await _api.delete('/perfil-financeiro/dados');
    } on ApiException catch (e) {
      throw Exception(e.detail ?? 'Não foi possível redefinir os dados.');
    }
  }
}
