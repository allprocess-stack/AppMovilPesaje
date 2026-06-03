import 'package:app2/screens/home_citas_screen.dart';
import 'package:app2/screens/home_main_screen.dart';
import 'package:app2/screens/home_register_screen.dart';
import 'package:app2/screens/login.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';

// const String baseUrl = 'http://192.168.1.164:5000';
String? baseUrl;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('es_ES', null);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Material App',
      routes: {
        'login': (_) => const LoginScreen(),
        'home_main_screen': (_) => const HomeMainScreen(usuario: ''),
        'home_register': (_) => const HomeRegisterScreen(usuario: ''),
        'home_citas': (_) => const HomeCitasScreen(usuario: ''),
      },
      initialRoute: 'login', //Llama a 'login'
    );
  }
}
