import 'dart:convert';

import 'package:http/http.dart' as http;

import 'config.dart';

/// Error devuelto por el backend, con su código HTTP y el campo `detail`.
class ApiException implements Exception {
  ApiException(this.codigo, this.mensaje);

  final int codigo;
  final String mensaje;

  @override
  String toString() => 'ApiException($codigo): $mensaje';
}

/// Único punto de comunicación con el backend.
///
/// El contrato de cada endpoint está documentado en la carpeta `odds/` del
/// repositorio del backend.
class ApiClient {
  ApiClient({required this.usuarioId, http.Client? cliente})
      : _cliente = cliente ?? http.Client();

  final String usuarioId;
  final http.Client _cliente;

  Map<String, String> get _cabeceras => {
        'Content-Type': 'application/json',
        'X-Usuario-Id': usuarioId,
      };

  Uri _uri(String ruta) => Uri.parse('${Config.apiBaseUrl}$ruta');

  Future<dynamic> get(String ruta) async {
    final respuesta = await _cliente.get(_uri(ruta), headers: _cabeceras);
    return _procesar(respuesta);
  }

  Future<dynamic> post(String ruta, [Map<String, dynamic>? cuerpo]) async {
    final respuesta = await _cliente.post(
      _uri(ruta),
      headers: _cabeceras,
      body: jsonEncode(cuerpo ?? <String, dynamic>{}),
    );
    return _procesar(respuesta);
  }

  dynamic _procesar(http.Response respuesta) {
    final texto = utf8.decode(respuesta.bodyBytes);
    final dynamic datos = texto.isEmpty ? null : jsonDecode(texto);
    if (respuesta.statusCode >= 200 && respuesta.statusCode < 300) {
      return datos;
    }
    final detalle = datos is Map && datos['detail'] != null
        ? datos['detail'].toString()
        : 'Error inesperado';
    throw ApiException(respuesta.statusCode, detalle);
  }
}
