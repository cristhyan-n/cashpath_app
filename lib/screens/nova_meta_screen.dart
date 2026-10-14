import 'package:flutter/material.dart';
import 'package:cashpath_app/screens/login_screen.dart';
import 'package:cashpath_app/services/api_client.dart';
import 'package:cashpath_app/services/meta_service.dart';
import 'package:cashpath_app/utils/formatters.dart';
import 'package:cashpath_app/utils/parsers.dart';
import 'package:cashpath_app/models/meta.dart';
import 'package:cashpath_app/models/categoria.dart';
import 'package:cashpath_app/services/categoria_service.dart';
import 'package:cashpath_app/widgets/categoria_visual.dart';

class NovaMetaScreen extends StatefulWidget {
  const NovaMetaScreen({super.key, this.meta});

  final Meta? meta;

  @override
  State<NovaMetaScreen> createState() => _NovaMetaScreenState();
}

class _NovaMetaScreenState extends State<NovaMetaScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  final _valorController = TextEditingController();
  final _metaService = MetaService();
  final _categoriaService = CategoriaService();

  String _tipo = 'economizar';
  int? _categoriaId;
  List<Categoria> _categoriasEconomia = [];
  bool _carregandoCategorias = true;
  DateTime _dataInicio = DateTime.now();
  DateTime? _dataAlvo;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    final meta = widget.meta;
    if (meta != null) {
      _nomeController.text = meta.nome;
      _valorController.text = (meta.valorAlvoCentavos / 100).toStringAsFixed(2);
      _tipo = meta.tipo;
      _categoriaId = meta.categoriaId;
      _dataInicio = meta.dataInicio;
      _dataAlvo = meta.dataAlvo;
    }
    _carregarCategoriasEconomia();
  }

  Future<void> _carregarCategoriasEconomia() async {
    try {
      final categorias = await _categoriaService.listar();
      if (!mounted) return;
      setState(() {
        _categoriasEconomia = categorias
            .where(
              (categoria) => categoria.ativa && categoria.grupo == 'economia',
            )
            .toList();
        _carregandoCategorias = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _carregandoCategorias = false;
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  String? _validarCategoria(int? value) =>
      value == null ? 'Escolha uma categoria de Economia/Investimentos.' : null;

  @override
  void dispose() {
    _valorController.dispose();
    _nomeController.dispose();
    super.dispose();
  }

  String? _validateValor(String? value) {
    final centavos = parseCentavos(value);
    if (centavos == null || centavos <= 0) {
      return 'Informe um valor maior que zero.';
    }
    return null;
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dataInicio,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );

    if (picked == null || !mounted) return;
    setState(() => _dataInicio = picked);
  }

  Future<void> _pickTargetDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dataAlvo ?? _dataInicio,
      firstDate: _dataInicio,
      lastDate: DateTime.now().add(const Duration(days: 365 * 30)),
    );
    if (picked == null || !mounted) return;
    setState(() => _dataAlvo = picked);
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    String? error;
    try {
      if (widget.meta == null) {
        await _metaService.criar(
          nome: _nomeController.text.trim(),
          tipo: _tipo,
          categoriaId: _categoriaId!,
          valorAlvoCentavos: parseCentavos(_valorController.text)!,
          dataInicio: _dataInicio,
          dataAlvo: _dataAlvo,
        );
      } else {
        await _metaService.atualizar(
          metaId: widget.meta!.id,
          nome: _nomeController.text.trim(),
          categoriaId: _categoriaId!,
          valorAlvoCentavos: parseCentavos(_valorController.text)!,
          dataAlvo: _dataAlvo,
        );
      }
    } on UnauthorizedException {
      if (!mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
      return;
    } catch (e) {
      error = e.toString().replaceFirst('Exception: ', '');
    }

    if (!mounted) return;

    if (error != null) {
      setState(() {
        _isLoading = false;
        _errorMessage = error;
      });
      return;
    }

    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.meta == null ? 'Nova meta' : 'Editar meta'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _nomeController,
                textCapitalization: TextCapitalization.sentences,
                maxLength: 100,
                decoration: const InputDecoration(labelText: 'Nome da meta'),
                validator: (value) => value == null || value.trim().length < 2
                    ? 'Informe um nome com ao menos 2 caracteres.'
                    : null,
              ),
              const SizedBox(height: 16),
              if (_carregandoCategorias)
                const LinearProgressIndicator()
              else if (_categoriasEconomia.isEmpty)
                const Text(
                  'Não há categorias de Economia/Investimentos ativas. Ative ou crie uma categoria antes de cadastrar uma meta.',
                  style: TextStyle(color: Color(0xFFB84242), fontSize: 12),
                )
              else
                DropdownButtonFormField<int>(
                  key: ValueKey(_categoriasEconomia.length),
                  initialValue:
                      _categoriasEconomia.any(
                        (categoria) => categoria.id == _categoriaId,
                      )
                      ? _categoriaId
                      : null,
                  isExpanded: true,
                  decoration: const InputDecoration(
                    labelText: 'Categoria de economia',
                    prefixIcon: Icon(Icons.category_outlined),
                    helperText: 'Aportes e retiradas desta meta atualizam esta categoria e o orçamento geral de Economia.',
                  ),
                  items: [
                    for (final categoria in _categoriasEconomia)
                      DropdownMenuItem(
                        value: categoria.id,
                        child: Row(
                          children: [
                            CategoriaIcone(
                              nome: categoria.nome,
                              grupo: categoria.grupo,
                              size: 30,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                categoria.nome,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                  onChanged: (value) => setState(() => _categoriaId = value),
                  validator: _validarCategoria,
                ),
              const SizedBox(height: 16),
              if (widget.meta == null)
                SegmentedButton<String>(
                  segments: const [
                    ButtonSegment(
                      value: 'economizar',
                      label: Text('Economizar'),
                    ),
                    ButtonSegment(value: 'investir', label: Text('Investir')),
                  ],
                  selected: {_tipo},
                  onSelectionChanged: (selection) {
                    setState(() => _tipo = selection.first);
                  },
                ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _valorController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(
                  labelText: 'Valor alvo',
                  prefixText: 'R\$ ',
                ),
                validator: _validateValor,
              ),
              const SizedBox(height: 16),
              if (widget.meta == null)
                OutlinedButton.icon(
                  onPressed: _pickDate,
                  icon: const Icon(Icons.calendar_today),
                  label: Text('Início: ${formatDate(_dataInicio)}'),
                ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _pickTargetDate,
                      icon: const Icon(Icons.flag_outlined),
                      label: Text(
                        _dataAlvo == null
                            ? 'Adicionar prazo (opcional)'
                            : 'Prazo: ${formatDate(_dataAlvo!)}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                  if (_dataAlvo != null)
                    IconButton(
                      tooltip: 'Remover prazo',
                      onPressed: () => setState(() => _dataAlvo = null),
                      icon: const Icon(Icons.close_rounded),
                    ),
                ],
              ),
              if (_errorMessage != null) ...[
                const SizedBox(height: 16),
                Text(
                  _errorMessage!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ],
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed:
                    _isLoading ||
                        _carregandoCategorias ||
                        _categoriasEconomia.isEmpty
                    ? null
                    : _handleSave,
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(
                        widget.meta == null
                            ? 'Criar meta'
                            : 'Salvar alterações',
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
