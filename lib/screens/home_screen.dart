import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'login_screen.dart';
import 'carrinho_screen.dart';
import '../models/produto.dart';

class HomePage extends StatefulWidget {
  final String emailUsuario;
  final String senhaUsuario;

  const HomePage({
    super.key,
    required this.emailUsuario,
    required this.senhaUsuario,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _categoriaSelecionada = 'Todos';
  String _textoBusca = '';
  int _abaAtual = 0;

  String get _primeiroNome {
    if (widget.emailUsuario.contains('@')) {
      String antesDoArroba = widget.emailUsuario.split('@')[0];
      if (antesDoArroba.isEmpty) return 'Usuário';
      return antesDoArroba.substring(0, 1).toUpperCase() +
          antesDoArroba.substring(1);
    }
    return widget.emailUsuario.isEmpty ? 'Usuário' : widget.emailUsuario;
  }

  final Map<Produto, int> _carrinho = {};

  final ScrollController _categoryScrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  final List<String> categorias = [
    'Todos',
    'Hambúrguer',
    'Pizza',
    'Porções',
    'Bebidas',
    'Sobremesas',
  ];

  final List<Produto> produtos = [
    Produto(
      id: 1,
      nome: 'Hambúrguer Artesanal',
      category: 'Hambúrguer',
      descricao:
          'Pão brioche, blend bovino 180g, queijo cheddar, alface, tomate e maionese da casa.',
      preco: 28.90,
      imagemUrl:
          'https://images.unsplash.com/photo-1568901346375-23c9450c58cd?auto=format&fit=crop&q=80&w=800',
    ),
    Produto(
      id: 2,
      nome: 'Pizza Calabresa',
      category: 'Pizza',
      descricao:
          'Molho de tomate, mozarela, calabresa fatiada, cebola e azeitonas pretas.',
      preco: 45.00,
      imagemUrl:
          'https://images.unsplash.com/photo-1513104890138-7c749659a591?auto=format&fit=crop&q=80&w=800',
    ),
    Produto(
      id: 3,
      nome: 'Batata Frita',
      category: 'Porções',
      descricao: 'Porção individual de batatas crocantes com sal e alecrim.',
      preco: 18.00,
      imagemUrl:
          'https://images.unsplash.com/photo-1630384060421-cb20d0e0649d?auto=format&fit=crop&q=80&w=800',
    ),
    Produto(
      id: 4,
      nome: 'Refrigerante 2L',
      category: 'Bebidas',
      descricao: 'Coca-cola gelada embalagem de 2 litros.',
      preco: 12.00,
      imagemUrl:
          'https://images.unsplash.com/photo-1622483767028-3f66f32aef97?auto=format&fit=crop&q=80&w=800',
    ),
  ];

  IconData _getIconecategoria(String categoria) {
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
      default:
        return Icons.icecream_rounded;
    }
  }

  int get _quantidadeTotalItens {
    return _carrinho.values.fold(0, (soma, qtd) => soma + qtd);
  }

  @override
  void dispose() {
    _categoryScrollController.dispose();
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final produtosFiltrados = produtos.where((produto) {
      final matchesCategoria =
          _categoriaSelecionada == 'Todos' ||
          produto.category == _categoriaSelecionada;
      final matchesBusca = produto.nome.toLowerCase().contains(
        _textoBusca.toLowerCase(),
      );
      return matchesCategoria && matchesBusca;
    }).toList();

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Column(
        children: [
          Container(
            color: Colors.red[600],
            width: double.infinity,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24.0, 48.0, 24.0, 32.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Olá, $_primeiroNome! Bem-vindo ao Cardápio Virtual.',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'O QUE VAMOS PEDIR HOJE?',
                              style: TextStyle(
                                color: Color(0xCCFFFFFF),
                                fontSize: 9,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 2,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          IconButton(
                            icon: const Icon(
                              Icons.shopping_cart_rounded,
                              color: Colors.white,
                              size: 28,
                            ),
                            onPressed: _irParaCarrinhoPage,
                          ),
                          if (_quantidadeTotalItens > 0)
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
                                  '$_quantidadeTotalItens',
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
                  const SizedBox(height: 20),

                  RawAutocomplete<String>(
                    textEditingController: _searchController,
                    focusNode: _searchFocusNode,
                    optionsBuilder: (TextEditingValue textEditingValue) {
                      if (textEditingValue.text.isEmpty) {
                        return const Iterable<String>.empty();
                      }
                      return produtos
                          .where(
                            (produto) => produto.nome.toLowerCase().contains(
                              textEditingValue.text.toLowerCase(),
                            ),
                          )
                          .map((produto) => produto.nome);
                    },
                    onSelected: (String selection) {
                      setState(() {
                        _textoBusca = selection;
                      });
                    },
                    fieldViewBuilder:
                        (context, controller, focusNode, onFieldSubmitted) {
                          return Container(
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.3),
                                width: 1,
                              ),
                            ),
                            child: TextField(
                              controller: controller,
                              focusNode: focusNode,
                              onChanged: (text) {
                                setState(() {
                                  _textoBusca = text;
                                });
                              },
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                              ),
                              decoration: InputDecoration(
                                hintText: 'Buscar pratos ou bebidas...',
                                hintStyle: const TextStyle(
                                  color: Colors.white70,
                                ),
                                prefixIcon: const Icon(
                                  Icons.search_rounded,
                                  color: Colors.white70,
                                  size: 20,
                                ),
                                suffixIcon: _textoBusca.isNotEmpty
                                    ? IconButton(
                                        icon: const Icon(
                                          Icons.clear_rounded,
                                          color: Colors.white70,
                                        ),
                                        onPressed: () {
                                          controller.clear();
                                          setState(() {
                                            _textoBusca = '';
                                          });
                                        },
                                      )
                                    : null,
                                border: InputBorder.none,
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 16,
                                ),
                              ),
                            ),
                          );
                        },
                    optionsViewBuilder: (context, onSelected, options) {
                      return Align(
                        alignment: Alignment.topLeft,
                        child: Padding(
                          padding: const EdgeInsets.only(top: 4.0),
                          child: Material(
                            elevation: 4.0,
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
                                itemBuilder: (BuildContext context, int index) {
                                  final String option = options.elementAt(
                                    index,
                                  );
                                  return InkWell(
                                    onTap: () => onSelected(option),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16.0,
                                        vertical: 12.0,
                                      ),
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.history_rounded,
                                            color: Colors.grey[400],
                                            size: 18,
                                          ),
                                          const SizedBox(width: 12),
                                          Text(
                                            option,
                                            style: TextStyle(
                                              color: Colors.grey[800],
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
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

          Padding(
            padding: EdgeInsetsGeometry.symmetric(vertical: 16),
            child: Column(
              children: [
                ScrollConfiguration(
                  behavior: ScrollConfiguration.of(context).copyWith(
                    dragDevices: {
                      PointerDeviceKind.touch,
                      PointerDeviceKind.mouse,
                    },
                  ),
                  child: Listener(
                    onPointerSignal: (pointerSignal) {
                      if (pointerSignal is PointerScrollEvent) {
                        final newOffset =
                            _categoryScrollController.offset +
                            pointerSignal.scrollDelta.dy;
                        _categoryScrollController.animateTo(
                          newOffset.clamp(
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
                        padding: const EdgeInsets.symmetric(horizontal: 24.0),
                        itemBuilder: (context, index) {
                          final categoria = categorias[index];
                          final isSelecionada =
                              categoria == _categoriaSelecionada;

                          return Padding(
                            padding: const EdgeInsets.only(right: 12),
                            child: InkWell(
                              onTap: () {
                                setState(() {
                                  _categoriaSelecionada = categoria;
                                });
                              },
                              borderRadius: BorderRadius.circular(100),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: isSelecionada
                                      ? Colors.red[600]
                                      : Colors.red[50],
                                  borderRadius: BorderRadius.circular(100),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      _getIconecategoria(categoria),
                                      color: isSelecionada
                                          ? Colors.white
                                          : Colors.red[700],
                                      size: 18,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      categoria,
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: isSelecionada
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
              ],
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 28),

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      child: Text(
                        'Refeições',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[800],
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      child: produtosFiltrados.isEmpty
                          ? const Padding(
                              padding: EdgeInsets.symmetric(vertical: 32.0),
                              child: Center(
                                child: Text('Nenhum produto encontrado.'),
                              ),
                            )
                          : ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              padding: EdgeInsets.zero,
                              itemCount: produtosFiltrados.length,
                              itemBuilder: (context, index) {
                                final produto = produtosFiltrados[index];

                                return InkWell(
                                  onTap: () => _mostrarModalQuantidade(produto),
                                  child: Card(
                                    color: Colors.white,
                                    elevation: 1.5,
                                    margin: const EdgeInsets.symmetric(
                                      vertical: 6.0,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 4.0,
                                      ),
                                      child: ListTile(
                                        leading: SizedBox(
                                          width: 50,
                                          height: 50,
                                          child: ClipRRect(
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                            child: Image.network(
                                              produto.imagemUrl,
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                        ),
                                        title: Text(
                                          produto.nome,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        subtitle: Text(produto.descricao),
                                        trailing: Text(
                                          'R\$ ${produto.preco.toStringAsFixed(2)}',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.red[700],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _abaAtual,
        onTap: (index) {
          if (index == 2) {
            _mostrarModalPerfil();
          } else {
            setState(() {
              _abaAtual = index;
            });
            if (index == 1) {
              _searchFocusNode.requestFocus();
            }
          }
        },
        selectedItemColor: Colors.red[700],
        unselectedItemColor: Colors.grey[600],
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_rounded),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search_rounded),
            label: 'Buscar',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_rounded),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }

  void _mostrarModalPerfil() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(24.0, 16.0, 24.0, 32.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 50,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(height: 20),
              CircleAvatar(
                radius: 40,
                backgroundColor: Colors.red[600],
                child: const Icon(
                  Icons.person_rounded,
                  size: 48,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Minha Conta',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(Icons.email_outlined, color: Colors.red),
                title: const Text(
                  'E-mail cadastrado',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
                subtitle: Text(
                  widget.emailUsuario,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(
                  Icons.lock_outline_rounded,
                  color: Colors.red,
                ),
                title: const Text(
                  'Senha',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
                subtitle: Text(
                  widget.senhaUsuario,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                height: 48,
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red[700],
                    side: BorderSide(color: Colors.red[600]!, width: 1.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: const Icon(Icons.logout_rounded),
                  label: const Text(
                    'Sair da Conta',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  onPressed: () {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const LoginPage(),
                      ),
                      (route) => false,
                    );
                  },
                ),
              ),

              const SizedBox(height: 12),

              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[200],
                    foregroundColor: Colors.grey[800],
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    'Fechar',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _mostrarModalQuantidade(Produto produto) {
    int quantidade = 1;
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    produto.nome,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        onPressed: () {
                          if (quantidade > 1)
                            setModalState(() {
                              quantidade--;
                            });
                        },
                        icon: const Icon(Icons.remove_circle_outline),
                      ),
                      Text(
                        quantidade.toString(),
                        style: const TextStyle(fontSize: 18),
                      ),
                      IconButton(
                        onPressed: () {
                          setModalState(() {
                            quantidade++;
                          });
                        },
                        icon: const Icon(Icons.add_circle_outline),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red[600],
                      foregroundColor: Colors.white,
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                      setState(() {
                        _carrinho[produto] =
                            (_carrinho[produto] ?? 0) + quantidade;
                      });
                    },
                    child: const Text('Adicionar ao Pedido'),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _irParaCarrinhoPage() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => CarrinhoPage(
          carrinho: _carrinho,
          onRemoverProduto: (produto) {
            setState(() {
              _carrinho.remove(produto);
            });
          },
          onFinalizarCompra: () {
            setState(() {
              _carrinho.clear();
            });
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Compra realizada com sucesso!'),
                backgroundColor: Colors.green,
              ),
            );
          },
        ),
      ),
    );
  }
}
