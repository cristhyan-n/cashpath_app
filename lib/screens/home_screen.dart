import 'package:flutter/material.dart';
import 'package:cashpath_app/models/alerta_orcamento.dart';
import 'package:cashpath_app/models/resumo_mensal.dart';
import 'package:cashpath_app/models/transacao.dart';
import 'package:cashpath_app/models/categoria.dart';
import 'package:cashpath_app/models/meta.dart';
import 'package:cashpath_app/models/meta_progresso.dart';
import 'package:cashpath_app/screens/login_screen.dart';
import 'package:cashpath_app/screens/nova_transacao_screen.dart';
import 'package:cashpath_app/services/api_client.dart';
import 'package:cashpath_app/services/categoria_service.dart';
import 'package:cashpath_app/services/orcamento_service.dart';
import 'package:cashpath_app/services/token_storage.dart';
import 'package:cashpath_app/services/auth_service.dart';
import 'package:cashpath_app/services/transacao_service.dart';
import 'package:cashpath_app/utils/formatters.dart';
import 'package:cashpath_app/widgets/alerta_orcamento_tile.dart';
import 'package:cashpath_app/widgets/resumo_card.dart';
import 'package:cashpath_app/widgets/transacao_tile.dart';
import 'package:cashpath_app/screens/projecao_screen.dart';
import 'package:cashpath_app/screens/orcamentos_screen.dart';
import 'package:cashpath_app/screens/metas_screen.dart';
import 'package:cashpath_app/screens/perfil_screen.dart';
import 'package:cashpath_app/screens/onboarding_financeiro_screen.dart';
import 'package:cashpath_app/services/perfil_service.dart';
import 'package:cashpath_app/screens/categorias_admin_screen.dart';
import 'package:cashpath_app/screens/categorias_personalizadas_screen.dart';
import 'package:cashpath_app/widgets/cashpath_brand.dart';
import 'package:cashpath_app/services/meta_service.dart';
import 'package:cashpath_app/widgets/home_sections.dart';

typedef HomeData = ({
  List<Transacao> transacoes,
  Map<int, Categoria> categorias,
  List<AlertaOrcamento> alertas,
  ResumoMensal resumo,
  List<({Meta meta, MetaProgresso progresso})> metasAtivas,
  bool metasErrored,
});

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _transacaoService = TransacaoService();
  final _categoriaService = CategoriaService();
  final _orcamentoService = OrcamentoService();
  final _metaService = MetaService();

  HomeData? _data;
  String? _errorMessage;
  bool _isLoading = true;
  bool _checkingOnboarding = false;
  bool _isAdmin = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final mes = DateTime.now();

    try {
      PerfilFinanceiro? perfilFinanceiro;
      if (!_checkingOnboarding) {
        _checkingOnboarding = true;
        final dadosConta = await Future.wait<Object?>([
          PerfilService().financeiroAtual(),
          PerfilService().papelUsuario(),
        ]);
        perfilFinanceiro = dadosConta[0] as PerfilFinanceiro?;
        _isAdmin = dadosConta[1] == 'admin';
        if (perfilFinanceiro == null && mounted) {
          final concluido = await Navigator.push<bool>(
            context,
            MaterialPageRoute(
              builder: (_) => const OnboardingFinanceiroScreen(),
            ),
          );
          if (concluido != true) {
            _checkingOnboarding = false;
            setState(() => _isLoading = false);
            return;
          }
          perfilFinanceiro = await PerfilService().financeiroAtual();
        }
      } else {
        perfilFinanceiro = await PerfilService().financeiroAtual();
      }
      final dadosBase = await Future.wait<Object?>([
        _transacaoService.listar(),
        _categoriaService.listar(),
        _orcamentoService.listarAlertas(formatPeriod(mes)),
      ]);
      final transacoes = dadosBase[0] as List<Transacao>;
      final categorias = dadosBase[1] as List<Categoria>;
      final alertas = dadosBase[2] as List<AlertaOrcamento>;
      var metasAtivas = <({Meta meta, MetaProgresso progresso})>[];
      var metasErrored = false;
      try {
        final dadosMetas = await Future.wait<Object?>([
          _metaService.listar(),
          _metaService.buscarProgressos(),
        ]);
        final metas = dadosMetas[0] as List<Meta>;
        final progressos = dadosMetas[1] as List<MetaProgresso>;
        final progressoPorMeta = {for (final p in progressos) p.metaId: p};
        metasAtivas = [
          for (final meta in metas)
            if (progressoPorMeta[meta.id] != null &&
                progressoPorMeta[meta.id]!.status != 'concluido')
              (meta: meta, progresso: progressoPorMeta[meta.id]!),
        ];
      } on UnauthorizedException {
        rethrow;
      } catch (_) {
        // Metas são um resumo complementar; uma falha nelas não bloqueia a home.
        metasErrored = true;
      }

      if (!mounted) return;
      setState(() {
        _data = (
          transacoes: transacoes,
          categorias: {for (final c in categorias) c.id: c},
          alertas: alertas.where((a) => a.precisaAtencao).toList(),
          resumo: ResumoMensal.fromTransacoes(
            transacoes,
            mes,
            salarioBaseCentavos: perfilFinanceiro?.rendaCentavos,
            categoriasSalario: {
              for (final categoria in categorias)
                if (categoria.grupo == 'receita' &&
                    categoria.nome.trim().toLowerCase() == 'salário')
                  categoria.id,
            },
          ),
          metasAtivas: metasAtivas,
          metasErrored: metasErrored,
        );
        _errorMessage = null;
        _isLoading = false;
      });
      _checkingOnboarding = false;
    } on UnauthorizedException {
      _goToLogin();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
        _isLoading = false;
      });
      _checkingOnboarding = false;
    }
  }

  void _goToLogin() {
    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  Future<void> _handleLogout() async {
    try {
      await AuthService().logout();
    } catch (_) {
      // Always clear local credentials, even when the API cannot be reached.
    } finally {
      await TokenStorage().delete();
      _goToLogin();
    }
  }

  Future<void> _openNovaTransacao() async {
    final created = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) =>
            NovaTransacaoScreen(categorias: _data!.categorias.values.toList()),
      ),
    );

    if (created == true) _loadData();
  }

  Future<void> _openOrcamentos() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const OrcamentosScreen()),
    );

    _loadData();
  }

  Future<void> _openMetas() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const MetasScreen()),
    );
    await _loadData();
  }

  Widget _buildBody() {
    if (_isLoading) return const Center(child: CircularProgressIndicator());
    if (_errorMessage != null) return Center(child: Text(_errorMessage!));
    if (_data == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Informe sua renda e seu objetivo para continuar.'),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: _openOnboarding,
                child: const Text('Completar perfil financeiro'),
              ),
            ],
          ),
        ),
      );
    }

    final data = _data!;

    return ListView(
      padding: const EdgeInsets.only(bottom: 80),
      children: [
        HomeIntro(month: data.resumo.mes),
        ResumoCard(resumo: data.resumo),
        HomeMetasSummary(
          metas: data.metasAtivas,
          errored: data.metasErrored,
          onOpenMetas: _openMetas,
        ),
        if (data.alertas.isNotEmpty) ...[
          const HomeSectionTitle('Alertas de orçamento'),
          for (final alerta in data.alertas)
            AlertaOrcamentoTile(alerta: alerta),
        ],
        const HomeSectionTitle('Transações'),
        if (data.transacoes.isEmpty)
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text('Nenhuma transação ainda.'),
          )
        else
          for (final transacao in data.transacoes)
            TransacaoTile(
              transacao: transacao,
              categoriaNome:
                  data.categorias[transacao.categoriaId]?.nome ??
                  'Sem categoria',
              categoriaGrupo: data.categorias[transacao.categoriaId]?.grupo,
              onDelete: () => _deleteTransaction(transacao),
            ),
      ],
    );
  }

  Future<void> _openOnboarding() async {
    setState(() => _isLoading = true);
    final concluido = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => const OnboardingFinanceiroScreen()),
    );
    if (!mounted) return;
    if (concluido == true) {
      _checkingOnboarding = false;
      await _loadData();
    } else {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteTransaction(Transacao transacao) async {
    final confirmado = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir transação?'),
        content: Text(
          'A transação de ${formatCurrency(transacao.valorCentavos)} será removida dos seus totais e orçamentos.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          FilledButton.tonal(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
    if (confirmado != true) return;
    try {
      await _transacaoService.excluir(transacao.id);
      await _loadData();
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Transação excluída.')));
      }
    } on UnauthorizedException {
      _goToLogin();
    } catch (e) {
      if (mounted)
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const CashPathWordmark(markSize: 36),
        actions: [
          PopupMenuButton<String>(
            tooltip: 'Abrir menu',
            icon: const Icon(Icons.grid_view_rounded),
            onSelected: (value) {
              switch (value) {
                case 'profile':
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const PerfilScreen()),
                  ).then((_) {
                    if (mounted) _loadData();
                  });
                  break;
                case 'goals':
                  _openMetas();
                  break;
                case 'budgets':
                  _openOrcamentos();
                  break;
                case 'projection':
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ProjecaoScreen()),
                  );
                  break;
                case 'categories':
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const CategoriasPersonalizadasScreen(),
                    ),
                  );
                  break;
                case 'admin_categories':
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const CategoriasAdminScreen(),
                    ),
                  );
                  break;
                case 'logout':
                  _handleLogout();
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'profile',
                child: ListTile(
                  leading: Icon(Icons.person_outline),
                  title: Text('Meu perfil'),
                  dense: true,
                ),
              ),
              const PopupMenuItem(
                value: 'goals',
                child: ListTile(
                  leading: Icon(Icons.flag_outlined),
                  title: Text('Metas'),
                  dense: true,
                ),
              ),
              const PopupMenuItem(
                value: 'budgets',
                child: ListTile(
                  leading: Icon(Icons.savings_outlined),
                  title: Text('Orçamentos'),
                  dense: true,
                ),
              ),
              const PopupMenuItem(
                value: 'projection',
                child: ListTile(
                  leading: Icon(Icons.insights_outlined),
                  title: Text('Projeção'),
                  dense: true,
                ),
              ),
              const PopupMenuItem(
                value: 'categories',
                child: ListTile(
                  leading: Icon(Icons.category_outlined),
                  title: Text('Minhas categorias'),
                  dense: true,
                ),
              ),
              if (_isAdmin)
                const PopupMenuItem(
                  value: 'admin_categories',
                  child: ListTile(
                    leading: Icon(Icons.settings_outlined),
                    title: Text('Administrar categorias'),
                    dense: true,
                  ),
                ),
              const PopupMenuDivider(),
              const PopupMenuItem(
                value: 'logout',
                child: ListTile(
                  leading: Icon(Icons.logout),
                  title: Text('Sair'),
                  dense: true,
                ),
              ),
            ],
          ),
        ],
      ),
      body: _buildBody(),
      floatingActionButton: _data == null
          ? null
          : FloatingActionButton(
              onPressed: _openNovaTransacao,
              child: const Icon(Icons.add),
            ),
    );
  }
}
