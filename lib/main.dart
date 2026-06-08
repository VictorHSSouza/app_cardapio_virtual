import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'screens/login_screen.dart';
import 'services/notificacao_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'App Cardápio Virtual',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.red,
          primary: Colors.red[600],
        ),
        useMaterial3: true,
      ),
      home: const AppInitializer(),
    );
  }
}

class AppInitializer extends StatefulWidget {
  const AppInitializer({super.key});

  @override
  State<AppInitializer> createState() => _AppInitializerState();
}

class _AppInitializerState extends State<AppInitializer> {
  late Future<void> _firebaseInit;

  @override
  void initState() {
    super.initState();
    _firebaseInit = _initFirebase();
  }

  Future<void> _initFirebase() async {
    if (kIsWeb) {
      await Firebase.initializeApp(
        options: const FirebaseOptions(
          apiKey: 'AIzaSyCKTaTwL3yp3dqwgtgHxN7pu8M1PxnpUN8',
          authDomain: 'appcardapio-c6f77.firebaseapp.com',
          projectId: 'appcardapio-c6f77',
          storageBucket: 'appcardapio-c6f77.firebasestorage.app',
          messagingSenderId: '193708960557',
          appId: '1:193708960557:web:72749db803392c1c3a41a4',
          measurementId: 'G-M08565DR4C',
        ),
      );
    } else {
      await Firebase.initializeApp();
    }

    // Inicializa notificações locais (apenas em plataformas nativas)
    if (!kIsWeb) {
      await NotificacaoService.inicializar();
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _firebaseInit,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Scaffold(
            body: Center(
              child: Text(
                'Erro ao inicializar o Firebase.',
                style: TextStyle(color: Colors.red),
              ),
            ),
          );
        }

        if (snapshot.connectionState == ConnectionState.done) {
          return const LoginPage();
        }

        // Loading enquanto o Firebase inicializa
        return Scaffold(
          backgroundColor: Colors.red,
          body: const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.restaurant_menu,
                  color: Colors.white,
                  size: 72,
                ),
                SizedBox(height: 24),
                CircularProgressIndicator(
                  color: Colors.white,
                ),
                SizedBox(height: 16),
                Text(
                  'Carregando...',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
