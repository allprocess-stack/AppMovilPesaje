import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

class RegisterService {
  final String baseUrl;
  RegisterService(this.baseUrl);

  // Cargar productos
  Future<List<dynamic>> cargarProductos() async {
    try {
      final url = Uri.parse('$baseUrl/api/obtener_productos');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Error al cargar productos');
      }
    } catch (e) {
      return [];
    }
  }

  // Obtener un registro específico
  Future<Map<String, dynamic>> obtenerRegistro(int id) async {
    try {
      final url = Uri.parse('$baseUrl/api/obtener_registro/$id');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('No se pudo obtener el registro');
      }
    } catch (e) {
      return {};
    }
  }

  // OBTENER REGISTROS
  Future<List<dynamic>> obtenerTodosRegistro() async {
    try {
      final url = Uri.parse('$baseUrl/api/todo_registro');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Error al cargar registros');
      }
    } catch (e) {
      return [];
    }
  }

  Future<bool> marcarSalida(int registroId) async {
    try {
      final url = Uri.parse('$baseUrl/api/marcar_salida/$registroId');

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'id': registroId}),
      );

      return response.statusCode == 200;
    } catch (e) {
      debugPrint('Error marcarSalida: $e');
      return false;
    }
  }

  // Subir imagen
  Future<String> subirImagen(File imagen) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/uploads'),
      );
      request.files.add(
        await http.MultipartFile.fromPath('image', imagen.path),
      );

      final response = await request.send();
      if (response.statusCode == 200) {
        final body = await response.stream.bytesToString();
        return jsonDecode(body)['filename'];
      } else {
        throw Exception('Error al subir imagen');
      }
    } catch (e) {
      return '';
    }
  }

  // Actualizar Registro
  Future<void> actualizarRegistro({
    required Map<String, String> fields,
    required List<File?> imagenes,
  }) async {
    final request = http.MultipartRequest(
      'POST',
      Uri.parse('$baseUrl/api/actualizar_registro'),
    );

    request.fields.addAll(fields);

    for (int i = 0; i < imagenes.length; i++) {
      final imagen = imagenes[i];
      if (imagen != null) {
        request.files.add(
          await http.MultipartFile.fromPath(
            'imagen${i + 1}', // 👈 CLAVE
            imagen.path,
          ),
        );
      }
    }

    final response = await request.send();

    if (response.statusCode != 200) {
      final body = await response.stream.bytesToString();
      throw Exception(body);
    }
  }

  // AUTOCOMPLETE PRODUCTOS
  Future<List<String>> autocompleteProducto(String query) async {
    try {
      final url = Uri.parse('$baseUrl/api/autocomplete_producto?q=$query');
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.cast<String>();
      } else {
        debugPrint("Error");
        return [];
      }
    } catch (e) {
      return [];
    }
  }

  // AUTOCOMPLETE PLACA
  Future<List<String>> autocompleteTicket(String query) async {
    try {
      final url = Uri.parse('$baseUrl/api/autocomplete_ticket?q=$query');
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.cast<String>();
      } else {
        debugPrint("Error");
        return [];
      }
    } catch (e) {
      return [];
    }
  }

  Future<List<dynamic>> obtenerRegistrosPorTicket(String ticket) async {
    try {
      final url = Uri.parse('$baseUrl/api/registros_por_ticket?ticket=$ticket');

      final response = await http.get(url);

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Error al obtener registros');
      }
    } catch (e) {
      return [];
    }
  }

  // DESCARGAR REGISTRO - PDF
  Future<String?> descargarPdfRegistro(int registroId) async {
    try {
      final url = Uri.parse('$baseUrl/descargar_registro_pdf/$registroId');
      debugPrint("id es :$registroId");
      debugPrint("baseurl es :$baseUrl");
      final response = await http.get(url);
      if (url.hasEmptyPath) return 'Registro inexistente';
      if (response.statusCode == 200) {
        final dir = await getTemporaryDirectory();
        final filePath = '${dir.path}/Registro_$registroId.pdf';

        final file = File(filePath);
        await file.writeAsBytes(response.bodyBytes);
        // debugPrint(registroId);
        return filePath;
      } else {
        return null;
      }
    } catch (e) {
      return 'Error';
    }
  }

  // BUSCAR REGISTROS FILTRADOS
  Future<List<dynamic>> buscarRegistros({
    required String tipo,
    required String valor,
  }) async {
    try {
      final url = Uri.parse('$baseUrl/api/buscar_registro');

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'tipo': tipo, 'valor': valor.toUpperCase()}),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Error al buscar registros');
      }
    } catch (e) {
      return [];
    }
  }
}
