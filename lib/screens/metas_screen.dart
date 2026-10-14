import 'package:flutter/material.dart';
import 'package:cashpath_app/models/meta.dart';
import 'package:cashpath_app/models/meta_progresso.dart';
import 'package:cashpath_app/screens/login_screen.dart';
import 'package:cashpath_app/services/api_client.dart';
import 'package:cashpath_app/services/meta_service.dart';
import 'package:cashpath_app/widgets/meta_tile.dart';
import 'package:cashpath_app/screens/nova_meta_screen.dart';
import 'package:cashpath_app/utils/formatters.dart';
import 'package:cashpath_app/widgets/meta_movimento_dialog.dart';

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
      final progressos = await _metaService.buscarProgressos();
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
    if (created == true) await _loadData();
  }

  Future<bool> _confirmarExclusao(String titulo, String mensagem) async =>
      await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(titulo),
          content: Text(mensagem),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Voltar')),
            FilledButton.tonal(onPressed: () => Navigator.pop(context, true), child: const Text('Excluir')),
          ],
        ),
      ) ?? false;

  Future<void> _editMeta(Meta meta) async {
    final saved = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => NovaMetaScreen(meta: meta)),
    );
    if (saved == true) await _loadData();
  }

  Future<void> _deleteMeta(Meta meta) async {
    if (!await _confirmarExclusao(
      'Excluir meta?',
      'A meta “${meta.nome}” e todo o histórico de aportes e retiradas serão removidos.',
    )) return;
    try {
      await _metaService.excluir(meta.id);
      await _loadData();
    } on UnauthorizedException {
      _goToLogin();
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
      );
    }
  }

  Future<void> _deleteMovement(
    Meta meta, Map<String, dynamic> movimento, BuildContext dialogContext,
  ) async {
    final id = movimento['id'] as int;
    if (!await _confirmarExclusao(
      'Excluir movimentação?',
      'O saldo e o progresso da meta serão recalculados.',
    )) return;
    try {
      await _metaService.excluirMovimento(meta.id, id);
      if (dialogContext.mounted) Navigator.pop(dialogContext);
      await _loadData();
      if (mounted) await _showHistory(meta);
    } on UnauthorizedException {
      _goToLogin();
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
      );
    }
  }

  Future<void> _registerMovement(Meta meta, String tipo) async {
    final valor = await MetaMovimentoDialog.show(
      context,
      tipo: tipo,
      metaNome: meta.nome,
      saldoAtualCentavos: _progressos[meta.id]?.valorAtualCentavos ?? 0,
    );
    if (valor == null) return;
    try {
      await _metaService.registrarMovimento(
        metaId: meta.id,
        tipo: tipo,
        valorCentavos: valor,
      );
      await _loadData();
    } on UnauthorizedException {
      _goToLogin();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
      );
    }
  }

  Future<void> _showHistory(Meta meta) async {
    try {
      final movimentos = await _metaService.listarMovimentos(meta.id);
      if (!mounted) return;
      await showDialog<void>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: Text('Movimentos · ${meta.nome}'),
          content: SizedBox(
            width: double.maxFinite,
            child: movimentos.isEmpty
                ? const Text('Ainda não há aportes ou retiradas nesta meta.')
                : ConstrainedBox(
                    constraints: BoxConstraints(
                      maxHeight: MediaQuery.sizeOf(dialogContext).height * .5,
                    ),
                    child: ListView.separated(
                      shrinkWrap: true,
                      itemCount: movimentos.length,
                      separatorBuilder: (_, _) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final movimento = movimentos[index];
                        final aporte = movimento['tipo'] == 'aporte';
                        final data = DateTime.parse(
                          movimento['data'] as String,
                        );
                        return ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: Icon(
                            aporte
                                ? Icons.add_circle_outline
                                : Icons.remove_circle_outline,
                            color: aporte
                                ? const Color(0xFF2C8A62)
                                : Theme.of(context).colorScheme.error,
                          ),
                          title: Text(aporte ? 'Aporte' : 'Retirada'),
                          subtitle: Text(formatDate(data)),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '${aporte ? '+' : '−'}${formatCurrency(movimento['valor'] as int)}',
                                style: const TextStyle(fontWeight: FontWeight.w700),
                              ),
                              IconButton(
                                tooltip: 'Excluir para corrigir',
                                onPressed: () => _deleteMovement(meta, movimento, dialogContext),
                                icon: const Icon(Icons.delete_outline, size: 19),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Fechar'),
            ),
          ],
        ),
      );
    } on UnauthorizedException {
      _goToLogin();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
      );
    }
  }

  Widget _buildBody() {
    if (_isLoading) return const Center(child: CircularProgressIndicator());
    if (_errorMessage != null) return Center(child: Text(_errorMessage!));
    if (_metas.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text(
            'Nenhuma meta ainda. Crie uma meta e registre seus aportes para acompanhar o progresso real.',
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return ListView.builder(
      itemCount: _metas.length,
      itemBuilder: (context, index) {
        final meta = _metas[index];
        final progresso = _progressos[meta.id]!;
        return MetaTile(
          meta: meta,
          progresso: progresso,
          onAddContribution: () => _registerMovement(meta, 'aporte'),
          onWithdraw: () => _registerMovement(meta, 'retirada'),
          onHistory: () => _showHistory(meta),
          onEdit: () => _editMeta(meta),
          onDelete: () => _deleteMeta(meta),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Metas')),
    body: _buildBody(),
    floatingActionButton: FloatingActionButton(
      onPressed: _openNovaMeta,
      child: const Icon(Icons.add),
    ),
  );
}
