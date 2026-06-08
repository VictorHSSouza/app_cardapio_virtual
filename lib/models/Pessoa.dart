class Pessoa {
  final String uid;
  final String nome;
  final String email;
  final String telefone;

  Pessoa({
    required this.uid,
    required this.nome,
    required this.email,
    required this.telefone,
  });

  factory Pessoa.fromMap(String uid, Map<String, dynamic> map) {
    return Pessoa(
      uid: uid,
      nome: map['nome'] ?? '',
      email: map['email'] ?? '',
      telefone: map['telefone'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'nome': nome,
      'email': email,
      'telefone': telefone,
    };
  }
}
