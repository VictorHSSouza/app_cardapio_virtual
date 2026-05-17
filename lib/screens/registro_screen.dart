import 'package:flutter/material.dart';
import 'login_screen.dart';
import '../models/pessoa.dart';

class RegistrarPage extends StatefulWidget {
  const RegistrarPage({super.key});

  @override
  State<RegistrarPage> createState() => _RegistrarPageState();
}

class _RegistrarPageState extends State<RegistrarPage> {
  bool _esconderSenha = true;
  final _formKey = GlobalKey<FormState>();

  final _nomeController = TextEditingController();
  final _emailController = TextEditingController();
  final _senhaController = TextEditingController();

  void validarRegistro() {
    if (_formKey.currentState!.validate()) {
      final nome = _nomeController.text.trim();
      final email = _emailController.text.trim();
      final senha = _senhaController.text.trim();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cadastro realizado com sucesso!'),
          backgroundColor: Colors.green,
        ),
      );

      Pessoa novaPessoa = Pessoa(nome: nome, email: email, senha: senha);

      _nomeController.clear();
      _emailController.clear();
      _senhaController.clear();

      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
      );
    }
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _emailController.dispose();
    _senhaController.dispose();
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
                    'https://cdn-icons-png.flaticon.com/512/3135/3135715.png',
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
                      // Campo de Nome Completo
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

                      // Campo de Senha
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
                    onPressed: validarRegistro,
                    icon: const Icon(Icons.person_add),
                    label: const Text('Registrar-se'),
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}
