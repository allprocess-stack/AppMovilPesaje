// ignore_for_file: use_build_context_synchronously

import 'dart:convert';
import 'package:app2/screens/config.dart';
import 'package:app2/screens/global.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'app_colors.dart'; // ← tu clase AppColors

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool isLoading = false;

  Future<void> loginUser() async {
    if (usernameController.text.isEmpty || passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor complete todos los campos')),
      );
      return;
    }

    setState(() => isLoading = true);

    final url = Uri.parse('${AppConfig.baseUrl}/api/login');
    final data = {
      'Usuario': usernameController.text.toUpperCase(),
      'Contrasenha': passwordController.text,
    };

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(data),
      );

      final resData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        final tipo = resData['Tipo'];
        tipoUsuarioGlobal = resData['Tipo'] ?? '';
        usuarioGlobal = resData['Usuario'] ?? '';

        if (tipo == 'admin' || tipo == 'seguridad' || tipo == 'calificador') {
          Navigator.pushReplacementNamed(context, 'home_main_screen');
          return;
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(resData['msg'] ?? 'Credenciales incorrectas')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error de conexión: $e')));
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Iniciar Sesión'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.home),
            onPressed: () {
              Navigator.popUntil(context, (route) => route.isFirst);
            },
          ),
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Card(
            color: AppColors.surface,
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: const BorderSide(color: AppColors.border),
            ),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.account_circle,
                    size: 90,
                    color: AppColors.primary,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Acceso al Sistema',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // USUARIO
                  TextField(
                    controller: usernameController,
                    textCapitalization: TextCapitalization.characters,
                    decoration: InputDecoration(
                      labelText: 'Usuario',
                      labelStyle: const TextStyle(
                        color: AppColors.textSecondary,
                      ),
                      prefixIcon: const Icon(Icons.person),
                      focusedBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: AppColors.primary),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // CONTRASEÑA
                  TextField(
                    controller: passwordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: 'Contraseña',
                      labelStyle: const TextStyle(
                        color: AppColors.textSecondary,
                      ),
                      prefixIcon: const Icon(Icons.lock),
                      focusedBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: AppColors.primary),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // BOTÓN
                  isLoading
                      ? const CircularProgressIndicator(color: AppColors.accent)
                      : SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton.icon(
                            onPressed: loginUser,
                            icon: const Icon(Icons.login),
                            label: const Text(
                              'INGRESAR',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
