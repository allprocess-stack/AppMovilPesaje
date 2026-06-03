import 'package:app2/screens/widgets/reusable_estado_view_register.dart';
import 'package:flutter/material.dart';

class ViewRegisterOutScreen extends StatelessWidget {
  final List<dynamic> registros;
  final List<dynamic> citas;

  final String usuario;

  const ViewRegisterOutScreen({
    super.key,
    required this.registros,
    required this.usuario,
    required this.citas,
  });

  @override
  Widget build(BuildContext context) {
    return ReusableEstadoViewRegister(
      registros: registros,
      usuario: usuario,
      estados: const [EstadoRegistro.salida], // AQUÍ se define el estado
      citas: citas,
    );
  }
}
