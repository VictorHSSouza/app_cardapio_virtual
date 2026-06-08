import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../services/notificacao_service.dart';
import '../services/pedido_service.dart';

class HistoricoScreen extends StatefulWidget {
  const HistoricoScreen({super.key});

  @override
  State<HistoricoScreen> createState() => _HistoricoScreenState();
}

class _HistoricoScreenState extends State<HistoricoScreen> {
  // Rastreia os status anteriores para detectar mudanças
  final Map<String, String> _statusAnterior = {};

  Color _corStatus(String status) {
    switch (status.toLowerCase()) {
      case 'aguardando':
        return Colors.orange;
      case 'em preparo':
        return Colors.blue;
      case 'pronto':
        return Colors.green;
      case 'entregue':
        return Colors.grey;
      case 'cancelado':
        return Colors.red;
      default:
        return Colors.black54;
    }
  }

  IconData _iconeStatus(String status) {
    switch (status.toLowerCase()) {
      case 'aguardando':
        return Icons.schedule;
      case 'em preparo':
        return Icons.restaurant;
      case 'pronto':
        return Icons.check_circle;
      case 'entregue':
        return Icons.delivery_dining;
      case 'cancelado':
        return Icons.cancel;
      default:
        return Icons.info;
    }
  }

  void _verificarMudancasStatus(List<dynamic> docs) {
    if (kIsWeb) return; // Notificações locais não disponíveis na web

    for (final pedido in docs) {
      final id = pedido.id as String;
      final status = pedido['status'] as String;

      if (_statusAnterior.containsKey(id) && _statusAnterior[id] != status) {
        NotificacaoService.mostrarNotificacaoStatus(status);
      }

      _statusAnterior[id] = status;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Meus Pedidos')),
      body: StreamBuilder(
        stream: PedidoService.meusPedidos(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Erro: ${snapshot.error}'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData) {
            return const Center(child: Text('Nenhum dado encontrado'));
          }

          final docs = snapshot.data!.docs;

          // Verifica mudanças de status para notificar
          _verificarMudancasStatus(docs);

          if (docs.isEmpty) {
            return const Center(
              child: Text('Você ainda não realizou nenhum pedido.'),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final pedido = docs[index];
              final status = pedido['status'] as String;
              final valorTotal = pedido['valorTotal'];
              final metodoPagamento = pedido['metodoPagamento'] ?? '';
              final enderecoEntrega = pedido['enderecoEntrega'] ?? '';
              final tipoAtendimento = pedido['tipoAtendimento'] ?? 'entrega';

              return Card(
                elevation: 3,
                margin: const EdgeInsets.only(bottom: 12),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Pedido #${pedido.id.substring(0, 6).toUpperCase()}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Icon(_iconeStatus(status), color: _corStatus(status)),
                          const SizedBox(width: 8),
                          Chip(
                            backgroundColor:
                                _corStatus(status).withValues(alpha: 0.15),
                            label: Text(
                              status.toUpperCase(),
                              style: TextStyle(
                                color: _corStatus(status),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Valor Total: R\$ ${(valorTotal as num).toStringAsFixed(2)}',
                        style: const TextStyle(fontSize: 15),
                      ),
                      if (metodoPagamento.isNotEmpty)
                        Text('Pagamento: $metodoPagamento'),
                      if (tipoAtendimento == 'entrega' && enderecoEntrega.isNotEmpty)
                        Text('Entrega: $enderecoEntrega')
                      else if (tipoAtendimento == 'restaurante')
                        const Text('Local: No restaurante'),                      const SizedBox(height: 10),
                      if (status == 'aguardando')
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            icon: const Icon(Icons.cancel),
                            label: const Text('Cancelar Pedido'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              foregroundColor: Colors.white,
                            ),
                            onPressed: () async {
                              final confirmar = await showDialog<bool>(
                                context: context,
                                builder: (_) => AlertDialog(
                                  title: const Text('Cancelar Pedido'),
                                  content: const Text(
                                    'Deseja realmente cancelar este pedido?',
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.pop(context, false),
                                      child: const Text('Não'),
                                    ),
                                    ElevatedButton(
                                      onPressed: () =>
                                          Navigator.pop(context, true),
                                      child: const Text('Sim'),
                                    ),
                                  ],
                                ),
                              );

                              if (confirmar == true) {
                                try {
                                  await PedidoService.cancelarPedido(pedido.id);
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Pedido cancelado.'),
                                        backgroundColor: Colors.green,
                                      ),
                                    );
                                  }
                                } catch (e) {
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('Erro: $e')),
                                    );
                                  }
                                }
                              }
                            },
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
