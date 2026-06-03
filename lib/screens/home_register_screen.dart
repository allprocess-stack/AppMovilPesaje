// ignore_for_file: deprecated_member_use, use_build_context_synchronously

import 'dart:async';
import 'package:app2/screens/admin/show_admin_menu.dart';
import 'package:app2/screens/app_colors.dart';
import 'package:app2/screens/config.dart';
import 'package:app2/screens/global.dart';
import 'package:app2/screens/services/register_service.dart';
import 'package:app2/screens/view_register_in_screen.dart';
import 'package:app2/screens/view_register_out_screen.dart';
import 'package:app2/screens/widgets/widget_app_bar_users.dart';
import 'package:flutter/material.dart';

class HomeRegisterScreen extends StatefulWidget {
  final String usuario;

  const HomeRegisterScreen({super.key, required this.usuario});

  @override
  State<HomeRegisterScreen> createState() => _HomeRegisterScreenState();
}

class _HomeRegisterScreenState extends State<HomeRegisterScreen> {
  String searchType = 'Ticket';
  final TextEditingController searchController = TextEditingController();
  bool isLoading = false;
  List<dynamic> ticketSugeridos = [];
  Timer? _debounce;
  String? estadoSeleccionado;
  late final RegisterService registerService;
  final FocusNode searchFocusNode = FocusNode();
  bool bloqueandoAutocomplete = false;

  @override
  void initState() {
    super.initState();
    // Listener para autocompletado de placas
    searchController.addListener(() {
      if (searchType == 'Ticket') {
        _onSearchChanged();
      }
    });
    registerService = RegisterService(AppConfig.baseUrl);
    searchFocusNode.addListener(() {
      setState(() {}); // fuerza redibujado cuando cambia el foco
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    searchFocusNode.dispose();
    searchController.dispose();
    super.dispose();
  }

  // Autocompletado con debounce
  void _onSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {});
    if (searchController.text.isNotEmpty) {
      _buscarTicketSeguridos(searchController.text);
    } else {
      setState(() => ticketSugeridos = []);
    }
  }

  Future<void> _buscarTicketSeguridos(String query) async {
    try {
      final data = await registerService.autocompleteTicket(query);

      setState(() {
        ticketSugeridos = data;
      });
    } catch (e) {
      debugPrint('Error buscando placas: $e');
    }
  }

  Future<void> buscarRegistros(bool esCalificador) async {
    setState(() => isLoading = true);
    List<dynamic> registros = [];
    List<dynamic> citas = [];

    try {
      // SIN TEXTO → TRAER TODOS
      if (searchController.text.isEmpty) {
        registros = await registerService.obtenerTodosRegistro();
      }
      // CON TEXTO → BUSCAR FILTRADO
      else {
        registros = await registerService.buscarRegistros(
          tipo: searchType,
          valor: searchController.text,
        );
      }
      // VALIDAR RESULTADOS
      if (registros.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No se encontraron registros')),
        );
        return;
      }
      // MOSTRAR MENÚ FLOTANTE
      showModalBottomSheet(
        context: context,
        builder: (ctx) {
          return Padding(
            padding: const EdgeInsets.only(
              top: 30,
              bottom: 40,
              left: 20,
              right: 20,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Estados de Registro:',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                ListTile(
                  leading: const Icon(Icons.login, color: Colors.blue),
                  title: const Text(
                    "VEHICULOS EN PLANTA",
                    style: TextStyle(color: Colors.blue),
                  ),
                  tileColor: Colors.blue.withOpacity(0.1),
                  onTap: () {
                    Navigator.pop(ctx);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ViewRegisterInScreen(
                          registros: registros,
                          usuario: widget.usuario,
                          citas: citas,
                        ),
                      ),
                    );
                  },
                ),
                if (!esCalificador) ...[
                  const SizedBox(height: 10),
                  ListTile(
                    leading: const Icon(Icons.exit_to_app, color: Colors.red),
                    title: const Text(
                      "SALIDAS DE PLANTA",
                      style: TextStyle(color: Colors.red),
                    ),
                    tileColor: Colors.red.withOpacity(0.1),
                    onTap: () {
                      Navigator.pop(ctx);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ViewRegisterOutScreen(
                            registros: registros,
                            usuario: widget.usuario,
                            citas: citas,
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ],
            ),
          );
        },
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool esCalificador = tipoUsuarioGlobal == 'calificador';

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: WidgetAppBarUsers(
        title: const Text(
          "Búsqueda de registro",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        tipoUsuario: tipoUsuarioGlobal,
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
            _titulo(),
            const SizedBox(height: 16),
            _bloqueBusqueda(),
            const SizedBox(height: 24),
            _botonBuscar(esCalificador),
          ],
        ),
      ),
    );
  }

  Widget _titulo() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Icon(Icons.manage_search, size: 40, color: Colors.blue),
        SizedBox(height: 8),
        Text(
          'Buscar registro',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 4),
        Text(
          'Ingrese el ticket para ver el detalle',
          style: TextStyle(color: Colors.grey),
        ),
      ],
    );
  }

  Widget _bloqueBusqueda() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Tipo de búsqueda',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            dynamicSearchTextTicket(),
            if (searchType == 'Ticket' && ticketSugeridos.isNotEmpty) ...[
              const SizedBox(height: 8),
              autocompleteTicket(),
            ],
          ],
        ),
      ),
    );
  }

  TextField dynamicSearchTextTicket() {
    return TextField(
      controller: searchController,
      focusNode: searchFocusNode,
      decoration: InputDecoration(
        labelText: 'Número de ticket',
        prefixIcon: const Icon(Icons.confirmation_number),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      textCapitalization: TextCapitalization.characters,
      onChanged: (value) {
        if (bloqueandoAutocomplete) return;
        _buscarTicketSeguridos(value);
      },
    );
  }

  Container autocompleteTicket() {
    return Container(
      constraints: const BoxConstraints(maxHeight: 220),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: ListView.builder(
        itemCount: ticketSugeridos.length,
        itemBuilder: (context, index) {
          final ticket = ticketSugeridos[index];

          return ListTile(
            leading: const Icon(Icons.receipt_long, color: Colors.blue),
            title: Text(ticket),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () async {
              bloqueandoAutocomplete = true;
              searchController.text = ticket;
              ticketSugeridos = [];

              final registros = await registerService.obtenerRegistrosPorTicket(
                ticket,
              );

              if (!context.mounted) return;

              if (registros.isNotEmpty) {
                final estado = registros[0]['Estado'] ?? '';

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => estado == "SALIDA"
                        ? ViewRegisterOutScreen(
                            registros: registros,
                            usuario: widget.usuario,
                            citas: registros,
                          )
                        : ViewRegisterInScreen(
                            registros: registros,
                            usuario: widget.usuario,
                            citas: registros,
                          ),
                  ),
                );
              }
              bloqueandoAutocomplete = false;
            },
          );
        },
      ),
    );
  }

  Widget _botonBuscar(bool esCalificador) {
    return isLoading
        ? const Center(child: CircularProgressIndicator())
        : ElevatedButton.icon(
            onPressed: () {
              FocusScope.of(context).unfocus();
              setState(() => ticketSugeridos.clear());
              buscarRegistros(esCalificador);
            },
            icon: const Icon(Icons.search, fontWeight: FontWeight.bold),
            label: const Text(
              'Buscar registro',
              style: TextStyle(fontSize: 18),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryLight,
              foregroundColor: AppColors.background,
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );
  }
}
