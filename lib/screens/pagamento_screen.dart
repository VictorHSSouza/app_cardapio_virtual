import 'package:flutter/material.dart';
import '../services/pedido_service.dart';
import 'home_screen.dart';

class PagamentoScreen extends StatefulWidget {
  final double total;
  final List<Map<String, dynamic>> itens;

  const PagamentoScreen({
    super.key,
    required this.total,
    required this.itens,
  });

  @override
  State<PagamentoScreen> createState() => _PagamentoScreenState();
}

class _PagamentoScreenState extends State<PagamentoScreen> {
  final _formKey = GlobalKey<FormState>();

  String tipoAtendimento = 'restaurante';
  String metodoPagamento = 'cartao';
  bool carregando = false;

  // Restaurante
  final mesaController = TextEditingController();

  // Entrega
  final enderecoController = TextEditingController();

  // Cartão
  final numeroCartaoController = TextEditingController();
  final nomeCartaoController = TextEditingController();
  final validadeController = TextEditingController();
  final cvvController = TextEditingController();

  // Dinheiro (entrega)
  final trocoController = TextEditingController();

  bool get _noRestaurante => tipoAtendimento == 'restaurante';

  // ─── Helpers de UI ───────────────────────────────────────────────

  Widget _tipoTile({
    required String titulo,
    required String subtitulo,
    required IconData icone,
    required String valor,
  }) {
    final sel = tipoAtendimento == valor;
    return GestureDetector(
      onTap: () => setState(() => tipoAtendimento = valor),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: sel ? Colors.red.shade50 : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: sel ? Colors.red : Colors.grey.shade300,
            width: sel ? 2 : 1.5,
          ),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 22,
              backgroundColor: sel ? Colors.red : Colors.grey.shade100,
              child: Icon(icone,
                  color: sel ? Colors.white : Colors.grey.shade600, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(titulo,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: sel ? Colors.red.shade700 : Colors.black87,
                      )),
                  const SizedBox(height: 2),
                  Text(subtitulo,
                      style: TextStyle(
                          fontSize: 12, color: Colors.grey.shade600)),
                ],
              ),
            ),
            Icon(
              sel ? Icons.radio_button_checked : Icons.radio_button_off,
              color: sel ? Colors.red : Colors.grey.shade400,
            ),
          ],
        ),
      ),
    );
  }

  Widget _metodoTile({
    required String titulo,
    required IconData icone,
    required String valor,
  }) {
    final sel = metodoPagamento == valor;
    return GestureDetector(
      onTap: () => setState(() => metodoPagamento = valor),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: sel ? Colors.red : Colors.grey.shade300,
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Icon(icone, color: Colors.red),
            const SizedBox(width: 12),
            Expanded(
              child: Text(titulo,
                  style: const TextStyle(
                      fontWeight: FontWeight.w600, fontSize: 16)),
            ),
            if (sel) const Icon(Icons.check, color: Colors.red),
          ],
        ),
      ),
    );
  }

  InputDecoration _dec(String hint, {IconData? icon}) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: icon != null ? Icon(icon) : null,
      filled: true,
      fillColor: Colors.white,
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.red),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.red),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.red, width: 2),
      ),
    );
  }

  Widget _aviso({
    required String texto,
    Color? cor,
    IconData icone = Icons.info_outline_rounded,
  }) {
    final c = cor ?? Colors.amber;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: c.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: c.withValues(alpha: 0.5)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icone, color: c, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              texto,
              style: TextStyle(
                fontSize: 14,
                color: c == Colors.amber ? Colors.amber.shade900 : c,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _pixWidget() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        children: [
          Container(
            width: 180,
            height: 180,
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Center(
              child: Icon(Icons.qr_code_2, size: 100, color: Colors.red),
            ),
          ),
          const SizedBox(height: 20),
          const Text('Escaneie o QR Code com o app do seu banco',
              textAlign: TextAlign.center),
          const SizedBox(height: 10),
          SelectableText(
            'pagamento@cardapiovirtual.com.br',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey.shade700),
          ),
        ],
      ),
    );
  }

  // ─── Validação e envio ───────────────────────────────────────────

  Future<void> _finalizar() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => carregando = true);

    try {
      await PedidoService.criarPedido(
        itens: widget.itens,
        total: widget.total,
        enderecoEntrega: _noRestaurante
            ? 'Mesa ${mesaController.text.trim()}'
            : enderecoController.text.trim(),
        metodoPagamento: _noRestaurante ? 'no_caixa' : metodoPagamento,
        tipoAtendimento: tipoAtendimento,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pedido realizado com sucesso!'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const HomePage()),
        (route) => false,
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao finalizar pedido: $e')),
      );
    } finally {
      if (mounted) setState(() => carregando = false);
    }
  }

  @override
  void dispose() {
    mesaController.dispose();
    enderecoController.dispose();
    numeroCartaoController.dispose();
    nomeCartaoController.dispose();
    validadeController.dispose();
    cvvController.dispose();
    trocoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F1F1),
      appBar: AppBar(
        title: const Text('Pagamento'),
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(20),
        color: Colors.white,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Total:',
                    style: TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold)),
                Text(
                  'R\$ ${widget.total.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: carregando ? null : _finalizar,
                child: carregando
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('FINALIZAR PEDIDO',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // ── Tipo de atendimento ────────────────────────────────
              const Text('Como você quer receber?',
                  style: TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),

              _tipoTile(
                titulo: 'Estou no restaurante',
                subtitulo: 'Consumo no local',
                icone: Icons.restaurant_rounded,
                valor: 'restaurante',
              ),
              _tipoTile(
                titulo: 'Entrega em domicílio',
                subtitulo: 'Receba no endereço informado',
                icone: Icons.delivery_dining_rounded,
                valor: 'entrega',
              ),

              // ── Campos específicos por tipo ────────────────────────
              AnimatedSize(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeInOut,
                child: _noRestaurante
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 4),
                          // Número da mesa
                          const Text('Número da Mesa',
                              style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600)),
                          const SizedBox(height: 10),
                          TextFormField(
                            controller: mesaController,
                            keyboardType: TextInputType.number,
                            decoration: _dec(
                              'Ex: 5',
                              icon: Icons.table_restaurant_rounded,
                            ),
                            validator: (v) {
                              if (v == null || v.trim().isEmpty) {
                                return 'Informe o número da mesa';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          // Aviso de pagamento no caixa
                          _aviso(
                            icone: Icons.point_of_sale_rounded,
                            texto:
                                'O pagamento será realizado no caixa do restaurante após o consumo.',
                          ),
                          const SizedBox(height: 16),
                        ],
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 4),
                          const Text('Endereço de Entrega',
                              style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600)),
                          const SizedBox(height: 10),
                          TextFormField(
                            controller: enderecoController,
                            decoration: _dec(
                              'Rua, número, bairro, cidade',
                              icon: Icons.location_on_outlined,
                            ),
                            validator: (v) {
                              if (v == null || v.trim().isEmpty) {
                                return 'Informe o endereço de entrega';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                        ],
                      ),
              ),

              // ── Método de pagamento (só para entrega) ─────────────
              if (!_noRestaurante) ...[
                const Text('Método de Pagamento',
                    style: TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),

                _metodoTile(
                    titulo: 'Cartão de Crédito/Débito',
                    icone: Icons.credit_card,
                    valor: 'cartao'),
                _metodoTile(
                    titulo: 'PIX', icone: Icons.pix, valor: 'pix'),
                _metodoTile(
                    titulo: 'Dinheiro',
                    icone: Icons.attach_money,
                    valor: 'dinheiro'),

                const SizedBox(height: 8),
              ],

              // ── Detalhes do método (só para entrega) ──────────────
              if (!_noRestaurante) ...[
                AnimatedSize(
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeInOut,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      // Cartão — campos obrigatórios
                      if (metodoPagamento == 'cartao') ...[
                        TextFormField(
                          controller: numeroCartaoController,
                          keyboardType: TextInputType.number,
                          decoration: _dec('Número do Cartão',
                              icon: Icons.credit_card),
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) {
                              return 'Informe o número do cartão';
                            }
                            if (v.replaceAll(' ', '').length < 13) {
                              return 'Número de cartão inválido';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 14),
                        TextFormField(
                          controller: nomeCartaoController,
                          textCapitalization: TextCapitalization.characters,
                          decoration: _dec('Nome impresso no cartão',
                              icon: Icons.person_outline),
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) {
                              return 'Informe o nome do titular';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 14),
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: validadeController,
                                keyboardType: TextInputType.datetime,
                                decoration: _dec('Validade (MM/AA)'),
                                validator: (v) {
                                  if (v == null || v.trim().isEmpty) {
                                    return 'Informe a validade';
                                  }
                                  return null;
                                },
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: TextFormField(
                                controller: cvvController,
                                keyboardType: TextInputType.number,
                                obscureText: true,
                                decoration: _dec('CVV'),
                                validator: (v) {
                                  if (v == null || v.trim().isEmpty) {
                                    return 'Informe o CVV';
                                  }
                                  if (v.length < 3) {
                                    return 'CVV inválido';
                                  }
                                  return null;
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                      ],

                      // PIX
                      if (metodoPagamento == 'pix') ...[
                        _pixWidget(),
                        const SizedBox(height: 8),
                      ],

                      // Dinheiro — entrega
                      if (metodoPagamento == 'dinheiro') ...[
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Troco para quanto?',
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600)),
                              const SizedBox(height: 14),
                              TextField(
                                controller: trocoController,
                                keyboardType: TextInputType.number,
                                decoration: _dec('R\$ 0,00'),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                      ],
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
