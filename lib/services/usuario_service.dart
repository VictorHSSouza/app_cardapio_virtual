import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/Pessoa.dart';

class UsuarioService {
  static final _db = FirebaseFirestore.instance;
  static const _colecao = 'usuarios';

  /// Salva ou atualiza os dados do usuário no Firestore
  static Future<void> salvar(Pessoa pessoa) async {
    await _db.collection(_colecao).doc(pessoa.uid).set(pessoa.toMap());
  }

  /// Busca os dados do usuário pelo UID
  static Future<Pessoa?> buscar(String uid) async {
    final doc = await _db.collection(_colecao).doc(uid).get();
    if (!doc.exists || doc.data() == null) return null;
    return Pessoa.fromMap(uid, doc.data()!);
  }
}
