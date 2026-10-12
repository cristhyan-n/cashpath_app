import 'package:flutter/material.dart';
import 'package:cashpath_app/models/alerta_orcamento.dart';
import 'package:cashpath_app/models/resumo_mensal.dart';
import 'package:cashpath_app/models/transacao.dart';
import 'package:cashpath_app/screens/login_screen.dart';
import 'package:cashpath_app/screens/nova_transacao_screen.dart';
import 'package:cashpath_app/services/api_client.dart';
import 'package:cashpath_app/services/categoria_service.dart';
import 'package:cashpath_app/services/orcamento_service.dart';
import 'package:cashpath_app/services/token_storage.dart';
import 'package:cashpath_app/services/transacao_service.dart';
import 'package:cashpath_app/utils/formatters.dart';
import 'package:cashpath_app/widgets/alerta_orcamento_tile.dart';
import 'package:cashpath_app/widgets/resumo_card.dart';
import 'package:cashpath_app/widgets/transacao_tile.dart';
import 'package:cashpath_app/screens/projecao_screen.dart';
import 'package:cashpath_app/screens/orcamentos_screen.dart';

typedef HomeData = ({
  List<Transacao> transacoes,
  Map<int, String> categorias,
  List<AlertaOrcamento> alertas,
  ResumoMensal resumo,
});

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _transacaoService = TransacaoService();
  final _categoriaService = CategoriaService();
  final _orcamentoService = OrcamentoService();

  HomeData? _data;
  String? _errorMessage;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final mes = DateTime.now();

    try {
      final transacoes = await _transacaoService.listar();
      final categorias = await _categoriaService.listar();
      final alertas = await _orcamentoService.listarAlertas(formatPeriod(mes));

      if (!mounted) return;
      setState(() {
        _data = (
          transacoes: transacoes,
          categorias: {for (final c in categorias) c.id: c.nome},
          alertas: alertas.where((a) => a.precisaAtencao).toList(),
          resumo: ResumoMensal.fromTransacoes(transacoes, mes),
        );
        _errorMessage = null;
        _isLoading = false;
      });
    } on UnauthorizedException {
      _goToLogin();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  void _goToLogin() {
    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  Future<void> _handleLogout() async {
    await TokenStorage().delete();
    _goToLogin();
  }

  Future<void> _openNovaTransacao() async {
    final created = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => NovaTransacaoScreen(categorias: _data!.categorias),
      ),
    );

    if (created == true) _loadData();
  }

  Future<void> _openOrcamentos() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const OrcamentosScreen()),
    );

    _loadData();
  }

  Widget _buildBody() {
    if (_isLoading) return const Center(child: CircularProgressIndicator());
    if (_errorMessage != null) return Center(child: Text(_errorMessage!));

    final data = _data!;

    return ListView(
      padding: const EdgeInsets.only(bottom: 80),
      children: [
        ResumoCard(resumo: data.resumo),
        if (data.alertas.isNotEmpty) ...[
          const _SectionTitle('Alertas de orçamento'),
          for (final alerta in data.alertas)
            AlertaOrcamentoTile(alerta: alerta),
        ],
        const _SectionTitle('Transações'),
        if (data.transacoes.isEmpty)
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text('Nenhuma transação ainda.'),
          )
        else
          for (final transacao in data.transacoes)
            TransacaoTile(
              transacao: transacao,
              categoriaNome:
                  data.categorias[transacao.categoriaId] ?? 'Sem categoria',
            ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('CashPath'),
        actions: [
          IconButton(
            icon: const Icon(Icons.savings_outlined),
            tooltip: 'Orçamentos',
            onPressed: _openOrcamentos,
          ),
          IconButton(
            icon: const Icon(Icons.insights),
            tooltip: 'Projeção',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ProjecaoScreen()),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Sair',
            onPressed: _handleLogout,
          ),
        ],
      ),
      body: _buildBody(),
      floatingActionButton: _data == null
          ? null
          : FloatingActionButton(
              onPressed: _openNovaTransacao,
              child: const Icon(Icons.add),
            ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Text(text, style: Theme.of(context).textTheme.titleMedium),
    );
  }
}
