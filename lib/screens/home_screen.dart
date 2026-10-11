import 'package:flutter/material.dart';
import 'package:cashpath_app/models/transacao.dart';
import 'package:cashpath_app/screens/login_screen.dart';
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
  late final Future<HomeData?> _dataFuture;

  @override
  void initState() {
    super.initState();
    _dataFuture = _loadData();
  }

  Future<HomeData?> _loadData() async {
    try {
      final transacoes = await _transacaoService.listar();
      final categorias = await _categoriaService.listar();

      return (
        transacoes: transacoes,
        categorias: {for (final c in categorias) c.id: c.nome},
      );
    } on UnauthorizedException {
      _goToLogin();
      return null;
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
      body: FutureBuilder<HomeData?>(
        future: _dataFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            final message = snapshot.error.toString().replaceFirst(
              'Exception: ',
              '',
            );
            return Center(child: Text(message));
          }

          final data = snapshot.data;
          if (data == null) return const SizedBox.shrink();

          if (data.transacoes.isEmpty) {
            return const Center(child: Text('Nenhuma transação ainda.'));
          }

          return ListView.builder(
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
        },
      ),
    );
  }
}
