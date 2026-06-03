import 'package:app2/screens/global.dart';
import 'package:app2/screens/home_citas_screen.dart';
import 'package:app2/screens/home_register_screen.dart';
import 'package:flutter/material.dart';

Future<void> showAdminMenu(BuildContext context) async {
  return showDialog(
    context: context,
    barrierDismissible: true,
    builder: (context) {
      return Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Cambiar Área',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              ListTile(
                leading: const Icon(Icons.security, color: Colors.blue),
                title: const Text('Seguridad'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (_) => HomeCitasScreen(usuario: usuarioGlobal),
                    ),
                  );
                },
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.fact_check, color: Colors.green),
                title: const Text('Calificador'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          HomeRegisterScreen(usuario: usuarioGlobal),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      );
    },
  );
}
