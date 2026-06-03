//import 'dart:io';

import 'package:app2/screens/app_colors.dart';
import 'package:app2/screens/edit_cita_screen.dart';
import 'package:app2/screens/widgets/reusable_fila_info.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ReusableViewCitasRegister extends StatelessWidget {
  final List<dynamic> citas;
  final String usuario;

  const ReusableViewCitasRegister({
    super.key,
    required this.citas,
    required this.usuario,
  });

  String get mensajeVacio => "No hay citas";

  String mostrarFechaES(String fecha) {
    fecha = fecha.replaceAll(" GM", " GMT");

    final date = DateFormat(
      "EEE, dd MMM yyyy HH:mm:ss 'GMT'",
      'en_US',
    ).parseUtc(fecha).toLocal();

    return DateFormat("d MMMM y, HH:mm", 'es_ES').format(date);
  }

  List<dynamic> get citasFiltrados => citas;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,

      appBar: AppBar(
        title: const Text(
          'Citas',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: () {
              Navigator.popUntil(context, (route) => route.isFirst);
            },
            icon: const Icon(Icons.home),
          ),
        ],
      ),

      body: citasFiltrados.isEmpty
          ? _vistaCitasVacia()
          : ListView.builder(
              padding: const EdgeInsets.only(bottom: 12),
              itemCount: citasFiltrados.length,
              itemBuilder: (context, index) {
                final cita = citasFiltrados[index];
                return _itemCitas(context, cita);
              },
            ),
    );
  }

  Widget _vistaCitasVacia() {
    return const Center(
      child:  Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children:  [
          Icon(Icons.event_busy, size: 60, color: Colors.grey),
          SizedBox(height: 12),
          Text(
            "No hay citas",
            style: TextStyle(fontSize: 18, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _itemCitas(BuildContext context, Map<String, dynamic> cita) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 14),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 10,
        ),

        leading: const CircleAvatar(
          radius: 22,
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          child:  Icon(Icons.local_shipping),
        ),

        title: Text(
          'Cita #${cita['Id']}',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
        ),

        subtitle: Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ReusableFilaInfo(etiqueta: 'Placa:', valor: '${cita['Placa']}'),
              ReusableFilaInfo(etiqueta: 'Chofer:', valor: '${cita['Chofer']}'),
              ReusableFilaInfo(
                etiqueta: 'Brevete:',
                valor: '${cita['Brevete']}',
              ),
              const SizedBox(height: 4),
              Text(
                mostrarFechaES(cita['FechaCita']),
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),

        trailing: const Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: Colors.grey,
        ),

        onTap: () {
          final int idCita = cita['Id'];
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  EditCitaScreen(cita: cita, usuario: usuario, idCita: idCita),
            ),
          );
        },
      ),
    );
  }
}
