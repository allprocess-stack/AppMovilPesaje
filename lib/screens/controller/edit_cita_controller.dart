import 'dart:io';

import 'package:app2/screens/services/citas_service.dart';
import 'package:flutter/foundation.dart';

class EditCitaController extends ChangeNotifier {
  final CitasService citasService;
  final VoidCallback onUpdate;

  Map<String, dynamic> citaActual = {};
  String tipoUsuario = "Seguridad";
  List<File> imagenesLocales = [];
  bool isPickingImage = false;
  bool isLoading = false;

  EditCitaController(
    this.citasService, {
    required int idCita,
    required this.onUpdate,
  }) {
    cargarCita(idCita);
  }

  Future<void> cargarCita(int idCita) async {
    isLoading = true;
    notifyListeners();

    final cita = await citasService.obtenerCita(idCita);
    citaActual = cita;

    isLoading = false;
    onUpdate();
    notifyListeners();
  }

  Future<List<String>> autocompletePlaca(String search) async {
    if (search.isEmpty) return [];

    try {
      return await citasService.autocompletePlacas(search);
    } catch (e) {
      debugPrint("Error en autocompletePlaca: $e");
      return [];
    }
  }

  Future<List<String>> autocompleteBrevete(String search) async {
    if (search.isEmpty) return [];

    try {
      return await citasService.autocompleteBrevetes(search);
    } catch (e) {
      debugPrint("Error en autocompleteBrevete: $e");
      return [];
    }
  }

  String? obtenerUrlSctrParaVista(int citaid) {
    return citasService.obtenerUrlSctr(citaid);
  }

  String? obtenerUrlBreveteParaVista(int citaid) {
    return citasService.obtenerUrlBrevete(citaid);
  }

  String? obtenerUrlGuiaRemisionParaVista(int citaid) {
    return citasService.obtenerUrlGuiaRemision(citaid);
  }

  String? obtenerUrlGuiaTransportistaParaVista(int citaid) {
    return citasService.obtenerUrlGuiaTransportista(citaid);
  }

  String? obtenerUrlOtroDocumentoParaVista(int citaid) {
    return citasService.obtenerUrlOtroDocumento(citaid);
  }

  Future<void> registrarCitaRegistro(int citaId, String optionOperation) async {
    if (isLoading) return;
    try {
      isLoading = true;
      notifyListeners();

      await citasService.registrarCita(citaId, optionOperation);

      onUpdate(); // refresca lista o vista
    } catch (e) {
      debugPrint('Error al registrar cita: $e');
      rethrow;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> actualizarEstadoCita(int citaId, String optionEstado) async {
    if (isLoading) return;
    try {
      isLoading = true;
      notifyListeners();

      await citasService.estadoCita(citaId, optionEstado);

      onUpdate(); // refresca lista o vista
    } catch (e) {
      debugPrint('Error actualizar estado cita: $e');
      rethrow;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
