import 'package:app2/screens/admin/show_admin_menu.dart';
import 'package:app2/screens/app_colors.dart';
import 'package:flutter/material.dart';

class WidgetAppBarUsers extends StatelessWidget implements PreferredSizeWidget {
  final Widget child;
  final String tipoUsuario;
  final Widget title;

  const WidgetAppBarUsers({
    super.key,
    required this.child,
    required this.tipoUsuario,
    required this.title,
    required bool automaticallyImplyLeading,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.primary,
      elevation: 2,
      // centerTitle: true,
      iconTheme: const IconThemeData(color: Colors.white),

      title: DefaultTextStyle(
        textAlign: TextAlign.start,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600,
          fontSize: 18,
        ),
        child: title,
      ),

      actions: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Center(
            child: DefaultTextStyle(
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
              child: child,
            ),
          ),
        ),

        PopupMenuButton<String>(
          icon: const Icon(Icons.menu, color: Colors.white),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          color: AppColors.surface,
          onSelected: (value) async {
            await Future.delayed(const Duration(milliseconds: 100));
            if (!context.mounted) return;

            switch (value) {
              case 'home':
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  'home_main_screen',
                  (route) => false,
                );
                break;
              case 'home_register':
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  'home_register',
                  (route) => false,
                );
                break;
              case 'home_citas':
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  'home_citas',
                  (route) => false,
                );
                break;
              case 'logout':
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  'login',
                  (route) => false,
                );
                break;
              case 'admin':
                showAdminMenu(context);
                break;
            }
          },
          itemBuilder: (context) => [
            _menuItem(
              value: 'home',
              icon: Icons.home_outlined,
              text: 'Principal',
            ),
            _menuItem(
              value: 'home_citas',
              icon: Icons.event,
              text: 'Inicio Citas',
            ),
            _menuItem(
              value: 'home_register',
              icon: Icons.assignment_outlined,
              text: 'Inicio Registros',
            ),
            _menuItem(value: 'logout', icon: Icons.exit_to_app, text: 'Salir'),
            if (tipoUsuario == 'admin')
              _menuItem(
                value: 'admin',
                icon: Icons.admin_panel_settings,
                text: 'Menú Admin',
              ),
          ],
        ),
      ],
    );
  }

  PopupMenuItem<String> _menuItem({
    required String value,
    required IconData icon,
    required String text,
  }) {
    return PopupMenuItem(
      value: value,
      child: ListTile(
        dense: true,
        leading: Icon(icon, color: AppColors.primary),
        title: Text(
          text,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
