import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

class CitasService {
  final String baseUrl;
  CitasService(this.baseUrl);

  Future<Map<String, dynamic>> obtenerCita(int id) async {
    try {
      final url = Uri.parse('$baseUrl/api/obtener_cita/$id');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        // debugPrint(response.body);
        return jsonDecode(response.body);
      } else {
        debugPrint('Error obtenerCita: ${response.statusCode}');
        return {};
      }
    } catch (e) {
      debugPrint('Excepción obtenerCita: $e');
      return {};
    }
  }

  Future<List<dynamic>> obtenerCitaRegistro() async {
    try {
      final url = Uri.parse('$baseUrl/api/obtener_cita_registro');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        debugPrint('Error obtenerCita: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      debugPrint('Excepción obtenerCita: $e');
      return [];
    }
  }

  Future<List<dynamic>> obtenerTodasCitas() async {
    try {
      final url = Uri.parse('$baseUrl/api/todo_cita');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        debugPrint('Error obtenerTodasCitas');
        return [];
      }
    } catch (e) {
      debugPrint('Excepción obtenerCita: $e');
      return [];
    }
  }

  // BUSCAR CITAS FILTRADOS
  Future<List<dynamic>> buscarCitas({
    required String tipo,
    required String valor,
  }) async {
    try {
      final url = Uri.parse('$baseUrl/api/buscar_cita');

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'tipo': tipo, 'valor': valor.toUpperCase()}),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        debugPrint('Error buscarCitas');
        return [];
      }
    } catch (e) {
      debugPrint('Excepción buscarCitas: $e');
      return [];
    }
  }

  Future<List<dynamic>> obtenerCitasPorPlaca(String placa) async {
    try {
      final url = Uri.parse('$baseUrl/api/citas_por_placa?placa=$placa');

      final response = await http.get(url);

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        debugPrint('Error obtenerCitasPorPlaca');
        return [];
      }
    } catch (e) {
      debugPrint('Excepción obtenerCitasPorPlaca: $e');
      return [];
    }
  }

  Future<List<dynamic>> obtenerCitasPorBrevete(String brevete) async {
    try {
      final url = Uri.parse('$baseUrl/api/citas_por_brevete?brevete=$brevete');

      final response = await http.get(url);

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        debugPrint('Error obtenerCitasPorBrevete');
        return [];
      }
    } catch (e) {
      debugPrint('Excepción obtenerCitasPorBrevete: $e');
      return [];
    }
  }

  // AUTOCOMPLETE PLACAS
  Future<List<String>> autocompletePlacas(String query) async {
    try {
      final url = Uri.parse('$baseUrl/api/autocomplete_placa?q=$query');
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.cast<String>();
      } else {
        return [];
      }
    } catch (e) {
      debugPrint('Excepción autocompletePlacas: $e');
      return [];
    }
  }

  // AUTOCOMPLETE PLACAS
  Future<List<String>> autocompleteBrevetes(String query) async {
    try {
      final url = Uri.parse('$baseUrl/api/autocomplete_brevete?q=$query');
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.cast<String>();
      } else {
        return [];
      }
    } catch (e) {
      debugPrint('Excepción autocompleteBrevetes: $e');
      return [];
    }
  }

  // Generar URL para ver SCTR
  String obtenerUrlSctr(int idCita) {
    // Construye la URL completa hacia tu endpoint Flask
    return "$baseUrl/preview_sctr/$idCita";
  }

  String obtenerUrlBrevete(int idCita) {
    return "$baseUrl/preview_brevete/$idCita";
  }

  String obtenerUrlGuiaRemision(int idCita) {
    return "$baseUrl/preview_guia_remision/$idCita";
  }

  String obtenerUrlGuiaTransportista(int idCita) {
    return "$baseUrl/preview_guia_transportista/$idCita";
  }

  String obtenerUrlOtroDocumento(int idCita) {
    return "$baseUrl/preview_otro_documento/$idCita";
  }

  Future<bool> registrarCita(int citaId, String optionOperation) async {
    try {
      final url = Uri.parse('$baseUrl/api/registrar_cita');

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'cita_id': citaId, 'operacion': optionOperation}),
      );

      return response.statusCode == 201;
    } catch (e) {
      debugPrint('Excepción registrarCita: $e');
      return false;
    }
  }

  Future<bool> estadoCita(int citaId, String optionEstado) async {
    try {
      final url = Uri.parse('$baseUrl/api/estado_cita');

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'cita_id': citaId, 'estado': optionEstado}),
      );

      return response.statusCode == 201;
    } catch (e) {
      debugPrint('Excepción estado Cita: $e');
      return false;
    }
  }

  Future<String?> descargarPdfCita(int citaId) async {
    try {
      final url = Uri.parse('$baseUrl/descargar_cita_pdf/$citaId');
      debugPrint("id es :$citaId");
      debugPrint("baseurl es :$baseUrl");
      final response = await http.get(url);
      if (url.hasEmptyPath) return 'Cita inexistente';
      if (response.statusCode == 200) {
        final dir = await getTemporaryDirectory();
        final filePath = '${dir.path}/Cita_$citaId.pdf';

        final file = File(filePath);
        await file.writeAsBytes(response.bodyBytes);
        // debugPrint(citaId);
        return filePath;
      } else {
        return null;
      }
    } catch (e) {
      return 'Error';
    }
  }
}
