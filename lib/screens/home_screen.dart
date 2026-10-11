import 'package:flutter/material.dart';
import 'package:cashpath_app/models/transacao.dart';
import 'package:cashpath_app/screens/login_screen.dart';
import 'package:cashpath_app/screens/nova_transacao_screen.dart';
import 'package:cashpath_app/services/api_client.dart';
import 'package:cashpath_app/services/categoria_service.dart';
import 'package:cashpath_app/services/token_storage.dart';
import 'package:cashpath_app/services/transacao_service.dart';
import 'package:cashpath_app/widgets/transacao_tile.dart';

typedef HomeData = ({List<Transacao> transacoes, Map<int, String> categorias});

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _transacaoService = TransacaoService();
  final _categoriaService = CategoriaService();

  HomeData? _data;
  String? _errorMessage;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final transacoes = await _transacaoService.listar();
      final categorias = await _categoriaService.listar();

      if (!mounted) return;
      setState(() {
        _data = (
          transacoes: transacoes,
          categorias: {for (final c in categorias) c.id: c.nome},
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

  Widget _buildBody() {
    if (_isLoading) return const Center(child: CircularProgressIndicator());
    if (_errorMessage != null) return Center(child: Text(_errorMessage!));

    final data = _data!;
    if (data.transacoes.isEmpty) {
      return const Center(child: Text('Nenhuma transação ainda.'));
    }

    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 80),
      itemCount: data.transacoes.length,
      itemBuilder: (context, index) {
        final transacao = data.transacoes[index];
        return TransacaoTile(
          transacao: transacao,
          categoriaNome:
              data.categorias[transacao.categoriaId] ?? 'Sem categoria',
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('CashPath'),
        actions: [
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
