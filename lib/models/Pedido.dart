import 'package:cloud_firestore/cloud_firestore.dart';

class Pedido {
  final String id;
  final String usuarioId;
  final String status;
  final double valorTotal;
  final Timestamp dataPedido;
  final List<dynamic> itens;

  Pedido({
    required this.id,
    required this.usuarioId,
    required this.status,
    required this.valorTotal,
    required this.dataPedido,
    required this.itens,
  });

  factory Pedido.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return Pedido(
      id: doc.id,
      usuarioId: data['usuarioId'],
      status: data['status'],
      valorTotal: (data['valorTotal'] as num).toDouble(),
      dataPedido: data['dataPedido'],
      itens: data['itens'],
    );
  }
}