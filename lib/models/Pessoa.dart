class Pessoa {
  final String uid;
  final String nome;
  final String email;
  final String telefone;
  final String tipo; // "cliente" ou "admin"

  Pessoa({
    required this.uid,
    required this.nome,
    required this.email,
    required this.telefone,
    this.tipo = 'cliente',
  });

  factory Pessoa.fromMap(String uid, Map<String, dynamic> map) {
    return Pessoa(
      uid: uid,
      nome: map['nome'] ?? '',
      email: map['email'] ?? '',
      telefone: map['telefone'] ?? '',
      tipo: map['tipo'] ?? 'cliente',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'nome': nome,
      'email': email,
      'telefone': telefone,
      'tipo': tipo,
    };
  }
}
