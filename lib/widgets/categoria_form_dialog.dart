import 'package:flutter/material.dart';
import 'package:cashpath_app/models/categoria.dart';

class CategoriaFormDialog extends StatefulWidget {
  const CategoriaFormDialog({
    super.key,
    this.categoria,
    this.permitirReceita = false,
  });

  final Categoria? categoria;
  final bool permitirReceita;

  @override
  State<CategoriaFormDialog> createState() => _CategoriaFormDialogState();
}

class _CategoriaFormDialogState extends State<CategoriaFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nome;
  late String _grupo;
  late bool _ativa;

  @override
  void initState() {
    super.initState();
    _nome = TextEditingController(text: widget.categoria?.nome ?? '');
    _grupo = widget.categoria?.grupo ?? 'necessidade';
    _ativa = widget.categoria?.ativa ?? true;
  }

  @override
  void dispose() {
    _nome.dispose();
    super.dispose();
  }

  void _salvar() {
    if (!_formKey.currentState!.validate()) return;
    Navigator.of(context).pop((_nome.text.trim(), _grupo, _ativa));
  }

  @override
  Widget build(BuildContext context) {
    final grupos = [
      const DropdownMenuItem(value: 'necessidade', child: Text('Necessidades')),
      const DropdownMenuItem(value: 'desejo', child: Text('Desejos')),
      const DropdownMenuItem(
        value: 'economia',
        child: Text(
          'Economia / investimentos',
          overflow: TextOverflow.ellipsis,
        ),
      ),
      if (widget.permitirReceita)
        const DropdownMenuItem(value: 'receita', child: Text('Receitas')),
    ];

    return AlertDialog(
      title: Text(
        widget.categoria == null ? 'Nova categoria' : 'Editar categoria',
      ),
      content: SizedBox(
        width: double.maxFinite,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.sizeOf(context).height * .65,
          ),
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextFormField(
                    controller: _nome,
                    autofocus: true,
                    maxLength: 80,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: const InputDecoration(
                      labelText: 'Nome da categoria',
                      hintText: 'Ex.: Academia',
                      counterText: '',
                    ),
                    validator: (value) =>
                        value == null || value.trim().length < 2
                        ? 'Digite pelo menos 2 caracteres.'
                        : null,
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    initialValue: _grupo,
                    isExpanded: true,
                    decoration: const InputDecoration(labelText: 'Grupo'),
                    items: grupos,
                    onChanged: (value) {
                      if (value != null) setState(() => _grupo = value);
                    },
                  ),
                  if (widget.categoria != null) ...[
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Expanded(child: Text('Categoria ativa')),
                        Switch(
                          value: _ativa,
                          onChanged: (value) => setState(() => _ativa = value),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        FilledButton(onPressed: _salvar, child: const Text('Salvar')),
      ],
    );
  }
}
