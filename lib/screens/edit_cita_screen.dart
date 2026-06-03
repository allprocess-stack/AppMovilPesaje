// ignore_for_file: use_build_context_synchronously, deprecated_member_use

import 'package:app2/screens/admin/show_admin_menu.dart';
import 'package:app2/screens/app_colors.dart';
import 'package:app2/screens/config.dart';
import 'package:app2/screens/controller/edit_cita_controller.dart';
import 'package:app2/screens/global.dart';
import 'package:app2/screens/home_citas_screen.dart';
import 'package:app2/screens/services/citas_service.dart';
import 'package:app2/screens/widgets/reusable_fila_info.dart';
import 'package:app2/screens/widgets/widget_app_bar_users.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class EditCitaScreen extends StatefulWidget {
  final Map<String, dynamic> cita;
  final String usuario;
  final int idCita;
  const EditCitaScreen({
    super.key,
    required this.cita,
    required this.usuario,
    required this.idCita,
  });

  @override
  State<EditCitaScreen> createState() => _EditCitaScreenState();
}

class _EditCitaScreenState extends State<EditCitaScreen> {
  late EditCitaController controller;
  late final CitasService citasService;
  String? pdfUrl;
  bool cargandoPdf = false;

  String? optionOperation;
  String? optionEstado;

  Map<String, dynamic> citaActual = {};
  bool _enviando = false;

  @override
  void initState() {
    super.initState();
    citasService = CitasService(AppConfig.baseUrl);
    controller = EditCitaController(
      citasService,
      onUpdate: () {
        if (mounted) setState(() {});
      },
      idCita: widget.idCita,
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool esCalificador = tipoUsuarioGlobal == 'calificador';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: WidgetAppBarUsers(
        tipoUsuario: tipoUsuarioGlobal,
        title: const Text(
          'Detalle de Cita',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        automaticallyImplyLeading: true,
        child: Text(
          tipoUsuarioGlobal.toUpperCase(),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      floatingActionButton: tipoUsuarioGlobal == 'admin'
          ? FloatingActionButton(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.background,
              child: const Icon(Icons.swap_horiz, fontWeight: FontWeight.bold),
              onPressed: () => showAdminMenu(context),
            )
          : null,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            informacionCita(),

            const SizedBox(height: 24),

            if (!esCalificador) _tipoOperacion(),

            if (!esCalificador) const SizedBox(height: 24),
            viewDocuments(context),
            const SizedBox(height: 10),

            if (!esCalificador) botonGuadarCitaRegistro(context),
          ],
        ),
      ),
    );
  }

  // BOTON MOTRAR MENU DOCUMENTOS
  ElevatedButton viewDocuments(BuildContext context) {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      onPressed: () async {
        showViewDocuments(context: context);
      },
      icon: const Icon(Icons.photo_library_outlined),
      label: const Text('Ver documentos', style: TextStyle(fontSize: 16)),
    );
  }

  // FUNCION DE MENSAJES (REUTILIZABLE)
  void showSnack(
    BuildContext context,
    String mensaje, {
    Color color = Colors.blueGrey,
  }) {
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(
        SnackBar(
          content: Text(mensaje),
          backgroundColor: color,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          duration: const Duration(seconds: 2),
        ),
      );
  }

  // VENTANA FLOTANTE QUE MUESTRA LOS DOCUMENTOS
  void showDocumentoDialog({
    required BuildContext context,
    required String url,
    required String titulo,
  }) {
    final isPdf = url.toLowerCase().endsWith(".pdf");
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Dialog(
        insetPadding: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        child: SizedBox(
          height: MediaQuery.of(context).size.height * 0.8,
          child: Column(
            children: [
              // CABECERA
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                decoration: const BoxDecoration(
                  color: Colors.redAccent,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
                ),
                child: Row(
                  children: [
                    Icon(
                      isPdf ? Icons.picture_as_pdf : Icons.image,
                      color: Colors.white,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        titulo,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),

              // CONTENIDO
              Expanded(
                child: isPdf
                    ? SfPdfViewer.network(
                        url,
                        onDocumentLoadFailed: (_) {
                          Navigator.pop(context);
                          showSnack(
                            context,
                            "No se pudo cargar el documento",
                            color: Colors.red,
                          );
                        },
                      )
                    : Image.network(
                        url,
                        fit: BoxFit.contain,
                        errorBuilder: (_, _, _) {
                          Navigator.pop(context);
                          showSnack(
                            context,
                            "No se pudo cargar la imagen",
                            color: Colors.red,
                          );
                          return const SizedBox.shrink();
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ESTILO DE LOS BOTONES
  ButtonStyle documentButtonStyle() {
    return ElevatedButton.styleFrom(
      backgroundColor: Colors.blue,
      foregroundColor: Colors.white,
    );
  }

  // ABRE LAS URL DE LOS BOTONES
  Future<void> abrirDocumento({
    required BuildContext context,
    required String? url,
    required String titulo,
    required String errorNoExiste,
  }) async {
    debugPrint("$titulo - URL: $url");
    if (url == null || url.isEmpty) {
      showSnack(context, errorNoExiste, color: Colors.red);
      return;
    }
    final response = await http.get(Uri.parse(url));
    if (response.statusCode != 200) {
      showSnack(context, "No existe $titulo", color: Colors.red);
      return;
    }
    showDocumentoDialog(context: context, url: url, titulo: titulo);
  }

  // ATRIBUTOS DE LOS BOTONES
  Widget documentButton({
    required BuildContext context,
    required String label,
    required IconData icon,
    required Future<String?> Function() getUrl,
    required String tituloDialog,
    required String errorTexto,
  }) {
    return ElevatedButton.icon(
      style: documentButtonStyle(),
      icon: Icon(icon),
      label: Text(label),
      onPressed: () async {
        final url = await getUrl();
        await abrirDocumento(
          context: context,
          url: url,
          titulo: tituloDialog,
          errorNoExiste: errorTexto,
        );
      },
    );
  }

  // BLOQUE DE LOS BOTONES(SCTR, BREVETE, REMISION, TRANSPORTISTA Y OTRO DOCUMENTO) DE CITA
  void showViewDocuments({required BuildContext context}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Dialog(
        shadowColor: Colors.black,
        elevation: 20,
        insetAnimationDuration: const Duration(milliseconds: 100),
        backgroundColor: const Color.fromARGB(235, 251, 253, 255),
        insetPadding: const EdgeInsets.all(40),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: const BorderSide(color: Colors.blue, width: 8),
        ),
        child: SizedBox(
          height: MediaQuery.of(context).size.height * 0.4,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: SingleChildScrollView(
              child: Column(
                spacing: 2,
                children: [
                  // HEADER
                  Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Vista de Documentos cita',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.close,
                            color: Colors.red,
                            // weight: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                  ),
                  // BOTONES
                  documentButton(
                    context: context,
                    label: 'SCTR',
                    icon: Icons.people,
                    getUrl: () async =>
                        controller.obtenerUrlSctrParaVista(widget.idCita),
                    tituloDialog: 'SCTR de la cita',
                    errorTexto: 'No hay SCTR',
                  ),
                  documentButton(
                    context: context,
                    label: 'Brevete',
                    icon: Icons.photo_camera_front_rounded,
                    getUrl: () async =>
                        controller.obtenerUrlBreveteParaVista(widget.idCita),
                    tituloDialog: 'Brevete de la cita',
                    errorTexto: 'No hay Brevete',
                  ),
                  documentButton(
                    context: context,
                    label: 'G. Remisión',
                    icon: Icons.insert_drive_file,
                    getUrl: () async => controller
                        .obtenerUrlGuiaRemisionParaVista(widget.idCita),
                    tituloDialog: 'Guía de Remisión',
                    errorTexto: 'No hay Guía de Remisión',
                  ),
                  documentButton(
                    context: context,
                    label: 'G. Transportista',
                    icon: Icons.insert_drive_file,
                    getUrl: () async => controller
                        .obtenerUrlGuiaTransportistaParaVista(widget.idCita),
                    tituloDialog: 'Guía de Transportista',
                    errorTexto: 'No hay Guía de Transportista',
                  ),
                  documentButton(
                    context: context,
                    label: 'Otro documento',
                    icon: Icons.insert_drive_file_outlined,
                    getUrl: () async => controller
                        .obtenerUrlOtroDocumentoParaVista(widget.idCita),
                    tituloDialog: 'Otro documento',
                    errorTexto: 'No hay Otro documento',
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Card informacionCita() {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const CircleAvatar(
                  radius: 22,
                  backgroundColor: AppColors.primaryLight,
                  foregroundColor: Colors.white,
                  child: Icon(Icons.assignment),
                ),
                const SizedBox(width: 12),
                Text(
                  'Cita #${controller.citaActual['Id'] ?? ''}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            ReusableFilaInfo(
              etiqueta: 'Placa: ',
              valor: '${controller.citaActual['Placa']}',
            ),
            ReusableFilaInfo(
              etiqueta: 'Chofer: ',
              valor: '${controller.citaActual['Chofer']}',
            ),
            ReusableFilaInfo(
              etiqueta: 'Brevete: ',
              valor: '${controller.citaActual['Brevete']}',
            ),
            ReusableFilaInfo(
              etiqueta: 'Teléfono: ',
              valor: '${controller.citaActual['Telefono']}',
            ),
            ReusableFilaInfo(
              etiqueta: 'Cliente: ',
              valor: '${controller.citaActual['Cliente']}',
            ),
          ],
        ),
      ),
    );
  }

  Widget _tipoOperacion() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(10),
            child: Text(
              'Tipo de operación',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          RadioListTile<String>(
            value: 'Carga',
            title: const Text('Carga (Salida de material)'),
            groupValue: optionOperation,
            onChanged: (value) {
              setState(() => optionOperation = value);
            },
          ),
          RadioListTile<String>(
            value: 'Descarga',
            title: const Text('Descarga (Entrada de material)'),
            groupValue: optionOperation,
            onChanged: (value) {
              setState(() => optionOperation = value);
            },
          ),
        ],
      ),
    );
  }

  ElevatedButton botonGuadarCitaRegistro(BuildContext context) {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.success,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      onPressed: _enviando
          ? null
          : () async {
              setState(() => _enviando = true);
              try {
                await controller.registrarCitaRegistro(
                  widget.idCita,
                  optionOperation!,
                );
                optionEstado = optionOperation == "Carga"
                    ? "SALIDA"
                    : "ENTRADA";
                await controller.actualizarEstadoCita(
                  widget.idCita,
                  optionEstado!,
                );
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Cita registrada correctamente'),
                    backgroundColor: AppColors.success,
                  ),
                );
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (_) => HomeCitasScreen(usuario: widget.usuario),
                  ),
                  (route) => false,
                );
              } catch (_) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Error al registrar cita'),
                    backgroundColor: AppColors.error,
                  ),
                );
              } finally {
                if (mounted) setState(() => _enviando = false);
              }
            },
      icon: const Icon(Icons.save_outlined),
      label: const Text(
        'Registrar ingreso / salida',
        style: TextStyle(fontSize: 16),
      ),
    );
  }
}
