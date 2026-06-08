class Produto {
  final String docId;
  final int id;
  final String nome;
  final String descricao;
  final double preco;
  final String imagemUrl;
  final String category;
  final int estoque;

  Produto({
    this.docId = '',
    required this.id,
    required this.nome,
    required this.descricao,
    required this.preco,
    required this.imagemUrl,
    required this.category,
    this.estoque = 0,
  });
}