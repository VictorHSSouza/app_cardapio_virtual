import 'package:flutter/material.dart';
import '../services/pedido_service.dart';

class AdminPedidosScreen extends StatelessWidget {
  const AdminPedidosScreen({super.key});

  Color _statusColor(String status) {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Gerenciar Pedidos',
        ),
      ),
      body: StreamBuilder(
        stream: PedidoService.todosPedidos(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(
              child:
                  CircularProgressIndicator(),
            );
          }

          final pedidos =
              snapshot.data!.docs;

          if (pedidos.isEmpty) {
            return const Center(
              child: Text(
                'Nenhum pedido encontrado.',
              ),
            );
          }

          return ListView.builder(
            padding:
                const EdgeInsets.all(12),
            itemCount: pedidos.length,
            itemBuilder: (context, index) {
              final pedido =
                  pedidos[index];

              final status =
                  pedido['status'];

              return Card(
                elevation: 3,
                margin:
                    const EdgeInsets.only(
                  bottom: 12,
                ),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor:
                        _statusColor(
                      status,
                    ),
                    child: const Icon(
                      Icons.receipt_long,
                      color: Colors.white,
                    ),
                  ),
                  title: Text(
                    'Pedido #${pedido.id.substring(0, 6)}',
                  ),
                  subtitle: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment
                            .start,
                    children: [
                      Text(
                        'Status: $status',
                      ),
                      Text(
                        'Valor: R\$ ${pedido['valorTotal']}',
                      ),
                    ],
                  ),
                  trailing:
                      PopupMenuButton<
                          String>(
                    icon: const Icon(
                      Icons.edit,
                    ),
                    onSelected:
                        (novoStatus) async {
                      await PedidoService
                          .atualizarStatus(
                        pedidoId:
                            pedido.id,
                        novoStatus:
                            novoStatus,
                      );

                      if (context
                          .mounted) {
                        ScaffoldMessenger
                                .of(
                                    context)
                            .showSnackBar(
                          SnackBar(
                            content: Text(
                              'Status alterado para $novoStatus',
                            ),
                          ),
                        );
                      }
                    },
                    itemBuilder:
                        (context) => [
                      const PopupMenuItem(
                        value:
                            'aguardando',
                        child: Text(
                          'Aguardando',
                        ),
                      ),
                      const PopupMenuItem(
                        value:
                            'em preparo',
                        child: Text(
                          'Em preparo',
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'pronto',
                        child: Text(
                          'Pronto',
                        ),
                      ),
                      const PopupMenuItem(
                        value:
                            'entregue',
                        child: Text(
                          'Entregue',
                        ),
                      ),
                      const PopupMenuItem(
                        value:
                            'cancelado',
                        child: Text(
                          'Cancelado',
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