import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/register_service.dart';

enum Operacion { carga, descarga }

class EditRegisterController extends ChangeNotifier {
  final RegisterService registerService;
  final VoidCallback onUpdate;

  EditRegisterController(
    this.registerService, {
    required Map<String, dynamic> registro,
    required String usuario,
    required this.onUpdate,
  }) {
    // Inicializar valores
    cargarValoresIniciales(registro, usuario);
  }

  TextEditingController observacionController = TextEditingController();

  // ESTADOS / VARIABLES
  bool isLoading = false;
  bool isLoadingProductos = false;
  bool isLoadingCantidad = false;
  bool isSaving = false;
  bool isPickingImage = false;

  Map<String, dynamic> registroActual = {};
  List<dynamic> listaProductos = [];
  List<String?> productosSeleccionados = List.filled(5, null);
  List<int> opcionesCantidad = [1, 2, 3, 4, 5];

  List<String?> impurezasSeleccionadas = List.filled(5, null);

  int cantidadSeleccionada = 1;
  String estado = '';
  bool isSalida = false;

  String tipoUsuario = "Seguridad"; // Se setea desde la UI
  File? imagenLocal;
  List<File?> imagenesLocales = List.filled(5, null);

  int fotosGuardadas = 0;
  int estadoIndex = 0;
  int? indiceFotoSeleccionada; // 0–4

  List<String> operacion = ["Carga", "Descarga"];

  // Contadores reales
  int cargasRealizadas = 0;
  int descargasRealizadas = 0;
  int contadorOperaciones = 0;

  bool bloqueoNavegacion = false;

  @override
  void dispose() {
    for (final c in productosControllers) {
      c.dispose();
    }
    for (final im in impurezasControllers) {
      im.dispose();
    }
    observacionController.dispose();
    super.dispose();
  }

  // CARGAR PRODUCTOS
  Future<void> cargarProductos() async {
    isLoadingProductos = true;
    onUpdate();

    try {
      listaProductos = await registerService.cargarProductos();
      isLoadingProductos = false;
      isLoadingCantidad = false;
    } catch (e) {
      listaProductos = [];
      isLoadingProductos = false;
      isLoadingCantidad = false;
      debugPrint("Error al cargar productos: $e");
    }
    onUpdate();
  }

  bool puedeAgregarImagen() {
    final nuevasFotos = imagenesLocales.where((f) => f != null).length;

    return (fotosGuardadas + nuevasFotos) < cantidadSeleccionada;
  }

  int? siguienteIndiceDisponible() {
    for (int i = fotosGuardadas; i < imagenesLocales.length; i++) {
      if (imagenesLocales[i] == null) return i;
    }
    return null;
  }

  // TOMAR FOTO
  Future<void> tomarFoto() async {
    if (isPickingImage) return;

    final index = siguienteIndiceDisponible();
    if (index == null) return; // ya no hay espacio

    isPickingImage = true;
    notifyListeners();

    try {
      final picker = ImagePicker();
      final photo = await picker.pickImage(source: ImageSource.camera);

      if (photo != null) {
        imagenesLocales[index] = File(photo.path);
        debugPrint("Foto guardada en índice: $index");
      }
    } finally {
      isPickingImage = false;
      notifyListeners();
    }
  }

  // GALERÍA / ARCHIVOS
  Future<void> seleccionarImagen() async {
    if (isPickingImage) return;

    final index = siguienteIndiceDisponible();
    if (index == null) return;

    isPickingImage = true;
    notifyListeners();

    try {
      final picker = ImagePicker();
      final photo = await picker.pickImage(source: ImageSource.gallery);

      if (photo != null) {
        imagenesLocales[index] = File(photo.path);
        debugPrint("Imagen guardada en índice: $index");
      }
    } finally {
      isPickingImage = false;
      notifyListeners();
    }
  }

  String producto(int i) {
    if (i >= productosSeleccionados.length) return '';
    return productosSeleccionados[i] ?? '';
  }

  String impureza(int i) {
    if (i >= impurezasSeleccionadas.length) return '';
    return impurezasSeleccionadas[i] ?? '';
  }

  // GUARDAR CAMBIOS
  Future<String?> guardarCambios() async {
    if (isSaving) return null;

    isSaving = true;
    notifyListeners();
    try {
      // avanzarEstado();
      await registerService.actualizarRegistro(
        fields: {
          'id': registroActual['Id'].toString(),
          'operacion': getOperacionParaBD(),
          'operaciones_realizadas': contadorOperaciones.toString(),
          'cantidad': cantidadSeleccionada.toString(),
          'usuario': tipoUsuario,
          'producto1': producto(0),
          'producto2': producto(1),
          'producto3': producto(2),
          'producto4': producto(3),
          'producto5': producto(4),
          'impureza1': impureza(0),
          'impureza2': impureza(1),
          'impureza3': impureza(2),
          'impureza4': impureza(3),
          'impureza5': impureza(4),
          'observacion': observacionController.text.trim(),
        },
        imagenes: imagenesLocales,
      );

      for (int i = 0; i < imagenesLocales.length; i++) {
        imagenesLocales[i] = null;
      }

      await actualizarDatosRegistro();

      return "Registro actualizado correctamente";
    } catch (e) {
      debugPrint("Error al guardar cambios: $e");
      return null;
    } finally {
      isSaving = false;
      notifyListeners();
    }
  }

  // Inicializar valores desde la UI
  void cargarValoresIniciales(Map<String, dynamic> registro, String tipoUser) {
    registroActual = registro;
    tipoUsuario = tipoUser;

    cambiarEstado(registro["Estado"] ?? "");

    cantidadSeleccionada = int.tryParse(registro["Cantidad"].toString()) ?? 1;

    contadorOperaciones =
        int.tryParse(registro['OperacionesRealizadas']?.toString() ?? '0') ?? 0;

    productosSeleccionados = List.generate(
      5,
      (i) => registro["Producto${i + 1}"],
    );

    impurezasSeleccionadas = List.generate(
      5,
      (i) => registro["Impureza${i + 1}"],
    );
    observacionController.text = registro["Observacion"] ?? '';

    fotosGuardadas = 0;
    for (int i = 1; i <= 5; i++) {
      if (registro["Foto$i"] != null &&
          registro["Foto$i"].toString().isNotEmpty) {
        fotosGuardadas++;
      }
    }

    cargarImpurezasEnCampos(impurezasSeleccionadas);
    cargarProductosEnCampos(productosSeleccionados);

    notifyListeners();
  }

  // ACTUALIZAR REGISTRO DESDE BD
  Future<void> actualizarDatosRegistro() async {
    try {
      final data = await registerService.obtenerRegistro(registroActual['Id']);

      registroActual = data;

      cantidadSeleccionada = int.tryParse(data["Cantidad"].toString()) ?? 1;

      contadorOperaciones =
          int.tryParse(data['OperacionesRealizadas']?.toString() ?? '0') ?? 0;

      productosSeleccionados = List.generate(
        5,
        (i) => data["Producto${i + 1}"],
      );
      impurezasSeleccionadas = List.generate(
        5,
        (i) => data["Impureza${i + 1}"],
      );
      cargarImpurezasEnCampos(impurezasSeleccionadas);
      cargarProductosEnCampos(productosSeleccionados);
    } catch (e) {
      debugPrint("Error en actualizarDatosRegistro: $e");
    }
    notifyListeners();
  }

  // CAMBIAR ESTADO
  void cambiarEstado(String nuevoEstado) {
    estado = nuevoEstado.toUpperCase();
    isSalida = estado == "SALIDA";
  }

  Future<String?> marcarSalida() async {
    if (isSaving || isSalida) return null;

    isSaving = true;
    notifyListeners();

    try {
      final ok = await registerService.marcarSalida(registroActual['Id']);
      if (!ok) return null;

      cambiarEstado("SALIDA");
      await actualizarDatosRegistro();

      return "Salida marcada correctamente";
    } catch (e) {
      debugPrint("Error marcarSalida: $e");
      return null;
    } finally {
      isSaving = false;
      notifyListeners();
    }
  }

  Future<List<String>> autocompleteProducto(String search) async {
    if (search.isEmpty) return [];

    try {
      return await registerService.autocompleteProducto(search);
    } catch (e) {
      debugPrint("Error en autocompleteProducto: $e");
      return [];
    }
  }

  final List<TextEditingController> productosControllers = List.generate(
    5,
    (_) => TextEditingController(),
  );

  final List<TextEditingController> impurezasControllers = List.generate(
    5,
    (_) => TextEditingController(),
  );

  // CAMBIAR PRODUCTO
  void cambiarProducto(int index, String? producto) {
    productosSeleccionados[index] = producto;
    notifyListeners();
  }

  void cambiarImpureza(int index, String? impureza) {
    impurezasSeleccionadas[index] = impureza;
    notifyListeners();
  }

  // CAMBIAR CANTIDAD
  void cambiarCantidad(int cantidad) {
    cantidadSeleccionada = cantidad;

    // Si sobran imágenes, las eliminamos
    if (imagenesLocales.length > cantidadSeleccionada) {
      imagenesLocales = imagenesLocales.sublist(0, cantidadSeleccionada);
    }

    notifyListeners();
  }

  void cargarProductosEnCampos(List<String?> productos) {
    for (int i = 0; i < productosControllers.length; i++) {
      productosControllers[i].text = productos[i] ?? '';
    }
    notifyListeners();
  }

  void cargarImpurezasEnCampos(List<String?> impurezas) {
    for (int i = 0; i < impurezasControllers.length; i++) {
      impurezasControllers[i].text = impurezas[i] ?? '';
    }
    notifyListeners();
  }

  // OPERACION
  /* String? get estadoOperacionTexto {
    if (cargasRealizadas == 0 && descargasRealizadas == 0) {
      return null; // Aún no se inició
    }
    if (descargasRealizadas >= cantidadSeleccionada) {
      return "DESCARGA";
    }
    return "CARGA";
  }*/

  // bool get puedeCargar => cargasRealizadas < cantidadSeleccionada;

  /*void realizarCarga() {
    if (!puedeCargar) return;

    cargasRealizadas++;
    notifyListeners();
  }*/

  // bool get puedeDescargar => descargasRealizadas < cargasRealizadas;

  /* void realizarDescarga() {
    if (!puedeDescargar) return;

    descargasRealizadas++;
    notifyListeners();
  }*/

  // Obtiene de la BD el valor OPERACION
  String getOperacionParaBD() {
    return getOperacionActual() == Operacion.carga ? "CARGA" : "DESCARGA";
  }

  Operacion getOperacionActual() {
    return contadorOperaciones % 2 == 0 ? Operacion.carga : Operacion.descarga;
  }

  /* bool get operacionesCompletadas =>
      contadorOperaciones >= cantidadSeleccionada * 2;*/

  // Operaciones realizadas
  /* Future<void> ejecutarOperacion(BuildContext context) async {
    if (operacionesCompletadas) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Operaciones completadas')));
      return;
    }

    final operacion = getOperacionActual(); // antes de incrementar

    contadorOperaciones++;

    await guardarOperacionEnBD(operacion);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '${operacion.name.toUpperCase()} realizada '
          '($contadorOperaciones / ${cantidadSeleccionada * 2})',
        ),
        duration: const Duration(seconds: 1),
      ),
    );

    notifyListeners();
  }

  Future<void> guardarOperacionEnBD(Operacion operacion) async {
    await registerService.actualizarRegistro(
      fields: {
        'Id': registroActual['Id'].toString(),
        'Operacion': operacion.name.toUpperCase(),
      },
      imagenes: const [],
    );
  }*/
}
