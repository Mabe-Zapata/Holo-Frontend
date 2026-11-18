/// Configuración de la aplicación.
///
/// La URL del backend se define al ejecutar:
/// `flutter run --dart-define=API_BASE_URL=http://192.168.1.10:8000`
///
/// El valor por defecto corresponde al emulador de Android, donde
/// `10.0.2.2` apunta al equipo que ejecuta el backend.
class Config {
  static const bool usarSimulacion = bool.fromEnvironment('USAR_SIMULACION');

  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://10.0.2.2:8000',
  );
}
