import 'package:flutter/material.dart';
import 'package:cashpath_app/screens/login_screen.dart';
import 'package:cashpath_app/services/api_client.dart';
import 'package:cashpath_app/services/transacao_service.dart';
import 'package:cashpath_app/utils/formatters.dart';
import 'package:cashpath_app/models/categoria.dart';
import 'package:cashpath_app/screens/categorias_personalizadas_screen.dart';
import 'package:cashpath_app/widgets/categoria_visual.dart';
import 'package:cashpath_app/widgets/categoria_picker_transacao.dart';
import 'package:cashpath_app/services/categoria_service.dart';

class NovaTransacaoScreen extends StatefulWidget {
  const NovaTransacaoScreen({super.key, required this.categorias});

  final List<Categoria> categorias;

  @override
  State<NovaTransacaoScreen> createState() => _NovaTransacaoScreenState();
}

class _NovaTransacaoScreenState extends State<NovaTransacaoScreen> {
  final _formKey = GlobalKey<FormState>();
  final _valorController = TextEditingController();
  final _descricaoController = TextEditingController();
  final _transacaoService = TransacaoService();

  String _tipo = 'despesa';
  int? _categoriaId;
  DateTime _data = DateTime.now();
  bool _isLoading = false;
  String? _errorMessage;
  late List<Categoria> _categorias;

  @override
  void initState() {
    super.initState();
    _categorias = widget.categorias;
  }

  List<Categoria> get _categoriasCompativeis => _categorias
      .where(
        (categoria) => _tipo == 'receita'
            ? categoria.grupo == 'receita'
            : categoria.grupo == 'necessidade' || categoria.grupo == 'desejo',
      )
      .toList();

  Future<void> _abrirCategorias() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const CategoriasPersonalizadasScreen()),
    );
    try {
      final categorias = await CategoriaService().listar();
      if (mounted) {
        setState(() {
          _categorias = categorias;
          if (!_categoriasCompativeis.any(
            (categoria) => categoria.id == _categoriaId,
          )) {
            _categoriaId = null;
          }
        });
      }
    } catch (_) {}
  }

  Future<int?> _mostrarSeletorCategoria() => CategoriaPickerTransacao.show(
    context,
    categorias: _categoriasCompativeis,
    tipo: _tipo,
    categoriaSelecionadaId: _categoriaId,
  );
  @override
  void dispose() {
    _valorController.dispose();
    _descricaoController.dispose();
    super.dispose();
  }

  double? _parseValor(String? text) {
    return double.tryParse((text ?? '').trim().replaceAll(',', '.'));
  }

  String? _validateValor(String? value) {
    final valor = _parseValor(value);
    if (valor == null || valor <= 0) return 'Informe um valor maior que zero.';
    return null;
  }

  String? _validateCategoria(int? value) {
    return value == null ? 'Selecione uma categoria.' : null;
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _data,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );

    if (picked == null || !mounted) return;
    setState(() => _data = picked);
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    String? error;
    try {
      await _transacaoService.criar(
        descricao: _descricaoController.text.trim(),
        valor: _parseValor(_valorController.text)!,
        data: _data,
        tipo: _tipo,
        categoriaId: _categoriaId!,
      );
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

  void _selecionarTipo(String tipo) {
    setState(() {
      _tipo = tipo;
      if (!_categoriasCompativeis.any(
        (categoria) => categoria.id == _categoriaId,
      )) {
        _categoriaId = null;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isReceita = _tipo == 'receita';
    final destaque = isReceita
        ? const Color(0xFF2C8A62)
        : const Color(0xFFB84242);

    return Scaffold(
      appBar: AppBar(title: const Text('Nova transação')),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Registre uma movimentação',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 5),
              const Text(
                'Informe o valor e os detalhes para manter seu controle atualizado.',
                style: TextStyle(color: Color(0xFF718078), fontSize: 13),
              ),
              const SizedBox(height: 20),
              const Padding(
                padding: EdgeInsets.only(bottom: 9),
                child: Text(
                  'Tipo de movimentação',
                  style: TextStyle(
                    color: Color(0xFF718078),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Row(
                children: [
                  Expanded(
                    child: _TipoTransacaoCard(
                      titulo: 'Despesa',
                      descricao: 'Dinheiro sai',
                      icone: Icons.south_rounded,
                      cor: const Color(0xFFB84242),
                      selecionado: !isReceita,
                      onTap: () => _selecionarTipo('despesa'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _TipoTransacaoCard(
                      titulo: 'Receita',
                      descricao: 'Dinheiro entra',
                      icone: Icons.north_rounded,
                      cor: const Color(0xFF2C8A62),
                      selecionado: isReceita,
                      onTap: () => _selecionarTipo('receita'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.fromLTRB(18, 15, 18, 13),
                decoration: BoxDecoration(
                  color: destaque.withValues(alpha: .07),
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: destaque.withValues(alpha: .18)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.payments_outlined,
                          color: destaque,
                          size: 19,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          isReceita ? 'Valor recebido' : 'Valor gasto',
                          style: TextStyle(
                            color: destaque,
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    TextFormField(
                      controller: _valorController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      textInputAction: TextInputAction.next,
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -1,
                      ),
                      decoration: const InputDecoration(
                        filled: false,
                        hintText: '0,00',
                        prefixText: 'R\$ ',
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        errorBorder: InputBorder.none,
                        focusedErrorBorder: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(vertical: 5),
                      ),
                      validator: _validateValor,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 23),
              Row(
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: const Color(0xFFEAF2EC),
                      borderRadius: BorderRadius.circular(9),
                    ),
                    child: const Icon(
                      Icons.tune_rounded,
                      color: Color(0xFF477A62),
                      size: 16,
                    ),
                  ),
                  const SizedBox(width: 9),
                  Text(
                    'Detalhes',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ],
              ),
              const SizedBox(height: 11),
              TextFormField(
                controller: _descricaoController,
                textCapitalization: TextCapitalization.sentences,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  labelText: 'Descrição',
                  hintText: 'Ex.: mercado, salário, conta de luz',
                  prefixIcon: Icon(Icons.notes_rounded),
                ),
              ),
              const SizedBox(height: 12),
              FormField<int>(
                key: ValueKey('categoria-$_tipo'),
                initialValue: _categoriaId,
                validator: _validateCategoria,
                builder: (field) {
                  final selecionada = _categorias
                      .where((categoria) => categoria.id == field.value)
                      .firstOrNull;
                  return Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: () async {
                        final id = await _mostrarSeletorCategoria();
                        if (id == null || !mounted) return;
                        field.didChange(id);
                        setState(() => _categoriaId = id);
                      },
                      child: InputDecorator(
                        isEmpty: false,
                        decoration: InputDecoration(
                          labelText: 'Categoria',
                          prefixIcon: const Icon(Icons.category_outlined),
                          suffixIcon: const Icon(Icons.expand_more_rounded),
                          helperText: _tipo == 'receita'
                              ? 'Escolha onde classificar esta receita.'
                              : 'Escolha o grupo de despesa correspondente.',
                          errorText: field.errorText,
                        ),
                        child: Row(
                          children: [
                            if (selecionada != null) ...[
                              CategoriaIcone(
                                nome: selecionada.nome,
                                grupo: selecionada.grupo,
                                size: 30,
                              ),
                              const SizedBox(width: 10),
                            ],
                            Expanded(
                              child: Text(
                                selecionada?.nome ?? 'Toque para escolher',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: selecionada == null
                                      ? const Color(0xFF718078)
                                      : Theme.of(context).colorScheme.onSurface,
                                  fontWeight: selecionada == null
                                      ? FontWeight.normal
                                      : FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
              if (_tipo == 'despesa') ...[
                const SizedBox(height: 3),
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton.icon(
                    onPressed: _abrirCategorias,
                    icon: const Icon(Icons.add_circle_outline_rounded),
                    label: const Text('Criar categoria personalizada'),
                  ),
                ),
              ],
              const SizedBox(height: 7),
              Material(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: _pickDate,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 15,
                      vertical: 13,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFE4EAE5)),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: const Color(0xFFEAF2EC),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.calendar_month_rounded,
                            color: Color(0xFF477A62),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Data da movimentação',
                                style: TextStyle(
                                  color: Color(0xFF718078),
                                  fontSize: 11,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                formatDate(_data),
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Icon(
                          Icons.edit_calendar_outlined,
                          color: Color(0xFF718078),
                          size: 19,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              if (_errorMessage != null) ...[
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8EBE9),
                    borderRadius: BorderRadius.circular(13),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.error_outline_rounded,
                        color: Color(0xFFB84242),
                        size: 19,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _errorMessage!,
                          style: const TextStyle(
                            color: Color(0xFF9D3838),
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Container(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
          decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(top: BorderSide(color: Color(0xFFE7ECE8))),
          ),
          child: FilledButton.icon(
            onPressed: _isLoading ? null : _handleSave,
            icon: _isLoading
                ? const SizedBox(
                    width: 19,
                    height: 19,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.check_rounded),
            label: Text(
              _isLoading
                  ? 'Salvando…'
                  : isReceita
                  ? 'Salvar receita'
                  : 'Salvar despesa',
            ),
          ),
        ),
      ),
    );
  }
}

class _TipoTransacaoCard extends StatelessWidget {
  const _TipoTransacaoCard({
    required this.titulo,
    required this.descricao,
    required this.icone,
    required this.cor,
    required this.selecionado,
    required this.onTap,
  });

  final String titulo;
  final String descricao;
  final IconData icone;
  final Color cor;
  final bool selecionado;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final fundo = selecionado ? cor.withValues(alpha: .09) : Colors.white;

    return Material(
      color: fundo,
      borderRadius: BorderRadius.circular(17),
      child: InkWell(
        borderRadius: BorderRadius.circular(17),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(17),
            border: Border.all(
              color: selecionado ? cor : const Color(0xFFE4EAE5),
              width: selecionado ? 1.5 : 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: cor.withValues(alpha: .12),
                  borderRadius: BorderRadius.circular(11),
                ),
                child: Icon(icone, color: cor, size: 19),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      titulo,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: selecionado ? cor : const Color(0xFF17231E),
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      descricao,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFF718078),
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
              if (selecionado) ...[
                const SizedBox(width: 4),
                Icon(Icons.check_circle_rounded, color: cor, size: 17),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
