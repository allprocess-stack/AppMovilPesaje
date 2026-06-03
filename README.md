# App Pesaje — Sistema de Gestion de Bascula

[![Flutter](https://img.shields.io/badge/Flutter-3.9+-02569B?logo=flutter)](https://flutter.dev)
[![Plataformas](https://img.shields.io/badge/Plataformas-Android%20%7C%20iOS%20%7C%20Web%20%7C%20Desktop-blue)]()
[![License](https://img.shields.io/badge/Licencia-Private-red)]()

Aplicacion movil multiplataforma para la gestion del ciclo completo de pesaje de vehiculos en planta industrial. Disenada para operadores de bascula, personal de seguridad y calificadores, permite controlar ingresos, pesadas multiples, asignacion de productos, captura de evidencias fotograficas y generacion de reportes.

---

## Tabla de Contenidos

- [Funcionalidades](#funcionalidades)
- [Roles del Sistema](#roles-del-sistema)
- [Flujo de Pesaje](#flujo-de-pesaje)
- [Stack Tecnologico](#stack-tecnologico)
- [Arquitectura](#arquitectura)
- [Requisitos](#requisitos)
- [Configuracion](#configuracion)
- [Ejecucion](#ejecucion)
- [Construccion](#construccion)
- [API](#api)
- [Estructura del Proyecto](#estructura-del-proyecto)

---

## Funcionalidades

- **Autenticacion por roles** — Login con credenciales. Tres niveles de acceso: administrador, seguridad y calificador.
- **Gestion de Citas** — Registro y busqueda de citas por numero de placa o brevete con autocompletado.
- **Control de Pesaje** — Registro progresivo de hasta 6 pesadas por vehiculo, desde ingreso hasta pesaje completado.
- **Productos e Impurezas** — Asignacion de 1 a 5 productos por registro con porcentaje de impureza cada uno.
- **Captura Fotografica** — Toma de fotos desde camara o seleccion desde galeria, hasta 5 fotos por registro.
- **Visor de Documentos** — Visualizacion integrada de SCTR, brevete, guia de remision, guia de transportista y documentos adicionales.
- **Reportes PDF** — Descarga de comprobantes de cita y registro con opcion de envio directo a WhatsApp.
- **Control de Salida** — Marcacion de salida de planta con registro de novedades.
- **Panel Admin** — Cambio rapido entre vistas de seguridad y calificador sin cerrar sesion.

---

## Roles del Sistema

| Rol            | Permisos                                                           |
|----------------|--------------------------------------------------------------------|
| Admin          | Acceso total. Cambio rapido entre vistas de operador.              |
| Seguridad      | Gestion de citas, control de ingreso/salida, visualizacion basica. |
| Calificador    | Edicion de registros de pesaje, productos, fotos y documentos.     |

---

## Flujo de Pesaje

```
Cita Programada
      |
      v
INGRESO a Planta
      |
      v
PRIMERA PESADA (peso bruto)
      |
      v
SEGUNDA PESADA
      |
      v
TERCERA PESADA
      |
      v
CUARTA PESADA
      |
      v
QUINTA PESADA
      |
      v
SEXTA PESADA
      |
      v
PESAJE COMPLETADO (asignacion de productos)
      |
      v
SALIDA de Planta (peso neto final)
```

---

## Stack Tecnologico

| Capa          | Tecnologia                               |
|---------------|------------------------------------------|
| Frontend      | Flutter 3.9+ / Dart                      |
| Backend       | Flask (Python) — REST API                |
| Estado        | Provider + ChangeNotifier                |
| Visor PDF     | Syncfusion Flutter PDF Viewer            |
| Camara        | camera / image_picker                    |
| Cliente HTTP  | http (Dart)                              |
| Compartir     | share_plus / url_launcher                |
| Autocompletar | flutter_typeahead                        |
| Fechas        | intl (locale es_ES)                      |

---

## Arquitectura

La aplicacion sigue una arquitectura de capas simple:

```
UI (Screens)
    |
    v
Controllers (ChangeNotifier) — logica de estado
    |
    v
Services (HTTP) — comunicacion con API
    |
    v
Flask REST API (backend)
```

Cada pantalla delega la logica de negocio a su Controller correspondiente, el cual utiliza los Services para obtener o enviar datos al backend. Los cambios de estado se notifican a la UI via `notifyListeners()`.

---

## Requisitos

- Flutter SDK `^3.9.2` (stable)
- Dart SDK `^3.9.2`
- Backend Flask corriendo en la red local
- Dispositivo o emulador configurado (Android / iOS / Web / Desktop)

---

## Configuracion

### 1. Clonar el repositorio

```bash
git clone <https://github.com/allprocess-stack/AppMovilPesaje.git>
cd App_Pesaje
```

### 2. Instalar dependencias

```bash
flutter pub get
```

### 3. Configurar URL del backend

Editar `lib/screens/config.dart`:

```dart
class AppConfig {
      <!-- Nombre de tu equipo - para emulador -->
  static String baseUrl = "http://TU_SERVIDOR:5000";
}
```

> Nota: Por defecto apunta a `LAPTOP-NKUNP3JQ:5000` (red local). Cambiar segun el entorno.

### 4. Verificar entorno

```bash
flutter doctor
```

---

## Ejecucion

```bash
# Dispositivo fisico o emulador
flutter run

# Navegador web
flutter run -d chrome --web-renderer html

# Windows Desktop
flutter run -d windows

# Linux Desktop
flutter run -d linux

# macOS Desktop
flutter run -d macos
```

---

## Construccion

```bash
# APK Android
flutter build apk

# AppBundle Android
flutter build appbundle

# Web
flutter build web --web-renderer html

# Windows
flutter build windows

# Linux
flutter build linux

# macOS
flutter build macos
```

---

## API

### Autenticacion

| Metodo | Endpoint       | Descripcion                 |
|--------|----------------|-----------------------------|
| POST   | `/api/login`   | Inicio de sesion de usuario |

### Citas (Appointments)

| Metodo | Endpoint                       | Descripcion                        |
|--------|--------------------------------|------------------------------------|
| GET    | `/api/todo_cita`               | Listar todas las citas             |
| GET    | `/api/obtener_cita/{id}`       | Obtener cita por ID                |
| GET    | `/api/obtener_cita_registro`   | Obtener citas con registros        |
| POST   | `/api/buscar_cita`             | Buscar citas por criterio          |
| POST   | `/api/registrar_cita`          | Crear una nueva cita               |
| POST   | `/api/estado_cita`             | Actualizar estado de una cita      |
| GET    | `/api/citas_por_placa`         | Citas filtradas por placa          |
| GET    | `/api/citas_por_brevete`       | Citas filtradas por brevete        |
| GET    | `/api/autocomplete_placa`      | Sugerencias de placas              |
| GET    | `/api/autocomplete_brevete`    | Sugerencias de brevetes            |

### Registros (Weigh Records)

| Metodo | Endpoint                          | Descripcion                             |
|--------|-----------------------------------|-----------------------------------------|
| GET    | `/api/todo_registro`              | Listar todos los registros              |
| GET    | `/api/obtener_registro/{id}`      | Obtener registro por ID                 |
| POST   | `/api/buscar_registro`            | Buscar registros por criterio           |
| POST   | `/api/actualizar_registro`        | Actualizar registro (multipart)         |
| POST   | `/api/marcar_salida/{id}`         | Marcar salida de vehiculo               |
| GET    | `/api/registros_por_ticket`       | Registros filtrados por ticket          |
| GET    | `/api/autocomplete_ticket`        | Sugerencias de tickets                  |
| GET    | `/api/autocomplete_producto`      | Sugerencias de productos                |

### Productos

| Metodo | Endpoint                   | Descripcion                       |
|--------|----------------------------|-----------------------------------|
| GET    | `/api/obtener_productos`   | Obtener catalogo de productos     |

### Archivos y Documentos

| Metodo | Endpoint                           | Descripcion                            |
|--------|------------------------------------|----------------------------------------|
| POST   | `/uploads`                         | Subir imagenes                         |
| GET    | `/descargar_cita_pdf/{id}`         | Descargar PDF de cita                  |
| GET    | `/descargar_registro_pdf/{id}`     | Descargar PDF de registro              |
| GET    | `/preview_sctr/{id}`               | Vista previa de SCTR                   |
| GET    | `/preview_brevete/{id}`            | Vista previa de brevete                |
| GET    | `/preview_guia_remision/{id}`      | Vista previa de guia de remision       |
| GET    | `/preview_guia_transportista/{id}` | Vista previa de guia de transportista  |
| GET    | `/preview_otro_documento/{id}`     | Vista previa de otro documento         |

---

## Estructura del Proyecto

```
lib/
├── main.dart                            # Punto de entrada y definicion de rutas
│
├── screens/
│   ├── login.dart                       # Pantalla de inicio de sesion
│   ├── home_main_screen.dart            # Dashboard principal con menu
│   ├── home_citas_screen.dart           # Busqueda de citas (placa/brevete)
│   ├── home_register_screen.dart        # Busqueda de registros (ticket)
│   ├── view_cita_screen.dart            # Listado de citas
│   ├── view_citas_out_screen.dart       # Citas con registros asociados
│   ├── view_register_in_screen.dart     # Vehiculos en planta
│   ├── view_register_out_screen.dart    # Vehiculos con salida registrada
│   ├── edit_cita_screen.dart            # Detalle y edicion de cita
│   ├── edit_register_screen.dart        # Edicion completa de registro
│   │
│   ├── controllers/
│   │   ├── edit_cita_controller.dart    # Estado y logica de citas
│   │   └── edit_register_controller.dart # Estado y logica de registros
│   │
│   ├── services/
│   │   ├── citas_service.dart           # Cliente HTTP para citas
│   │   └── register_service.dart        # Cliente HTTP para registros
│   │
│   ├── widgets/
│   │   ├── reusable_estado_view_register.dart  # Lista filtrada por estado
│   │   ├── reusable_fila_info.dart             # Fila label + valor
│   │   ├── reusable_item_app_bar.dart          # Item de menu (reutilizable)
│   │   ├── reusable_view_citas_register.dart   # Lista de citas
│   │   └── widget_app_bar_users.dart           # AppBar con navegacion y roles
│   │
│   ├── admin/
│   │   └── show_admin_menu.dart         # Dialogo de cambio rapido de rol
│   │
│   ├── app_colors.dart                  # Paleta de colores de la app
│   ├── config.dart                      # URL base de la API
│   ├── global.dart                      # Variables globales de sesion
│   └── example.dart                     # Helper para abrir WhatsApp
│
test/
└── widget_test.dart                     # Test por defecto (pendiente)
```

---

## Plataformas Compatibles

Android | iOS | Web | Windows | Linux | macOS

---

## Licencia

Uso interno - Desarrolaldo por Anthony Josue Laura Perez.
