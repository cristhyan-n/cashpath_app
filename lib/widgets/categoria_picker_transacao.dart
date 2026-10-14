import 'package:flutter/material.dart';
import 'package:cashpath_app/models/categoria.dart';
import 'package:cashpath_app/widgets/categoria_visual.dart';

class CategoriaPickerTransacao extends StatefulWidget {
  const CategoriaPickerTransacao({
    required this.categorias,
    required this.tipo,
    required this.categoriaSelecionadaId,
    super.key,
  });

  final List<Categoria> categorias;
  final String tipo;
  final int? categoriaSelecionadaId;

  static Future<int?> show(
    BuildContext context, {
    required List<Categoria> categorias,
    required String tipo,
    int? categoriaSelecionadaId,
  }) => showModalBottomSheet<int>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Colors.transparent,
    builder: (_) => CategoriaPickerTransacao(
      categorias: categorias,
      tipo: tipo,
      categoriaSelecionadaId: categoriaSelecionadaId,
    ),
  );

  @override
  State<CategoriaPickerTransacao> createState() =>
      _CategoriaPickerTransacaoState();
}

class _CategoriaPickerTransacaoState extends State<CategoriaPickerTransacao> {
  final _buscaController = TextEditingController();

  @override
  void dispose() {
    _buscaController.dispose();
    super.dispose();
  }

  String _nomeGrupo(String grupo) => switch (grupo) {
    'necessidade' => 'Necessidades',
    'desejo' => 'Desejos',
    'receita' => 'Receitas',
    _ => grupo,
  };

  List<Widget> _construirItens(String termo, BuildContext sheetContext) {
    final filtradas = widget.categorias
        .where((categoria) => categoria.nome.toLowerCase().contains(termo))
        .toList();
    final grupos = widget.tipo == 'receita'
        ? const ['receita']
        : const ['necessidade', 'desejo'];
    final itens = <Widget>[];

    for (final grupo in grupos) {
      final categorias = filtradas
          .where((categoria) => categoria.grupo == grupo)
          .toList();
      if (categorias.isEmpty) continue;

      itens.add(
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 7),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  _nomeGrupo(grupo),
                  style: const TextStyle(
                    color: Color(0xFF718078),
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Text(
                '${categorias.length}',
                style: const TextStyle(color: Color(0xFF718078), fontSize: 11),
              ),
            ],
          ),
        ),
      );

      for (final categoria in categorias) {
        final selecionada = categoria.id == widget.categoriaSelecionadaId;
        itens.add(
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
            child: Material(
              color: selecionada ? const Color(0xFFEAF2EC) : Colors.transparent,
              borderRadius: BorderRadius.circular(15),
              child: ListTile(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                leading: CategoriaIcone(
                  nome: categoria.nome,
                  grupo: categoria.grupo,
                  size: 38,
                ),
                title: Text(
                  categoria.nome,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                subtitle: Text(_nomeGrupo(grupo)),
                trailing: Icon(
                  selecionada
                      ? Icons.check_circle_rounded
                      : Icons.chevron_right_rounded,
                  color: selecionada
                      ? const Color(0xFF2C8A62)
                      : const Color(0xFF9AA69E),
                ),
                onTap: () => Navigator.pop(sheetContext, categoria.id),
              ),
            ),
          ),
        );
      }
    }

    if (filtradas.isEmpty) {
      itens.add(
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 35, 24, 24),
          child: Column(
            children: [
              const Icon(
                Icons.search_off_rounded,
                size: 34,
                color: Color(0xFF9AA69E),
              ),
              const SizedBox(height: 9),
              Text(
                termo.isEmpty
                    ? 'Nenhuma categoria disponível para este tipo.'
                    : 'Nenhuma categoria encontrada para "$termo".',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Color(0xFF718078), fontSize: 13),
              ),
            ],
          ),
        ),
      );
    }
    return itens;
  }

  @override
  Widget build(BuildContext context) {
    final insetTeclado = MediaQuery.viewInsetsOf(context).bottom;
    final alturaDisponivel = MediaQuery.sizeOf(context).height - insetTeclado;
    final termo = _buscaController.text.trim().toLowerCase();

    return Padding(
      padding: EdgeInsets.only(bottom: insetTeclado),
      child: SizedBox(
        height: alturaDisponivel * .78,
        child: Container(
          decoration: const BoxDecoration(
            color: Color(0xFFF9FBF8),
            borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
          ),
          child: Column(
            children: [
              const SizedBox(height: 10),
              Container(
                width: 38,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFD4DDD6),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 14, 12),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Escolha uma categoria',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -.3,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            widget.tipo == 'receita'
                                ? 'Classifique de onde vem sua renda.'
                                : 'Encontre a categoria desta despesa.',
                            style: const TextStyle(
                              color: Color(0xFF718078),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      tooltip: 'Fechar',
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close_rounded),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18),
                child: TextField(
                  controller: _buscaController,
                  onChanged: (_) => setState(() {}),
                  decoration: InputDecoration(
                    hintText: 'Buscar categoria',
                    prefixIcon: const Icon(Icons.search_rounded),
                    suffixIcon: termo.isEmpty
                        ? null
                        : IconButton(
                            tooltip: 'Limpar busca',
                            onPressed: () {
                              _buscaController.clear();
                              setState(() {});
                            },
                            icon: const Icon(Icons.close_rounded),
                          ),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 5),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.only(bottom: 20),
                  children: _construirItens(termo, context),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
