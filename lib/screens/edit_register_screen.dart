// ignore_for_file: deprecated_member_use, use_build_context_synchronously

import 'package:app2/screens/admin/show_admin_menu.dart';
import 'package:app2/screens/app_colors.dart';
import 'package:app2/screens/config.dart';
import 'package:app2/screens/controller/edit_cita_controller.dart';
import 'package:app2/screens/controller/edit_register_controller.dart';
import 'package:app2/screens/example.dart';
import 'package:app2/screens/home_register_screen.dart';
import 'package:app2/screens/services/citas_service.dart';
import 'package:app2/screens/services/register_service.dart';
import 'package:app2/screens/global.dart';
import 'package:app2/screens/widgets/reusable_fila_info.dart';
import 'package:app2/screens/widgets/widget_app_bar_users.dart';
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:http/http.dart' as http;
import 'package:share_plus/share_plus.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class EditRegisterScreen extends StatefulWidget {
  final Map<String, dynamic> registro;
  final int idCita;

  final String usuario;

  const EditRegisterScreen({
    super.key,
    required this.registro,
    required this.usuario,
    required this.idCita,
  });

  @override
  State<EditRegisterScreen> createState() => _EditScreenState();
}

class _EditScreenState extends State<EditRegisterScreen> {
  late EditRegisterController controller;
  late EditCitaController controllerCita;

  late final RegisterService registerService;
  late final CitasService citasService;

  TextEditingController? fieldController;
  FocusNode? fieldFocusNode;

  bool bloqueoBack = false;

  @override
  void initState() {
    super.initState();
    registerService = RegisterService(AppConfig.baseUrl);
    citasService = CitasService(AppConfig.baseUrl);
    controller = EditRegisterController(
      registerService,
      registro: widget.registro,
      usuario: tipoUsuarioGlobal,
      onUpdate: () {
        if (mounted) setState(() {});
      },
    );
    controllerCita = EditCitaController(
      citasService,
      onUpdate: () {
        if (mounted) setState(() {});
      },
      idCita: widget.idCita,
    );
    controller.cargarProductos();
  }

  Future<String?> obtenerMimeType(String url) async {
    try {
      final request = http.Request('GET', Uri.parse(url));
      final response = await request.send();

      return response.headers['content-type'];
    } catch (e) {
      debugPrint("Error obteniendo MIME: $e");
      return null;
    }
  }

  // FUNCIONAL
  Future<void> compartirPdfWhatsApp(String filePath) async {
    await SharePlus.instance.share(
      ShareParams(
        text: 'Aquí está tu registro en PDF',
        files: [XFile(filePath, mimeType: 'application/pdf')],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool esAdmin = tipoUsuarioGlobal == 'admin';
    final bool esSeguridad = tipoUsuarioGlobal == 'seguridad';
    final bool esCalificador = tipoUsuarioGlobal == 'calificador';

    return WillPopScope(
      onWillPop: () async => !bloqueoBack,
      child: Scaffold(
        appBar: WidgetAppBarUsers(
          tipoUsuario: tipoUsuarioGlobal,
          title: const Text("Editar Registro"),
          automaticallyImplyLeading: !bloqueoBack,
          child: Text(
            tipoUsuarioGlobal.toUpperCase(),
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        floatingActionButton: esAdmin
            ? FloatingActionButton(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.background,
                child: const Icon(
                  Icons.swap_horiz,
                  fontWeight: FontWeight.bold,
                ),
                onPressed: () => showAdminMenu(context),
              )
            : null,
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (!esAdmin && !esCalificador) warningMessage(),

              _sectionCard(title: 'Registro', child: informationRegistration()),
              const SizedBox(height: 14),
              _sectionCard(
                title: 'Producto',
                child: controller.isLoadingProductos
                    ? const Center(child: CircularProgressIndicator())
                    : generateProductField(esAdmin, esCalificador),
              ),
              const SizedBox(height: 14),
              _sectionCard(
                title: 'Cantidad',
                child: controller.isLoadingCantidad
                    ? const Center(child: CircularProgressIndicator())
                    : fieldQuantity(esAdmin, esCalificador),
              ),
              const SizedBox(height: 14),
              _sectionCard(
                title: 'Impurezas',
                child: generateImpurityFields(esAdmin, esCalificador),
              ),

              if (!esSeguridad) const SizedBox(height: 16),
              _sectionCard(
                title: 'Documentos',
                child: Center(
                  child: Wrap(
                    spacing: 16,
                    runSpacing: 10,
                    alignment: WrapAlignment.center,
                    children: [viewSctr(context), shareButtonDownloadPdf()],
                  ),
                ),
              ),
              if (!esSeguridad) const SizedBox(height: 16),
              if (!esSeguridad)
                _sectionCard(
                  title: 'Fotografía',
                  child: (esCalificador || esAdmin)
                      ? buttonsPhoto()
                      : const Text(
                          'Solo visualización',
                          style: TextStyle(color: Colors.grey),
                        ),
                ),
              const SizedBox(height: 16),
              _sectionCard(
                title: 'Acciones',
                child: Center(
                  child: Wrap(
                    spacing: 14,
                    runSpacing: 10,
                    alignment: WrapAlignment.center,
                    children: [
                      if (!esSeguridad) textFieldObservacion(),
                      if (!esSeguridad)
                        saveChangesButton(context, esCalificador, esAdmin),
                      if (!esCalificador) exitButton(context),
                      exampleWsp(),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionCard({required String title, required Widget child}) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
            ),
            const Divider(height: 20),
            child,
          ],
        ),
      ),
    );
  }

  TextField textFieldObservacion() {
    return TextField(
      controller: controller.observacionController,
      maxLines: 3,
      decoration: InputDecoration(
        labelText: 'Observación',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        prefixIcon: const Icon(Icons.comment),
      ),
    );
  }

  // MENSAJE DE ADVERTENCIA
  Container warningMessage() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange.shade300),
      ),
      child: Row(
        children: [
          Icon(Icons.warning_amber_rounded, color: Colors.orange.shade700),
          const SizedBox(width: 10),
          const Expanded(
            child: Text(
              'Solo modo lectura. Contacte a un administrador para modificar.',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  // COMPARTIR/DESCARGAR PDF REGISTRO
  ElevatedButton shareButtonDownloadPdf() {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      onPressed: () async {
        final path = await citasService.descargarPdfCita(widget.idCita);
        if (path != null) {
          await compartirPdfWhatsApp(path);
        } else {
          debugPrint('El PDF no existe');
        }
      },
      icon: const Icon(Icons.picture_as_pdf_outlined),
      label: const Text('Ver / Compartir PDF'),
    );
  }

  ElevatedButton exampleWsp() {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        backgroundColor: const Color.fromRGBO(37, 211, 102, 1),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      onPressed: () {
        final urlPdf =
            '${AppConfig.baseUrl}/descargar_registro_pdf/${widget.registro['Id']}';

        final mensaje =
            '''*Registro PDF*
                          Copie el enlace y péguelo en la barra de direcciones de su navegador para iniciar la descarga:
                        $urlPdf
                        ''';
        launchWhatsApp(
          phoneNumber: widget.registro['Telefono'],
          message: mensaje,
        );
      },
      icon: const Icon(
        Icons.share,
        color: Color.fromARGB(255, 250, 250, 250),
        fontWeight: FontWeight.bold,
      ),
      label: const Text(
        'Compartir wsp',
        style: TextStyle(color: Color.fromARGB(255, 255, 255, 255)),
      ),
    );
  }

  // MARCAR SALIDA
  ElevatedButton exitButton(BuildContext context) {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.redAccent,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      onPressed: controller.isSalida || controller.isSaving
          ? null
          : () async {
              final mensaje = await controller.marcarSalida();

              if (!context.mounted) return;

              if (mensaje != null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(mensaje),
                    backgroundColor: Colors.green,
                  ),
                );
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (_) => HomeRegisterScreen(usuario: widget.usuario),
                  ),
                  (route) => false,
                );
              } else {
                setState(() {
                  bloqueoBack = false;
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Error al marcar salida"),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
      icon: const Icon(
        Icons.exit_to_app_outlined,
        color: Color.fromARGB(255, 250, 250, 250),
        fontWeight: FontWeight.bold,
      ),
      label: const Text(
        'Marcar Salida',
        style: TextStyle(color: Color.fromARGB(255, 255, 255, 255)),
      ),
    );
  }

  // TOMAR/SELECCIONAR FOTO
  Center buttonsPhoto() {
    return Center(
      child: Wrap(
        spacing: 16,
        runSpacing: 12,
        alignment: WrapAlignment.center,
        children: [
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () {
              controller.indiceFotoSeleccionada ??=
                  controller.siguienteIndiceDisponible() ?? 0;
              controller.tomarFoto();
            },
            icon: const Icon(Icons.camera_alt_outlined),
            label: const Text('Cámara'),
          ),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () {
              controller.indiceFotoSeleccionada ??=
                  controller.siguienteIndiceDisponible() ?? 0;
              controller.seleccionarImagen();
            },
            icon: const Icon(Icons.photo_library_outlined),
            label: const Text('Galería'),
          ),
        ],
      ),
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

  // MUESTRA SCTR(showDialog)
  void showSctrDialog({required BuildContext context, required String url}) {
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
                    const Expanded(
                      child: Text(
                        "SCTR de la cita",
                        style: TextStyle(
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
                        onDocumentLoadFailed: (details) {
                          Navigator.pop(context);
                          showSnack(
                            context,
                            "No se pudo cargar el PDF del SCTR",
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
                            "No se pudo cargar la imagen del SCTR",
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

  // VISTA SCTR
  ElevatedButton viewSctr(BuildContext context) {
    return ElevatedButton.icon(
      icon: const Icon(Icons.visibility_outlined),
      label: const Text("Ver SCTR"),
      onPressed: () async {
        try {
          final url = controllerCita.obtenerUrlSctrParaVista(widget.idCita);

          if (url == null || url.isEmpty) {
            showSnack(context, "No hay registro de SCTR", color: Colors.red);
            return;
          }

          // VALIDACIÓN REAL DEL ENDPOINT
          final response = await http.get(Uri.parse(url));

          if (response.statusCode != 200) {
            showSnack(
              context,
              "No existe SCTR para esta cita",
              color: Colors.red,
            );
            return;
          }

          // AQUÍ ABRE EL VISOR
          showSctrDialog(context: context, url: url);
        } catch (e, s) {
          debugPrint("Error al abrir SCTR: $e\n$s");
          showSnack(
            context,
            "Error inesperado al abrir el SCTR",
            color: Colors.red,
          );
        }
      },
    );
  }

  // BOTON GUARDAR CAMBIOS
  ElevatedButton saveChangesButton(
    BuildContext context,
    bool esAdmin,
    bool esCalificador,
  ) {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primaryLight,
        foregroundColor: AppColors.background,
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      onPressed: controller.isSalida
          ? null
          : () async {
              final mensaje = await controller.guardarCambios();
              if (!mounted) return;

              if (mensaje != null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(mensaje),
                    backgroundColor: Colors.green,
                  ),
                );
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (_) => HomeRegisterScreen(usuario: widget.usuario),
                  ),
                  (route) => false,
                );
              } else {
                setState(() {
                  bloqueoBack = false;
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Error al guardar los cambios"),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
      icon: const Icon(Icons.save_outlined),
      label: const Text('Guardar Cambios'),
    );
  }

  // CAMPO CANTIDAD(COMBOBOX)
  Widget fieldQuantity(bool esAdmin, bool esCalificador) {
    if (!(esAdmin || esCalificador)) {
      return const SizedBox.shrink();
    }

    return DropdownButtonFormField<int>(
      value: controller.cantidadSeleccionada,
      decoration: InputDecoration(
        labelText: 'Cantidad de productos',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        prefixIcon: const Icon(Icons.format_list_numbered),
        filled: true,
        fillColor: Colors.grey.shade50,
      ),
      onChanged: (value) {
        setState(() {
          controller.cantidadSeleccionada = value!;
        });
      },
      items: controller.opcionesCantidad.map((cantidad) {
        return DropdownMenuItem<int>(
          value: cantidad,
          child: Text(
            cantidad.toString(),
            style: const TextStyle(fontSize: 16),
          ),
        );
      }).toList(),
    );
  }

  // CAMPOS PRODUCTOS
  Widget generateProductField(bool esAdmin, bool esCalificador) {
    if (!(esAdmin || esCalificador)) {
      return const SizedBox.shrink();
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(controller.cantidadSeleccionada, (index) {
        TextEditingController? fieldController;
        FocusNode? fieldFocusNode;

        return Card(
          elevation: 2,
          margin: const EdgeInsets.only(top: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: TypeAheadField<String>(
              debounceDuration: const Duration(milliseconds: 300),

              suggestionsCallback: (search) async {
                if (search.isEmpty) return [];
                return await controller.autocompleteProducto(search);
              },

              itemBuilder: (context, suggestion) {
                return ListTile(
                  leading: const Icon(Icons.inventory_2_outlined),
                  title: Text(suggestion),
                );
              },

              onSelected: (suggestion) {
                fieldController?.text = suggestion;
                controller.cambiarProducto(index, suggestion);
                fieldFocusNode?.unfocus();
              },

              emptyBuilder: (context) => const Padding(
                padding: EdgeInsets.all(10),
                child: Text("No hay coincidencias"),
              ),

              builder: (context, textController, focusNode) {
                fieldController = textController;
                fieldFocusNode = focusNode;

                final valorBD = controller.productosSeleccionados[index];
                if (valorBD != null && textController.text.isEmpty) {
                  textController.text = valorBD;
                }

                return TextField(
                  controller: textController,
                  focusNode: focusNode,
                  onChanged: (value) {
                    controller.cambiarProducto(index, value);
                  },
                  decoration: InputDecoration(
                    labelText: 'Producto ${index + 1}',
                    prefixIcon: const Icon(Icons.inventory_outlined),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.grey.shade50,
                  ),
                );
              },
            ),
          ),
        );
      }),
    );
  }

  // CAMPOS IMPUREZAS
  Widget generateImpurityFields(bool esAdmin, bool esCalificador) {
    if (!(esAdmin || esCalificador)) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(controller.cantidadSeleccionada, (index) {
        return Card(
          margin: const EdgeInsets.only(top: 10),
          color: Colors.orange.shade50,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: controller.impurezasControllers[index],
              onChanged: (value) {
                controller.cambiarImpureza(index, value);
              },
              decoration: InputDecoration(
                labelText: 'Impureza ${index + 1}',
                prefixIcon: const Icon(Icons.warning_amber_outlined),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        );
      }),
    );
  }

  // INFORMACION REGISTRO
  Card informationRegistration() {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.assignment_outlined, color: Colors.blue),
                SizedBox(width: 8),
                Text(
                  'Información del Registro',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const Divider(height: 24),
            ReusableFilaInfo(
              etiqueta: 'Ticket: ',
              valor: '${controller.registroActual['Ticket'] ?? 'N/A'}',
            ),
            ReusableFilaInfo(
              etiqueta: 'Placa: ',
              valor: '${controllerCita.citaActual['Placa'] ?? 'N/A'}',
            ),
            ReusableFilaInfo(
              etiqueta: 'Transportista: ',
              valor: '${controllerCita.citaActual['Transportista'] ?? 'N/A'}',
            ),
            ReusableFilaInfo(
              etiqueta: 'Estado: ',
              valor: '${controller.registroActual['Estado']}',
            ),
          ],
        ),
      ),
    );
  }
}
