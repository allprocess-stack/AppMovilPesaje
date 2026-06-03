import 'package:app2/screens/widgets/reusable_fila_info.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ViewCitasOutScreen extends StatelessWidget {
  final List<dynamic> citas;
  final List<dynamic> registros;
  final String usuario;
  const ViewCitasOutScreen({
    super.key,
    required this.citas,
    required this.usuario,
    required this.registros,
  });
  String get mensajeVacio {
    return "No hay citas";
  }

  List<Map<String, dynamic>> _registrosPorCita(int citaId) {
    return registros
        .where((r) => r['CitaId'] == citaId)
        .cast<Map<String, dynamic>>()
        .toList();
  }

  String mostrarFechaES(String fecha) {
    fecha = fecha.replaceAll(" GM", " GMT");

    final date = DateFormat(
      "EEE, dd MMM yyyy HH:mm:ss 'GMT'",
      'en_US',
    ).parseUtc(fecha).toLocal();

    return DateFormat("d MMMM y, HH:mm", 'es_ES').format(date);
  }
  /* DateTime parsearFecha(dynamic fecha) {
    if (fecha == null) {
      throw Exception("Fecha nula");
    }

    final valor = fecha.toString();

    // Formato SQL: 2026-01-02 10:09:44
    if (valor.contains('-') && valor.contains(':')) {
      return DateTime.parse(valor).toLocal();
    }

    // Formato HTTP: Mon, 05 Jan 2026 17:18:51 GMT
    if (valor.contains('GMT')) {
      return HttpDate.parse(valor).toLocal();
    }

    throw FormatException("Formato de fecha no soportado: $valor");
  }

  // FILTRO
  List<dynamic> get citasFiltrados {
    final hoy = DateTime.now();

    return citas.where((r) {
      final fechaCita = HttpDate.parse(r['FechaCita']).toLocal();

      return fechaCita.year == hoy.year &&
          fechaCita.month == hoy.month &&
          fechaCita.day == hoy.day;
    }).toList();
  }*/

  // PRUEBA
  List<dynamic> get citasFiltrados {
    return citas;
  }

  Color estadoColor(String? estado) {
    switch (estado) {
      case 'INGRESO':
        return Colors.blue;
      case 'PRIMERA PESADA':
      case 'SEGUNDA PESADA':
      case 'TERCERA PESADA':
      case 'CUARTA PESADA':
      case 'QUINTA PESADA':
      case 'SEXTA PESADA':
        return Colors.yellow;
      case 'SALIDA':
        return Colors.red;
      case 'PESAJE COMPLETADO':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueAccent,
        elevation: 2,
        title: const Text(
          'Citas Registros',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {
              Navigator.popUntil(context, (route) => route.isFirst);
            },
            icon: const Icon(Icons.home, color: Colors.white),
          ),
        ],
      ),
      body: citasFiltrados.isEmpty
          ? _vistaCitasVacia()
          : ListView.builder(
              padding: const EdgeInsets.only(bottom: 16),
              itemCount: citasFiltrados.length,
              itemBuilder: (context, index) {
                final citas = citasFiltrados[index];
                return _itemCitas(context, citas);
              },
            ),
    );
  }

  Widget _vistaCitasVacia() {
    debugPrint("estas con las citas: $citas");

    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.event_busy, size: 70, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            "No hay citas registradas",
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _itemCitas(BuildContext context, Map<String, dynamic> cita) {
    final regs = _registrosPorCita(cita['Id']);

    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // CABECERA CITA
            // Row(
            //   children: [
            //     CircleAvatar(
            //       radius: 24,
            //       backgroundColor: Colors.redAccent,
            //       child: const Icon(Icons.event, color: Colors.white),
            //     ),
            //     const SizedBox(width: 14),
            //     Expanded(
            //       child: Column(
            //         crossAxisAlignment: CrossAxisAlignment.start,
            //         children: [
            //           Text(
            //             'Cita #${cita['Id']}',
            //             style: const TextStyle(
            //               fontWeight: FontWeight.bold,
            //               fontSize: 16,
            //             ),
            //           ),
            //           ReusableFilaInfo(
            //             etiqueta: 'Placa: ',
            //             valor: '${cita['Placa']}',
            //           ),
            //           ReusableFilaInfo(
            //             etiqueta: 'Chofer: ',
            //             valor: '${cita['Chofer']}',
            //           ),
            //           ReusableFilaInfo(
            //             etiqueta: 'Fecha: ',
            //             valor: mostrarFechaES(cita['FechaCita']),
            //           ),
            //         ],
            //       ),
            //     ),
            //   ],
            // ),

            // const SizedBox(height: 12),
            // const Divider(),

            // REGISTROS
            if (regs.isEmpty)
              const Text("Sin registros", style: TextStyle(color: Colors.grey))
            else
              Column(children: regs.map((r) => _itemRegistroMini(r)).toList()),
          ],
        ),
      ),
    );
  }

  Widget _itemRegistroMini(Map<String, dynamic> registro) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // CABECERA
          Row(
            children: [
              Icon(
                Icons.local_shipping,
                size: 18,
                color: estadoColor(registro['Estado']),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  registro['Ticket'] ?? 'SIN TICKET',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: estadoColor(registro['Estado']).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  registro['Estado'],
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: estadoColor(registro['Estado']),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 6),

          ReusableFilaInfo(
            etiqueta: 'ID Registro: ',
            valor: '${registro['Id']}',
          ),
          ReusableFilaInfo(
            etiqueta: 'Cantidad: ',
            valor: '${registro['Cantidad'] ?? 'N/A'}',
          ),

          ...List.generate(
            int.tryParse(registro['Cantidad'].toString()) ?? 1,
            (i) => ReusableFilaInfo(
              etiqueta: 'Producto ${i + 1}: ',
              valor: '${registro["Producto${i + 1}"] ?? 'N/A'}',
            ),
          ),

          ReusableFilaInfo(
            etiqueta: 'Fecha: ',
            valor: mostrarFechaES(registro['FechaRegistro']),
          ),
        ],
      ),
    );
  }
}
