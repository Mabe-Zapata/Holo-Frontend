# Holo · Aplicación móvil

Aplicación del proyecto Holo, desarrollada en Flutter. Este repositorio contiene la interfaz para el paciente, el usuario estándar y el tratante. El backend se encuentra en el repositorio `Holo-project`.

> **Estado:** demostración en desarrollo. Opera con cuentas ficticias. No debe utilizarse con datos de personas reales.

## Requisitos

- Flutter 3.50 o superior (Dart 3.14 o superior)
- Android Studio con un emulador, o un teléfono Android en modo desarrollador
- El backend en ejecución (ver el README del repositorio `Holo-project`)

## Primer paso: generar las carpetas de plataforma

Este repositorio contiene el código de la aplicación (`lib/`, `test/`, `pubspec.yaml`), pero aún no las carpetas de plataforma (`android/`, `web/`). **Una sola persona del equipo** debe generarlas una vez y subirlas al repositorio:

```bash
flutter create --org com.holo --project-name holo_app --platforms android,web .
flutter pub get
flutter analyze
flutter test
```

El comando `flutter create` completa los archivos faltantes sin reemplazar los existentes. Tras verificar que el análisis y las pruebas no reportan errores, las carpetas generadas se integran mediante un pull request (`chore: generar carpetas de plataforma`).

## Puesta en marcha

```bash
flutter pub get
flutter run
```

La aplicación necesita conocer la dirección del backend. Se indica al ejecutar:

| Entorno | Comando |
| --- | --- |
| Emulador de Android | `flutter run` (por defecto usa `http://10.0.2.2:8000`) |
| Teléfono en la misma red | `flutter run --dart-define=API_BASE_URL=http://IP_DEL_EQUIPO:8000` |
| Navegador | `flutter run -d chrome --dart-define=API_BASE_URL=http://localhost:8000` |

Para utilizar un teléfono, el backend debe iniciarse con `--host 0.0.0.0`.

## Comprobaciones

```bash
dart format .     # formato del código
flutter analyze   # análisis estático
flutter test      # pruebas automáticas
```

## Estructura

```text
lib/
  main.dart                 Punto de entrada
  app.dart                  Tema y rutas de navegación
  core/
    api_client.dart         Único punto de comunicación con el backend
    config.dart             URL del backend
    rutas.dart              Nombres de las rutas
    sesion.dart             Cuenta de demostración activa
  features/
    inicio/                 Selección de la cuenta de demostración
    consentimiento/         Consentimiento informado (HU-02)
    chat/                   Conversación con el asistente (HU-05)
    crisis/                 Pantalla fija de crisis (HU-15)
    tratante/               Vista del tratante (HU-18)
test/                       Pruebas de widgets
docs/                       Documentación del proyecto y de la aplicación
```

## Estado de las pantallas

| Pantalla | Estado | Historia |
| --- | --- | --- |
| Inicio (selección de cuenta) | Operativa | |
| Consentimiento | Estructura creada, pendiente de implementar | HU-02 |
| Conversación | Estructura creada, pendiente de implementar | HU-05 |
| Crisis | Estructura creada, pendiente de implementar | HU-15 |
| Vista del tratante | Estructura creada, pendiente de implementar | HU-18 |

## Documentación

- [Documento de trabajo del equipo](docs/documento-de-trabajo-equipo.md)
- [Product backlog](docs/product-backlog.md)
- [Pantallas y navegación](docs/pantallas.md)
- [Consumo de la API](docs/consumo-api.md)
- [Convenios de desarrollo y requisitos de pull request](CONTRIBUTING.md)

## Consideraciones

- La aplicación no contiene claves ni llama directamente al modelo de lenguaje: toda la comunicación pasa por el backend.
- El texto de crisis y los recursos de ayuda provienen del backend y no se modifican en la aplicación.
- Holo no emite diagnósticos, no indica medicación y no sustituye a un profesional ni a un servicio de emergencia.
