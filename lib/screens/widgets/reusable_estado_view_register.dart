// ignore_for_file: deprecated_member_use

//import 'dart:io';
import 'package:intl/intl.dart';
import 'package:app2/screens/edit_register_screen.dart';
import 'package:app2/screens/widgets/reusable_fila_info.dart';
import 'package:flutter/material.dart';

enum EstadoRegistro {
  ingreso,
  primerapesada,
  segundapesada,
  tercerpesada,
  cuartapesada,
  quientapesada,
  sextapesada,
  pesajecompletado,
  salida,
}

class ReusableEstadoViewRegister extends StatelessWidget {
  final List<dynamic> registros;
  final List<dynamic> citas;
  final String usuario;

  final List<EstadoRegistro> estados;

  const ReusableEstadoViewRegister({
    super.key,
    required this.registros,
    required this.usuario,
    required this.estados,
    required this.citas,
  });

  // MAPEO ESTADO → TEXTO BD
  String estadoToTexto(EstadoRegistro estado) {
    switch (estado) {
      case EstadoRegistro.ingreso:
        return "INGRESO";
      case EstadoRegistro.primerapesada:
        return "PRIMERA PESADA";
      case EstadoRegistro.segundapesada:
        return "SEGUNDA PESADA";
      case EstadoRegistro.tercerpesada:
        return "TERCERA PESADA";
      case EstadoRegistro.cuartapesada:
        return "CUARTA PESADA";
      case EstadoRegistro.quientapesada:
        return "QUINTA PESADA";
      case EstadoRegistro.sextapesada:
        return "SEXTA PESADA";
      case EstadoRegistro.salida:
        return "SALIDA";
      case EstadoRegistro.pesajecompletado:
        return "PESAJE COMPLETADO";
    }
  }

  // CONFIGURACIÓN VISUAL
  String get estadoTitulo {
    return estados.contains(EstadoRegistro.salida)
        ? "FUERA DE PLANTA"
        : "VEHICULOS EN PLANTA";
  }

  Color get estadoColor {
    return estados.contains(EstadoRegistro.salida) ? Colors.red : Colors.blue;
  }

  IconData get estadoIcono {
    return estados.contains(EstadoRegistro.salida) ? Icons.logout : Icons.login;
  }

  String get mensajeVacio {
    return "No hay registros";
  }

  String mostrarFechaES(String fecha) {
    fecha = fecha.replaceAll(" GM", " GMT");

    final date = DateFormat(
      "EEE, dd MMM yyyy HH:mm:ss 'GMT'",
      'en_US',
    ).parseUtc(fecha).toLocal();

    return DateFormat("d MMMM y, HH:mm", 'es_ES').format(date);
  }

  // FILTRO POR VARIOS ESTADOS
  List<dynamic> get registrosFiltrados {
    final estadosPermitidos = estados.map((e) => estadoToTexto(e)).toSet();

    return registros.where((r) {
      final estadoBD = r['Estado']?.toString().toUpperCase().trim();
      return estadosPermitidos.contains(estadoBD);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: Text(
          estadoTitulo,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: estadoColor,
        actions: [
          IconButton(
            icon: const Icon(Icons.home),
            onPressed: () {
              Navigator.popUntil(context, (route) => route.isFirst);
            },
          ),
        ],
      ),
      body: registrosFiltrados.isEmpty
          ? _vistaVacia()
          : ListView.builder(
              itemCount: registrosFiltrados.length,
              padding: const EdgeInsets.all(8),
              itemBuilder: (context, index) {
                final registro = registrosFiltrados[index];
                final int idRegistro = registro['Id'];
                debugPrint("idregistro: $idRegistro");
                final int idCita = registro['CitaId'];
                return _itemRegistro(context, registro, idCita, idRegistro);
              },
            ),
    );
  }

  Widget _vistaVacia() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(estadoIcono, size: 90, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text(
            mensajeVacio,
            style: const TextStyle(fontSize: 18, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _itemRegistro(
    BuildContext context,
    Map<String, dynamic> registro,
    int idCita,
    int idRegistro,
  ) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 14, horizontal: 4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => EditRegisterScreen(
                registro: registro,
                usuario: usuario,
                idCita: idCita,
              ),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // CABECERA
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: estadoColor,
                    radius: 22,
                    child: Icon(estadoIcono, color: Colors.white),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${registro['Ticket'] ?? 'N/A'}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Placa: ${registro['Placa'] ?? 'N/A'}',
                          style: TextStyle(
                            color: Colors.grey.shade700,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: estadoColor.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      registro['Estado'],
                      style: TextStyle(
                        color: estadoColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 10),
              const Divider(),

              // DETALLE
              ReusableFilaInfo(
                etiqueta: 'ID Registro: ',
                valor: '${registro['Id'] ?? 'N/A'}',
              ),
              ReusableFilaInfo(
                etiqueta: 'Cantidad: ',
                valor: '${registro['Cantidad'] ?? 'N/A'}',
              ),

              const SizedBox(height: 6),

              ...List.generate(
                int.tryParse(registro['Cantidad'].toString()) ?? 1,
                (i) => ReusableFilaInfo(
                  etiqueta: 'Producto ${i + 1}: ',
                  valor: '${registro["Producto${i + 1}"] ?? 'N/A'}',
                ),
              ),

              const SizedBox(height: 6),

              ReusableFilaInfo(
                etiqueta: 'Fecha: ',
                valor: mostrarFechaES(registro['FechaRegistro']),
              ),
            ],
          ),
        ),
      ),
    );
  }
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
  List<dynamic> get registrosFiltrados {
    final hoy = DateTime.now();

    return registros.where((r) {
      final fechaRegistro = HttpDate.parse(r['FechaRegistro']).toLocal();

      return fechaRegistro.year == hoy.year &&
          fechaRegistro.month == hoy.month &&
          fechaRegistro.day == hoy.day;
    }).toList();
  }*/