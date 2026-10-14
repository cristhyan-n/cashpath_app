import 'package:flutter/material.dart';
import 'package:cashpath_app/models/projecao.dart';
import 'package:cashpath_app/screens/login_screen.dart';
import 'package:cashpath_app/services/api_client.dart';
import 'package:cashpath_app/services/projecao_service.dart';
import 'package:cashpath_app/utils/formatters.dart';

class ProjecaoScreen extends StatefulWidget {
  const ProjecaoScreen({super.key});

  @override
  State<ProjecaoScreen> createState() => _ProjecaoScreenState();
}

class _ProjecaoScreenState extends State<ProjecaoScreen> {
  final _service = ProjecaoService();

  int _meses = 3;
  Projecao? _projecao;
  String? _errorMessage;
  bool _isLoading = true;
  bool _semHistorico = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final meses = _meses;

    try {
      final projecao = await _service.buscar(meses);

      if (!mounted || meses != _meses) return;
      setState(() {
        _projecao = projecao;
        _errorMessage = null;
        _semHistorico = false;
        _isLoading = false;
      });
    } on UnauthorizedException {
      _goToLogin();
    } on HistoricoInsuficienteException {
      if (!mounted || meses != _meses) return;
      setState(() {
        _semHistorico = true;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted || meses != _meses) return;
      setState(() {
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  void _goToLogin() {
    if (!mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  void _changeMeses(int meses) {
    setState(() {
      _meses = meses;
      _isLoading = true;
      _errorMessage = null;
      _semHistorico = false;
    });
    _load();
  }

  Widget _buildSemHistorico() {
    return const Padding(
      padding: EdgeInsets.only(top: 48),
      child: Column(
        children: [
          Icon(Icons.history, size: 48),
          SizedBox(height: 16),
          Text(
            'Ainda não há histórico suficiente.',
            textAlign: TextAlign.center,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Text(
            'Registre transações de ao menos um mês anterior ao atual '
            'para ver sua projeção.',
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildResult(Projecao projecao) {
    final textTheme = Theme.of(context).textTheme;
    final saldoColor = projecao.saldoProjetadoCentavos < 0
        ? Colors.red
        : Colors.green;
    final fonteRenda = projecao.usaPerfilFinanceiro
        ? 'Perfil financeiro'
        : 'Média das suas receitas';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                const Text('Aporte mensal sugerido'),
                const SizedBox(height: 4),
                Text(
                  formatCurrency(projecao.metaSugeridaCentavos),
                  style: textTheme.headlineMedium,
                ),
                const SizedBox(height: 6),
                Text(
                  'Sugestão de até 20% da renda base, limitada ao saldo após despesas. Registre o valor em uma meta para contabilizá-lo.',
                  textAlign: TextAlign.center,
                  style: textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        ListTile(
          title: const Text('Saldo após despesas'),
          subtitle: const Text(
            'Aportes em metas são contabilizados separadamente em Economia.',
          ),
          trailing: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              formatCurrency(projecao.saldoProjetadoCentavos),
              style: TextStyle(color: saldoColor, fontWeight: FontWeight.bold),
            ),
          ),
        ),
        ListTile(
          title: const Text('Renda base'),
          subtitle: Text(fonteRenda),
          trailing: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(formatCurrency(projecao.rendaBaseCentavos)),
          ),
        ),
        ListTile(
          title: const Text('Média de despesas por mês'),
          trailing: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(formatCurrency(projecao.mediaDespesasCentavos)),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Calculado com ${projecao.mesesConsiderados} '
          '${projecao.mesesConsiderados == 1 ? 'mês' : 'meses'} de histórico.',
          textAlign: TextAlign.center,
          style: textTheme.bodySmall,
        ),
      ],
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const Padding(
        padding: EdgeInsets.only(top: 48),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (_semHistorico) return _buildSemHistorico();

    if (_errorMessage != null) {
      return Padding(
        padding: const EdgeInsets.only(top: 48),
        child: Center(child: Text(_errorMessage!)),
      );
    }

    return _buildResult(_projecao!);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Projeção')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (!_semHistorico) ...[
            const Text('Histórico considerado'),
            const SizedBox(height: 8),
            SegmentedButton<int>(
              segments: const [
                ButtonSegment(value: 3, label: Text('3 meses')),
                ButtonSegment(value: 6, label: Text('6 meses')),
                ButtonSegment(value: 12, label: Text('12 meses')),
              ],
              selected: {_meses},
              onSelectionChanged: (selection) => _changeMeses(selection.first),
            ),
            const SizedBox(height: 16),
          ],
          _buildContent(),
        ],
      ),
    );
  }
}
