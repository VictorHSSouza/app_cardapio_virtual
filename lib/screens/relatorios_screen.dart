import 'package:flutter/material.dart';
import '../services/pedido_service.dart';

class RelatoriosScreen extends StatefulWidget {
  const RelatoriosScreen({super.key});

  @override
  State<RelatoriosScreen> createState() => _RelatoriosScreenState();
}

class _RelatoriosScreenState extends State<RelatoriosScreen> {
  double totalVendas = 0;
  double ticketMedio = 0;
  int quantidadePedidos = 0;
  bool carregando = true;

  // Filtro de período
  DateTime? _inicio;
  DateTime? _fim;

  @override
  void initState() {
    super.initState();
    // Default: mês atual
    final agora = DateTime.now();
    _inicio = DateTime(agora.year, agora.month, 1);
    _fim = DateTime(agora.year, agora.month + 1, 0, 23, 59, 59);
    carregarDados();
  }

  Future<void> carregarDados() async {
    setState(() => carregando = true);

    final total = await PedidoService.totalVendas(inicio: _inicio, fim: _fim);
    final quantidade = await PedidoService.quantidadePedidos(inicio: _inicio, fim: _fim);
    final ticket = await PedidoService.ticketMedio(inicio: _inicio, fim: _fim);

    setState(() {
      totalVendas = total;
      quantidadePedidos = quantidade;
      ticketMedio = ticket;
      carregando = false;
    });
  }

  Future<void> _selecionarPeriodo() async {
    final intervalo = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDateRange: _inicio != null && _fim != null
          ? DateTimeRange(start: _inicio!, end: _fim!)
          : null,
      locale: const Locale('pt', 'BR'),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(primary: Colors.red.shade600),
          ),
          child: child!,
        );
      },
    );

    if (intervalo != null) {
      setState(() {
        _inicio = intervalo.start;
        _fim = DateTime(
          intervalo.end.year,
          intervalo.end.month,
          intervalo.end.day,
          23, 59, 59,
        );
      });
      await carregarDados();
    }
  }

  String get _periodoLabel {
    if (_inicio == null || _fim == null) return 'Todos os períodos';
    final f = (DateTime d) =>
        '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
    return '${f(_inicio!)} — ${f(_fim!)}';
  }

  Widget cardRelatorio({
    required String titulo,
    required String valor,
    required IconData icone,
    required Color cor,
  }) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: cor.withValues(alpha: 0.15),
              child: Icon(icone, color: cor, size: 30),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    titulo,
                    style: const TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    valor,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Relatório de Vendas'),
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Seletor de período
          InkWell(
            onTap: _selecionarPeriodo,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              color: Colors.red.shade50,
              child: Row(
                children: [
                  Icon(Icons.date_range, color: Colors.red.shade600, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      _periodoLabel,
                      style: TextStyle(
                        color: Colors.red.shade700,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Icon(Icons.edit_calendar, color: Colors.red.shade400, size: 18),
                ],
              ),
            ),
          ),

          Expanded(
            child: carregando
                ? const Center(child: CircularProgressIndicator())
                : RefreshIndicator(
                    onRefresh: carregarDados,
                    child: ListView(
                      padding: const EdgeInsets.all(16),
                      children: [
                        cardRelatorio(
                          titulo: 'Total de Vendas',
                          valor: 'R\$ ${totalVendas.toStringAsFixed(2)}',
                          icone: Icons.attach_money,
                          cor: Colors.green,
                        ),
                        cardRelatorio(
                          titulo: 'Quantidade de Pedidos',
                          valor: quantidadePedidos.toString(),
                          icone: Icons.receipt_long,
                          cor: Colors.blue,
                        ),
                        cardRelatorio(
                          titulo: 'Ticket Médio',
                          valor: 'R\$ ${ticketMedio.toStringAsFixed(2)}',
                          icone: Icons.bar_chart,
                          cor: Colors.orange,
                        ),
                        const SizedBox(height: 8),
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              children: [
                                const Icon(Icons.analytics, size: 50, color: Colors.red),
                                const SizedBox(height: 10),
                                const Text(
                                  'Resumo Geral',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  'Período: $_periodoLabel\nValores calculados automaticamente a partir dos pedidos registrados no Firebase.',
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(color: Colors.grey),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
