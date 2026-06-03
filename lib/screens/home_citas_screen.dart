// ignore_for_file: use_build_context_synchronously

import 'dart:async';

import 'package:app2/screens/admin/show_admin_menu.dart';
import 'package:app2/screens/app_colors.dart';
import 'package:app2/screens/config.dart';
import 'package:app2/screens/global.dart';
import 'package:app2/screens/services/citas_service.dart';
import 'package:app2/screens/services/register_service.dart';
import 'package:app2/screens/view_cita_screen.dart';
import 'package:app2/screens/view_citas_out_screen.dart';
import 'package:app2/screens/widgets/widget_app_bar_users.dart';
import 'package:flutter/material.dart';

enum SearchType { placa, brevete }

class HomeCitasScreen extends StatefulWidget {
  final String usuario;
  const HomeCitasScreen({super.key, required this.usuario});

  @override
  State<HomeCitasScreen> createState() => _HomeCitasScreenState();
}

class _HomeCitasScreenState extends State<HomeCitasScreen> {
  bool isLoading = false;
  final TextEditingController searchController = TextEditingController();
  SearchType searchType = SearchType.placa;
  late final CitasService citasService;
  late final RegisterService registerService;
  List<dynamic> placasSugeridas = [];
  List<dynamic> brevetesSugeridos = [];

  List<dynamic> listaCitas = [];
  Timer? _debounce;
  bool seleccionandoPlaca = false;
  bool bloqueandoAutocomplete = false;

  @override
  void initState() {
    super.initState();
    citasService = CitasService(AppConfig.baseUrl);
    registerService = RegisterService(AppConfig.baseUrl);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    searchController.dispose();
    super.dispose();
  }

  void onSearchChanged(String value) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      if (value.isEmpty) {
        setState(() {
          placasSugeridas.clear();
          brevetesSugeridos.clear();
        });
        return;
      }
      if (searchType == SearchType.placa) {
        _buscarPlacasSugeridas(value);
      } else {
        _buscarBrevetesSugeridos(value);
      }
    });
  }

  Future<void> _buscarPlacasSugeridas(String query) async {
    try {
      final data = await citasService.autocompletePlacas(query);
      setState(() => placasSugeridas = data);
    } catch (e) {
      debugPrint('Error buscando placas: $e');
    }
  }

  Future<void> _buscarBrevetesSugeridos(String query) async {
    try {
      final data = await citasService.autocompleteBrevetes(query);
      setState(() => brevetesSugeridos = data);
    } catch (e) {
      debugPrint('Error buscando brevetes: $e');
    }
  }

  // CONVIERTE EL 'ENUM' EN STRING
  String get searchTypeValue {
    switch (searchType) {
      case SearchType.placa:
        return 'Placa';
      case SearchType.brevete:
        return 'Brevete';
    }
  }

  Future<void> buscarCitas() async {
    setState(() => isLoading = true);

    List<dynamic> citas = [];

    try {
      // SIN TEXT -> TRAE TODOS
      if (searchController.text.isEmpty) {
        citas = await citasService.obtenerTodasCitas();
      }
      // CON TEXTO -> BUSCAR FILTRADO
      else {
        citas = await citasService.buscarCitas(
          tipo: searchTypeValue,
          valor: searchController.text,
        );
      }
      if (citas.isEmpty) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('No hay citas')));
        return;
      }
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ViewCitaScreen(citas: citas, usuario: widget.usuario),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  Future<void> buscarCitasRegistros() async {
    setState(() => isLoading = true);

    List<dynamic> citasRegistro = [];
    List<dynamic> registros = [];

    try {
      // SIN TEXT -> TRAE TODOS
      if (searchController.text.isEmpty) {
        citasRegistro = await citasService.obtenerCitaRegistro();
      }
      // CON TEXTO -> BUSCAR FILTRADO
      else {
        citasRegistro = await citasService.buscarCitas(
          tipo: searchTypeValue,
          valor: searchController.text,
        );
      }

      registros = await registerService.obtenerTodosRegistro();

      if (citasRegistro.isEmpty) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('No hay registros')));
        return;
      }
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ViewCitasOutScreen(
            citas: citasRegistro,
            usuario: widget.usuario,
            registros: registros,
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: WidgetAppBarUsers(
        tipoUsuario: tipoUsuarioGlobal,
        title: const Text(
          'Búsqueda de Citas',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        automaticallyImplyLeading: true,
        child: Text(
          tipoUsuarioGlobal.toUpperCase(),
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
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
      body: Padding(
        padding: const EdgeInsets.only(left: 18, right: 18, top: 12),
        child: SingleChildScrollView(
          child: Wrap(
            runSpacing: 26,
            children: [
              // TÍTULO
              const Center(
                child: Text(
                  'Buscar por',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),

              // SELECTOR PLACA / BREVETE
              optionsFindAppointment(),

              // INPUT + AUTOCOMPLETE
              Wrap(
                runSpacing: 4,
                children: [
                  dynamicSearchText(),

                  if (searchType == SearchType.placa &&
                      placasSugeridas.isNotEmpty)
                    autocompletePlates(),

                  if (searchType == SearchType.brevete &&
                      brevetesSugeridos.isNotEmpty)
                    autocompleteDrivingLicenses(),
                ],
              ),

              // BOTONES
              Center(child: searchAppointmentButton()),
              Center(child: searchAppointmentButtonRegister()),

              // MENSAJE INFORMATIVO
              suggestionMessage(),
            ],
          ),
        ),
      ),
    );
  }

  // TEXTO DINAMICO DE BUSCADOR
  TextField dynamicSearchText() {
    return TextField(
      controller: searchController,
      decoration: InputDecoration(
        labelText: 'Ingrese el $searchTypeValue',
        labelStyle: const TextStyle(color: AppColors.textSecondary),
        prefixIcon: Icon(
          searchType == SearchType.placa ? Icons.directions_car : Icons.badge,
          color: AppColors.primary,
        ),
        filled: true,
        fillColor: AppColors.surface,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary),
        ),
      ),
      textCapitalization: TextCapitalization.characters,
      onChanged: onSearchChanged,
    );
  }

  // MENSAJE DE BUSCADOR PLACA/BREVETE
  Container suggestionMessage() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.accent.withOpacity(0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.accent),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline, color: AppColors.info),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              searchType == SearchType.placa
                  ? 'Escriba para ver sugerencias de Placa'
                  : 'Ingrese el número de Brevete',
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // BOTON BUSCRA CITA
  ElevatedButton searchAppointmentButton() {
    return ElevatedButton.icon(
      onPressed: isLoading ? null : buscarCitas,
      icon: const Icon(Icons.search),
      label: const Text('Buscar'),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        minimumSize: const Size(double.infinity, 50),
        textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  // BOTON BUSCAR CITA
  ElevatedButton searchAppointmentButtonRegister() {
    return ElevatedButton.icon(
      onPressed: isLoading ? null : buscarCitasRegistros,
      icon: const Icon(Icons.search),
      label: const Text('Ver citas Registro'),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primaryLight,
        foregroundColor: Colors.white,
        minimumSize: const Size(double.infinity, 50),
        textStyle: const TextStyle(fontSize: 18),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  // SUGERENCIAS/AUTOCOMPLETADO DE PLACAS
  Container autocompletePlates() {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      decoration: BoxDecoration(
        color: AppColors.background,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListView.builder(
        shrinkWrap: true,
        itemCount: placasSugeridas.length,
        itemBuilder: (context, index) {
          final placa = placasSugeridas[index];

          return ListTile(
            leading: const Icon(Icons.directions_car, color: AppColors.primary),
            title: Text(
              placa,
              style: const TextStyle(color: AppColors.textPrimary),
            ),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () async {
              bloqueandoAutocomplete = true;
              placasSugeridas = [];
              searchController.text = placa;

              final citas = await citasService.obtenerCitasPorPlaca(placa);

              if (!context.mounted) return;

              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      ViewCitaScreen(usuario: widget.usuario, citas: citas),
                ),
              );
              bloqueandoAutocomplete = false;
            },
          );
        },
      ),
    );
  }

  // SUGERENCIAS/AUTOCOMPLETADO DE BREVETES
  Container autocompleteDrivingLicenses() {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      decoration: BoxDecoration(
        color: AppColors.background,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListView.builder(
        shrinkWrap: true,
        itemCount: brevetesSugeridos.length,
        itemBuilder: (context, index) {
          final brevete = brevetesSugeridos[index];

          return ListTile(
            leading: const Icon(Icons.badge, color: AppColors.primary),
            title: Text(
              brevete,
              style: const TextStyle(color: AppColors.textPrimary),
            ),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () async {
              bloqueandoAutocomplete = true;
              brevetesSugeridos = [];
              searchController.text = brevete;

              final citas = await citasService.obtenerCitasPorBrevete(brevete);

              if (!context.mounted) return;

              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      ViewCitaScreen(usuario: widget.usuario, citas: citas),
                ),
              );
              bloqueandoAutocomplete = false;
            },
          );
        },
      ),
    );
  }

  // BUSCAR POR PLACA/BREVETE
  Row optionsFindAppointment() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () {
              setState(() {
                searchType = SearchType.placa;
                searchController.clear();
                placasSugeridas.clear();
              });
            },
            icon: const Icon(Icons.directions_car),
            label: const Text('Placa'),
            style: ElevatedButton.styleFrom(
              backgroundColor: searchType == SearchType.placa
                  ? AppColors.primary
                  : AppColors.surface,
              foregroundColor: searchType == SearchType.placa
                  ? Colors.white
                  : AppColors.textPrimary,
              minimumSize: const Size(double.infinity, 50),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () {
              setState(() {
                searchType = SearchType.brevete;
                searchController.clear();
                brevetesSugeridos.clear();
              });
            },
            icon: const Icon(Icons.badge),
            label: const Text('Brevete'),
            style: ElevatedButton.styleFrom(
              backgroundColor: searchType == SearchType.brevete
                  ? AppColors.primary
                  : AppColors.surface,
              foregroundColor: searchType == SearchType.brevete
                  ? Colors.white
                  : AppColors.textPrimary,
              minimumSize: const Size(double.infinity, 50),
            ),
          ),
        ),
      ],
    );
  }
}
