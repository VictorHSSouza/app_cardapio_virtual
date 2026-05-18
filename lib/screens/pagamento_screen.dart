import 'package:flutter/material.dart';

class PagamentoScreen extends StatefulWidget {
  final double total;

  const PagamentoScreen({super.key, required this.total});

  @override
  State<PagamentoScreen> createState() => _PagamentoScreenState();
}

class _PagamentoScreenState extends State<PagamentoScreen> {
  String metodoPagamento = 'cartao';

  final enderecoController = TextEditingController();

  // Cartão
  final numeroCartaoController = TextEditingController();
  final nomeCartaoController = TextEditingController();
  final validadeController = TextEditingController();
  final cvvController = TextEditingController();

  // Dinheiro
  final trocoController = TextEditingController();

  Widget metodoTile({
    required String titulo,
    required IconData icone,
    required String valor,
  }) {
    final selecionado = metodoPagamento == valor;

    return GestureDetector(
      onTap: () {
        setState(() {
          metodoPagamento = valor;
        });
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selecionado ? Colors.red : Colors.grey.shade300,
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Icon(icone, color: Colors.red),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                titulo,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
            ),
            if (selecionado)
              const Icon(Icons.check, color: Colors.red),
          ],
        ),
      ),
    );
  }

  InputDecoration campoDecoration(String hint, {IconData? icon}) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: icon != null ? Icon(icon) : null,
      filled: true,
      fillColor: Colors.white,
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.red),
      ),
    );
  }

  Widget pixWidget() {
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
              child: Icon(
                Icons.qr_code_2,
                size: 100,
                color: Colors.red,
              ),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Escaneie o QR Code com o app do seu banco',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 10),
          SelectableText(
            'Ou copie a chave PIX: pagamento@cardapiovirtual.com.br',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey.shade700,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget dinheiroWidget() {
    return Container(
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
          const Text(
            'Troco para quanto?',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: trocoController,
            keyboardType: TextInputType.number,
            decoration: campoDecoration('R\$ 0,00'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F1F1),
      appBar: AppBar(
        title: const Text('Pagamento'),
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
        elevation: 0,
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
                const Text(
                  'Total:',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
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
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Pedido realizado com sucesso!',
                      ),
                    ),
                  );
                },
                child: const Text(
                  'FINALIZAR PEDIDO',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Endereço de Entrega',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: enderecoController,
              decoration: campoDecoration(
                'Digite seu endereço completo',
                icon: Icons.location_on_outlined,
              ),
            ),
            const SizedBox(height: 28),

            const Text(
              'Método de Pagamento',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 12),

            metodoTile(
              titulo: 'Cartão de Crédito/Débito',
              icone: Icons.credit_card,
              valor: 'cartao',
            ),

            metodoTile(
              titulo: 'PIX',
              icone: Icons.pix,
              valor: 'pix',
            ),

            metodoTile(
              titulo: 'Dinheiro',
              icone: Icons.attach_money,
              valor: 'dinheiro',
            ),

            const SizedBox(height: 24),

            // CARTÃO
            if (metodoPagamento == 'cartao') ...[
              const Text(
                'Dados do Cartão',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),

              TextField(
                controller: numeroCartaoController,
                keyboardType: TextInputType.number,
                decoration: campoDecoration(
                  'Número do Cartão',
                  icon: Icons.credit_card,
                ),
              ),

              const SizedBox(height: 14),

              TextField(
                controller: nomeCartaoController,
                decoration: campoDecoration('Nome no Cartão'),
              ),

              const SizedBox(height: 14),

              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: validadeController,
                      keyboardType: TextInputType.number,
                      decoration:
                          campoDecoration('Validade (MM/AA)'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: cvvController,
                      keyboardType: TextInputType.number,
                      decoration: campoDecoration('CVV'),
                    ),
                  ),
                ],
              ),
            ],

            // PIX
            if (metodoPagamento == 'pix') ...[
              pixWidget(),
            ],

            // DINHEIRO
            if (metodoPagamento == 'dinheiro') ...[
              dinheiroWidget(),
            ],

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}