import 'package:app2/screens/widgets/reusable_estado_view_register.dart';
import 'package:flutter/material.dart';

class ViewRegisterInScreen extends StatelessWidget {
  final List<dynamic> registros;
  final List<dynamic> citas;

  final String usuario;

  const ViewRegisterInScreen({
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
      estados: const [
        EstadoRegistro.ingreso,
        EstadoRegistro.primerapesada,
        EstadoRegistro.segundapesada,
        EstadoRegistro.tercerpesada,
        EstadoRegistro.cuartapesada,
        EstadoRegistro.quientapesada,
        EstadoRegistro.sextapesada,
        EstadoRegistro.pesajecompletado,
      ], // AQUÍ se define el estado
      citas: citas,
    );
  }
}
