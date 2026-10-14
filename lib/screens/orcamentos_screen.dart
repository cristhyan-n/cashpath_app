import 'package:flutter/material.dart';
import 'package:cashpath_app/models/alerta_orcamento.dart';
import 'package:cashpath_app/models/categoria.dart';
import 'package:cashpath_app/models/orcamento_grupo.dart';
import 'package:cashpath_app/screens/login_screen.dart';
import 'package:cashpath_app/screens/categorias_personalizadas_screen.dart';
import 'package:cashpath_app/widgets/categoria_visual.dart';
import 'package:cashpath_app/services/api_client.dart';
import 'package:cashpath_app/services/categoria_service.dart';
import 'package:cashpath_app/services/orcamento_service.dart';
import 'package:cashpath_app/utils/formatters.dart';
import 'package:cashpath_app/widgets/limite_dialog.dart';
import 'package:cashpath_app/widgets/orcamento_cards.dart';

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
  List<OrcamentoGrupo> _orcamentosGrupo = [];
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
      final grupos = await _orcamentoService.listarGrupos(
        formatPeriod(DateTime.now()),
      );

      if (!mounted) return;
      setState(() {
        _categorias = categorias.where((c) => c.grupo != 'receita').toList();
        _orcamentos = {for (final a in alertas) a.categoriaId: a};
        _orcamentosGrupo = grupos;
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

  Future<void> _editLimite(Categoria categoria) async {
    final novoLimite = await LimiteDialog.show(
      context,
      categoriaNome: categoria.nome,
      valorLabel: categoria.grupo == 'economia'
          ? 'Aporte mensal planejado'
          : 'Limite mensal',
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

  Future<void> _editLimiteGrupo(OrcamentoGrupo grupo) async {
    final novoLimite = await LimiteDialog.show(
      context,
      categoriaNome: _nomeGrupo(grupo.grupo),
      valorLabel: grupo.grupo == 'economia'
          ? 'Meta mensal de economia/investimento'
          : 'Limite mensal do grupo',
      limiteAtualCentavos: grupo.valorLimiteCentavos == 0
          ? null
          : grupo.valorLimiteCentavos,
    );
    if (novoLimite == null) return;

    try {
      await _orcamentoService.definirLimiteGrupo(
        grupo: grupo.grupo,
        valorLimiteCentavos: novoLimite,
        periodo: formatPeriod(DateTime.now()),
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

  Future<void> _sugerirOrcamentosGrupo() async {
    try {
      final sugestoes = await _orcamentoService.sugerir();
      final totais = <String, int>{
        'necessidade': 0,
        'desejo': 0,
        'economia': 0,
      };
      for (final sugestao in sugestoes) {
        final grupo = sugestao['grupo'] as String;
        totais[grupo] =
            (totais[grupo] ?? 0) + (sugestao['valor_sugerido'] as int);
      }
      final rendaBaseCentavos = totais.values.fold<int>(
        0,
        (soma, valor) => soma + valor,
      );

      if (!mounted) return;
      final prosseguir = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Como funciona a divisão 50/30/20?'),
          content: SizedBox(
            width: double.maxFinite,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'A renda mensal planejada considerada é ${formatCurrency(rendaBaseCentavos)}. A divisão reserva partes para despesas essenciais, gastos flexíveis e aportes nas metas:',
                  ),
                  const SizedBox(height: 12),
                  DivisaoOrcamentoLinha(
                    titulo: '50% · Necessidades',
                    descricao:
                        'Moradia, alimentação, transporte e contas essenciais.',
                    valor: totais['necessidade']!,
                    cor: const Color(0xFF477A62),
                  ),
                  DivisaoOrcamentoLinha(
                    titulo: '30% · Desejos',
                    descricao:
                        'Lazer, compras, viagens e outros gastos flexíveis.',
                    valor: totais['desejo']!,
                    cor: const Color(0xFFAD6684),
                  ),
                  DivisaoOrcamentoLinha(
                    titulo: '20% · Economia e investimentos',
                    descricao:
                        'Valor planejado para guardar ou investir no mês.',
                    valor: totais['economia']!,
                    cor: const Color(0xFF2C8A62),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Os percentuais são referências: você não precisa gastar todo o limite de Necessidades ou Desejos. Ao prosseguir, os três valores substituirão os orçamentos gerais atuais; os limites individuais por categoria continuam separados e podem ser ajustados abaixo.',
                    style: TextStyle(fontSize: 12, color: Color(0xFF718078)),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Não prosseguir'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Prosseguir e aplicar'),
            ),
          ],
        ),
      );
      if (prosseguir != true) return;

      await _orcamentoService.definirDivisaoGrupos(
        limitesCentavos: totais,
        periodo: formatPeriod(DateTime.now()),
      );
      await _loadData();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Orçamentos gerais definidos pela regra 50/30/20.'),
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

  Future<void> _confirmarReset({required bool porGrupo}) async {
    final confirmado = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          porGrupo
              ? 'Resetar orçamento geral?'
              : 'Resetar limites por categoria?',
        ),
        content: Text(
          porGrupo
              ? 'Isso remove os limites gerais salvos para Necessidades, Desejos e Economia/Investimentos. Seus gastos, renda, metas e limites individuais por categoria serão mantidos. Depois, você poderá definir ou sugerir os limites gerais novamente.'
              : 'Isso remove os limites individuais salvos para todas as categorias. Seus gastos, renda, categorias e orçamentos gerais dos três grupos serão mantidos. Depois, você poderá definir os limites de cada categoria individualmente.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Manter orçamento'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFFB84242),
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Resetar orçamento'),
          ),
        ],
      ),
    );
    if (confirmado != true) return;

    try {
      if (porGrupo) {
        await _orcamentoService.resetarGrupos();
      } else {
        await _orcamentoService.resetarCategorias();
      }
      await _loadData();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            porGrupo
                ? 'Orçamentos gerais resetados.'
                : 'Limites por categoria resetados.',
          ),
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

  Widget _suggestionActions({
    required String label,
    required VoidCallback onSuggest,
    required bool porGrupo,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: onSuggest,
              icon: const Icon(Icons.auto_awesome_outlined, size: 18),
              label: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis),
            ),
          ),
          const SizedBox(width: 5),
          TextButton.icon(
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFFB84242),
              padding: const EdgeInsets.symmetric(horizontal: 7),
            ),
            onPressed: () => _confirmarReset(porGrupo: porGrupo),
            icon: const Icon(Icons.restart_alt_rounded, size: 18),
            label: const Text('Resetar'),
          ),
        ],
      ),
    );
  }

  Widget _categoryResetAction() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 4),
      child: Align(
        alignment: Alignment.centerRight,
        child: TextButton.icon(
          style: TextButton.styleFrom(
            foregroundColor: const Color(0xFF8A7777),
            padding: const EdgeInsets.symmetric(horizontal: 7),
          ),
          onPressed: () => _confirmarReset(porGrupo: false),
          icon: const Icon(Icons.restart_alt_rounded, size: 17),
          label: const Text('Resetar'),
        ),
      ),
    );
  }

  Future<void> _openCategories() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const CategoriasPersonalizadasScreen()),
    );
    await _loadData();
  }

  Widget _buildGroupSection(String grupo) {
    final categorias = _categorias.where((c) => c.grupo == grupo).toList();
    final visual = CategoriaVisual.para(_nomeGrupo(grupo), grupo: grupo);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 7),
          child: Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: visual.fundo,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(visual.icone, color: visual.cor, size: 17),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  _nomeGrupo(grupo),
                  style: Theme.of(context).textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.w700),
                ),
              ),
              Text(
                '${categorias.length} ${categorias.length == 1 ? 'categoria' : 'categorias'}',
                style: const TextStyle(color: Color(0xFF718078), fontSize: 11),
              ),
            ],
          ),
        ),
        if (categorias.isEmpty)
          Card(
            margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: Padding(
              padding: const EdgeInsets.all(15),
              child: Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Nenhuma categoria neste grupo ainda. Você pode criar uma personalizada.',
                      style: TextStyle(color: Color(0xFF718078), fontSize: 12),
                    ),
                  ),
                  TextButton(
                    onPressed: _openCategories,
                    child: const Text('Criar'),
                  ),
                ],
              ),
            ),
          )
        else
          for (final categoria in categorias)
            CategoriaOrcamentoTile(
              categoria: categoria,
              orcamento: _orcamentos[categoria.id],
              onTap: () => _editLimite(categoria),
            ),
      ],
    );
  }

  Widget _buildBody() {
    if (_isLoading) return const Center(child: CircularProgressIndicator());
    if (_errorMessage != null) return Center(child: Text(_errorMessage!));

    return ListView(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 17, 16, 3),
          child: Text(
            'Orçamento geral',
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ),
        const Padding(
          padding: EdgeInsets.fromLTRB(16, 0, 16, 8),
          child: Text(
            'A divisão usa sua renda planejada. Necessidades e Desejos acompanham despesas; Economia acompanha os aportes líquidos nas metas.',
            style: TextStyle(color: Color(0xFF718078), fontSize: 12),
          ),
        ),
        _suggestionActions(
          label: 'Sugerir divisão 50/30/20',
          onSuggest: _sugerirOrcamentosGrupo,
          porGrupo: true,
        ),
        for (final grupo in _orcamentosGrupo)
          OrcamentoGrupoCard(
            orcamento: grupo,
            nome: _nomeGrupo(grupo.grupo),
            onEditar: () => _editLimiteGrupo(grupo),
          ),
        const Padding(
          padding: EdgeInsets.fromLTRB(16, 22, 16, 3),
          child: Text(
            'Orçamentos por categoria',
            style: TextStyle(fontSize: 19, fontWeight: FontWeight.w700),
          ),
        ),
        const Padding(
          padding: EdgeInsets.fromLTRB(16, 0, 16, 4),
          child: Text(
            'Acompanhe cada categoria e ajuste o limite quando precisar.',
            style: TextStyle(color: Color(0xFF718078), fontSize: 12),
          ),
        ),
        _categoryResetAction(),
        for (final grupo in ['necessidade', 'desejo', 'economia'])
          _buildGroupSection(grupo),
      ],
    );
  }

  String _nomeGrupo(String grupo) => switch (grupo) {
    'necessidade' => 'Necessidades',
    'desejo' => 'Desejos',
    'economia' => 'Economia / investimentos',
    _ => grupo,
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Orçamentos'),
        actions: [
          IconButton(
            tooltip: 'Minhas categorias',
            icon: const Icon(Icons.category_outlined),
            onPressed: _openCategories,
          ),
        ],
      ),
      body: _buildBody(),
    );
  }
}
