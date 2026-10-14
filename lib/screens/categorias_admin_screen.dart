import 'package:flutter/material.dart';
import 'package:cashpath_app/models/categoria.dart';
import 'package:cashpath_app/services/categoria_service.dart';
import 'package:cashpath_app/widgets/categoria_visual.dart';
import 'package:cashpath_app/widgets/categoria_form_dialog.dart';

class CategoriasAdminScreen extends StatefulWidget {
  const CategoriasAdminScreen({super.key});
  @override
  State<CategoriasAdminScreen> createState() => _CategoriasAdminScreenState();
}

class _CategoriasAdminScreenState extends State<CategoriasAdminScreen> {
  final _service = CategoriaService();
  List<Categoria> _categorias = [];
  String? _erro;
  bool _loading = true;
  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final rows = await _service.listarTodasAdmin();
      if (mounted) {
        setState(() {
          _categorias = rows;
          _loading = false;
          _erro = null;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _erro = e.toString().replaceFirst('Exception: ', '');
          _loading = false;
        });
      }
    }
  }

  Future<void> _edit([Categoria? categoria]) async {
    final result = await showDialog<(String, String, bool)?>(
      context: context,
      builder: (_) =>
          CategoriaFormDialog(categoria: categoria, permitirReceita: true),
    );
    if (result == null) return;
    if (result.$1.length < 2) return;
    try {
      if (categoria == null) {
        await _service.criarFixa(result.$1, result.$2);
      } else {
        await _service.atualizar(
          categoria,
          nome: result.$1,
          grupo: result.$2,
          ativa: result.$3,
        );
      }
      await _load();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Categorias do sistema')),
    floatingActionButton: FloatingActionButton(
      onPressed: () => _edit(),
      child: const Icon(Icons.add),
    ),
    body: _loading
        ? const Center(child: CircularProgressIndicator())
        : _erro != null
        ? Center(child: Text(_erro!))
        : ListView(
            padding: const EdgeInsets.fromLTRB(8, 8, 8, 88),
            children: [
              for (final c in _categorias)
                Card(
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 4,
                    ),
                    leading: CategoriaIcone(nome: c.nome, grupo: c.grupo),
                    title: Text(
                      c.nome,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: Text(
                      '${_nomeGrupo(c.grupo)} • ${c.ativa ? 'Ativa' : 'Desativada'}',
                    ),
                    trailing: const Icon(Icons.edit_outlined),
                    onTap: () => _edit(c),
                  ),
                ),
            ],
          ),
  );

  String _nomeGrupo(String grupo) => switch (grupo) {
    'necessidade' => 'Necessidades',
    'desejo' => 'Desejos',
    'economia' => 'Economia / investimentos',
    'receita' => 'Receitas',
    _ => grupo,
  };
}
