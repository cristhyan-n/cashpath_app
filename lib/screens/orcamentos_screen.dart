import 'package:flutter/material.dart';
import 'package:cashpath_app/models/alerta_orcamento.dart';
import 'package:cashpath_app/models/categoria.dart';
import 'package:cashpath_app/screens/login_screen.dart';
import 'package:cashpath_app/services/api_client.dart';
import 'package:cashpath_app/services/categoria_service.dart';
import 'package:cashpath_app/services/orcamento_service.dart';
import 'package:cashpath_app/utils/formatters.dart';
import 'package:cashpath_app/widgets/limite_dialog.dart';

class OrcamentosScreen extends StatefulWidget {
  const OrcamentosScreen({super.key});

  @override
  State<OrcamentosScreen> createState() => _OrcamentosScreenState();
}

class _OrcamentosScreenState extends State<OrcamentosScreen> {
  final _categoriaService = CategoriaService();
  final _orcamentoService = OrcamentoService();

  List<Categoria> _categorias = [];
  Map<int, AlertaOrcamento> _orcamentos = {};
  String? _errorMessage;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final categorias = await _categoriaService.listar();
      final alertas = await _orcamentoService.listarAlertas(
        formatPeriod(DateTime.now()),
      );

      if (!mounted) return;
      setState(() {
        _categorias = categorias;
        _orcamentos = {for (final a in alertas) a.categoriaId: a};
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

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  String _describe(AlertaOrcamento? orcamento) {
    if (orcamento == null) return 'Sem limite definido';

    final limite = formatCurrency(orcamento.valorLimiteCentavos);
    final gasto = formatCurrency(orcamento.valorGastoCentavos);
    return 'Limite $limite • gasto no mês $gasto';
  }

  Future<void> _editLimite(Categoria categoria) async {
    final novoLimite = await LimiteDialog.show(
      context,
      categoriaNome: categoria.nome,
      limiteAtualCentavos: _orcamentos[categoria.id]?.valorLimiteCentavos,
    );

    if (novoLimite == null) return;

    try {
      await _orcamentoService.definirLimite(
        categoriaId: categoria.id,
        valorLimiteCentavos: novoLimite,
      );
    } on UnauthorizedException {
      _goToLogin();
      return;
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
      );
      return;
    }

    await _loadData();
  }

  Widget _buildBody() {
    if (_isLoading) return const Center(child: CircularProgressIndicator());
    if (_errorMessage != null) return Center(child: Text(_errorMessage!));

    return ListView.builder(
      itemCount: _categorias.length,
      itemBuilder: (context, index) {
        final categoria = _categorias[index];

        return ListTile(
          title: Text(categoria.nome),
          subtitle: Text(_describe(_orcamentos[categoria.id])),
          trailing: const Icon(Icons.edit_outlined),
          onTap: () => _editLimite(categoria),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Orçamentos')),
      body: _buildBody(),
    );
  }
}
