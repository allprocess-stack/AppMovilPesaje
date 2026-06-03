import 'package:app2/screens/widgets/reusable_view_citas_register.dart';
import 'package:flutter/material.dart';

class ViewCitaScreen extends StatelessWidget {
  final List<dynamic> citas;
  final String usuario;
  const ViewCitaScreen({super.key, required this.citas, required this.usuario});

  @override
  Widget build(BuildContext context) {
    return ReusableViewCitasRegister(citas: citas, usuario: usuario);
  }
}
