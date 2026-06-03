import 'package:app2/screens/admin/show_admin_menu.dart';
import 'package:app2/screens/app_colors.dart';
import 'package:app2/screens/example.dart';
import 'package:app2/screens/global.dart';
import 'package:app2/screens/home_citas_screen.dart';
import 'package:app2/screens/home_register_screen.dart';
import 'package:app2/screens/widgets/widget_app_bar_users.dart';
import 'package:flutter/material.dart';

class HomeMainScreen extends StatefulWidget {
  final String usuario;

  const HomeMainScreen({super.key, required this.usuario});

  @override
  State<HomeMainScreen> createState() => _HomeMainScreenState();
}

class _HomeMainScreenState extends State<HomeMainScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: WidgetAppBarUsers(
        tipoUsuario: tipoUsuarioGlobal,
        title: const Text(
          'Principal',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        automaticallyImplyLeading: true,
        child: Text(
          tipoUsuarioGlobal.toUpperCase(),
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
      floatingActionButton: tipoUsuarioGlobal == 'admin'
          ? FloatingActionButton(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.background,
              child: const Icon(Icons.swap_horiz, fontWeight: FontWeight.bold),
              onPressed: () => showAdminMenu(context),
            )
          : null,
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            const Text(
              'Seleccione una opción',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Accesos principales del sistema',
              style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 32),
            // OPCIONES
            navigationOptions(context),
            IconButton(
              onPressed: () {
                const number = "51914713545";
                const sms =
                    "http://LAPTOP-NKUNP3JQ/descargar_registro_pdf/2";
                launchWhatsApp(phoneNumber: number, message: sms);
              },
              icon: const Icon(Icons.share),
            ),
          ],
        ),
      ),
    );
  }

  Center navigationOptions(BuildContext context) {
    return Center(
      child: Wrap(
        spacing: 20,
        runSpacing: 20,
        children: [
          _menuButton(
            icon: Icons.access_time_filled,
            label: 'Citas',
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) => HomeCitasScreen(usuario: usuarioGlobal),
                ),
              );
            },
          ),
          _menuButton(
            icon: Icons.how_to_reg,
            label: 'Registros',
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) => HomeRegisterScreen(usuario: usuarioGlobal),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _menuButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      width: 160,
      height: 140,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Card(
          color: AppColors.surface,
          elevation: 3,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: AppColors.border),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 48, color: AppColors.primary),
              const SizedBox(height: 12),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
