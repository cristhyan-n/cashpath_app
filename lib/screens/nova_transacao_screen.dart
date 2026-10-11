import 'package:flutter/material.dart';
import 'package:cashpath_app/screens/login_screen.dart';
import 'package:cashpath_app/services/api_client.dart';
import 'package:cashpath_app/services/transacao_service.dart';
import 'package:cashpath_app/utils/formatters.dart';

class NovaTransacaoScreen extends StatefulWidget {
  const NovaTransacaoScreen({super.key, required this.categorias});

  final Map<int, String> categorias;

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nova transação')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SegmentedButton<String>(
                segments: const [
                  ButtonSegment(value: 'despesa', label: Text('Despesa')),
                  ButtonSegment(value: 'receita', label: Text('Receita')),
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
                  labelText: 'Valor',
                  prefixText: 'R\$ ',
                ),
                validator: _validateValor,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descricaoController,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                  labelText: 'Descrição (opcional)',
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<int>(
                initialValue: _categoriaId,
                decoration: const InputDecoration(labelText: 'Categoria'),
                items: [
                  for (final entry in widget.categorias.entries)
                    DropdownMenuItem(
                      value: entry.key,
                      child: Text(entry.value),
                    ),
                ],
                onChanged: (value) => setState(() => _categoriaId = value),
                validator: _validateCategoria,
              ),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: _pickDate,
                icon: const Icon(Icons.calendar_today),
                label: Text(formatDate(_data)),
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
                onPressed: _isLoading ? null : _handleSave,
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Salvar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
