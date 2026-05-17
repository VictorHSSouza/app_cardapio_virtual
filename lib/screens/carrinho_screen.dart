import 'package:flutter/material.dart';
import '../models/produto.dart';

class CarrinhoPage extends StatefulWidget {
  final Map<Produto, int> carrinho;
  final Function(Produto) onRemoverProduto;
  final VoidCallback onFinalizarCompra;

  const CarrinhoPage({
    super.key,
    required this.carrinho,
    required this.onRemoverProduto,
    required this.onFinalizarCompra,
  });

  @override
  State<CarrinhoPage> createState() => _CarrinhoPageState();
}

class _CarrinhoPageState extends State<CarrinhoPage> {
  double get valorTotal {
    double total = 0.0;
    widget.carrinho.forEach((produto, qtd) {
      total += produto.preco * qtd;
    });
    return total;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Meu Carrinho'),
        backgroundColor: Colors.red[600],
        foregroundColor: Colors.white,
      ),
      body: widget.carrinho.isEmpty
          ? const Center(
              child: Text(
                'Seu carrinho está vazio.',
                style: TextStyle(fontSize: 16),
              ),
            )
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: widget.carrinho.length,
                    itemBuilder: (context, index) {
                      final produto = widget.carrinho.keys.elementAt(index);
                      final quantidade = widget.carrinho[produto]!;
                      final subtotal = produto.preco * quantidade;

                      return Card(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4.0),
                          child: ListTile(
                            leading: ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: Image.network(
                                produto.imagemUrl,
                                width: 45,
                                height: 45,
                                fit: BoxFit.cover,
                              ),
                            ),
                            title: Text(
                              produto.nome,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Text(
                              '$quantidade x R\$ ${produto.preco.toStringAsFixed(2)}',
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'R\$ ${subtotal.toStringAsFixed(2)}',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey[800],
                                  ),
                                ),
                                const SizedBox(width: 8),
                                IconButton(
                                  icon: const Icon(
                                    Icons.delete_outline_rounded,
                                    color: Colors.red,
                                  ),
                                  onPressed: () {
                                    widget.onRemoverProduto(produto);
                                    setState(() {});
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.2),
                        blurRadius: 10,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Total do Pedido:',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'R\$ ${valorTotal.toStringAsFixed(2)}',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.red[700],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
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
                            widget.onFinalizarCompra();
                          },
                          child: const Text(
                            'COMPRAR',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
