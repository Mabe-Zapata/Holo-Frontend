import 'api_client.dart';

/// Respuestas de demostración basadas en los contratos de `odds/`.
/// Cada petición devuelve un ejemplo independiente.
class ApiSimulado implements ApiClient {
  ApiSimulado({required this.usuarioId});

  /// Entrada de prueba para mostrar la pantalla de crisis.
  static const String mensajeCrisis = '[simular crisis]';
  static const String _fecha = '2026-11-12T15:30:00Z';
  static const String _ejemploChat = 'Estoy muy estresada';

  @override
  final String usuarioId;

  @override
  Future<dynamic> get(String ruta) async {
    switch (ruta) {
      case '/salud':
        return {'estado': 'ok', 'version': '0.1.0'};
      case '/chat/historial':
        _validarCuenta(tratante: false);
        return [
          {
            'autor': 'usuario',
            'texto': _ejemploChat,
            'fecha': '2026-11-12T15:31:00Z',
            'tipo': 'mensaje',
          },
          {
            'autor': 'asistente',
            'texto': '[eco] $_ejemploChat',
            'fecha': '2026-11-12T15:31:01Z',
            'tipo': 'respuesta',
          },
        ];
      case '/tratante/paciente':
        _validarCuenta(tratante: true);
        return {
          'paciente_id': 'luis',
          'nombre': 'Luis',
          'alertas': [
            {
              'nivel': 'alto',
              'mensaje': 'Texto del mensaje que originó la alerta',
              'fecha': '2026-11-12T15:40:00Z',
            },
          ],
          'resumen': null,
        };
      default:
        throw ApiException(404, 'Ruta simulada no disponible');
    }
  }

  @override
  Future<dynamic> post(String ruta, [Map<String, dynamic>? cuerpo]) async {
    switch (ruta) {
      case '/consentimiento':
        _validarCuenta();
        final mayorDeEdad = cuerpo?['mayor_de_edad'];
        final acepta = cuerpo?['acepta'];
        if (mayorDeEdad is! bool || acepta is! bool) {
          throw ApiException(422, 'Envía ambos campos como valores booleanos');
        }
        if (!mayorDeEdad || !acepta) {
          throw ApiException(
            400,
            'Se requiere la aceptación del consentimiento',
          );
        }
        return {'usuario_id': usuarioId, 'aceptado_en': _fecha};
      case '/chat':
        _validarCuenta(tratante: false);
        final texto = cuerpo?['texto'];
        if (texto is! String ||
            texto.trim().isEmpty ||
            texto.runes.length > 2000) {
          throw ApiException(
            422,
            'El mensaje debe tener entre 1 y 2000 caracteres',
          );
        }
        if (texto.trim() == mensajeCrisis) {
          return _respuestaCrisis();
        }
        return {
          'tipo': 'respuesta',
          'texto': '[eco] ${texto.trim()}',
          'riesgo': 'sin_riesgo',
          'fragmentos': <String>[],
          'recursos': <Map<String, String>>[],
        };
      case '/resumen':
        _validarCuenta(tratante: true);
        return {
          'paciente_id': 'luis',
          'desde': '2026-11-05',
          'hasta': '2026-11-12',
          'generado_en': '2026-11-12T16:00:00Z',
          'generado_por_ia': true,
          'temas': ['Carga académica', 'Dificultad para dormir'],
          'hechos': [
            {
              'fecha': '2026-11-07',
              'descripcion': 'Relató que no pudo dormir antes de un examen.',
            },
          ],
          'patrones': [
            'El malestar aumenta en los días previos a una entrega.',
          ],
          'alertas': <Map<String, String>>[],
        };
      default:
        throw ApiException(404, 'Ruta simulada no disponible');
    }
  }

  void _validarCuenta({bool? tratante}) {
    if (!const {'ana', 'luis', 'tratante'}.contains(usuarioId)) {
      throw ApiException(401, 'Cuenta desconocida');
    }
    if (tratante != null && tratante != (usuarioId == 'tratante')) {
      throw ApiException(403, 'La cuenta no tiene acceso a esta ruta');
    }
  }

  Map<String, dynamic> _respuestaCrisis() => {
        'tipo': 'crisis',
        'texto':
            '[Texto provisional, pendiente de aprobación de la especialista] ...',
        'riesgo': 'alto',
        'fragmentos': <String>[],
        'recursos': [
          {
            'nombre': 'ECU 911',
            'telefono': '911',
            'descripcion': 'Emergencias'
          },
          {
            'nombre': 'Línea 171, opción 6',
            'telefono': '171',
            'descripcion': 'Salud mental, Ministerio de Salud Pública',
          },
        ],
      };
}
