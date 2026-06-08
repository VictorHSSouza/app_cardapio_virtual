import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/Pessoa.dart';
import '../models/Produto.dart';
import '../services/usuario_service.dart';
import 'admin_pedidos_screen.dart';
import 'admin_produtos_screen.dart';
import 'carrinho_screen.dart';
import 'historico_screen.dart';
import 'login_screen.dart';
import 'relatorios_screen.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _abaAtual = 0;
  bool _ehAdmin = false;
  bool _perfilCarregado = false;

  late Future<List<Produto>> _produtosFuture;

  @override
  void initState() {
    super.initState();
    _produtosFuture = _carregarProdutos();
    _carregarPerfil();
  }

  Future<void> _carregarPerfil() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    final doc = await FirebaseFirestore.instance
        .collection('usuarios')
        .doc(uid)
        .get();

    if (!mounted) return;
    setState(() {
      _ehAdmin = doc.exists && doc['tipo'] == 'admin';
      _perfilCarregado = true;
    });
  }

  Future<List<Produto>> _carregarProdutos() async {
    final snapshot =
        await FirebaseFirestore.instance.collection('produtos').get();

    return snapshot.docs.asMap().entries.map((entry) {
      final index = entry.key;
      final doc = entry.value;
      final data = doc.data();

      final nome = (data['nome'] ?? '').toString();
      final descricao = (data['descricao'] ?? '').toString();
      final imagemUrl = (data['imagemUrl'] ?? '').toString();
      final category =
          (data['categoria'] ?? data['category'] ?? 'Outros').toString();
      final preco =
          data['preco'] is num ? (data['preco'] as num).toDouble() : 0.0;
      final id = data['id'] is int ? data['id'] as int : index + 1;
      final estoque = (data['estoque'] ?? 0) as int;

      return Produto(
        docId: doc.id,
        id: id,
        nome: nome,
        category: category,
        descricao: descricao,
        preco: preco,
        imagemUrl: imagemUrl,
        estoque: estoque,
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    // Aguarda perfil carregar para evitar flash de UI errada
    if (!_perfilCarregado) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_ehAdmin) {
      return _AdminHome(
        abaAtual: _abaAtual,
        onAbaChanged: (i) => setState(() => _abaAtual = i),
        produtosFuture: _produtosFuture,
        onRecarregarProdutos: () =>
            setState(() => _produtosFuture = _carregarProdutos()),
      );
    }

    return _ClienteHome(
      produtosFuture: _produtosFuture,
    );
  }
}

// ─────────────────────────────────────────────
// HOME DO ADMIN
// ─────────────────────────────────────────────
class _AdminHome extends StatefulWidget {
  final int abaAtual;
  final ValueChanged<int> onAbaChanged;
  final Future<List<Produto>> produtosFuture;
  final VoidCallback onRecarregarProdutos;

  const _AdminHome({
    required this.abaAtual,
    required this.onAbaChanged,
    required this.produtosFuture,
    required this.onRecarregarProdutos,
  });

  @override
  State<_AdminHome> createState() => _AdminHomeState();
}

class _AdminHomeState extends State<_AdminHome> {
  late int _aba;

  @override
  void initState() {
    super.initState();
    _aba = widget.abaAtual;
  }

  void _trocarAba(int i) {
    setState(() => _aba = i);
    widget.onAbaChanged(i);
  }

  @override
  Widget build(BuildContext context) {
    final abas = [
      _CardapioView(
        produtosFuture: widget.produtosFuture,
        ehAdmin: true,
        carrinho: const {},
        onAdicionarAoCarrinho: null,
        onIrCarrinho: null,
      ),
      _AdminProdutosTab(
        onRecarregar: widget.onRecarregarProdutos,
      ),
      const AdminPedidosScreen(),
      const RelatoriosScreen(),
      const _PerfilView(),
    ];

    return Scaffold(
      body: abas[_aba],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _aba,
        onTap: _trocarAba,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.red[700],
        unselectedItemColor: Colors.grey[600],
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.restaurant_menu_rounded),
            label: 'Cardápio',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.inventory_2_rounded),
            label: 'Produtos',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long_rounded),
            label: 'Pedidos',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart_rounded),
            label: 'Relatórios',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_rounded),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }
}

// Aba Produtos do admin embutida na navegação
class _AdminProdutosTab extends StatelessWidget {
  final VoidCallback onRecarregar;

  const _AdminProdutosTab({required this.onRecarregar});

  @override
  Widget build(BuildContext context) {
    return AdminProdutosScreen(onProdutoAlterado: onRecarregar);
  }
}

// ─────────────────────────────────────────────
// HOME DO CLIENTE
// ─────────────────────────────────────────────
class _ClienteHome extends StatefulWidget {
  final Future<List<Produto>> produtosFuture;

  const _ClienteHome({required this.produtosFuture});

  @override
  State<_ClienteHome> createState() => _ClienteHomeState();
}

class _ClienteHomeState extends State<_ClienteHome> {
  int _aba = 0;
  final Map<Produto, int> _carrinho = {};

  int get _totalItens =>
      _carrinho.values.fold(0, (soma, qtd) => soma + qtd);

  @override
  Widget build(BuildContext context) {
    final abas = [
      _CardapioView(
        produtosFuture: widget.produtosFuture,
        ehAdmin: false,
        carrinho: _carrinho,
        onAdicionarAoCarrinho: (produto, qtd) {
          setState(() {
            _carrinho[produto] = (_carrinho[produto] ?? 0) + qtd;
          });
        },
        onIrCarrinho: () => setState(() => _aba = 1),
        totalItensCarrinho: _totalItens,
      ),
      // Aba Carrinho embutida
      CarrinhoPage(
        carrinho: _carrinho,
        mostrarAppBar: false,
        onRemoverProduto: (p) => setState(() => _carrinho.remove(p)),
        onFinalizarCompra: () {
          setState(() {
            _carrinho.clear();
            _aba = 0;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Compra realizada com sucesso!'),
              backgroundColor: Colors.green,
            ),
          );
        },
      ),
      const HistoricoScreen(),
      const _PerfilView(),
    ];

    return Scaffold(
      body: abas[_aba],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _aba,
        onTap: (i) => setState(() => _aba = i),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.red[700],
        unselectedItemColor: Colors.grey[600],
        items: [
          const BottomNavigationBarItem(
            icon: Icon(Icons.home_rounded),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Stack(
              clipBehavior: Clip.none,
              children: [
                const Icon(Icons.shopping_cart_rounded),
                if (_totalItens > 0)
                  Positioned(
                    right: -6,
                    top: -4,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: Colors.red[600],
                        shape: BoxShape.circle,
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 16,
                        minHeight: 16,
                      ),
                      child: Text(
                        '$_totalItens',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
            label: 'Carrinho',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long_rounded),
            label: 'Meus Pedidos',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.person_rounded),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// VIEW COMPARTILHADA: CARDÁPIO
// ─────────────────────────────────────────────
class _CardapioView extends StatefulWidget {
  final Future<List<Produto>> produtosFuture;
  final bool ehAdmin;
  final Map<Produto, int> carrinho;
  final void Function(Produto, int)? onAdicionarAoCarrinho;
  final VoidCallback? onIrCarrinho;
  final int totalItensCarrinho;

  const _CardapioView({
    required this.produtosFuture,
    required this.ehAdmin,
    required this.carrinho,
    required this.onAdicionarAoCarrinho,
    required this.onIrCarrinho,
    this.totalItensCarrinho = 0,
  });

  @override
  State<_CardapioView> createState() => _CardapioViewState();
}

class _CardapioViewState extends State<_CardapioView> {
  String _categoriaSelecionada = 'Todos';
  String _textoBusca = '';

  final ScrollController _categoryScrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  String get _emailUsuario =>
      FirebaseAuth.instance.currentUser?.email ?? 'Usuário';

  String get _primeiroNome {
    final email = _emailUsuario;
    if (email.contains('@')) {
      final antes = email.split('@')[0];
      if (antes.isEmpty) return 'Usuário';
      return antes.substring(0, 1).toUpperCase() + antes.substring(1);
    }
    return email.isEmpty ? 'Usuário' : email;
  }

  @override
  void dispose() {
    _categoryScrollController.dispose();
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  List<String> _categoriasPara(List<Produto> produtos) {
    final set = <String>{};
    for (final p in produtos) {
      if (p.category.trim().isNotEmpty) set.add(p.category.trim());
    }
    return ['Todos', ...(set.toList()..sort())];
  }

  IconData _iconeCategoria(String categoria) {
    switch (categoria.toLowerCase()) {
      case 'todos':
        return Icons.restaurant_menu_rounded;
      case 'hambúrguer':
        return Icons.lunch_dining_rounded;
      case 'pizza':
        return Icons.local_pizza_rounded;
      case 'porções':
        return Icons.fastfood_rounded;
      case 'bebidas':
        return Icons.local_drink_rounded;
      case 'sobremesas':
        return Icons.icecream_rounded;
      default:
        return Icons.restaurant_rounded;
    }
  }

  void _mostrarModalQuantidade(BuildContext context, Produto produto) {
    int quantidade = 1;
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => StatefulBuilder(
        builder: (context, setModal) => Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                produto.nome,
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.remove_circle_outline),
                    onPressed: () {
                      if (quantidade > 1) setModal(() => quantidade--);
                    },
                  ),
                  Text(
                    '$quantidade',
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add_circle_outline),
                    onPressed: () => setModal(() => quantidade++),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red[600],
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                    widget.onAdicionarAoCarrinho?.call(produto, quantidade);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Row(
                          children: [
                            const Icon(Icons.check_circle,
                                color: Colors.white, size: 20),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                '${produto.nome} adicionado ao carrinho!',
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        backgroundColor: Colors.green[700],
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  },
                  child: const Text('Adicionar ao Pedido'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Produto>>(
      future: widget.produtosFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                'Erro ao carregar produtos.\n${snapshot.error}',
                textAlign: TextAlign.center,
              ),
            ),
          );
        }

        final produtos = snapshot.data ?? [];
        final categorias = _categoriasPara(produtos);

        if (!categorias.contains(_categoriaSelecionada)) {
          _categoriaSelecionada = 'Todos';
        }

        final filtrados = produtos.where((p) {
          final matchCat = _categoriaSelecionada == 'Todos' ||
              p.category == _categoriaSelecionada;
          final matchBusca =
              p.nome.toLowerCase().contains(_textoBusca.toLowerCase()) ||
              p.descricao.toLowerCase().contains(_textoBusca.toLowerCase());
          return matchCat && matchBusca;
        }).toList();

        return Column(
          children: [
            // Header vermelho
            Container(
              color: Colors.red[600],
              width: double.infinity,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 48, 24, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Olá, $_primeiroNome!${widget.ehAdmin ? ' (Admin)' : ' Bem-vindo ao Cardápio Virtual.'}',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                widget.ehAdmin
                                    ? 'VISUALIZAÇÃO DO CARDÁPIO'
                                    : 'O QUE VAMOS PEDIR HOJE?',
                                style: const TextStyle(
                                  color: Color(0xCCFFFFFF),
                                  fontSize: 9,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 2,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Carrinho só para clientes / Produtos para admin
                        if (!widget.ehAdmin)
                          Stack(
                            alignment: Alignment.center,
                            children: [
                              IconButton(
                                icon: const Icon(
                                  Icons.shopping_cart_rounded,
                                  color: Colors.white,
                                  size: 28,
                                ),
                                onPressed: widget.onIrCarrinho,
                              ),
                              if (widget.totalItensCarrinho > 0)
                                Positioned(
                                  right: 4,
                                  top: 4,
                                  child: Container(
                                    padding: const EdgeInsets.all(2),
                                    decoration: BoxDecoration(
                                      color: Colors.amber[600],
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: Colors.red[600]!,
                                        width: 1.5,
                                      ),
                                    ),
                                    constraints: const BoxConstraints(
                                      minWidth: 18,
                                      minHeight: 18,
                                    ),
                                    child: Text(
                                      '${widget.totalItensCarrinho}',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    // Campo de busca
                    RawAutocomplete<String>(
                      textEditingController: _searchController,
                      focusNode: _searchFocusNode,
                      optionsBuilder: (tv) {
                        if (tv.text.isEmpty) return const Iterable.empty();
                        return produtos
                            .where((p) => p.nome
                                .toLowerCase()
                                .contains(tv.text.toLowerCase()))
                            .map((p) => p.nome);
                      },
                      onSelected: (s) => setState(() => _textoBusca = s),
                      fieldViewBuilder:
                          (context, controller, focusNode, onSubmitted) {
                        return Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.3),
                            ),
                          ),
                          child: TextField(
                            controller: controller,
                            focusNode: focusNode,
                            onChanged: (t) =>
                                setState(() => _textoBusca = t),
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                            ),
                            decoration: InputDecoration(
                              hintText: 'Buscar pratos ou bebidas...',
                              hintStyle:
                                  const TextStyle(color: Colors.white70),
                              prefixIcon: const Icon(Icons.search_rounded,
                                  color: Colors.white70, size: 20),
                              suffixIcon: _textoBusca.isNotEmpty
                                  ? IconButton(
                                      icon: const Icon(Icons.clear_rounded,
                                          color: Colors.white70),
                                      onPressed: () {
                                        controller.clear();
                                        setState(() => _textoBusca = '');
                                      },
                                    )
                                  : null,
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 16),
                            ),
                          ),
                        );
                      },
                      optionsViewBuilder: (context, onSelected, options) {
                        return Align(
                          alignment: Alignment.topLeft,
                          child: Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Material(
                              elevation: 4,
                              borderRadius: BorderRadius.circular(12),
                              color: Colors.white,
                              child: ConstrainedBox(
                                constraints: BoxConstraints(
                                  maxWidth:
                                      MediaQuery.of(context).size.width - 48,
                                  maxHeight: 200,
                                ),
                                child: ListView.builder(
                                  padding: EdgeInsets.zero,
                                  shrinkWrap: true,
                                  itemCount: options.length,
                                  itemBuilder: (_, i) {
                                    final opt = options.elementAt(i);
                                    return InkWell(
                                      onTap: () => onSelected(opt),
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 16, vertical: 12),
                                        child: Row(
                                          children: [
                                            Icon(Icons.history_rounded,
                                                color: Colors.grey[400],
                                                size: 18),
                                            const SizedBox(width: 12),
                                            Text(opt,
                                                style: TextStyle(
                                                    color: Colors.grey[800],
                                                    fontWeight:
                                                        FontWeight.w500)),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),

            // Filtro de categorias
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: ScrollConfiguration(
                behavior: ScrollConfiguration.of(context).copyWith(
                  dragDevices: {
                    PointerDeviceKind.touch,
                    PointerDeviceKind.mouse,
                  },
                ),
                child: Listener(
                  onPointerSignal: (e) {
                    if (e is PointerScrollEvent) {
                      _categoryScrollController.animateTo(
                        (_categoryScrollController.offset + e.scrollDelta.dy)
                            .clamp(
                          0.0,
                          _categoryScrollController.position.maxScrollExtent,
                        ),
                        duration: const Duration(milliseconds: 100),
                        curve: Curves.linear,
                      );
                    }
                  },
                  child: SizedBox(
                    height: 46,
                    child: ListView.builder(
                      controller: _categoryScrollController,
                      scrollDirection: Axis.horizontal,
                      itemCount: categorias.length,
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      itemBuilder: (_, i) {
                        final cat = categorias[i];
                        final sel = cat == _categoriaSelecionada;
                        return Padding(
                          padding: const EdgeInsets.only(right: 12),
                          child: InkWell(
                            onTap: () =>
                                setState(() => _categoriaSelecionada = cat),
                            borderRadius: BorderRadius.circular(100),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 8),
                              decoration: BoxDecoration(
                                color: sel ? Colors.red[600] : Colors.red[50],
                                borderRadius: BorderRadius.circular(100),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(_iconeCategoria(cat),
                                      color: sel
                                          ? Colors.white
                                          : Colors.red[700],
                                      size: 18),
                                  const SizedBox(width: 8),
                                  Text(
                                    cat,
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: sel
                                          ? Colors.white
                                          : Colors.red[700],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),

            // Lista de produtos
            Expanded(
              child: filtrados.isEmpty
                  ? const Center(child: Text('Nenhum produto encontrado.'))
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                      itemCount: filtrados.length,
                      itemBuilder: (_, i) {
                        final produto = filtrados[i];
                        return InkWell(
                          onTap: widget.ehAdmin
                              ? null
                              : () => _mostrarModalQuantidade(
                                    context,
                                    produto,
                                  ),
                          child: Card(
                            color: Colors.white,
                            elevation: 1.5,
                            margin: const EdgeInsets.symmetric(vertical: 6),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: ListTile(
                              leading: SizedBox(
                                width: 50,
                                height: 50,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.network(
                                    produto.imagemUrl,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => const Icon(
                                      Icons.fastfood,
                                    ),
                                  ),
                                ),
                              ),
                              title: Text(
                                produto.nome,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(produto.descricao),
                                  if (widget.ehAdmin)
                                    Text(
                                      'Estoque: ${produto.estoque}',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: produto.estoque > 0
                                            ? Colors.green[700]
                                            : Colors.red[700],
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                ],
                              ),
                              trailing: Text(
                                'R\$ ${produto.preco.toStringAsFixed(2)}',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.red[700],
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        );
      },
    );
  }
}

// ─────────────────────────────────────────────
// VIEW COMPARTILHADA: PERFIL
// ─────────────────────────────────────────────
class _PerfilView extends StatelessWidget {
  const _PerfilView();

  String get _emailUsuario =>
      FirebaseAuth.instance.currentUser?.email ?? 'Usuário';

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Minha Conta'),
        backgroundColor: Colors.red[600],
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const SizedBox(height: 16),
            CircleAvatar(
              radius: 48,
              backgroundColor: Colors.red[600],
              child: const Icon(Icons.person_rounded,
                  size: 56, color: Colors.white),
            ),
            const SizedBox(height: 20),
            FutureBuilder<Pessoa?>(
              future: uid != null ? UsuarioService.buscar(uid) : null,
              builder: (context, snapshot) {
                final pessoa = snapshot.data;
                final carregando =
                    snapshot.connectionState == ConnectionState.waiting;

                return Card(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  child: Column(
                    children: [
                      _infoTile(
                        icon: Icons.person_outline,
                        label: 'Nome',
                        valor: pessoa?.nome.isNotEmpty == true
                            ? pessoa!.nome
                            : (carregando ? 'Carregando...' : 'Não informado'),
                      ),
                      const Divider(height: 1),
                      _infoTile(
                        icon: Icons.email_outlined,
                        label: 'E-mail',
                        valor: _emailUsuario,
                      ),
                      const Divider(height: 1),
                      _infoTile(
                        icon: Icons.phone_outlined,
                        label: 'Telefone',
                        valor: pessoa?.telefone.isNotEmpty == true
                            ? pessoa!.telefone
                            : (carregando ? 'Carregando...' : 'Não informado'),
                      ),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: OutlinedButton.icon(
                icon: const Icon(Icons.logout_rounded),
                label: const Text(
                  'Sair da Conta',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red[700],
                  side: BorderSide(color: Colors.red[600]!, width: 1.5),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () async {
                  await FirebaseAuth.instance.signOut();
                  if (!context.mounted) return;
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginPage()),
                    (route) => false,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoTile({
    required IconData icon,
    required String label,
    required String valor,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.red),
      title: Text(label,
          style: const TextStyle(fontSize: 12, color: Colors.grey)),
      subtitle: Text(
        valor,
        style: const TextStyle(
            fontSize: 15, fontWeight: FontWeight.bold, color: Colors.black),
      ),
    );
  }
}
