import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AdminProdutosScreen extends StatelessWidget {
  final VoidCallback? onProdutoAlterado;

  const AdminProdutosScreen({super.key, this.onProdutoAlterado});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gerenciar Produtos'),
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Novo Produto'),
        onPressed: () => _abrirFormulario(context, null),
      ),      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('produtos')
            .orderBy('nome')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Erro: ${snapshot.error}'));
          }

          final docs = snapshot.data?.docs ?? [];

          if (docs.isEmpty) {
            return const Center(
              child: Text('Nenhum produto cadastrado.'),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final doc = docs[index];
              final data = doc.data() as Map<String, dynamic>;
              final nome = data['nome'] ?? '';
              final preco = (data['preco'] as num?)?.toDouble() ?? 0.0;
              final categoria = data['categoria'] ?? data['category'] ?? '';
              final estoque = data['estoque'] ?? 0;
              final imagemUrl = data['imagemUrl'] ?? '';

              return Card(
                margin: const EdgeInsets.only(bottom: 10),
                child: ListTile(
                  leading: imagemUrl.isNotEmpty
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            imagemUrl,
                            width: 50,
                            height: 50,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => const Icon(
                              Icons.fastfood,
                              size: 40,
                            ),
                          ),
                        )
                      : const Icon(Icons.fastfood, size: 40),
                  title: Text(
                    nome,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    '$categoria  •  R\$ ${preco.toStringAsFixed(2)}  •  Estoque: $estoque',
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit_outlined, color: Colors.blue),
                        onPressed: () => _abrirFormulario(context, doc),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline, color: Colors.red),
                        onPressed: () => _confirmarExclusao(context, doc),
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

  void _abrirFormulario(BuildContext context, DocumentSnapshot? doc) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => _FormularioProdutoScreen(
          doc: doc,
          onSalvo: onProdutoAlterado,
        ),
      ),
    );
  }

  void _confirmarExclusao(BuildContext context, DocumentSnapshot doc) {
    final nome = (doc.data() as Map<String, dynamic>)['nome'] ?? 'este produto';

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Excluir Produto'),
        content: Text('Deseja excluir "$nome"? Esta ação não pode ser desfeita.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              Navigator.pop(context);
              await FirebaseFirestore.instance
                  .collection('produtos')
                  .doc(doc.id)
                  .delete();

              onProdutoAlterado?.call();

              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Produto excluído.')),
                );
              }
            },
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
  }
}

class _FormularioProdutoScreen extends StatefulWidget {
  final DocumentSnapshot? doc;
  final VoidCallback? onSalvo;

  const _FormularioProdutoScreen({this.doc, this.onSalvo});

  @override
  State<_FormularioProdutoScreen> createState() =>
      _FormularioProdutoScreenState();
}

class _FormularioProdutoScreenState extends State<_FormularioProdutoScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _salvando = false;

  late final TextEditingController _nomeCtrl;
  late final TextEditingController _descricaoCtrl;
  late final TextEditingController _precoCtrl;
  late final TextEditingController _imagemCtrl;
  late final TextEditingController _categoriaCtrl;
  late final TextEditingController _estoqueCtrl;

  bool get _editando => widget.doc != null;

  @override
  void initState() {
    super.initState();
    final data = widget.doc?.data() as Map<String, dynamic>?;

    _nomeCtrl = TextEditingController(text: data?['nome'] ?? '');
    _descricaoCtrl = TextEditingController(text: data?['descricao'] ?? '');
    _precoCtrl = TextEditingController(
      text: data != null
          ? (data['preco'] as num?)?.toStringAsFixed(2) ?? ''
          : '',
    );
    _imagemCtrl = TextEditingController(text: data?['imagemUrl'] ?? '');
    _categoriaCtrl = TextEditingController(
      text: data?['categoria'] ?? data?['category'] ?? '',
    );
    _estoqueCtrl = TextEditingController(
      text: data != null ? (data['estoque'] ?? 0).toString() : '0',
    );
  }

  @override
  void dispose() {
    _nomeCtrl.dispose();
    _descricaoCtrl.dispose();
    _precoCtrl.dispose();
    _imagemCtrl.dispose();
    _categoriaCtrl.dispose();
    _estoqueCtrl.dispose();
    super.dispose();
  }

  Future<void> _salvar() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _salvando = true);

    final dados = {
      'nome': _nomeCtrl.text.trim(),
      'descricao': _descricaoCtrl.text.trim(),
      'preco': double.tryParse(_precoCtrl.text.replaceAll(',', '.')) ?? 0.0,
      'imagemUrl': _imagemCtrl.text.trim(),
      'categoria': _categoriaCtrl.text.trim(),
      'estoque': int.tryParse(_estoqueCtrl.text.trim()) ?? 0,
    };

    try {
      if (_editando) {
        await FirebaseFirestore.instance
            .collection('produtos')
            .doc(widget.doc!.id)
            .update(dados);
      } else {
        await FirebaseFirestore.instance.collection('produtos').add(dados);
      }

      if (!mounted) return;
      Navigator.pop(context);
      widget.onSalvo?.call();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _editando ? 'Produto atualizado.' : 'Produto cadastrado.',
          ),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro: $e'), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _salvando = false);
    }
  }

  InputDecoration _dec(String label, {IconData? icon}) {
    return InputDecoration(
      labelText: label,
      prefixIcon: icon != null ? Icon(icon) : null,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_editando ? 'Editar Produto' : 'Novo Produto'),
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nomeCtrl,
                textCapitalization: TextCapitalization.sentences,
                decoration: _dec('Nome do Produto', icon: Icons.fastfood),
                validator: (v) =>
                    v == null || v.isEmpty ? 'Informe o nome' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descricaoCtrl,
                maxLines: 3,
                textCapitalization: TextCapitalization.sentences,
                decoration: _dec('Descrição', icon: Icons.description),
                validator: (v) =>
                    v == null || v.isEmpty ? 'Informe a descrição' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _categoriaCtrl,
                textCapitalization: TextCapitalization.sentences,
                decoration: _dec('Categoria', icon: Icons.category),
                validator: (v) =>
                    v == null || v.isEmpty ? 'Informe a categoria' : null,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _precoCtrl,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: _dec('Preço (R\$)', icon: Icons.attach_money),
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Informe o preço';
                        if (double.tryParse(v.replaceAll(',', '.')) == null) {
                          return 'Preço inválido';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _estoqueCtrl,
                      keyboardType: TextInputType.number,
                      decoration: _dec('Estoque', icon: Icons.inventory),
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Informe o estoque';
                        if (int.tryParse(v) == null) return 'Número inválido';
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _imagemCtrl,
                keyboardType: TextInputType.url,
                decoration: _dec('URL da Imagem', icon: Icons.image),
                validator: (v) =>
                    v == null || v.isEmpty ? 'Informe a URL da imagem' : null,
              ),
              // Preview da imagem
              if (_imagemCtrl.text.isNotEmpty) ...[
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    _imagemCtrl.text,
                    height: 160,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      height: 80,
                      color: Colors.grey[200],
                      child: const Center(child: Text('Imagem inválida')),
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: _salvando ? null : _salvar,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: _salvando
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Icon(Icons.save),
                  label: Text(_salvando
                      ? 'Salvando...'
                      : (_editando ? 'Salvar Alterações' : 'Cadastrar Produto')),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
