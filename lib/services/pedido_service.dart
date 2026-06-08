import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PedidoService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  // RF05 — Criar pedido e RF10 — Decrementar estoque
  static Future<void> criarPedido({
    required List<Map<String, dynamic>> itens,
    required double total,
    required String enderecoEntrega,
    required String metodoPagamento,
    String tipoAtendimento = 'entrega',
  }) async {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    // Valida estoque antes de criar o pedido
    for (final item in itens) {
      final ref = _db.collection('produtos').doc(item['produtoId']);
      final snapshot = await ref.get();

      if (!snapshot.exists) {
        throw Exception('Produto "${item['nome']}" não encontrado.');
      }

      final estoqueAtual = (snapshot['estoque'] ?? 0) as int;
      final quantidade = (item['quantidade'] ?? 0) as int;

      if (estoqueAtual < quantidade) {
        throw Exception(
          'Estoque insuficiente para "${item['nome']}". '
          'Disponível: $estoqueAtual, solicitado: $quantidade.',
        );
      }
    }

    // Cria o pedido
    await _db.collection('pedidos').add({
      'usuarioId': uid,
      'status': 'aguardando',
      'cancelavel': true,
      'valorTotal': total,
      'enderecoEntrega': enderecoEntrega,
      'metodoPagamento': metodoPagamento,
      'tipoAtendimento': tipoAtendimento,
      'dataPedido': Timestamp.now(),
      'itens': itens,
    });

    // RF10 — Decrementa estoque em transação
    for (final item in itens) {
      final ref = _db.collection('produtos').doc(item['produtoId']);

      await _db.runTransaction((transaction) async {
        final snapshot = await transaction.get(ref);
        if (!snapshot.exists) return;

        final estoqueAtual = (snapshot['estoque'] ?? 0) as int;
        final quantidade = (item['quantidade'] ?? 0) as int;

        transaction.update(ref, {'estoque': estoqueAtual - quantidade});
      });
    }
  }

  // RF13 — Pedidos do cliente logado
  static Stream<QuerySnapshot> meusPedidos() {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    return _db
        .collection('pedidos')
        .where('usuarioId', isEqualTo: uid)
        .orderBy('dataPedido', descending: true)
        .snapshots();
  }

  // RF09 — Todos os pedidos (admin)
  static Stream<QuerySnapshot> todosPedidos() {
    return _db
        .collection('pedidos')
        .orderBy('dataPedido', descending: true)
        .snapshots();
  }

  // RF09 — Atualizar status do pedido (admin)
  static Future<void> atualizarStatus({
    required String pedidoId,
    required String novoStatus,
  }) async {
    await _db.collection('pedidos').doc(pedidoId).update({
      'status': novoStatus,
      'cancelavel': novoStatus == 'aguardando', // RF14
    });
  }

  // RF14 — Cancelar pedido e devolver estoque
  static Future<void> cancelarPedido(String pedidoId) async {
    final pedidoRef = _db.collection('pedidos').doc(pedidoId);
    final pedido = await pedidoRef.get();

    if (!pedido.exists) return;

    final dados = pedido.data() as Map<String, dynamic>;

    if (dados['cancelavel'] != true) {
      throw Exception('Este pedido não pode mais ser cancelado.');
    }

    final itens = List<Map<String, dynamic>>.from(dados['itens'] ?? []);

    // Devolve estoque
    for (final item in itens) {
      final produtoRef = _db.collection('produtos').doc(item['produtoId']);

      await _db.runTransaction((transaction) async {
        final produto = await transaction.get(produtoRef);
        if (!produto.exists) return;

        final estoque = (produto['estoque'] ?? 0) as int;
        final quantidade = (item['quantidade'] ?? 0) as int;

        transaction.update(produtoRef, {'estoque': estoque + quantidade});
      });
    }

    await pedidoRef.update({
      'status': 'cancelado',
      'cancelavel': false,
    });
  }

  // RF11 — Total de vendas (exceto cancelados)
  static Future<double> totalVendas({
    DateTime? inicio,
    DateTime? fim,
  }) async {
    Query query = _db.collection('pedidos');

    if (inicio != null) {
      query = query.where(
        'dataPedido',
        isGreaterThanOrEqualTo: Timestamp.fromDate(inicio),
      );
    }
    if (fim != null) {
      query = query.where(
        'dataPedido',
        isLessThanOrEqualTo: Timestamp.fromDate(fim),
      );
    }

    final pedidos = await query.get();
    double total = 0;

    for (final doc in pedidos.docs) {
      final data = doc.data() as Map<String, dynamic>;
      if (data['status'] != 'cancelado') {
        total += (data['valorTotal'] as num).toDouble();
      }
    }

    return total;
  }

  // RF11 — Quantidade de pedidos no período
  static Future<int> quantidadePedidos({
    DateTime? inicio,
    DateTime? fim,
  }) async {
    Query query = _db.collection('pedidos');

    if (inicio != null) {
      query = query.where(
        'dataPedido',
        isGreaterThanOrEqualTo: Timestamp.fromDate(inicio),
      );
    }
    if (fim != null) {
      query = query.where(
        'dataPedido',
        isLessThanOrEqualTo: Timestamp.fromDate(fim),
      );
    }

    final pedidos = await query.get();
    return pedidos.docs.length;
  }

  // RF11 — Ticket médio no período
  static Future<double> ticketMedio({
    DateTime? inicio,
    DateTime? fim,
  }) async {
    final quantidade = await quantidadePedidos(inicio: inicio, fim: fim);
    if (quantidade == 0) return 0;

    final total = await totalVendas(inicio: inicio, fim: fim);
    return total / quantidade;
  }
}
