import 'package:flutter/material.dart';
import 'package:cashpath_app/models/categoria.dart';
import 'package:cashpath_app/services/categoria_service.dart';
import 'package:cashpath_app/widgets/categoria_visual.dart';
import 'package:cashpath_app/widgets/categoria_form_dialog.dart';

class CategoriasPersonalizadasScreen extends StatefulWidget {
  const CategoriasPersonalizadasScreen({super.key});

  @override
  State<CategoriasPersonalizadasScreen> createState() =>
      _CategoriasPersonalizadasScreenState();
}

class _CategoriasPersonalizadasScreenState
    extends State<CategoriasPersonalizadasScreen> {
  final _service = CategoriaService();
  List<Categoria> _categorias = [];
  bool _carregando = true;
  String? _erro;

  @override
  void initState() {
    super.initState();
    _carregar();
  }

  Future<void> _carregar() async {
    try {
      final categorias = await _service.listarMinhas();
      if (mounted) {
        setState(() {
          _categorias = categorias;
          _carregando = false;
          _erro = null;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _erro = e.toString().replaceFirst('Exception: ', '');
          _carregando = false;
        });
      }
    }
  }

  Future<void> _editar([Categoria? categoria]) async {
    final resultado = await showDialog<(String, String, bool)?>(
      context: context,
      builder: (_) =>
          CategoriaFormDialog(categoria: categoria, permitirReceita: false),
    );
    if (resultado == null) return;
    if (resultado.$1.length < 2) return;
    try {
      if (categoria == null) {
        await _service.criar(resultado.$1, resultado.$2);
      } else {
        await _service.atualizar(
          categoria,
          nome: resultado.$1,
          grupo: resultado.$2,
          ativa: resultado.$3,
        );
      }
      await _carregar();
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
    appBar: AppBar(title: const Text('Minhas categorias')),
    floatingActionButton: FloatingActionButton(
      onPressed: () => _editar(),
      tooltip: 'Criar categoria personalizada',
      child: const Icon(Icons.add),
    ),
    body: _carregando
        ? const Center(child: CircularProgressIndicator())
        : _erro != null
        ? Center(child: Text(_erro!))
        : _categorias.isEmpty
        ? const Center(
            child: Text('Você ainda não criou categorias personalizadas.'),
          )
        : ListView(
            padding: const EdgeInsets.fromLTRB(8, 8, 8, 88),
            children: [
              for (final categoria in _categorias)
                Card(
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 4,
                    ),
                    leading: CategoriaIcone(
                      nome: categoria.nome,
                      grupo: categoria.grupo,
                    ),
                    title: Text(
                      categoria.nome,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: Text(
                      '${_nomeGrupo(categoria.grupo)} • ${categoria.ativa ? 'Ativa' : 'Desativada'}',
                    ),
                    trailing: const Icon(Icons.edit_outlined),
                    onTap: () => _editar(categoria),
                  ),
                ),
            ],
          ),
  );

  String _nomeGrupo(String grupo) => switch (grupo) {
    'necessidade' => 'Necessidades',
    'desejo' => 'Desejos',
    'economia' => 'Economia / investimentos',
    _ => grupo,
  };
}
