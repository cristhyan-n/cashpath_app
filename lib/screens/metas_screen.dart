import 'package:flutter/material.dart';
import 'package:cashpath_app/models/meta.dart';
import 'package:cashpath_app/models/meta_progresso.dart';
import 'package:cashpath_app/screens/login_screen.dart';
import 'package:cashpath_app/services/api_client.dart';
import 'package:cashpath_app/services/meta_service.dart';
import 'package:cashpath_app/widgets/meta_tile.dart';
import 'package:cashpath_app/screens/nova_meta_screen.dart';

class MetasScreen extends StatefulWidget {
  const MetasScreen({super.key});

  @override
  State<MetasScreen> createState() => _MetasScreenState();
}

class _MetasScreenState extends State<MetasScreen> {
  final _metaService = MetaService();

  List<Meta> _metas = [];
  Map<int, MetaProgresso> _progressos = {};
  String? _errorMessage;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final metas = await _metaService.listar();
      final progressos = await Future.wait(
        metas.map((meta) => _metaService.buscarProgresso(meta.id)),
      );

      if (!mounted) return;
      setState(() {
        _metas = metas;
        _progressos = {for (final p in progressos) p.metaId: p};
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

  Future<void> _openNovaMeta() async {
    final created = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => const NovaMetaScreen()),
    );

    if (created == true) _loadData();
  }

  Widget _buildBody() {
    if (_isLoading) return const Center(child: CircularProgressIndicator());
    if (_errorMessage != null) return Center(child: Text(_errorMessage!));
    if (_metas.isEmpty) return const Center(child: Text('Nenhuma meta ainda.'));

    return ListView.builder(
      itemCount: _metas.length,
      itemBuilder: (context, index) {
        final meta = _metas[index];
        return MetaTile(meta: meta, progresso: _progressos[meta.id]!);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Metas')),
      body: _buildBody(),
      floatingActionButton: FloatingActionButton(
        onPressed: _openNovaMeta,
        child: const Icon(Icons.add),
      ),
    );
  }
}
