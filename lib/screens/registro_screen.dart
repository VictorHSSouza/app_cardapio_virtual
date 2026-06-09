import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/Pessoa.dart';
import '../services/usuario_service.dart';
import 'login_screen.dart';

class RegistrarPage extends StatefulWidget {
  const RegistrarPage({super.key});

  @override
  State<RegistrarPage> createState() => _RegistrarPageState();
}

class _RegistrarPageState extends State<RegistrarPage> {
  bool _esconderSenha = true;
  bool _carregando = false;
  final _formKey = GlobalKey<FormState>();

  final _nomeController = TextEditingController();
  final _emailController = TextEditingController();
  final _senhaController = TextEditingController();
  final _telefoneController = TextEditingController();

  Future<void> validarRegistro() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _carregando = true);

    try {
      // Cria o usuário no Firebase Auth
      final credencial = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
            email: _emailController.text.trim(),
            password: _senhaController.text,
          );

      final uid = credencial.user!.uid;

      // Atualiza o nome de exibição no Firebase Auth
      await credencial.user?.updateDisplayName(_nomeController.text.trim());

      // Salva os dados completos (incluindo telefone e tipo) no Firestore
      await UsuarioService.salvar(
        Pessoa(
          uid: uid,
          nome: _nomeController.text.trim(),
          email: _emailController.text.trim(),
          telefone: _telefoneController.text.trim(),
          tipo: 'cliente',
        ),
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cadastro realizado com sucesso!'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
        (route) => false,
      );
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;

      String mensagem;
      switch (e.code) {
        case 'email-already-in-use':
          mensagem = 'Este e-mail já está cadastrado.';
          break;
        case 'invalid-email':
          mensagem = 'E-mail inválido.';
          break;
        case 'weak-password':
          mensagem = 'Senha muito fraca. Use pelo menos 6 caracteres.';
          break;
        case 'operation-not-allowed':
          mensagem = 'Cadastro por e-mail desativado. Contate o suporte.';
          break;
        default:
          mensagem = 'Erro ao criar conta. Tente novamente.';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(mensagem), backgroundColor: Colors.red[700]),
      );
    } finally {
      if (mounted) setState(() => _carregando = false);
    }
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _emailController.dispose();
    _senhaController.dispose();
    _telefoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Registrar-se')),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(32.0, 80.0, 32.0, 0),
          child: Center(
            child: Column(
              children: [
                const Image(
                  image: NetworkImage(
                    'https://cdn-icons-png.flaticon.com/512/2771/2771406.png',
                  ),
                  width: 150,
                  height: 150,
                ),

                const SizedBox(height: 16),

                const Text(
                  "Registrar-se",
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 8),

                const Text(
                  "Crie uma conta para acessar o Cardápio Virtual e fazer seus pedidos.",
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 20),

                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      // Nome
                      TextFormField(
                        controller: _nomeController,
                        textCapitalization: TextCapitalization.words,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor, insira seu nome completo';
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          labelText: 'Nome Completo',
                          hintText: 'Seu nome completo',
                          hintStyle: const TextStyle(color: Colors.grey),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15.0),
                          ),
                          suffixIcon: const Padding(
                            padding: EdgeInsets.only(right: 4.0),
                            child: Icon(Icons.person),
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Email
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor, insira seu email';
                          }
                          if (!value.contains('@')) {
                            return 'Por favor, insira um e-mail válido';
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          labelText: 'Email',
                          hintText: 'seu@email.com',
                          hintStyle: const TextStyle(color: Colors.grey),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15.0),
                          ),
                          suffixIcon: const Padding(
                            padding: EdgeInsets.only(right: 4.0),
                            child: Icon(Icons.email),
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Telefone
                      TextFormField(
                        controller: _telefoneController,
                        keyboardType: TextInputType.phone,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor, insira seu telefone';
                          }
                          if (value.replaceAll(RegExp(r'\D'), '').length < 10) {
                            return 'Telefone inválido';
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          labelText: 'Telefone',
                          hintText: '(00) 00000-0000',
                          hintStyle: const TextStyle(color: Colors.grey),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15.0),
                          ),
                          suffixIcon: const Padding(
                            padding: EdgeInsets.only(right: 4.0),
                            child: Icon(Icons.phone),
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Senha
                      TextFormField(
                        controller: _senhaController,
                        obscureText: _esconderSenha,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor, insira sua senha';
                          }
                          if (value.length < 6) {
                            return 'A senha deve ter pelo menos 6 caracteres';
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          labelText: 'Senha',
                          hintText: '••••••••',
                          hintStyle: const TextStyle(color: Colors.grey),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15.0),
                          ),
                          suffixIcon: Padding(
                            padding: const EdgeInsets.only(right: 4.0),
                            child: IconButton(
                              onPressed: () {
                                setState(() {
                                  _esconderSenha = !_esconderSenha;
                                });
                              },
                              icon: Icon(
                                !_esconderSenha
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                SizedBox(
                  height: 50,
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _carregando ? null : validarRegistro,
                    icon: _carregando
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Icon(Icons.person_add),
                    label: Text(
                      _carregando ? 'Cadastrando...' : 'Registrar-se',
                    ),
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15.0),
                      ),
                      backgroundColor: Colors.red.shade600,
                      foregroundColor: Colors.white,
                      textStyle: const TextStyle(fontSize: 18),
                      shadowColor: Colors.redAccent,
                      elevation: 5,
                    ),
                  ),
                ),

                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
