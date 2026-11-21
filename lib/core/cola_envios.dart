import 'dart:convert';
import 'dart:math';

import 'package:shared_preferences/shared_preferences.dart';

/// Mensaje que el servidor aún no confirmó. Se reenvía con el mismo [id]:
/// el backend no duplica el mensaje ni la alerta si llega dos veces (HU-16).
class EnvioPendiente {
  const EnvioPendiente({required this.id, required this.texto});

  factory EnvioPendiente.desde(Map<String, dynamic> datos) => EnvioPendiente(
        id: datos['id'] as String,
        texto: datos['texto'] as String,
      );

  final String id;
  final String texto;

  Map<String, dynamic> aMapa() => {'id': id, 'texto': texto};
}

/// Lugar donde se guarda la cola. En pruebas se reemplaza por uno en memoria.
abstract class AlmacenEnvios {
  Future<String?> leer();
  Future<void> guardar(String contenido);
}

/// Guarda la cola en las preferencias del dispositivo (funciona también en web).
class AlmacenEnviosPreferencias implements AlmacenEnvios {
  static const _clave = 'holo.envios_pendientes';

  @override
  Future<String?> leer() async {
    try {
      final preferencias = await SharedPreferences.getInstance();
      return preferencias.getString(_clave);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> guardar(String contenido) async {
    try {
      final preferencias = await SharedPreferences.getInstance();
      await preferencias.setString(_clave, contenido);
    } catch (_) {
      // Sin almacenamiento el envío sigue en memoria; la app no debe caerse por ello.
    }
  }
}

/// Mensajes enviados desde la conversación que todavía no tienen confirmación.
class ColaEnvios {
  ColaEnvios({AlmacenEnvios? almacen})
      : _almacen = almacen ?? AlmacenEnviosPreferencias();

  final AlmacenEnvios _almacen;
  // Cada cambio espera al anterior: evita que dos escrituras se pisen.
  Future<void> _turno = Future.value();

  Future<T> _enSerie<T>(Future<T> Function() operacion) {
    final resultado = _turno.then((_) => operacion());
    _turno = resultado.then((_) {}, onError: (_) {});
    return resultado;
  }

  Future<List<EnvioPendiente>> pendientes() async {
    final contenido = await _almacen.leer();
    if (contenido == null || contenido.isEmpty) return [];
    try {
      final lista = jsonDecode(contenido) as List<dynamic>;
      return lista
          .map((e) => EnvioPendiente.desde(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      // Un contenido dañado no debe impedir usar la conversación.
      return [];
    }
  }

  Future<void> encolar(EnvioPendiente envio) => _enSerie(() async {
        final actuales = await pendientes();
        await _guardar([...actuales, envio]);
      });

  Future<void> quitar(String id) => _enSerie(() async {
        final actuales = await pendientes();
        await _guardar(actuales.where((e) => e.id != id).toList());
      });

  Future<void> _guardar(List<EnvioPendiente> envios) =>
      _almacen.guardar(jsonEncode(envios.map((e) => e.aMapa()).toList()));
}

/// Identificador de evento para el backend: 32 caracteres hexadecimales (HU-16).
String generarIdEvento([Random? aleatorio]) {
  final generador = aleatorio ?? Random.secure();
  return List.generate(
    16,
    (_) => generador.nextInt(256).toRadixString(16).padLeft(2, '0'),
  ).join();
}
